import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { on } from '@ember/modifier';
import { NativeSelect, type ListItem } from './native-select';
import { Listbox, type ListboxSignature } from '@frontile/collections';
import type { ComponentLike } from '@glint/template';
import {
  useStyles,
  type SelectSlots,
  type SelectVariants,
  type SlotsToClasses
} from '@frontile/theme';
import { Spinner, VisuallyHidden, ref } from '@frontile/utilities';
import {
  Popover,
  type PopoverSignature,
  type ContentSignature
} from '@frontile/overlays';
import { FormControl, type FormControlSharedArgs } from './form-control';
import { triggerFormInputEvent } from '../utils';
import { CloseButton } from '@frontile/buttons';
import { IconChevronUpDown } from './icons';
import { keyAndLabelForItem } from '@frontile/collections/utils/listManager';

interface SelectArgs<T>
  extends Pick<
      PopoverSignature['Args'],
      | 'placement'
      | 'flipOptions'
      | 'middleware'
      | 'shiftOptions'
      | 'offsetOptions'
      | 'strategy'
      | 'didClose'
    >,
    Pick<
      ListboxSignature<T>['Args'],
      | 'appearance'
      | 'intent'
      | 'selectedKeys'
      | 'disabledKeys'
      | 'allowEmpty'
      | 'onSelectionChange'
      | 'items'
      | 'onAction'
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
    >,
    FormControlSharedArgs {
  /**
   * Determines the selection mode of the select component.
   * - 'single': Only one item can be selected at a time.
   * - 'multiple': Allows multiple selections.
   * @defaultValue 'single'
   */
  selectionMode?: 'single' | 'multiple';

  /**
   * The unique identifier for the select component.
   */
  id?: string;

  /**
   * Defines the input size of the select.
   */
  inputSize?: SelectVariants['size'];

  /**
   * Defines the size of the popover dropdown.
   * - 'sm': Small
   * - 'md': Medium
   * - 'lg': Large
   */
  popoverSize?: 'sm' | 'md' | 'lg';

  /**
   * Custom classes to style different slots within the select component.
   */
  classes?: SlotsToClasses<SelectSlots>;

  /**
   * Whether the select should close upon selecting an item.
   *
   * @defaultValue true
   */
  closeOnItemSelect?: boolean;

  /**
   * Whether scrolling should be blocked when the select dropdown is open.
   *
   * @defaultValue true
   */
  blockScroll?: boolean;

  /**
   * Whether the focus trap should be disabled when the dropdown is open.
   *
   * @defaultValue true
   */
  disableFocusTrap?: boolean;

  /**
   * The placeholder text displayed when no option is selected.
   */
  placeholder?: string;

  /**
   * Whether the select should be disabled, preventing user interaction.
   */
  isDisabled?: boolean;

  /**
   * Allows filtering of the items in the select dropdown.
   * If true, a search input is displayed for filtering.
   *
   * @defaultValue false
   */
  isFilterable?: boolean;

  /**
   * Function to filter the items in the select.
   * The default implementation performs a case-insensitive search.
   *
   * @param itemValue - The value of an item in the dropdown.
   * @param filterValue - The user's input in the filter/search box.
   * @returns A boolean indicating whether the item should be shown.
   */
  filter?: (itemValue: string, filterValue: string) => boolean;

  /**
   * If true, the select will show a loading spinner instead of the dropdown icon.
   */
  isLoading?: boolean;

  /**
   * The name attribute for the select component, useful for form submissions.
   */
  name?: string;

  /**
   * Whether to include a clear button in the select component.
   * If enabled, this allows users to clear the selection.
   * This option ignores the `allowEmpty` setting.
   *
   * @defaultValue false
   */
  isClearable?: boolean;

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

  /**
   * If true, hides the empty content when there are no options available.
   *
   * @defaultValue false
   */
  hideEmptyContent?: boolean;
}

interface SelectSignature<T> {
  Args: SelectArgs<T>;
  Element: HTMLDivElement;
  Blocks: ListboxSignature<T>['Blocks'] & {
    /**
     * Content to display at the **beginning** of the select component.
     * This can be an icon, a label, or any custom UI element.
     *
     * Example: A search icon or a custom label.
     */
    startContent: [];

    /**
     * Content to display at the **end** of the select component.
     * This can be an icon, a button, or any custom UI element.
     *
     * Example: A clear button or a dropdown arrow.
     */
    endContent: [];

    /**
     * The content to display when there are no available options.
     * If `hideEmptyContent` argument is true, this content will not be shown.
     */
    emptyContent: [];
  };
}

class Select<T = unknown> extends Component<SelectSignature<T>> {
  @tracked nodes: ListItem[] = [];
  @tracked isOpen = false;
  @tracked _selectedKeys: string[] = this.args.selectedKeys || [];

