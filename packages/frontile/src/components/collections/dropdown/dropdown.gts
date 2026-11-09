import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Button, type ButtonSignature } from '../../buttons/button';
import { Listbox, type ListboxSignature, type ListItem } from '../listbox';
import {
  Popover,
  type PopoverSignature,
  type ContentSignature
} from '../../overlays/popover';
import { assert } from '@ember/debug';
import { hash } from '@ember/helper';
import { on } from '@ember/modifier';
import { registerDestructor } from '@ember/destroyable';
import Modifier from 'ember-modifier';
import { Sub } from './sub';
import {
  createOverriddenMenuContext,
  createRootMenuContext
} from './menu-context';
import type { MenuContext, OpenSource, SubHandle } from './menu-context';
import type { ModifierLike } from '@glint/template';
import type { ListboxItem } from '../listbox/item';
import type { WithBoundArgs } from '@glint/template';
import { cached } from '@glimmer/tracking';
import { renamedArgValue } from '../../../-private/deprecated-args';

interface DropdownArgs extends Pick<
  PopoverSignature['Args'],
  | 'placement'
  | 'flipOptions'
  | 'middleware'
  | 'shiftOptions'
  | 'offsetOptions'
  | 'strategy'
  | 'didClose'
  | 'isOpen'
  | 'onOpenChange'
> {
  /**
   * Whether the dropdown should close upon selecting an item.
   *
   * @defaultValue true
   */
  closeOnItemSelect?: boolean;
}

interface DropdownSignature {
  Args: DropdownArgs;
  Element: HTMLUListElement;
  Blocks: {
    default: [
      {
        Trigger: WithBoundArgs<typeof Trigger, 'triggerModifier'>;
        /**
         * Makes the element it is placed on the dropdown's anchor and trigger,
         * wired exactly like `Trigger`: it positions the menu, opens it on
         * click, and opens it onto the first item on ArrowDown, ArrowUp, Enter
         * or Space. Use it to make something other than a `Button` -- a link, a
         * nav item -- the trigger.
         *
         * The element should be focusable and announce itself as a button (a
         * `<button>`, or `role="button"` with `tabindex="0"`). Enter and Space
         * are cancelled on it, so an `<a href>` does not follow its link from
         * the keyboard; a pointer click on one still does (see the docs).
         */
        triggerModifier: TriggerModifier;
        Menu: WithBoundArgs<
          typeof Menu,
          'toggle' | 'close' | 'Content' | 'closeOnItemSelect'
        >;
      }
    ];
  };
}

class Dropdown extends Component<DropdownSignature> {
  /**
   * How the menu was last asked to open.
   *
   * The WAI-ARIA menu button pattern opens onto an item when the keyboard
   * opened the menu, and onto nothing when a pointer did -- so the trigger has
   * to tell the menu how it was reached. `Sub` already says this for submenus
   * with `OpenSource`; the root says it the same way rather than inventing a
   * second spelling of the same idea.
   */
  @tracked openSource: OpenSource = 'pointer';

  setOpenSource = (source: OpenSource): void => {
    // Only on a real change: Ember's tracked setter dirties its tag
    // unconditionally, and the resting value is already `'pointer'`, so an
    // unguarded write would invalidate this component -- and with it the two
    // curried components it yields -- on every pointer press.
    if (this.openSource !== source) {
      this.openSource = source;
    }
  };

  <template>
    <Popover
      @placement={{@placement}}
      @flipOptions={{@flipOptions}}
      @middleware={{@middleware}}
      @shiftOptions={{@shiftOptions}}
      @offsetOptions={{@offsetOptions}}
      @strategy={{@strategy}}
      @didClose={{@didClose}}
      @isOpen={{@isOpen}}
      @onOpenChange={{@onOpenChange}}
      as |p|
    >
      {{#let
        (modifier
          TriggerBehavior
          anchor=p.anchor
          trigger=p.trigger
          open=p.open
          toggle=p.toggle
          setOpenSource=this.setOpenSource
        )
        as |triggerModifier|
      }}
        {{yield
          (hash
            Trigger=(component Trigger triggerModifier=triggerModifier)
            triggerModifier=triggerModifier
            Menu=(component
              Menu
              Content=p.Content
              toggle=p.toggle
              close=p.close
              closeOnItemSelect=@closeOnItemSelect
              openSource=this.openSource
            )
          )
        }}
      {{/let}}
    </Popover>
  </template>
}

