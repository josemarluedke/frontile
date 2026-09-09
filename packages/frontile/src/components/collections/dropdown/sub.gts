/* eslint-disable ember/no-runloop */
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { guidFor } from '@ember/object/internals';
import { assert } from '@ember/debug';
import { hash } from '@ember/helper';
import { cancel, later } from '@ember/runloop';
import { modifier } from 'ember-modifier';
import { Popover, type PopoverSignature } from '../../overlays/popover';
import { createChildMenuContext } from './menu-context';
import type { MenuContext, OpenSource, SubHandle } from './menu-context';
import type { ListboxItem } from '../listbox/item';
import type Owner from '@ember/owner';
import type { Timer } from '@ember/runloop';
import type { WithBoundArgs } from '@glint/template';
import type { ModifierLike } from '@glint/template';
import type { Menu } from './dropdown';
import { isPointInSafeArea, type Rect } from '../../../utils/safe-area';

/**
 * Long enough that dragging the pointer across a row on its way somewhere else
 * does not flash a submenu open, short enough to feel immediate when the
 * pointer settles.
 */
const SUBMENU_OPEN_DELAY = 100;

/**
 * The pointer has to cross a gap to reach the submenu, so leaving the trigger
 * cannot close it instantly. Task 11's safe area decides *where* the pointer
 * is allowed to go; this is how long it has to get there.
 */
const SUBMENU_CLOSE_DELAY = 300;

/**
 * The raw, unbound `Menu` component, handed in rather than imported.
 *
 * `Menu` yields `Sub`, and a `Sub` renders a `Menu` for its own level. Passing
 * it in keeps the *runtime* import running one way -- `dropdown.gts` imports
 * `sub.gts` and nothing goes back at runtime, so there is no import cycle to
 * reason about there. This is a TYPE-only import of `Menu` from `dropdown.gts`
 * (see the `import type` above): it disappears entirely once compiled, so it
 * creates no runtime dependency and no cycle. A loose `ComponentLike<...>`
 * shape was tried first and rejected by Glint -- currying `Sub`'s own named
 * args onto a `ComponentLike` signature produced an "excessively deep type
 * instantiation" error, because Glint could not resolve the curried result
 * back to a concrete `Blocks` shape. Naming the real `Menu` type here (still
 * without a runtime import) keeps that resolution concrete.
 */
type MenuComponent = typeof Menu;

/**
 * The bound-args shape `Sub` produces for its own `s.Menu` -- `Content`,
 * `context`, `depth`, `menuId`, `autoActivateMode` and `close` are all curried
 * by `Sub` itself (see the template below), so a consumer only ever supplies
 * the public args (`@selectionMode`, `@onAction`, and so on).
 */
type BoundMenuComponent = WithBoundArgs<
  typeof Menu,
  'context' | 'depth' | 'menuId' | 'autoActivateMode' | 'close' | 'Content'
>;

interface SubArgs extends Pick<
  PopoverSignature['Args'],
  | 'placement'
  | 'flipOptions'
  | 'middleware'
  | 'shiftOptions'
  | 'offsetOptions'
  | 'strategy'
> {
  /**
   * @internal
   *
   * Named `item` rather than `Item`: Ember's template compiler treats any
   * named arg whose first letter is not lowercase (`@Item`, `@Menu`, ...) as
   * reserved and refuses to reference it inside a template -- so every named
   * arg here and on `SubTrigger` below is lowercase even though the values
   * yielded to consumers (`Trigger`, `Menu`, `Sub`) stay capitalized block
   * params, which are not subject to that rule.
   */
  item: WithBoundArgs<typeof ListboxItem, 'manager'>;

  /**
   * @internal
   *
   * The raw, unbound `Menu` -- `Sub` curries `Content`/`context`/`depth`/
   * `menuId`/`autoActivateMode`/`close` onto it itself (see `BoundMenuComponent`
   * above and the template below).
   */
  menu: MenuComponent;

  /**
   * @internal
   */
  parentContext: MenuContext;
}

export interface SubSignature {
  Args: SubArgs;
  Blocks: {
    default: [
      {
        Trigger: WithBoundArgs<
          typeof SubTrigger,
          | 'item'
          | 'anchor'
          | 'onTriggerClick'
          | 'isOpen'
          | 'submenuId'
          | 'key'
          | 'hoverTrigger'
        >;
        Menu: BoundMenuComponent;
        isOpen: boolean;
      }
    ];
  };
}

