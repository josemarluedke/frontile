import Component from '@glimmer/component';
import { hash } from '@ember/helper';
import { action } from '@ember/object';
import { on } from '@ember/modifier';
import { useStyles } from '@frontile/theme';
import {
  ListManager,
  keyAndLabelForItem,
  type SelectionMode,
  type Node
} from './listManager';
import { ListboxItem, type ListboxItemSignature } from './item';
import type { WithBoundArgs } from '@glint/template';

type ItemCompBounded = WithBoundArgs<typeof ListboxItem, 'manager'>;

interface ListboxSignature<T = unknown> {
  Args: {
    /**
     * @default 'listbox'
     */
    type?: 'menu' | 'listbox';
    selectionMode?: SelectionMode;
    selectedKeys?: string[];
    disabledKeys?: string[];
    allowEmpty?: boolean;
    items?: T[];
    class?: string;
    isKeyboardEventsEnabled?: boolean;

    onAction?: (key: string) => void;
    onSelectionChange?: (key: string[]) => void;

    /**
     * The appearance of each item
     *
     * @defaultValue 'default'
     */
    appearance?: 'default' | 'outlined' | 'faded';

    /**
     * The intent of each item
     */
    intent?: 'default' | 'primary' | 'success' | 'warning' | 'danger';
  };
  Element: HTMLUListElement;
  Blocks: {
    item: [{ item: T; key: string; label: string; Item: ItemCompBounded }];
    default: [{ Item: ItemCompBounded }];
  };
}

class Listbox extends Component<ListboxSignature> {
  listManager = new ListManager({
    selectionMode: this.args.selectionMode,
    selectedKeys: this.args.selectedKeys,
    disabledKeys: this.args.disabledKeys,
    allowEmpty: this.args.allowEmpty,
    onSelectionChange: this.args.onSelectionChange,
    onAction: this.args.onAction
  });

  @action
  handleKeyPress(event: KeyboardEvent) {
    if (this.args.isKeyboardEventsEnabled) {
      if (
        event.key === 'Enter' ||
        ((event.key === 'Space' || event.key === ' ') &&
          this.listManager.searchKeys == '')
      ) {
        this.listManager.selectActiveNode();
        event.preventDefault();
        event.stopPropagation();
      } else if (event.key.length === 1) {
        this.listManager.search(event.key);
      }
    }
  }

  @action
  handleKeyDown(event: KeyboardEvent) {
    if (!this.args.isKeyboardEventsEnabled) {
      return;
    }
    if (
      ['ArrowUp', 'ArrowDown', 'PageUp', 'PageDown', 'Home', 'End'].includes(
        event.key
      )
    ) {
      event.preventDefault();
    }
  }

  @action
  handleKeyUp(event: KeyboardEvent) {
    if (!this.args.isKeyboardEventsEnabled) {
      return;
    }
    if (event.key === 'ArrowDown') {
      this.listManager.setNextOptionActive();
    } else if (event.key === 'ArrowUp') {
      this.listManager.setPreviousOptionActive();
    } else if (event.key === 'Home' || event.key === 'PageUp') {
      this.listManager.setFirstOptionActive();
    } else if (event.key === 'End' || event.key === 'PageDown') {
      this.listManager.setLastOptionActive();
    }
  }

  get classNames() {
    const { listbox } = useStyles();
    return listbox({ class: this.args.class });
  }

  get role() {
    if (this.args.type === 'menu') {
      return this.args.type;
    }
    return 'listbox';
  }

  <template>
    <ul
      tabindex="0"
      role={{this.role}}
      {{this.listManager.onUpdate
        selectedKeys=@selectedKeys
        disabledKeys=@disabledKeys
        selectionMode=@selectionMode
        allowEmpty=@allowEmpty
      }}
      {{on "keypress" this.handleKeyPress}}
      {{on "keydown" this.handleKeyDown}}
      {{on "keyup" this.handleKeyUp}}
      data-test-id="listbox"
      class={{this.classNames}}
      ...attributes
    >
      {{#each @items as |item|}}
        {{#let (keyAndLabelForItem item) as |keyLabel|}}
          {{#if (has-block "item")}}
            {{yield
              (hash
                item=item
                key=keyLabel.key
                label=keyLabel.label
                Item=(component
                  ListboxItem
                  manager=this.listManager
                  appearance=@appearance
                  intent=@intent
                  type=this.role
                  key=keyLabel.key
                )
              )
              to="item"
            }}
          {{else}}
            <ListboxItem
              @manager={{this.listManager}}
              @key={{keyLabel.key}}
              @appearance={{@appearance}}
              @intent={{@intent}}
              @type={{this.role}}
            >
              {{keyLabel.label}}
            </ListboxItem>
          {{/if}}
        {{/let}}
      {{/each}}

      {{yield
        (hash
          Item=(component
            ListboxItem
            manager=this.listManager
            appearance=@appearance
            intent=@intent
            type=this.role
          )
        )
        to="default"
      }}
    </ul>
  </template>
}

export {
  Listbox,
  ListboxItem,
  type ListboxSignature,
  type ListboxItemSignature,
  type Node as ListItemNode
};
export default Listbox;
