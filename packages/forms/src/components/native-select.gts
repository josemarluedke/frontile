import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { hash } from '@ember/helper';
import { action } from '@ember/object';
import { on } from '@ember/modifier';
import { assert } from '@ember/debug';
import type Owner from '@ember/owner';
import {
  useStyles,
  type NativeSelectSlots,
  type NativeSelectVariants,
  type SlotsToClasses
} from '@frontile/theme';
import { FormControl, type FormControlSharedArgs } from './form-control';
import {
  ListManager,
  keyAndLabelForItem,
  type ListItem
} from '@frontile/collections/utils/listManager';
import { IconChevronUpDown } from './icons';
import type { WithBoundArgs } from '@glint/template';

type ItemCompBounded = WithBoundArgs<typeof NativeSelectItem, 'manager'>;

// Base interface for shared properties
interface BaseArgs<T> extends FormControlSharedArgs {
  disabledKeys?: string[];
  allowEmpty?: boolean;
  items?: T[];
  id?: string;
  name?: string;
  size?: NativeSelectVariants['size'];
  classes?: SlotsToClasses<NativeSelectSlots>;

  /**
   * Placeholder text used when `allowEmpty` is set to `true`.
   */
  placeholder?: string;

  onAction?: (key: string) => void;

  /**
   * @internal
   */
  onItemsChange?: (items: ListItem[], action: 'add' | 'remove') => void;

  /**
   * Controls pointer-events property of startContent.
   * If you want to pass the click event to the input, set it to `none`.
   *
   * @defaultValue 'auto'
   */
  startContentPointerEvents?: 'none' | 'auto';

  /**
   * Controls pointer-events property of endContent.
   * Defauled to `none` to pass the click event to the input. If your content
   * needs to capture events, consider adding `pointer-events-auto` class to that
   * element only.
   *
   * @defaultValue 'none'
   */
  endContentPointerEvents?: 'none' | 'auto';
}

// Single selection mode interface
interface SingleNativeSelectArgs<T> extends BaseArgs<T> {
  selectionMode?: 'single' | undefined;
  selectedKey?: string | null;
  selectedKeys?: never;
  onSelectionChange?: (key: string | null) => void;
}

// Multiple selection mode interface
interface MultipleNativeSelectArgs<T> extends BaseArgs<T> {
  selectionMode: 'multiple';
  selectedKey?: never;
  selectedKeys?: string[];
  onSelectionChange?: (keys: string[]) => void;
}

// Union type for the component
type Args<T> = SingleNativeSelectArgs<T> | MultipleNativeSelectArgs<T>;

interface NativeSelectSignature<T> {
  Args: Args<T>;
  Element: HTMLSelectElement;
  Blocks: {
    item: [{ item: T; key: string; label: string; Item: ItemCompBounded }];
    default: [{ Item: ItemCompBounded }];
    startContent: [];
    endContent: [];
  };
}

class NativeSelect<T = unknown> extends Component<NativeSelectSignature<T>> {
  constructor(owner: Owner, args: Args<T>) {
    super(owner, args);
    // Runtime warnings for incorrect API usage
    this.validateArgs();
  }

  validateArgs() {
    if (this.args.selectionMode === 'multiple') {
      if (
        typeof (this.args as unknown as Record<string, unknown>)[
          'selectedKey'
        ] !== 'undefined'
      ) {
        console.warn(
          'WARNING: selectedKey is not supported in multiple selection mode. Use selectedKeys instead.'
        );
      }
    } else {
      if (
        typeof (this.args as unknown as Record<string, unknown>)[
          'selectedKeys'
        ] !== 'undefined'
      ) {
        console.warn(
          'WARNING: selectedKeys is deprecated for single selection mode. Use selectedKey instead.'
        );
      }
    }
  }

  get normalizedSelectedKeys(): string[] {
    if (this.args.selectionMode === 'multiple') {
      return this.args.selectedKeys || [];
    } else {
      // Single mode: convert selectedKey to array for ListManager
      const singleArgs = this.args as SingleNativeSelectArgs<T>;
      return singleArgs.selectedKey ? [singleArgs.selectedKey] : [];
    }
  }

  listManager = new ListManager({
    selectionMode: this.args.selectionMode,
    selectedKeys: this.normalizedSelectedKeys,
    disabledKeys: this.args.disabledKeys,
    allowEmpty: this.args.allowEmpty,
    onSelectionChange: (keys: string[]) => this.handleSelectionChange(keys),
    onAction: this.args.onAction,
    onListItemsChange: this.args.onItemsChange
  });

  handleSelectionChange(keys: string[]) {
    if (this.args.selectionMode === 'multiple') {
      if (typeof this.args.onSelectionChange === 'function') {
        (this.args.onSelectionChange as (keys: string[]) => void)(keys);
      }
    } else {
      const singleKey: string | null = keys.length > 0 ? keys[0] || null : null;
      if (typeof this.args.onSelectionChange === 'function') {
        (this.args.onSelectionChange as (key: string | null) => void)(
          singleKey
        );
      }
    }
  }

  get classes() {
    const { nativeSelect } = useStyles();
    return nativeSelect({
      size: this.args.size
    });
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

    this.handleSelectionChange(newSelectedKeys);
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
      @class={{this.classes.base class=@classes.base}}
      as |c|
    >
      <div class={{this.classes.innerContainer class=@classes.innerContainer}}>
        {{#if (has-block "startContent")}}
          <div
            data-test-id="input-start-content"
            class={{this.classes.startContent
              class=@classes.startContent
              startContentPointerEvents=(if
                @startContentPointerEvents @startContentPointerEvents "auto"
              )
            }}
          >
            {{yield to="startContent"}}
          </div>
        {{/if}}
        <select
          {{this.listManager.setup
            selectedKeys=this.normalizedSelectedKeys
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
          class={{this.classes.input
            class=@classes.input
            hasStartContent=(has-block "startContent")
            hasEndContent=true
          }}
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
        <div
          data-test-id="input-end-content"
          class={{this.classes.endContent
            class=@classes.endContent
            endContentPointerEvents=(if
              @endContentPointerEvents @endContentPointerEvents "none"
            )
          }}
        >
          {{yield to="endContent"}}

          <IconChevronUpDown class={{this.classes.icon class=@classes.icon}} />
        </div>
      </div>
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
