import Component from '@glimmer/component';
import { Button, type ButtonSignature } from '../../buttons/button';
import { Listbox, type ListboxSignature } from '../listbox';
import {
  Popover,
  type PopoverSignature,
  type ContentSignature
} from '../../overlays/popover';
import { assert } from '@ember/debug';
import { hash } from '@ember/helper';
import { on } from '@ember/modifier';
import { Sub } from './sub';
import { createRootMenuContext } from './menu-context';
import type { MenuContext, SubHandle } from './menu-context';
import type { ModifierLike } from '@glint/template';
import type { ListboxItem } from '../listbox/item';
import type { WithBoundArgs } from '@glint/template';

interface DropdownArgs extends Pick<
  PopoverSignature['Args'],
  | 'placement'
  | 'flipOptions'
  | 'middleware'
  | 'shiftOptions'
  | 'offsetOptions'
  | 'strategy'
  | 'didClose'
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
        Trigger: WithBoundArgs<typeof Trigger, 'anchor' | 'toggle' | 'trigger'>;
        Menu: WithBoundArgs<
          typeof Menu,
          'toggle' | 'close' | 'Content' | 'closeOnItemSelect'
        >;
      }
    ];
  };
}

class Dropdown extends Component<DropdownSignature> {
  <template>
    <Popover
      @placement={{@placement}}
      @flipOptions={{@flipOptions}}
      @middleware={{@middleware}}
      @shiftOptions={{@shiftOptions}}
      @offsetOptions={{@offsetOptions}}
      @strategy={{@strategy}}
      @didClose={{@didClose}}
      as |p|
    >
      {{yield
        (hash
          Trigger=(component
            Trigger anchor=p.anchor trigger=p.trigger toggle=p.toggle
          )
          Menu=(component
            Menu
            Content=p.Content
            toggle=p.toggle
            close=p.close
            closeOnItemSelect=@closeOnItemSelect
          )
        )
      }}
    </Popover>
  </template>
}

interface TriggerArgs extends Pick<
  ButtonSignature['Args'],
  'appearance' | 'intent' | 'size' | 'isInGroup' | 'class'
> {
  /**
   * @internal
   */
  anchor: ModifierLike<{ Element: HTMLElement }>;

  /**
   * @internal
   */
  trigger: ModifierLike<{ Element: HTMLElement }>;

  /**
   * @internal
   */
  toggle: () => void;
}

export interface TriggerSignature {
  Args: TriggerArgs;
  Element: HTMLButtonElement;
  Blocks: {
    default: [];
  };
}

class Trigger extends Component<TriggerSignature> {
  get anchor() {
    assert(
      `Dropdown Trigger does not have anchor modifier; Missing argument @anchor`,
      this.args.anchor
    );
    return this.args.anchor;
  }
  get trigger() {
    assert(
      `Dropdown Trigger does not have trigger modifier; Missing argument @trigger`,
      this.args.trigger
    );
    return this.args.trigger;
  }

  handleKeyDown = (event: KeyboardEvent) => {
    if (['ArrowUp', 'ArrowDown'].includes(event.key)) {
      event.preventDefault();
    }
  };

  /**
   * Enter and Space have to be handled here rather than left to the button's
   * native activation. The trigger renders Frontile's Button, whose `press`
   * modifier calls preventDefault on Enter/Space keydown — that is deliberate,
   * since press synthesises its own press event for `@onPress` consumers — but
   * it also cancels the native click, and Popover's `trigger` modifier opens on
   * click. Without this the menu could only be opened with the arrow keys.
   *
   * Select is unaffected because its trigger is a plain `<button>` with no press
   * modifier, so its native click still fires. Handling this in Popover instead
   * would double-toggle there.
   */
  handleKeyUp = (event: KeyboardEvent) => {
    if (
      event.key === 'ArrowDown' ||
      event.key === 'ArrowUp' ||
      event.key === 'Enter' ||
      event.key === ' '
    ) {
      this.args.toggle();
    }
  };

  <template>
    <Button
      {{this.trigger}}
      {{this.anchor}}
      {{on "keydown" this.handleKeyDown}}
      {{on "keyup" this.handleKeyUp}}
      @type="button"
      @appearance={{@appearance}}
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
      | 'appearance'
      | 'intent'
      | 'class'
      | 'selectionMode'
      | 'selectedKeys'
      | 'disabledKeys'
      | 'allowEmpty'
      | 'onSelectionChange'
      | 'shortcutAppearance'
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
   */
  toggle: () => void;

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
   */
  autoActivateMode?: 'none' | 'first';

  /**
   * @internal
   */
  close?: () => void;
}

export interface MenuSignature {
  Args: MenuArgs;
  Element: HTMLUListElement;
  Blocks: {
    default: [
      item: WithBoundArgs<typeof ListboxItem, 'manager'>,
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
   * A submenu is handed its level's context by the `Sub` that renders it. The
   * root builds its own, from the arguments the consumer wrote once.
   */
  get context(): MenuContext {
    if (this.args.context) {
      return this.args.context;
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
      appearance: this.args.appearance,
      intent: this.args.intent,
      shortcutAppearance: this.args.shortcutAppearance,
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
   * Only the root locks the page scroll. A submenu is a second overlay over
   * the same interaction; locking again would just churn the reference count.
   */
  get blockScroll() {
    if (this.args.blockScroll === false) {
      return false;
    }
    return this.depth === 0;
  }

  get disableFocusTrap() {
    if (this.args.disableFocusTrap === true) {
      return true;
    }
    return false;
  }

  get autoActivateMode(): 'none' | 'first' {
    return this.args.autoActivateMode ?? 'none';
  }

  <template>
    <@Content
      @target={{@target}}
      @renderInPlace={{@renderInPlace}}
      @disableFocusTrap={{this.disableFocusTrap}}
      @blockScroll={{this.blockScroll}}
      @transitionDuration={{this.context.transitionDuration}}
      @backdrop={{@backdrop}}
      @disableTransitions={{this.context.disableTransitions}}
      @focusTrapOptions={{@focusTrapOptions}}
      @closeOnOutsideClick={{@closeOnOutsideClick}}
      @closeOnEscapeKey={{@closeOnEscapeKey}}
      @backdropTransition={{@backdropTransition}}
      @transition={{@transition}}
    >
      <Listbox
        @allowEmpty={{this.context.allowEmpty}}
        @appearance={{this.context.appearance}}
        @disabledKeys={{this.context.disabledKeys}}
        @intent={{this.context.intent}}
        @shortcutAppearance={{this.context.shortcutAppearance}}
        @isKeyboardEventsEnabled={{true}}
        @onAction={{this.onAction}}
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
          (component l.Item)
          (component
            Sub item=(component l.Item) menu=Menu parentContext=this.context
          )
        }}
      </Listbox>
    </@Content>
  </template>
}

export { Dropdown, type DropdownSignature, Menu };
export default Dropdown;
