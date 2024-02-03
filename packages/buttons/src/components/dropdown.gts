/* eslint-disable ember/no-at-ember-render-modifiers */
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { on } from '@ember/modifier';
import { hash } from '@ember/helper';
import { Velcro } from 'ember-velcro';
import type { ModifierLike } from '@glint/template';
import Button from './button';
import Listbox from './listbox';
import { useStyles } from '@frontile/theme';
import Overlay from '@frontile/overlays/components/overlay';
import { assert } from '@ember/debug';
import type { ListboxItem } from './listbox/item';
import type { WithBoundArgs } from '@glint/template';

export interface DropdownSignature {
  Args: null;
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
          )
        )
      }}
    </Velcro>
  </template>
}

export interface TriggerSignature {
  Args: {
    hook: ModifierLike<{ Element: HTMLElement }>;
    onClick: () => void;
  };
  Element: HTMLUListElement;
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
    >
      {{yield}}
    </Button>
  </template>
}

export interface ContentSignature {
  Args: {
    loop: ModifierLike<{ Element: HTMLElement }>;
    isOpen: boolean;
    onClose: () => void;
    onAction: (key: string) => void;
    class?: string;
  };
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
        @onAction={{@onAction}}
        @isKeyboardEventsEnabled={{true}}
        @selectionMode="none"
        as |l|
      >
        {{yield (component l.Item)}}
      </Listbox>
    </Overlay>
  </template>
}