/**
 * The public shape of the modifier `Dropdown` yields as `triggerModifier`.
 */
type TriggerModifier = ModifierLike<{ Element: HTMLElement }>;

interface TriggerBehaviorSignature {
  Element: HTMLElement;
  Args: {
    Named: {
      anchor: TriggerModifier;
      trigger: TriggerModifier;
      open: () => void;
      toggle: () => void;
      setOpenSource: (source: OpenSource) => void;
    };
  };
}

/**
 * Everything that makes an element a dropdown trigger, in one place, so a
 * `Trigger` button and a consumer's own element behave identically.
 *
 * It installs Popover's `anchor` and `trigger` modifiers by calling them. Both
 * are function-based `ember-modifier`s, and `modifier(fn)` hands back `fn`
 * itself (with a manager attached), so they are callable as
 * `(element, positional, named) => cleanup`. Glimmer has no way to apply two
 * modifiers from one, and the alternative -- yielding both and making every
 * consumer apply them together with the key handlers -- is the very thing this
 * exists to avoid. If either stops being a plain function the assert below
 * fails loudly instead of the trigger silently doing nothing.
 *
 * The class form is deliberate. Popover's `trigger` reads `isOpen`, so this
 * modifier re-runs on every open and close; a class instance keeps the key and
 * pointer listeners and the `anchor` call (which writes tracked state, and
 * would re-position the menu if repeated) once per element, and only re-runs
 * `trigger`, whose cleanup it owns.
 */
class TriggerBehavior extends Modifier<TriggerBehaviorSignature> {
  #element?: HTMLElement;
  #cleanupTrigger?: () => void;
  #removeListeners?: () => void;
  #destructorRegistered = false;

  modify(
    element: HTMLElement,
    _positional: [],
    {
      anchor,
      trigger,
      open,
      toggle,
      setOpenSource
    }: TriggerBehaviorSignature['Args']['Named']
  ) {
    if (!this.#destructorRegistered) {
      this.#destructorRegistered = true;
      registerDestructor(this, () => {
        this.#cleanupTrigger?.();
        this.#removeListeners?.();
      });
    }

    if (this.#element !== element) {
      this.#removeListeners?.();
      this.#element = element;
      this.#removeListeners = this.#listen(
        element,
        open,
        toggle,
        setOpenSource
      );

      this.#call(anchor, element);
    }