  @tracked filterValue?: string;

  containerRef = ref<HTMLDivElement>();
  triggerRef = ref<HTMLInputElement | HTMLButtonElement>();

  onSelectionChange = (keys: string[]) => {
    if (typeof this.args.onSelectionChange === 'function') {
      this.args.onSelectionChange(keys);
    } else {
      this._selectedKeys = keys;
    }

    this.filterValue = undefined;
    triggerFormInputEvent(this.containerRef.element);
  };

  onOpenChange = (isOpen: boolean) => {
    this.isOpen = isOpen;
  };

  onFilterChange = (event: Event) => {
    const target = event.target as HTMLInputElement;
    this.filterValue = target.value;
  };

  get selectedKeys(): string[] {
    if (
      typeof this.args.selectedKeys !== 'undefined' &&
      typeof this.args.onSelectionChange === 'function'
    ) {
      return this.args.selectedKeys;
    }

    return this._selectedKeys;
  }

  get blockScroll() {
    if (this.args.blockScroll === false) {
      return false;
    }
    return true;
  }

  get disableFocusTrap() {
    if (this.args.disableFocusTrap === false) {
      return false;
    }
    return true;
  }

  onAction = (key: string) => {
    if (typeof this.args.onAction === 'function') {
      this.args.onAction(key);
    }

    if (
      this.args.closeOnItemSelect !== false &&
      this.args.selectionMode !== 'multiple'
    ) {
      this.isOpen = false;
    }
  };

  clearSelectedKeys = (event: Event) => {
    this.onSelectionChange([]);
    event.stopPropagation();
  };

  onItemsChange = (nodes: ListItem[], _: 'add' | 'remove') => {
    this.nodes = nodes;
  };

  didClose = () => {
    this.filterValue = undefined;
    if (typeof this.args.didClose === 'function') {
      this.args.didClose();
    }
  };

  get selectedText() {
    return this.selectedKeys?.join(', ');
  }

  get selectedTextValue(): string {
    let selectedTextValues: string[] = [];
    for (let node of this.nodes) {
      if (this.selectedKeys?.includes(node.key)) {
        selectedTextValues.push(node.textValue);
      }
    }
    return selectedTextValues.join(', ');
  }

  get backdrop() {
    if (typeof this.args.backdrop === 'undefined') {
      return 'transparent';
    }
    return this.args.backdrop;
  }

  get classes() {
    const { select } = useStyles();
    return select({
      size: this.args.inputSize
    });
  }

  get isClearable() {
    return (
      this.args.isClearable && this.selectedKeys && this.selectedKeys.length > 0
    );
  }

  get filterFieldValue() {
    if (this.filterValue !== undefined) {
      return this.filterValue;
    }
    return this.selectedTextValue;
  }

  get filteredItems() {
    if (this.filterValue === undefined) {
      return this.args.items;
    }

    let filter =
      this.args.filter ||
      ((itemValue: string, filterValue: string) =>
        itemValue.toLowerCase().includes(filterValue.toLowerCase()));

    return this.args.items?.filter((item) =>
      filter(keyAndLabelForItem(item).label, this.filterValue || '')
    );
  }

  get showEmptyContent() {
    return this.filteredItems?.length === 0 && !this.args.hideEmptyContent;
  }

