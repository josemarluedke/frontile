import Component from '@glimmer/component';
import { tracked, cached } from '@glimmer/tracking';
import { on } from '@ember/modifier';
import type Owner from '@ember/owner';
import { NativeSelect, type ListItem } from './native-select';
import { Listbox, type ListboxSignature } from '../collections/listbox';
import {
  useStyles,
  type AutocompleteSlots,
  type AutocompleteVariants,
  type SlotsToClasses
} from '@frontile/theme';
import { Spinner } from '../utilities/spinner';
import { VisuallyHidden } from '../utilities/visually-hidden';
import { ref } from '../../utils/ref';
import {
  Popover,
  type PopoverSignature,
  type ContentSignature
} from '../overlays/popover';
import { FormControl, type FormControlSharedArgs } from './form-control';
import { triggerFormInputEvent } from '../../utils/forms-utils-index';
import { CloseButton } from '../buttons/close-button';
import { IconChevronUpDown } from './icons';
import { keyAndLabelForItem, defaultFilter } from '../../utils/listManager';
import { later, debounce, cancel } from '@ember/runloop';

import { modifier } from 'ember-modifier';

interface AutocompleteArgs<T>
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
      | 'disabledKeys'
      | 'allowEmpty'
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
   * The currently selected key.
   *
   * Autocomplete is single-selection only — for a searchable multi-select,
   * use `Select` with `@isFilterable` and `@selectionMode="multiple"`.
   *
   * **Data Flow:**
   * - Pass this to set the initial selection
   * - Update this in your `onSelectionChange` handler to maintain two-way binding
   * - The component calls `onSelectionChange` whenever the user changes the selection
   */
  selectedKey?: string | null;

  /**
   * Callback fired when the selection changes.
   *
   * Update your `@selectedKey` state in this callback to maintain two-way binding.
   *
   * @param key - The newly selected key, or null if selection was cleared
   */
  onSelectionChange?: (key: string | null) => void;
  /**
   * The unique identifier for the autocomplete component.
   */
  id?: string;

  /**
   * Defines the input size of the autocomplete.
   */
  inputSize?: AutocompleteVariants['size'];

  /**
   * Defines the size of the popover dropdown.
   * - 'sm': Small
   * - 'md': Medium
   * - 'lg': Large
   * - 'trigger': Same size as the trigger
   *
   * @defaultValue 'trigger'
   */
  popoverSize?: 'sm' | 'md' | 'lg' | 'trigger';

  /**
   * Custom classes to style different slots within the autocomplete component.
   */
  classes?: SlotsToClasses<AutocompleteSlots>;

  /**
   * Whether the autocomplete should close upon selecting an item.
   *
   * @defaultValue true
   */
  closeOnItemSelect?: boolean;

  /**
   * Whether scrolling should be blocked when the dropdown is open.
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
   * The placeholder text displayed when the input is empty.
   */
  placeholder?: string;

  /**
   * Whether the autocomplete should be disabled, preventing user interaction.
   */
  isDisabled?: boolean;

  /**
   * The text value of the input.
   *
   * Pass this together with `onInputChange` to control the input text externally,
   * for example to implement server-side filtering.
   */
  inputValue?: string;

  /**
   * Callback fired whenever the user changes the input text.
   *
   * @param value - The current text of the input
   */
  onInputChange?: (value: string) => void;

  /**
   * Function to filter the items against the current input text.
   * The default implementation performs a case-insensitive "contains" search.
   *
   * @param itemValue - The label of an item in the dropdown.
   * @param inputValue - The user's input text.
   * @returns A boolean indicating whether the item should be shown.
   */
  filter?: (itemValue: string, inputValue: string) => boolean;

  /**
   * Disables the built-in filtering, rendering `@items` as-is.
   * Use together with `inputValue`/`onInputChange` when filtering happens
   * outside of the component (e.g. server-side).
   *
   * @defaultValue false
   */
  disableFiltering?: boolean;

  /**
   * Async search function. When provided, the component calls it (debounced)
   * as the user types and renders the resolved items, showing a loading
   * spinner while the returned promise is pending. Stale responses are
   * ignored (latest query wins). Built-in filtering is disabled; `@items`
   * is used as the initial list before the first search.
   *
   * @param query - The current input text
   * @returns The items matching the query
   */
  onSearch?: (query: string) => Promise<T[]> | T[];

  /**
   * Debounce duration, in milliseconds, applied to `onSearch` calls.
   *
   * @defaultValue 250
   */
  searchDebounce?: number;

  /**
   * When true, the text typed by the user is kept on blur/close even if it
   * does not match any option. By default the input reverts to the selected
   * item's label (or empty) when the dropdown closes without a selection.
   *
   * @defaultValue false
   */
  allowsCustomValue?: boolean;

  /**
   * If true, the autocomplete will show a loading spinner instead of the dropdown icon.
   * The spinner is also shown automatically while an `onSearch` promise is pending.
   */
  isLoading?: boolean;

  /**
   * The name attribute for the autocomplete component, useful for form submissions.
   */
  name?: string;

  /**
   * Whether to include a clear button in the autocomplete component.
   * If enabled, this allows users to clear the selection and input text.
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
   * Defaults to `none` to pass click events to the input. If your content
   * needs to capture events, add the `pointer-events-auto` class to that element.
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

  /**
   * Message shown in the dropdown of an async autocomplete (`onSearch`)
   * while the query is blank — e.g. "Type to search for an address…".
   * Prompts the user to start typing when they open the dropdown by
   * clicking. Also customizable via the `searchMessage` block.
   */
  searchMessage?: string;

  /**
   * Callback fired when the autocomplete component loses focus.
   */
  onBlur?: () => void;
}