class Sub extends Component<SubSignature> {
  /**
   * The key the trigger registers under.
   *
   * Generated rather than asked for: a sub-trigger never selects, so its key
   * never reaches `onAction` or `selectedKeys`, and making consumers invent
   * one would be asking for a value nothing observes.
   */
  triggerKey = `${guidFor(this)}-sub-trigger`;

  /** The id of this submenu's `role="menu"` element, for `aria-controls`. */
  submenuId = `${guidFor(this)}-submenu`;

  /**
   * The registry this level's own children write into. One map for the life of
   * the component -- see `createRootMenuContext` for why it cannot be built in
   * the getter.
   */
  #childSubs = new Map<string, SubHandle>();

  /**
   * The popover is driven in controlled mode.
   *
   * The parent level has to be able to open this submenu from its own
   * ArrowRight handler, through the registered `SubHandle` -- so the open
   * state has to live somewhere reachable from outside the Popover's block,
   * which the yielded `open`/`close` are not.
   */
  @tracked isOpen = false;

  /**
   * Not tracked: it is read once, when the freshly mounted `Listbox`
   * constructs its `ListManager`, and never rendered.
   */
  openSource: OpenSource = 'pointer';

  constructor(owner: Owner, args: SubArgs) {
    super(owner, args);
    this.args.parentContext.registerSub(this.triggerKey, this.handle);
  }

