import Component from '@glimmer/component';
import { Button, type ButtonSignature } from '@frontile/buttons';
import { Listbox, type ListboxSignature } from './listbox';
import {
  Popover,
  type PopoverSignature,
  type ContentSignature
} from '@frontile/overlays';
import { assert } from '@ember/debug';
import { hash } from '@ember/helper';
import { on } from '@ember/modifier';
import { useStyles } from '@frontile/theme';
import type { ModifierLike } from '@glint/template';
import type { ListboxItem } from './listbox/item';
import type { WithBoundArgs } from '@glint/template';

interface DropdownArgs
  extends Pick<
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
          'toggle' | 'Content' | 'closeOnItemSelect'
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
            closeOnItemSelect=@closeOnItemSelect
          )
        )
      }}
    </Popover>
  </template>
}

interface TriggerArgs
  extends Pick<
    ButtonSignature['Args'],
    'appearance' | 'intent' | 'size' | 'isInGroup' | 'class'
  > {
  /**
   * @internal
   */
  anchor: ModifierLike<{ Element: HTMLElement }>;
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

  handleKeyUp = (event: KeyboardEvent) => {
    if (event.key === 'ArrowDown' || event.key == 'ArrowUp') {
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
  extends Pick<
      ListboxSignature<unknown>['Args'],
      | 'appearance'
      | 'intent'
      | 'class'
      | 'selectionMode'
      | 'selectedKeys'
      | 'disabledKeys'
      | 'allowEmpty'
      | 'onSelectionChange'
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

  onAction?: (key: string) => void;

  /**
   * @defaultValue true
   */
  blockScroll?: boolean;

  /**
   * @defaultValue false
   */
  disableFocusTrap?: boolean;
}

export interface MenuSignature {
  Args: MenuArgs;
  Element: HTMLUListElement;
  Blocks: { default: [item: WithBoundArgs<typeof ListboxItem, 'manager'>] };
}

class Menu extends Component<MenuSignature> {
  get classNames() {
    const { dropdownContent } = useStyles();
    return dropdownContent({ class: this.args.class });
  }

  onAction = (key: string) => {
    if (typeof this.args.onAction === 'function') {
      this.args.onAction(key);
    }

    if (
      typeof this.args.toggle === 'function' &&
      this.args.closeOnItemSelect !== false
    ) {
      this.args.toggle();
    }
  };

  get blockScroll() {
    if (this.args.blockScroll === false) {
      return false;
    }
    return true;
  }

  get disableFocusTrap() {
    if (this.args.disableFocusTrap === true) {
      return true;
    }
    return false;
  }

  <template>
    <@Content
      @target={{@target}}
      @renderInPlace={{@renderInPlace}}
      @disableFocusTrap={{this.disableFocusTrap}}
      @blockScroll={{this.blockScroll}}
      @transitionDuration={{@transitionDuration}}
      @backdrop={{@backdrop}}
      @disableTransitions={{@disableTransitions}}
      @focusTrapOptions={{@focusTrapOptions}}
      @closeOnOutsideClick={{@closeOnOutsideClick}}
      @closeOnEscapeKey={{@closeOnEscapeKey}}
      @backdropTransition={{@backdropTransition}}
      @transition={{@transition}}
    >
      <Listbox
        @allowEmpty={{@allowEmpty}}
        @appearance={{@appearance}}
        @disabledKeys={{@disabledKeys}}
        @intent={{@intent}}
        @isKeyboardEventsEnabled={{true}}
        @onAction={{this.onAction}}
        @onSelectionChange={{@onSelectionChange}}
        @selectedKeys={{@selectedKeys}}
        @selectionMode={{if @selectionMode @selectionMode "none"}}
        @type="menu"
        @autoActivateMode="none"
        ...attributes
        as |l|
      >
        {{yield (component l.Item)}}
      </Listbox>
    </@Content>
  </template>
}

export { Dropdown, type DropdownSignature };
export default Dropdown;
