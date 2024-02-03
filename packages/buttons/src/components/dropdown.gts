import Component from '@glimmer/component';
import Button, { type ButtonArgs } from './button';
import Listbox, { type ListboxSignature } from './listbox';
import Overlay from '@frontile/overlays/components/overlay';
import { tracked } from '@glimmer/tracking';
import { Velcro } from 'ember-velcro';
import { assert } from '@ember/debug';
import { guidFor } from '@ember/object/internals';
import { hash } from '@ember/helper';
import { on } from '@ember/modifier';
import { useStyles } from '@frontile/theme';
import type { ModifierLike } from '@glint/template';
import type { ListboxItem } from './listbox/item';
import type { WithBoundArgs } from '@glint/template';

export interface DropdownSignature {
  Args: {
    /**
     * Whether the dropdown should close upon selecting an item.
     *
     * @defaultValue true
     */
    closeOnItemSelect?: boolean;

    /**
     * Placement of the menu when open
     *
     * @defaultValue 'bottom-end'
     */
    placement?:
      | 'top'
      | 'top-start'
      | 'top-end'
      | 'right'
      | 'right-start'
      | 'right-end'
      | 'bottom'
      | 'bottom-start'
      | 'bottom-end'
      | 'left'
      | 'left-start'
      | 'left-end';
  };
  Element: HTMLUListElement;
  Blocks: {
    default: [
      {
        Trigger: WithBoundArgs<typeof Trigger, 'hook' | 'onClick'>;
        Menu: WithBoundArgs<
          typeof Menu,
          'loop' | 'isOpen' | 'id' | 'onClose' | 'closeOnItemSelect'
        >;
      }
    ];
  };
}

export default class Dropdown extends Component<DropdownSignature> {
  menuId = guidFor(this);
  @tracked isOpen = false;

  toggle = () => {
    this.isOpen = !this.isOpen;
  };

  close = () => {
    this.isOpen = false;
  };

  <template>
    <Velcro
      @placement={{if @placement @placement "bottom-end"}}
      @offsetOptions={{5}}
      as |velcro|
    >
      {{yield
        (hash
          Trigger=(component
            Trigger
            hook=velcro.hook
            onClick=this.toggle
            isOpen=this.isOpen
            menuId=this.menuId
          )
          Menu=(component
            Menu
            id=this.menuId
            loop=velcro.loop
            isOpen=this.isOpen
            onClose=this.close
            closeOnItemSelect=@closeOnItemSelect
          )
        )
      }}
    </Velcro>
  </template>
}

interface TriggerArgs
  extends Pick<
    ButtonArgs,
    'appearance' | 'intent' | 'size' | 'isInGroup' | 'class'
  > {
  /**
   * @internal
   */
  hook: ModifierLike<{ Element: HTMLElement }>;

  /**
   * @internal
   */
  onClick: () => void;

  /**
   * @internal
   */
  isOpen?: boolean;

  /**
   * @internal
   */
  menuId?: string;
}

export interface TriggerSignature {
  Args: TriggerArgs;
  Element: HTMLButtonElement;
  Blocks: {
    default: [];
  };
}

class Trigger extends Component<TriggerSignature> {
  get hook() {
    assert(
      `Dropdown Trigger does not have hook; Missing argument @hook`,
      this.args.hook
    );
    return this.args.hook;
  }

  handleKeyDown = (event: KeyboardEvent) => {
    if (['ArrowUp', 'ArrowDown'].includes(event.key)) {
      event.preventDefault();
    }
  };

  handleKeyUp = (event: KeyboardEvent) => {
    if (event.key === 'ArrowDown' || event.key == 'ArrowUp') {
      this.args.onClick();
    }
  };

  <template>
    <Button
      {{this.hook}}
      {{on "click" @onClick}}
      {{on "keydown" this.handleKeyDown}}
      {{on "keyup" this.handleKeyUp}}
      @type="button"
      @appearance={{@appearance}}
      @intent={{@intent}}
      @size={{@size}}
      @class={{@class}}
      @isInGroup={{@isInGroup}}
      aria-haspopup="true"
      aria-expanded="{{@isOpen}}"
      aria-controls={{@menuId}}
      ...attributes
    >
      {{yield}}
    </Button>
  </template>
}

interface MenuArgs
  extends Pick<
    ListboxSignature['Args'],
    | 'appearance'
    | 'intent'
    | 'class'
    | 'selectionMode'
    | 'selectedKeys'
    | 'disabledKeys'
    | 'allowEmpty'
    | 'onSelectionChange'
  > {
  /**
   * @internal
   */
  loop: ModifierLike<{ Element: HTMLElement }>;
  /**
   * @internal
   */
  isOpen: boolean;

  /**
   * @internal
   */
  closeOnItemSelect?: boolean;

  /**
   * @internal
   */
  onClose: () => void;

  onAction?: (key: string) => void;

  disableTransitions?: boolean;

  /**
   * @defaultValue true
   */
  disableBackdrop?: boolean;

  id: string;
}

export interface MenuSignature {
  Args: MenuArgs;
  Element: HTMLUListElement;
  Blocks: { default: [item: WithBoundArgs<typeof ListboxItem, 'manager'>] };
}

class Menu extends Component<MenuSignature> {
  get loop() {
    assert(
      `Dropdown Content does not have loop; Missing argument @loop`,
      this.args.loop
    );
    return this.args.loop;
  }

  get classNames() {
    const { dropdownContent } = useStyles();
    return dropdownContent({ class: this.args.class });
  }

  get disableBackdrop() {
    return this.args.disableBackdrop === false ? false : true;
  }

  onAction = (key: string) => {
    if (typeof this.args.onAction === 'function') {
      this.args.onAction(key);
    }

    if (
      typeof this.args.onClose === 'function' &&
      this.args.closeOnItemSelect !== false
    ) {
      this.args.onClose();
    }
  };

  <template>
    <Overlay
      @contentTransitionName="overlay-transition--scale"
      @customContentModifier={{this.loop}}
      @disableBackdrop={{this.disableBackdrop}}
      @disableFlexContent={{true}}
      @disableTransitions={{@disableTransitions}}
      @isOpen={{@isOpen}}
      @onClose={{@onClose}}
    >
      <Listbox
        @allowEmpty={{@allowEmpty}}
        @appearance={{@appearance}}
        @class={{this.classNames}}
        @disabledKeys={{@disabledKeys}}
        @intent={{@intent}}
        @isKeyboardEventsEnabled={{true}}
        @onAction={{this.onAction}}
        @onSelectionChange={{@onSelectionChange}}
        @selectedKeys={{@selectedKeys}}
        @selectionMode={{if @selectionMode @selectionMode "none"}}
        @type="menu"
        id={{@id}}
        ...attributes
        as |l|
      >
        {{yield (component l.Item)}}
      </Listbox>
    </Overlay>
  </template>
}
