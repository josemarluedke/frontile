import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { hash } from '@ember/helper';
import { action } from '@ember/object';
import { on } from '@ember/modifier';
import { assert } from '@ember/debug';
import { useStyles } from '@frontile/theme';
import { FormControl, type FormControlSharedArgs } from './form-control';
import {
  ListManager,
  keyAndLabelForItem,
  type ListItem
} from '@frontile/collections/utils/listManager';
import type { WithBoundArgs } from '@glint/template';

type ItemCompBounded = WithBoundArgs<typeof NativeSelectItem, 'manager'>;

interface Args<T> extends FormControlSharedArgs {
  selectionMode?: 'single' | 'multiple';
  selectedKeys?: string[];
  disabledKeys?: string[];
  allowEmpty?: boolean;
  items?: T[];
  class?: string;

  containerClass?: string;
  id?: string;
  size?: 'sm' | 'md' | 'lg';
  name?: string;

  /**
   * Placeholder text used when `allowEmpty` is set to `true`.
   */
  placeholder?: string;

  onAction?: (key: string) => void;
  onSelectionChange?: (key: string[]) => void;

  /**
   * @internal
   */
  onItemsChange?: (items: ListItem[], action: 'add' | 'remove') => void;
}

interface NativeSelectSignature<T> {
  Args: Args<T>;
  Element: HTMLSelectElement;
  Blocks: {
    item: [{ item: T; key: string; label: string; Item: ItemCompBounded }];
    default: [{ Item: ItemCompBounded }];
  };
}

class NativeSelect<T = unknown> extends Component<NativeSelectSignature<T>> {
  listManager = new ListManager({
    selectionMode: this.args.selectionMode,
    selectedKeys: this.args.selectedKeys,
    disabledKeys: this.args.disabledKeys,
    allowEmpty: this.args.allowEmpty,
    onSelectionChange: this.args.onSelectionChange,
    onAction: this.args.onAction,
    onListItemsChange: this.args.onItemsChange
  });

  get classNames() {
    const { nativeSelect } = useStyles();

    const { input } = nativeSelect({
      size: this.args.size
    });

    return {
      input: input({
        class: this.args.class
      })
    };
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
    <FormControl
      @id={{@id}}
      @size={{@size}}
      @label={{@label}}
      @isRequired={{@isRequired}}
      @description={{@description}}
      @errors={{@errors}}
      @isInvalid={{@isInvalid}}
      @class={{@containerClass}}
      as |c|
    >
      <select
        {{this.listManager.setup
          selectedKeys=@selectedKeys
          disabledKeys=@disabledKeys
          selectionMode=@selectionMode
          allowEmpty=@allowEmpty
          onListItemsChange=@onItemsChange
          isKeyboardEventsEnabled=false
        }}
        {{on "change" this.handleOnChange}}
        multiple={{this.isMultiple}}
        data-test-id="native-select"
        data-component="native-select"
        class={{this.classNames.input}}
        id={{c.id}}
        name={{@name}}
        aria-invalid={{if c.isInvalid "true"}}
        aria-describedby={{c.describedBy @description c.isInvalid}}
        ...attributes
      >
        {{#if this.args.allowEmpty}}
          <NativeSelectItem @manager={{this.listManager}} @key="">
            {{this.args.placeholder}}
          </NativeSelectItem>
        {{/if}}
        {{#each @items as |item|}}
          {{#let (keyAndLabelForItem item) as |keyLabel|}}
            {{#if (has-block "item")}}
              {{yield
                (hash
                  item=item
                  key=keyLabel.key
                  label=keyLabel.label
                  Item=(component NativeSelectItem manager=this.listManager)
                )
                to="item"
              }}
            {{else}}
              <NativeSelectItem
                @manager={{this.listManager}}
                @key={{keyLabel.key}}
              >
                {{keyLabel.label}}
              </NativeSelectItem>
            {{/if}}
          {{/let}}
        {{/each}}

        {{yield
          (hash Item=(component NativeSelectItem manager=this.listManager))
          to="default"
        }}
      </select>
    </FormControl>
  </template>
}

export interface SelectItemSignature {
  Args: {
    manager: ListManager;
    key: string;
    textValue?: string;
  };
  Element: HTMLOptionElement;
  Blocks: {
    default: [];
    selectedIcon: [];
    start: [];
    end: [];
  };
}

class NativeSelectItem extends Component<SelectItemSignature> {
  @tracked listItem?: ListItem;

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
  onRegister(item: ListItem) {
    this.listItem = item;
  }

  <template>
    <option
      {{this.manager.setupItem
        key=this.key
        textValue=@textValue
        onRegister=this.onRegister
      }}
      data-selected="{{this.listItem.isSelected}}"
      data-test-id="option"
      data-key={{this.key}}
      selected={{this.listItem.isSelected}}
      value={{this.key}}
      disabled={{this.listItem.isDisabled}}
      ...attributes
    >
      {{yield}}
    </option>
  </template>
}

export { NativeSelect, type NativeSelectSignature, type ListItem };
export default NativeSelect;