  willDestroy(): void {
    super.willDestroy();
    this.args.parentContext.unregisterSub(this.triggerKey);
    this.stopTracking();
    cancel(this.#openTimer);
    cancel(this.#closeTimer);
  }

  handle: SubHandle = {
    open: (source: OpenSource) => this.open(source),
    close: () => this.close()
  };

  open = (source: OpenSource = 'pointer') => {
    this.openSource = source;
    this.isOpen = true;
    this.startTracking();
  };

  close = () => {
    this.stopTracking();

    if (this.isDestroyed || this.isDestroying) {
      return;
    }
    this.isOpen = false;
  };

  #openTimer?: Timer;
  #closeTimer?: Timer;

  /**
   * The trigger element, captured by `hoverTrigger`, so the safe area can be
   * measured without querying for it.
   */
  #triggerEl?: HTMLElement;

  /**
   * Whether the pointer is currently being tracked against the safe area.
   * Guards against installing the document listener twice.
   */
  #isTracking = false;

  /**
   * Keeps the submenu open while the pointer is heading for it.
   *
   * The pointer has to cross a gap to reach a submenu, and it crosses it
   * diagonally -- so `pointerleave` on the trigger cannot mean "close". While
   * the submenu is open, every pointer move is tested against the safe area:
   * inside it, the pending close is cancelled; outside it, the pointer has
   * clearly gone elsewhere and the submenu closes.
   *
   * This also handles hovering a sibling row with no extra wiring: a sibling
   * is outside the safe area, so moving onto one closes the submenu.
   */
  trackPointer = (event: PointerEvent) => {
    const submenu = document.getElementById(this.submenuId);
    if (!this.#triggerEl || !submenu) {
      return;
    }

    const trigger: Rect = this.#triggerEl.getBoundingClientRect();
    const content: Rect = submenu.getBoundingClientRect();
    const point = { x: event.clientX, y: event.clientY };

    if (isPointInSafeArea(point, trigger, content)) {
      this.cancelClose();
    } else {
      this.scheduleClose();
    }
  };

  startTracking = () => {
    if (this.#isTracking) {
      return;
    }
    this.#isTracking = true;
    document.addEventListener('pointermove', this.trackPointer);
  };

  stopTracking = () => {
    if (!this.#isTracking) {
      return;
    }
    this.#isTracking = false;
    document.removeEventListener('pointermove', this.trackPointer);
  };

  scheduleOpen = () => {
    this.cancelClose();
    cancel(this.#openTimer);
    this.#openTimer = later(
      this,
      () => this.open('pointer'),
      SUBMENU_OPEN_DELAY
    );
  };

  scheduleClose = () => {
    cancel(this.#openTimer);
    cancel(this.#closeTimer);
    this.#closeTimer = later(this, this.close, SUBMENU_CLOSE_DELAY);
  };

  cancelClose = () => {
    cancel(this.#closeTimer);
    this.#closeTimer = undefined;
  };

  hoverTrigger = modifier((el: HTMLElement) => {
    this.#triggerEl = el;
    el.addEventListener('pointerenter', this.scheduleOpen);
    el.addEventListener('pointerleave', this.scheduleClose);

    return () => {
      el.removeEventListener('pointerenter', this.scheduleOpen);
      el.removeEventListener('pointerleave', this.scheduleClose);
      cancel(this.#openTimer);
      cancel(this.#closeTimer);
      this.stopTracking();
      if (this.#triggerEl === el) {
        this.#triggerEl = undefined;
      }
    };
  });

  onTriggerClick = () => {
    if (this.isOpen) {
      this.close();
    } else {
      this.open('pointer');
    }
  };

  setOpen = (isOpen: boolean) => {
    this.isOpen = isOpen;
  };

  get childContext(): MenuContext {
    return createChildMenuContext(this.args.parentContext, {
      closeSelf: this.close,
      subs: this.#childSubs
    });
  }

  /**
   * `first` only for a keyboard open. A hover-opened submenu that highlighted
   * its first row would move the selection somewhere the user never pointed.
   */
  get autoActivateMode(): 'none' | 'first' {
    return this.openSource === 'keyboard' ? 'first' : 'none';
  }

  get depth(): number {
    return this.args.parentContext.depth + 1;
  }

  <template>
    <Popover
      @isOpen={{this.isOpen}}
      @onOpenChange={{this.setOpen}}
      @placement={{if @placement @placement "right-start"}}
      @flipOptions={{@flipOptions}}
      @middleware={{@middleware}}
      @shiftOptions={{@shiftOptions}}
      @offsetOptions={{@offsetOptions}}
      @strategy={{@strategy}}
      as |p|
    >
      {{yield
        (hash
          Trigger=(component
            SubTrigger
            item=@item
            anchor=p.anchor
            onTriggerClick=this.onTriggerClick
            isOpen=this.isOpen
            submenuId=this.submenuId
            key=this.triggerKey
            hoverTrigger=this.hoverTrigger
          )
          Menu=(component
            @menu
            Content=p.Content
            context=this.childContext
            depth=this.depth
            menuId=this.submenuId
            autoActivateMode=this.autoActivateMode
            close=this.close
          )
          isOpen=this.isOpen
        )
      }}
    </Popover>
  </template>
}

interface SubTriggerArgs {
  /**
   * @internal
   */
  item: WithBoundArgs<typeof ListboxItem, 'manager'>;

  /**
   * @internal
   */
  anchor: ModifierLike<{ Element: HTMLElement }>;

  /**
   * @internal
   */
  onTriggerClick: () => void;

  /**
   * @internal
   */
  isOpen: boolean;

  /**
   * @internal
   */
  submenuId: string;

  /**
   * The key this row registers under. Generated by `Sub` when omitted; accept
   * an override so a test or a consumer can address the row by `data-key`.
   */
  key?: string;

  /**
   * @internal
   */
  hoverTrigger: ModifierLike<{ Element: HTMLElement }>;
}

export interface SubTriggerSignature {
  Args: SubTriggerArgs;
  Element: HTMLLIElement;
  Blocks: { default: [] };
}

/**
 * The row that opens a submenu.
 *
 * It renders the parent level's own bound `item`, so it registers with that
 * level's `ListManager` and takes part in arrow navigation, type-ahead and the
 * roving tab stop exactly like any other row -- while `@hasSubmenu` keeps it
 * from ever selecting.
 */
class SubTrigger extends Component<SubTriggerSignature> {
  /**
   * `Sub` always binds a generated `key` by default (see `Sub`'s
   * `Trigger=(component SubTrigger ... key=this.triggerKey)`), so this is
   * never actually missing -- but `@key` on `SubTriggerArgs` stays optional so
   * a consumer-supplied override can win, and `ListboxItem.key` needs a plain
   * `string`, not `string | undefined`.
   */
  get key(): string {
    assert(
      `Sub's item did not receive a @key -- Sub always binds a generated key by default`,
      this.args.key
    );

    return this.args.key;
  }

  <template>
    <@item
      @key={{this.key}}
      @hasSubmenu={{true}}
      @isSubmenuOpen={{@isOpen}}
      @submenuId={{@submenuId}}
      @onClick={{@onTriggerClick}}
      {{@anchor}}
      {{@hoverTrigger}}
      data-test-id="dropdown-submenu-trigger"
      ...attributes
    >
      {{yield}}
    </@item>
  </template>
}

export { Sub, SubTrigger };