    this.#cleanupTrigger?.();
    const cleanup = this.#call(trigger, element);
    this.#cleanupTrigger =
      typeof cleanup === 'function' ? (cleanup as () => void) : undefined;
  }

  #call(modifier: TriggerModifier, element: HTMLElement): unknown {
    assert(
      'Dropdown could not install its trigger: Popover no longer yields function-based `anchor`/`trigger` modifiers',
      typeof modifier === 'function'
    );
    return (
      modifier as unknown as (
        el: HTMLElement,
        positional: unknown[],
        named: Record<string, unknown>
      ) => unknown
    )(element, [], {});
  }

  #listen(
    element: HTMLElement,
    open: () => void,
    toggle: () => void,
    setOpenSource: (source: OpenSource) => void
  ): () => void {
    /**
     * Enter and Space are cancelled here, on both key events, on top of the
     * arrows. Frontile's `Button` already does it for Enter/Space (its `press`
     * modifier), but any other element would not: a `<button>` fires its own
     * click on Enter (keydown) and Space (keyup), which Popover's `trigger`
     * toggles on -- on top of the `keyup` toggle below, so the menu would open
     * and straight away close -- and an `<a href>` would navigate on Enter. The
     * arrows are cancelled so they do not scroll the page.
     */
    const onKeyDown = (event: KeyboardEvent) => {
      if (['ArrowUp', 'ArrowDown', 'Enter', ' '].includes(event.key)) {
        event.preventDefault();
      }
      // Popover's own keydown handler, which runs after this one, opens the
      // menu on an arrow; say it was the keyboard before it renders, so it
      // opens onto the first item.
      if (event.key === 'ArrowDown' || event.key === 'ArrowUp') {
        setOpenSource('keyboard');
      }
    };

    /**
     * Enter and Space have to be handled here rather than left to native
     * activation: `Button`'s `press` modifier cancels the native click on
     * Enter/Space (deliberately -- press synthesises its own press event for
     * `@onPress` consumers), and Popover's `trigger` opens on click. Without
     * this the menu could only be opened with the arrow keys.
     *
     * Select is unaffected because its trigger is a plain `<button>` with no
     * press modifier, so its native click still fires. Handling this in
     * Popover instead would double-toggle there.
     *
     * Space is cancelled again on keyup because Firefox activates a button on
     * Space keyup regardless of what keydown did.
     */
    const onKeyUp = (event: KeyboardEvent) => {
      if (event.key === 'Enter' || event.key === ' ') {
        event.preventDefault();
        setOpenSource('keyboard');
        toggle();
      } else if (event.key === 'ArrowDown' || event.key === 'ArrowUp') {
        // Only ever opens. The arrow's keydown has usually opened the menu
        // already, and when focus has not moved into it by the keyup (a fast
        // key, a slow render), toggling here would close it again.
        setOpenSource('keyboard');
        open();
      }
    };

    /**
     * A pointer press opens onto nothing: moving the highlight somewhere the
     * user never pointed is exactly what the menu button pattern avoids.
     *
     * On `pointerup` rather than `pointerdown`: the two are equivalent here
     * because `pointerup` still precedes the `click` that Popover's `trigger`
     * opens on, and a press the user drags away from and cancels should leave
     * nothing behind.
     */
    const onPointerUp = () => {
      setOpenSource('pointer');
    };

    element.addEventListener('keydown', onKeyDown);
    element.addEventListener('keyup', onKeyUp);
    element.addEventListener('pointerup', onPointerUp);

    return () => {
      element.removeEventListener('keydown', onKeyDown);
      element.removeEventListener('keyup', onKeyUp);
      element.removeEventListener('pointerup', onPointerUp);
    };
  }
}

interface TriggerArgs extends Pick<
  ButtonSignature['Args'],
  'variant' | 'appearance' | 'color' | 'intent' | 'size' | 'isInGroup' | 'class'
> {
  /**
   * @internal
   *
   * The dropdown's own `triggerModifier`, bound by `Dropdown`.
   */
  triggerModifier: TriggerModifier;
}

export interface TriggerSignature {
  Args: TriggerArgs;
  Element: HTMLButtonElement;
  Blocks: {
    default: [];
  };
}

/**
 * The button form of the trigger: Frontile's `Button` with `triggerModifier`
 * on it, so all of the open/close behaviour lives in one place.
 */
class Trigger extends Component<TriggerSignature> {
  <template>
    <Button
      {{@triggerModifier}}
      @type="button"
      @variant={{@variant}}
      @appearance={{@appearance}}
      @color={{@color}}
      @intent={{@intent}}
      @size={{@size}}
      @class={{@class}}
      @isInGroup={{@isInGroup}}
      data-test-id="dropdown-trigger"
      ...attributes
    >
      {{yield}}
    </Button>
  </template>
}