interface AutocompleteSignature<T> {
  Args: AutocompleteArgs<T>;
  Element: HTMLDivElement;
  Blocks: ListboxSignature<T>['Blocks'] & {
    /**
     * Content to display at the **beginning** of the autocomplete component.
     * This can be an icon, a label, or any custom UI element.
     */
    startContent: [];

    /**
     * Content to display at the **end** of the autocomplete component.
     * This can be an icon, a button, or any custom UI element.
     */
    endContent: [];

    /**
     * The content to display when there are no matching options.
     * If `hideEmptyContent` argument is true, this content will not be shown.
     */
    emptyContent: [];

    /**
     * Message shown in the dropdown of an async autocomplete while the
     * query is blank, prompting the user to start typing. Takes priority
     * over the `searchMessage` argument.
     */
    searchMessage: [];
  };
}

/**
 * Autocomplete Component - a text input combined with a listbox popover,
 * following the WAI-ARIA 1.2 combobox pattern.
 *
 * Users filter the options by typing (type-ahead). Options can come from a
 * static list (built-in filtering), an externally filtered list
 * (`disableFiltering` + `onInputChange`), or an async source (`onSearch`).
 *
 * Selection state follows the same two-way data binding pattern as `Select`:
 * internal tracked state gives immediate UI updates, while `onSelectionChange`
 * notifies the parent, whose arg updates sync back through modifiers.
 */
class Autocomplete<T = unknown> extends Component<AutocompleteSignature<T>> {
  @tracked nodes: ListItem[] = [];
  @tracked isOpen = false;

  /**
   * Internal tracked selection state.
   * Synced with @selectedKey via the updateSelectedKey modifier.
   */
  @tracked _selectedKey: string | null = null;

  /**
   * The text the user has typed. `undefined` means the user is not editing,
   * so the input displays the selected item's label instead.
   */
  @tracked _inputValue?: string;

  /**
   * Items resolved from the latest `onSearch` call. `undefined` until the
   * first search resolves; `@items` is rendered in the meantime.
   */
  @tracked asyncItems?: T[];

  @tracked isSearchPending = false;

  /** Monotonic token to discard out-of-order onSearch resolutions. */
  #searchToken = 0;

  #pendingSearch?: ReturnType<typeof debounce>;

  /** Element id of the currently active (highlighted) option, for aria-activedescendant. */
  @tracked activeDescendant?: string;

  /** The currently active (highlighted) option. */
  activeItem?: ListItem;

  /**
   * Label of the selected key, captured at selection time. Needed in async
   * mode, where the selected item may no longer be present in the currently
   * rendered items (e.g. after search results are reset on close).
   */
  @tracked selectedLabel?: string;

  containerRef = ref<HTMLDivElement>();
  triggerRef = ref<HTMLInputElement>();

  constructor(owner: Owner, args: AutocompleteArgs<T>) {
    super(owner, args);
    this._selectedKey = this.args.selectedKey || null;
  }

  willDestroy(): void {
    super.willDestroy();
    if (this.#pendingSearch) {
      cancel(this.#pendingSearch);
    }
  }

  onSelectionChange = (keys: string[]) => {
    this.applySelection(keys[0] ?? null);
  };

  onNativeSelectionChange = (key: string | null) => {
    this.applySelection(key);
  };

  applySelection(key: string | null) {
    this.selectedLabel = key
      ? this.nodes.find((n) => n.key === key)?.textValue
      : undefined;
    this._selectedKey = key;
    this.args.onSelectionChange?.(key);
    this.clearInputValue();
    triggerFormInputEvent(this.containerRef.current);
  }

  onOpenChange = (isOpen: boolean) => {
    this.isOpen = isOpen;
  };

  onInput = (event: Event) => {
    const target = event.target as HTMLInputElement;
    this.setInputValue(target.value);

    if (!this.isOpen) {
      this.isOpen = true;
    }
  };

  setInputValue(value: string) {
    this._inputValue = value;

    if (typeof this.args.onInputChange === 'function') {
      this.args.onInputChange(value);
    }

    if (typeof this.args.onSearch === 'function') {
      if (value === '') {
        // A blank query shows the default `@items` again instead of searching.
        this.resetSearch();
        return;
      }

      this.isSearchPending = true;
      this.#pendingSearch = debounce(
        this,
        this.performSearch,
        value,
        this.args.searchDebounce ?? 250
      );
    }
  }

