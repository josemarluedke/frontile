import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { hash } from '@ember/helper';
import { action } from '@ember/object';
import { on } from '@ember/modifier';
import { assert } from '@ember/debug';
import { useStyles } from '@frontile/theme';
import { ListManager, type Node } from './listbox/listManager';
import type { WithBoundArgs } from '@glint/template';

type ItemCompBounded = WithBoundArgs<typeof NativeSelectItem, 'manager'>;

interface NativeSelectSignature<T = unknown> {
  Args: {
    /**
     * @default 'listbox'
     */
    type?: 'menu' | 'listbox';
    selectionMode?: 'single' | 'multiple';
    selectedKeys?: string[];
    disabledKeys?: string[];
    allowEmpty?: boolean;
    items?: T[];
    class?: string;

    /**
     * Placeholder text used when `allowEmpty` is set to `true`.
     */
    placeholder?: string;

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

    /**
     * @internal
     */
    onItemsChange?: (nodes: Node[], action: 'add' | 'remove') => void;
  };
  Element: HTMLUListElement | HTMLSelectElement;
  Blocks: {
    item: [{ item: T; Item: ItemCompBounded }];
    default: [{ Item: ItemCompBounded }];
  };
}

class NativeSelect extends Component<NativeSelectSignature> {
  listManager = new ListManager({
    selectionMode: this.args.selectionMode,
    selectedKeys: this.args.selectedKeys,
    disabledKeys: this.args.disabledKeys,
    allowEmpty: this.args.allowEmpty,
    onSelectionChange: this.args.onSelectionChange,
    onAction: this.args.onAction,
    onNodesChange: this.args.onItemsChange
  });

  get classNames() {
    const { listbox } = useStyles();
    return listbox({ class: this.args.class });
  }

  get isMultiple() {
    return this.args.selectionMode === 'multiple';
  }

  @action
  handleOnChange(event: Event) {
    const selectElement = event.target as HTMLSelectElement;
    let newSelectedKeys: string[] = [];

    for (var i = 0; i < selectElement.options.length; i++) {
      const option = selectElement.options[i];
      if (option && option.selected && option.value !== '') {
        newSelectedKeys.push(option.value);
      }

      // handle allowEmpty
      if (
        this.args.selectionMode !== 'multiple' &&
        this.args.allowEmpty === true &&
        option &&
        option.selected &&
        option.value === ''
      ) {
        newSelectedKeys = [];
      }
    }

    if (typeof this.args.onSelectionChange === 'function') {
      this.args.onSelectionChange(newSelectedKeys);
    }
  }

  <template>
    <select
      {{this.listManager.onUpdate
        selectedKeys=@selectedKeys
        disabledKeys=@disabledKeys
        selectionMode=@selectionMode
        allowEmpty=@allowEmpty
        onNodesChange=@onItemsChange
      }}
      {{on "change" this.handleOnChange}}
      multiple={{this.isMultiple}}
      data-test-id="select"
      class={{this.classNames}}
      ...attributes
    >
      {{#if this.args.allowEmpty}}
        <NativeSelectItem @manager={{this.listManager}} @key="">
          {{this.args.placeholder}}
        </NativeSelectItem>
      {{/if}}
      {{#each @items as |item|}}
        {{#if (has-block "item")}}
          {{yield
            (hash
              item=item
              Item=(component
                NativeSelectItem
                manager=this.listManager
                appearance=@appearance
                intent=@intent
              )
            )
            to="item"
          }}
        {{else}}
          <NativeSelectItem
            @manager={{this.listManager}}
            {{! @glint-expect-error: if we get to this option, we are assuming the option is primitive value}}
            @key={{item}}
            @appearance={{@appearance}}
            @intent={{@intent}}
          >
            {{! @glint-expect-error: if we get to this option, we are assuming the option is primitive value}}
            {{item}}
          </NativeSelectItem>
        {{/if}}
      {{/each}}

      {{yield
        (hash
          Item=(component
            NativeSelectItem
            manager=this.listManager
            appearance=@appearance
            intent=@intent
          )
        )
        to="default"
      }}
    </select>
  </template>
}

export interface SelectItemSignature {
  Args: {
    manager: ListManager;
    key: string;
    textValue?: string;
  };
  Element: HTMLOptionElement | HTMLLIElement;
  Blocks: {
    default: [];
    selectedIcon: [];
    start: [];
    end: [];
  };
}

class NativeSelectItem extends Component<SelectItemSignature> {
  @tracked node?: Node;

  get manager(): ListManager {
    assert(
      `SelectItem does not have a listManager; Missing argument @manager`,
      this.args.manager
    );

    return this.args.manager;
  }

  get key(): string {
    if (this.args.key !== '') {
      assert(
        `Argument @key is undefined or null, @key must be provided in Select.Item component`,
        this.args.key
      );
    }

    return this.args.key;
  }

  @action
  onRegister(node: Node) {
    this.node = node;
  }

  <template>
    <option
      {{this.manager.setupItem
        key=this.key
        textValue=@textValue
        onRegister=this.onRegister
      }}
      data-selected="{{this.node.isSelected}}"
      data-test-id="select-option"
      data-key={{this.key}}
      selected={{this.node.isSelected}}
      value={{this.key}}
      disabled={{this.node.isDisabled}}
      ...attributes
    >
      {{yield}}
    </option>
  </template>
}

export { NativeSelect, type NativeSelectSignature };
export default NativeSelect;