interface MenuArgs
  extends
    Pick<
      ListboxSignature<unknown>['Args'],
      | 'variant'
      | 'appearance'
      | 'color'
      | 'intent'
      | 'class'
      | 'selectionMode'
      | 'selectedKeys'
      | 'disabledKeys'
      | 'allowEmpty'
      | 'onSelectionChange'
      | 'shortcutVariant'
    >,
    Pick<
      ContentSignature['Args'],
      | 'renderInPlace'
      | 'target'
      | 'transitionDuration'
      | 'backdrop'
      | 'disableTransitions'
      | 'focusTrapOptions'
      | 'closeOnOutsideClick'
      | 'closeOnEscapeKey'
      | 'backdropTransition'
      | 'transition'
    > {
  /**
   * @internal
   */
  closeOnItemSelect?: boolean;

  /**
   * @internal
   */
  Content: PopoverSignature['Blocks']['default'][0]['Content'];

  /**
   * @internal
   *
   * Optional rather than required: the root `Dropdown` binds this, but a
   * `Sub`-rendered `Menu` never does (a submenu is dismissed through `close`,
   * not `toggle` -- see `Sub`'s `Menu=(component @menu ...)` invocation, which
   * has no `toggle=` at all). `closeRoot` below already guards this with a
   * `typeof this.args.toggle === 'function'` check, so this only makes the
   * type match the runtime behavior that was already there; it does not
   * change it. Leaving this required was what made every `Sub`-bound `Menu`
   * require a fully-populated args hash at the type level, even though every
   * other remaining arg is optional.
   */
  toggle?: () => void;

  /**
   * Callback when a menu item is selected, receiving that item's `@key`.
   */
  onAction?: (key: string) => void;

  /**
   * @defaultValue true
   */
  blockScroll?: boolean;

  /**
   * @defaultValue false
   */
  disableFocusTrap?: boolean;

  /**
   * @internal
   */
  context?: MenuContext;

  /**
   * @internal
   */
  depth?: number;

  /**
   * @internal
   */
  menuId?: string;

  /**
   * @internal
   *
   * How this level was reached -- by the root `Trigger` for the root menu, by
   * its `Sub` for a submenu -- so a keyboard open highlights the first row per
   * the WAI-ARIA menu button pattern. Translated by `autoActivateMode` below.
   */
  openSource?: OpenSource;

  /**
   * @internal
   */
  autoActivateMode?: 'none' | 'first';

  /**
   * @internal
   */
  close?: () => void;

  /**
   * Callback when the active (highlighted) row changes.
   */
  onActiveItemChange?: (key?: string, item?: ListItem) => void;
}

export interface MenuSignature {
  Args: MenuArgs;
  Element: HTMLUListElement;
  Blocks: {
    default: [
      item: WithBoundArgs<typeof ListboxItem, 'manager' | 'onLinkActivate'>,
      sub: WithBoundArgs<typeof Sub, 'item' | 'menu' | 'parentContext'>
    ];
  };
}

class Menu extends Component<MenuSignature> {
  /**
   * The submenus registered at this level. One map for the life of the
   * component: `context` below is a getter, rebuilt on every render, and a map
   * created there would drop every `Sub` that had already registered.
   */
  #subs = new Map<string, SubHandle>();

  get depth(): number {
    return this.args.depth ?? 0;
  }

  /**
   * Resolved once (`@cached`): `context` is read many times per render, and
   * without caching each read would re-run the deprecation.
   */
  @cached
  get variant() {
    return renamedArgValue(
      this.args.variant,
      this.args.appearance,
      { default: 'solid', outlined: 'outline', faded: 'subtle' } as const,
      {
        component: 'Dropdown',
        from: 'appearance',
        to: 'variant',
        id: 'frontile.dropdown.appearance'
      }
    );
  }

  /**
   * Resolved once (`@cached`) and forwarded to the internal `Listbox` as
   * `@color` only -- never `@intent` as well, which would make the inner
   * `Listbox` raise its own deprecation for the same usage.
   */
  @cached
  get color() {
    return renamedArgValue(
      this.args.color,
      this.args.intent,
      { default: 'neutral' } as const,
      {
        component: 'Dropdown',
        from: 'intent',
        to: 'color',
        id: 'frontile.dropdown.intent'
      }
    );
  }