  /** Cancels any in-flight search and restores the default `@items`. */
  resetSearch() {
    if (this.#pendingSearch) {
      cancel(this.#pendingSearch);
    }
    this.#searchToken++;
    this.asyncItems = undefined;
    this.isSearchPending = false;
  }

  clearInputValue() {
    this._inputValue = undefined;
    if (typeof this.args.onInputChange === 'function') {
      this.args.onInputChange('');
    }
  }

  async performSearch(query: string) {
    const token = ++this.#searchToken;

    try {
      const result = await this.args.onSearch?.(query);
      if (token === this.#searchToken && !this.isDestroying) {
        this.asyncItems = result;
      }
    } finally {
      if (token === this.#searchToken && !this.isDestroying) {
        this.isSearchPending = false;
      }
    }
  }

  onKeyDown = (event: KeyboardEvent) => {
    if (event.key === 'Enter' && this.isOpen) {
      // Prevent form submission while the dropdown is open. Canceling
      // keydown also suppresses the keypress event the Listbox listens to,
      // so select the active option directly.
      event.preventDefault();

      this.activeItem?.el.click();
    }
  };

  /** Current selection as an array, for the Listbox / NativeSelect API. */
  get selectedKeys(): string[] {
    return this._selectedKey ? [this._selectedKey] : [];
  }

  get blockScroll() {
    return this.args.blockScroll !== false;
  }

  get disableFocusTrap() {
    return this.args.disableFocusTrap !== false;
  }

  onAction = (key: string) => {
    if (typeof this.args.onAction === 'function') {
      this.args.onAction(key);
    }

    if (this.args.closeOnItemSelect !== false) {
      this.isOpen = false;
    }

    this.handleBlur();
  };

  // wait a beat for any side effects to complete before calling onBlur
  handleBlur = () => {
    if (typeof this.args.onBlur === 'function') {
      later(() => {
        this.args.onBlur?.();
      }, 150);
    }
  };

  clearSelectedKeys = () => {
    this.onSelectionChange([]);
    this.clearInputValue();
    this.triggerRef.current?.focus();
  };

  onItemsChange = (nodes: ListItem[], _: 'add' | 'remove') => {
    this.nodes = nodes;
  };

  didClose = () => {
    if (!this.args.allowsCustomValue) {
      this._inputValue = undefined;
    }
    this.activeDescendant = undefined;
    this.activeItem = undefined;

    // Reset async results so reopening shows the default `@items` again.
    if (typeof this.args.onSearch === 'function') {
      this.resetSearch();
    }

    this.args.didClose?.();
  };

  onActiveItemChange = (_key?: string, item?: ListItem) => {
    this.activeItem = item;
    this.activeDescendant = item?.el.id || undefined;
  };

  get selectedTextValue(): string {
    const key = this._selectedKey;
    if (!key) {
      return '';
    }
    const node = this.nodes.find((n) => n.key === key);
    return node?.textValue ?? this.selectedLabel ?? key;
  }

  get inputValue(): string {
    if (typeof this.args.inputValue === 'string') {
      return this.args.inputValue;
    }
    if (this._inputValue !== undefined) {
      return this._inputValue;
    }
    return this.selectedTextValue;
  }

  get isFiltering(): boolean {
    const value =
      typeof this.args.inputValue === 'string'
        ? this.args.inputValue
        : this._inputValue;

    return typeof value === 'string' && value !== '';
  }

  get backdrop() {
    return this.args.backdrop ?? 'transparent';
  }

  @cached
  get classes() {
    const { autocomplete } = useStyles();
    return autocomplete({
      size: this.args.inputSize
    });
  }

  get isClearable() {
    return (
      this.args.isClearable &&
      (this.selectedKeys.length > 0 || this.isFiltering)
    );
  }

  get isLoading() {
    return this.args.isLoading || this.isSearchPending;
  }

  @cached
  get filteredItems() {
    if (typeof this.args.onSearch === 'function') {
      return this.asyncItems ?? this.args.items;
    }

    if (this.args.disableFiltering || !this.isFiltering) {
      return this.args.items;
    }

    const filter = this.args.filter || defaultFilter;
    const query = this.inputValue;

    return this.args.items?.filter((item) =>
      filter(keyAndLabelForItem(item).label, query)
    );
  }

  /**
   * True when an async autocomplete is open with a blank query and nothing
   * to show — the moment to prompt the user to start typing.
   */
  get isSearchPromptState(): boolean {
    return (
      typeof this.args.onSearch === 'function' &&
      !this.isFiltering &&
      !this.isLoading &&
      (this.filteredItems?.length ?? 0) === 0
    );
  }

  get showEmptyContent() {
    return (
      this.filteredItems?.length === 0 &&
      !this.isLoading &&
      !this.args.hideEmptyContent
    );
  }

  get autoActivateMode(): 'first' | 'selected' {
    if (this.isFiltering) {
      return 'first';
    }
    return 'selected';
  }

  /**
   * Syncs internal `_selectedKey` with external `@selectedKey` argument.
   */
  updateSelectedKey = modifier(
    (_: HTMLDivElement, [selectedKey]: [string | null | undefined]) => {
      if (selectedKey !== undefined) {
        this._selectedKey = selectedKey;
      }
    }
  );

  <template>
    <div
      {{this.updateSelectedKey @selectedKey}}
      {{this.containerRef.setup}}
      class={{this.classes.base class=@classes.base}}
      data-component="autocomplete"
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
              @onSelectionChange={{this.onNativeSelectionChange}}
              @selectedKey={{this._selectedKey}}
              @selectionMode="single"
              @onItemsChange={{this.onItemsChange}}
              @placeholder={{@placeholder}}
              @id={{c.id}}
              @name={{@name}}
              tabindex="-1"
              disabled={{@isDisabled}}
            >
              <:item as |l|>
                <l.Item @key={{l.key}}>
                  {{l.label}}
                </l.Item>
              </:item>
              <:default as |l|>
                {{! @glint-expect-error: the signature of the native select is not the same as the listbox}}
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
            {{! aria-expanded and aria-controls are set at runtime by the
                Popover trigger modifier, and role=combobox is not implicit
                on a text input }}
            {{! template-lint-disable no-redundant-role require-mandatory-role-attributes }}
            <input
              type="text"
              role="combobox"
              aria-autocomplete="list"
              aria-activedescendant={{this.activeDescendant}}
              autocomplete="off"
              autocapitalize="off"
              autocorrect="off"
              spellcheck="false"
              {{p.trigger}}
              {{p.anchor}}
              {{this.triggerRef.setup}}
              data-test-id="trigger"
              data-component="autocomplete-trigger"
              disabled={{@isDisabled}}
              placeholder={{@placeholder}}
              class={{this.classes.input
                class=@classes.input
                hasStartContent=(has-block "startContent")
                hasEndContent=true
              }}
              value={{this.inputValue}}
              {{on "input" this.onInput}}
              {{on "keydown" this.onKeyDown}}
              {{on "blur" this.handleBlur}}
            />
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

              {{#if this.isLoading}}
                <Spinner
                  @size={{if (isSm @inputSize) "xs" "sm"}}
                  data-test-id="loading-spinner"
                />
              {{else if this.isClearable}}
                <CloseButton
                  @title="Clear"
                  @variant="subtle"
                  @size="xs"
                  @class={{this.classes.clearButton class=@classes.clearButton}}
                  data-test-id="input-clear-button"
                  @onPress={{this.clearSelectedKeys}}
                />
              {{else}}
                <IconChevronUpDown
                  class={{this.classes.icon class=@classes.icon}}
                />
              {{/if}}
            </div>
          </div>

          <p.Content
            @size={{if @popoverSize @popoverSize "trigger"}}
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
              @onActiveItemChange={{this.onActiveItemChange}}
              @selectedKeys={{this.selectedKeys}}
              @selectionMode="single"
              @type="listbox"
              @class={{this.classes.listbox class=@classes.listbox}}
              @elementToAddKeyboardEvents={{this.triggerRef.current}}
              @autoActivateMode={{this.autoActivateMode}}
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
            {{#if
              (and
                this.isSearchPromptState
                (or @searchMessage (has-block "searchMessage"))
              )
            }}
              <div
                class={{this.classes.emptyContent class=@classes.emptyContent}}
                data-test-id="search-message"
              >
                {{#if (has-block "searchMessage")}}
                  {{yield to="searchMessage"}}
                {{else}}
                  {{@searchMessage}}
                {{/if}}
              </div>
            {{else if this.showEmptyContent}}
              <div
                class={{this.classes.emptyContent class=@classes.emptyContent}}
                data-test-id="empty-content"
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

const isSm = (size: AutocompleteVariants['size']) => size === 'sm';
const and = (a: unknown, b: unknown) => Boolean(a) && Boolean(b);
const or = (a: unknown, b: unknown) => Boolean(a) || Boolean(b);

export { Autocomplete, type AutocompleteSignature };
export default Autocomplete;