  <template>
    <div
      {{this.containerRef.setup}}
      class={{this.classes.base class=@classes.base}}
      ...attributes
    >
      <FormControl
        @id={{@id}}
        @size={{@inputSize}}
        @label={{@label}}
        @isRequired={{@isRequired}}
        @description={{@description}}
        @errors={{@errors}}
        @isInvalid={{@isInvalid}}
        as |c|
      >
        <Popover
          @placement={{@placement}}
          @flipOptions={{@flipOptions}}
          @middleware={{@middleware}}
          @shiftOptions={{@shiftOptions}}
          @offsetOptions={{@offsetOptions}}
          @strategy={{@strategy}}
          @didClose={{this.didClose}}
          @isOpen={{this.isOpen}}
          @onOpenChange={{this.onOpenChange}}
          as |p|
        >
          <VisuallyHidden>
            <NativeSelect
              @items={{this.filteredItems}}
              @allowEmpty={{@allowEmpty}}
              @disabledKeys={{@disabledKeys}}
              @onSelectionChange={{this.onSelectionChange}}
              @selectedKeys={{this.selectedKeys}}
              @selectionMode={{if @selectionMode @selectionMode "single"}}
              @onItemsChange={{this.onItemsChange}}
              @placeholder={{@placeholder}}
              @id={{c.id}}
              @name={{@name}}
              tabindex="-1"
              disabled={{@isDisabled}}
            >
              <:item as |l|>
                {{#if (has-block "item")}}
                  {{! @glint-expect-error: the signature of the native select item is not the same as the listtbox item}}
                  {{yield l to="item"}}
                {{else}}
                  <l.Item @key={{l.key}}>
                    {{l.label}}
                  </l.Item>
                {{/if}}
              </:item>
              <:default as |l|>
                {{! @glint-expect-error: the signature of the native select is not the same as the listtbox}}
                {{yield l to="default"}}
              </:default>
            </NativeSelect>
          </VisuallyHidden>

          <div
            class={{this.classes.innerContainer class=@classes.innerContainer}}
          >
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
            {{#if @isFilterable}}
              <input
                type="text"
                {{p.trigger}}
                {{p.anchor}}
                {{this.triggerRef.setup}}
                data-test-id="trigger"
                data-component="select-trigger"
                disabled={{@isDisabled}}
                placeholder={{@placeholder}}
                class={{this.classes.input
                  class=@classes.input
                  hasStartContent=(has-block "startContent")
                  hasEndContent=true
                }}
                value={{this.filterFieldValue}}
                {{on "input" this.onFilterChange}}
              />
            {{else}}
              <button
                type="button"
                {{p.trigger}}
                {{p.anchor}}
                {{this.triggerRef.setup}}
                data-test-id="trigger"
                data-component="select-trigger"
                disabled={{@isDisabled}}
                class={{this.classes.input
                  class=@classes.input
                  hasStartContent=(has-block "startContent")
                  hasEndContent=true
                }}
              >
                {{#if this.selectedText}}
                  <span>
                    {{this.selectedTextValue}}
                  </span>
                {{else}}
                  <span
                    class={{this.classes.placeholder
                      class=@classes.placeholder
                    }}
                  >
                    {{@placeholder}}
                  </span>
                {{/if}}
              </button>
            {{/if}}
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

              {{#if @isLoading}}
                <Spinner @size={{if (isSm @inputSize) "xs" "sm"}} />
              {{else if this.isClearable}}
                <CloseButton
                  @title="Clear"
                  @variant="subtle"
                  @size="xs"
                  @class={{this.classes.clearButton class=@classes.clearButton}}
                  data-test-id="input-clear-button"
                  @onClick={{this.clearSelectedKeys}}
                />
              {{else}}
                <IconChevronUpDown
                  class={{this.classes.icon class=@classes.icon}}
                />
              {{/if}}
            </div>
          </div>

          <p.Content
            @size={{@popoverSize}}
            @target={{@target}}
            @renderInPlace={{@renderInPlace}}
            @disableFocusTrap={{this.disableFocusTrap}}
            @blockScroll={{this.blockScroll}}
            @transitionDuration={{@transitionDuration}}
            @backdrop={{this.backdrop}}
            @disableTransitions={{@disableTransitions}}
            @focusTrapOptions={{@focusTrapOptions}}
            @closeOnOutsideClick={{@closeOnOutsideClick}}
            @closeOnEscapeKey={{@closeOnEscapeKey}}
            @backdropTransition={{@backdropTransition}}
            @transition={{@transition}}
            @preventAutoFocus={{true}}
          >
            <Listbox
              @items={{this.filteredItems}}
              @allowEmpty={{@allowEmpty}}
              @appearance={{@appearance}}
              @disabledKeys={{@disabledKeys}}
              @intent={{@intent}}
              @isKeyboardEventsEnabled={{true}}
              @onAction={{this.onAction}}
              @onSelectionChange={{this.onSelectionChange}}
              @selectedKeys={{this.selectedKeys}}
              @selectionMode={{if @selectionMode @selectionMode "single"}}
              @type="listbox"
              @class={{this.classes.listbox class=@classes.listbox}}
              @elementToAddKeyboardEvents={{this.triggerRef.element}}
            >
              <:item as |l|>
                {{#if (has-block "item")}}
                  {{yield l to="item"}}
                {{else}}
                  <l.Item
                    @key={{l.key}}
                    @appearance={{@appearance}}
                    @intent={{@intent}}
                  >
                    {{l.label}}
                  </l.Item>
                {{/if}}
              </:item>
              <:default as |l|>
                {{yield l to="default"}}
              </:default>
            </Listbox>
            {{#if this.showEmptyContent}}
              <div
                class={{this.classes.emptyContent class=@classes.emptyContent}}
              >
                {{#if (has-block "emptyContent")}}
                  {{yield to="emptyContent"}}
                {{else}}
                  No results found.
                {{/if}}
              </div>
            {{/if}}
          </p.Content>
        </Popover>
      </FormControl>
    </div>
  </template>
}

const isSm = (size: SelectVariants['size']) => size === 'sm';

export { Select, type SelectSignature };
export default Select;