  /**
   * A submenu is handed its level's context by the `Sub` that renders it. The
   * root builds its own, from the arguments the consumer wrote once.
   *
   * A submenu inherits that context, but may override any part of it with its
   * own arguments -- so a navigation menu can hold a multi-select submenu
   * without the root pretending to select, which is the shape every faceted
   * filter menu needs. Inheritance remains the default: a submenu that
   * declares nothing keeps using the root's settings, and is handed the
   * parent's own context object back untouched.
   *
   * Resolved once (`@cached`) for the same reason `variant` is: `context` is
   * read a dozen times per render, and the overriding branch below builds a
   * new object each time it runs. Without the cache every read produced a
   * fresh identity, which `Sub` then turned into a fresh child context for
   * the level beneath it.
   */
  @cached
  get context(): MenuContext {
    if (this.args.context) {
      return createOverriddenMenuContext(this.args.context, this.args);
    }

    return createRootMenuContext({
      close: this.closeRoot,
      subs: this.#subs,
      selectionMode: this.args.selectionMode,
      selectedKeys: this.args.selectedKeys,
      disabledKeys: this.args.disabledKeys,
      allowEmpty: this.args.allowEmpty,
      onAction: this.args.onAction,
      onSelectionChange: this.args.onSelectionChange,
      variant: this.variant,
      color: this.color,
      shortcutVariant: this.args.shortcutVariant,
      closeOnItemSelect: this.args.closeOnItemSelect,
      disableTransitions: this.args.disableTransitions,
      transitionDuration: this.args.transitionDuration
    });
  }

  closeRoot = () => {
    if (typeof this.args.close === 'function') {
      this.args.close();
    } else if (typeof this.args.toggle === 'function') {
      this.args.toggle();
    }
  };

  onAction = (key: string) => {
    const { onAction, closeOnItemSelect, closeRoot } = this.context;

    if (typeof onAction === 'function') {
      onAction(key);
    }

    // A leaf three levels down dismisses the whole dropdown, not just its own
    // level -- so this closes the root rather than `closeSelf`.
    if (closeOnItemSelect !== false) {
      closeRoot();
    }
  };

  /**
   * A link item is followed by the browser (or `LinkTo`), not selected, so it
   * must skip `onAction` -- but it still dismisses the menu like any other
   * choice, and under the same `closeOnItemSelect` rule.
   */
  onLinkActivate = () => {
    const { closeOnItemSelect, closeRoot } = this.context;

    if (closeOnItemSelect !== false) {
      closeRoot();
    }
  };

  /**
   * Only the root locks the page scroll. A submenu is a second overlay over
   * the same interaction; locking again would just churn the reference count.
   */
  get blockScroll() {
    if (this.args.blockScroll === false) {
      return false;
    }
    return this.depth === 0;
  }

  /**
   * Focus goes into the menu as soon as it renders, not a timer later (focus
   * trap's default `delayInitialFocus`). Until it does, keys still land on
   * the trigger: a quick ArrowDown after Enter would reach the trigger
   * instead of moving through the menu. Nothing needs the delay here: the
   * menu opens on a click, an Enter/Space keyup, or an arrow keydown whose
   * keyup the menu ignores (it acts on keydown).
   *
   * `preventScroll`, because at that moment the menu has not been positioned
   * yet (Velcro places it a promise later): focusing it would scroll the page
   * to where it sits before then, carrying the trigger out of view, which
   * hides the menu (Velcro's `hide`) and drops focus to the body.
   *
   * A consumer's options still win.
   */
  get focusTrapOptions(): MenuArgs['focusTrapOptions'] {
    return {
      delayInitialFocus: false,
      preventScroll: true,
      ...this.args.focusTrapOptions
    };
  }

  get disableFocusTrap() {
    if (this.args.disableFocusTrap === true) {
      return true;
    }
    return false;
  }

