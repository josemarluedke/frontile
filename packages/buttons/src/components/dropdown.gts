/* eslint-disable ember/no-at-ember-render-modifiers */
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { on } from '@ember/modifier';
import { hash } from '@ember/helper';
import { Velcro } from 'ember-velcro';
import type { ModifierLike } from '@glint/template';
import Button, { type ButtonArgs } from './button';
import { useStyles } from '@frontile/theme';
import Overlay from '@frontile/overlays/components/overlay';
import { assert } from '@ember/debug';
import Listbox, { type ListboxSignature } from './listbox';
import type { ListboxItem } from './listbox/item';
import type { WithBoundArgs } from '@glint/template';

export interface DropdownSignature {
  Args: {
    /**
     * Whether the dropdown should close upon selecting an item.
     * @default true
     */
    closeOnItemSelect?: boolean;
  };
  Element: HTMLUListElement;
  Blocks: {
    default: [
      {
        hook: ModifierLike<{ Element: HTMLElement }>;
        Trigger: WithBoundArgs<typeof Trigger, 'hook'> &
          WithBoundArgs<typeof Trigger, 'onClick'>;

        Content: WithBoundArgs<typeof Content, 'loop'> &
          WithBoundArgs<typeof Content, 'isOpen'> &
          WithBoundArgs<typeof Content, 'onClose'>;
      }
    ];
  };
}

export default class Dropdown extends Component<DropdownSignature> {
  @tracked isOpen = false;

  toggle = () => {
    this.isOpen = !this.isOpen;
  };

  close = () => {
    this.isOpen = false;
  };

  get offsetOptions() {
    return 5;
  }

  <template>
    <Velcro
      @placement="bottom-end"
      @offsetOptions={{this.offsetOptions}}
      as |velcro|
    >
      {{yield
        (hash
          hook=velcro.hook
          Trigger=(component Trigger hook=velcro.hook onClick=this.toggle)
          Content=(component
            Content
            loop=velcro.loop
            isOpen=this.isOpen
            onClose=this.close
            onAction=this.close
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
      ...attributes
    >
      {{yield}}
    </Button>
  </template>
}

interface ContentArgs
  extends Pick<ListboxSignature['Args'], 'appearance' | 'intent' | 'class'> {
  /**
   * @internal
   */
  hook: ModifierLike<{ Element: HTMLElement }>;
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

  onAction: (key: string) => void;
}

export interface ContentSignature {
  Args: ContentArgs;
  Element: HTMLUListElement;
  Blocks: { default: [item: WithBoundArgs<typeof ListboxItem, 'manager'>] };
}

class Content extends Component<ContentSignature> {
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

  // TODO change role to menu

  <template>
    <Overlay
      @isOpen={{@isOpen}}
      @disableBackdrop={{true}}
      @onClose={{@onClose}}
      @customContentModifier={{this.loop}}
      @contentTransitionName="overlay-transition--scale"
      @disableFlexContent={{true}}
    >
      <Listbox
        @class={{this.classNames}}
        @onAction={{this.onAction}}
        @isKeyboardEventsEnabled={{true}}
        @selectionMode="none"
        @appearance={{@appearance}}
        @intent={{@intent}}
        ...attributes
        as |l|
      >
        {{yield (component l.Item)}}
      </Listbox>
    </Overlay>
  </template>
}