  /**
   * The one place an open source becomes an activation mode.
   *
   * Every level is told only how it was reached -- the root by its own
   * trigger, a submenu by its `Sub` -- and decides here, so the WAI-ARIA rule
   * that a keyboard open lands on an item has a single home. A consumer's
   * explicit `@autoActivateMode` outranks it.
   */
  get autoActivateMode(): 'none' | 'first' {
    if (this.args.autoActivateMode) {
      return this.args.autoActivateMode;
    }

    return this.args.openSource === 'keyboard' ? 'first' : 'none';
  }

  /**
   * The key of the row the arrow keys are currently on.
   *
   * ArrowRight has to open the submenu belonging to the *active* row, and the
   * row itself never learns about the submenu -- so the level tracks which key
   * is active and looks the submenu up in its own registry.
   */
  @tracked activeKey?: string;

  /**
   * Chained rather than replaced: a consumer that passed
   * `@onActiveItemChange` still hears about every move.
   */
  onActiveItemChange = (key?: string) => {
    this.activeKey = key;

    if (typeof this.args.onActiveItemChange === 'function') {
      this.args.onActiveItemChange(key);
    }
  };

  /**
   * ArrowRight and ArrowLeft, which `Listbox` does not handle.
   *
   * There is no "which level is focused" bookkeeping to do: every level is its
   * own portaled `Listbox` with its own `<ul tabindex="0">`, and a submenu's
   * portal is a *sibling* of its parent's content element -- so a keypress
   * only ever reaches the level that holds focus.
   */
  handleArrowKeys = (event: KeyboardEvent) => {
    if (event.key === 'ArrowRight') {
      const handle = this.activeKey
        ? this.context.subs.get(this.activeKey)
        : undefined;

      if (handle) {
        event.preventDefault();
        event.stopPropagation();
        handle.open('keyboard');
      }
      return;
    }

    // The root has no parent to step back to; ArrowLeft there belongs to
    // whatever the consumer put in the row.
    if (event.key === 'ArrowLeft' && this.context.depth > 0) {
      event.preventDefault();
      event.stopPropagation();
      this.context.closeSelf();
    }
  };

  <template>
    <@Content
      @target={{@target}}
      @renderInPlace={{@renderInPlace}}
      @disableFocusTrap={{this.disableFocusTrap}}
      @blockScroll={{this.blockScroll}}
      @transitionDuration={{this.context.transitionDuration}}
      @backdrop={{@backdrop}}
      @disableTransitions={{this.context.disableTransitions}}
      @focusTrapOptions={{this.focusTrapOptions}}
      @closeOnOutsideClick={{@closeOnOutsideClick}}
      @closeOnEscapeKey={{@closeOnEscapeKey}}
      @backdropTransition={{@backdropTransition}}
      @transition={{@transition}}
    >
      <Listbox
        {{on "keydown" this.handleArrowKeys}}
        @allowEmpty={{this.context.allowEmpty}}
        @variant={{this.context.variant}}
        @disabledKeys={{this.context.disabledKeys}}
        @color={{this.context.color}}
        @shortcutVariant={{this.context.shortcutVariant}}
        @isKeyboardEventsEnabled={{true}}
        @onAction={{this.onAction}}
        @onActiveItemChange={{this.onActiveItemChange}}
        @onSelectionChange={{this.context.onSelectionChange}}
        @selectedKeys={{this.context.selectedKeys}}
        @selectionMode={{if
          this.context.selectionMode
          this.context.selectionMode
          "none"
        }}
        @type="menu"
        @autoActivateMode={{this.autoActivateMode}}
        id={{@menuId}}
        ...attributes
        as |l|
      >
        {{yield
          (component l.Item onLinkActivate=this.onLinkActivate)
          (component
            Sub item=(component l.Item) menu=Menu parentContext=this.context
          )
        }}
      </Listbox>
    </@Content>
  </template>
}

export { Dropdown, type DropdownSignature, type Menu };
export default Dropdown;
