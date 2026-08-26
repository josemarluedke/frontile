import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { on } from '@ember/modifier';
import { concat, fn } from '@ember/helper';
import type Owner from '@ember/owner';
import { NativeSelect, type ListItem } from './native-select';
import { Listbox, type ListboxSignature } from '../collections/listbox';
import {
  useStyles,
  type SelectSlots,
  type SelectVariants,
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
import { Chip, type ChipSignature } from '../buttons/chip';
import { IconChevronUpDown } from './icons';
import { keyAndLabelForItem, defaultFilter } from '../../utils/listManager';
import { action } from '@ember/object';
import { later } from '@ember/runloop';

import { modifier } from 'ember-modifier';

// Import helper function directly instead of using ember-truth-helpers
const eq = (a: unknown, b: unknown) => a === b;
const and = (a: unknown, b: unknown) => Boolean(a) && Boolean(b);
const valueUnless = <T,>(condition: unknown, value: T): T | undefined =>
  condition ? undefined : value;

/**
 * A selected option reduced to what a chip needs to render.
 */
interface SelectedItem {
  key: string;
  textValue: string;
}

/**
 * Appearance options forwarded to the {@link Chip} rendered for each selected
 * option in multiple selection mode. Derived from {@link ChipSignature} so the
 * two can never drift apart; see {@link MultipleSelectArgs.chip} for the
 * Select-specific defaults applied on top of Chip's own.
 */
interface SelectChipOptions
  extends Pick<ChipSignature['Args'], 'radius' | 'withDot'> {
  /**
   * The chip appearance.
   *
   * @defaultValue 'faded'
   */
  appearance?: ChipSignature['Args']['appearance'];

  /**
   * The intent of the chip. Defaults to the Select's own `@intent`.
   */
  intent?: ChipSignature['Args']['intent'];

  /**
   * The size of the chip.
   *
   * @defaultValue 'sm'
   */
  size?: ChipSignature['Args']['size'];
}

// Base interface for shared properties
interface BaseSelectArgs<T>
  extends
    Pick<
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
    FormControlSharedArgs {}

// Base interface for single selection mode (backward compatible)
interface BaseSingleSelectArgs<T> extends BaseSelectArgs<T> {
  /**
   * The currently selected key for single selection mode.
   *
   * **Data Flow:**
   * - Pass this to set the initial selection
   * - Update this in your `onSelectionChange` handler to maintain two-way binding
   * - The component calls `onSelectionChange` whenever the user changes the selection
   *
   * @example
   * ```gts
   * import { tracked } from '@glimmer/tracking';
   *
   * class MyComponent {
   *   @tracked selectedKey = 'option1';
   *
   *   handleSelectionChange = (key: string | null) => {
   *     this.selectedKey = key; // Update parent state
   *   }
   *
   *   <template>
   *     <Select
   *       @selectedKey={{this.selectedKey}}
   *       @onSelectionChange={{this.handleSelectionChange}}
   *       @items={{this.items}}
   *     />
   *   </template>
   * }
   * ```
   */
  selectedKey?: string | null;

  /**
   * @deprecated Use selectedKey for single selection mode
   */
  selectedKeys?: never;

  /**
   * Callback fired when the selection changes in single mode.
   *
   * Update your `@selectedKey` state in this callback to maintain two-way binding.
   *
   * @param key - The newly selected key, or null if selection was cleared
   */
  onSelectionChange?: (key: string | null) => void;
}

// Single selection mode interface (when selectionMode is explicitly 'single')
interface ExplicitSingleSelectArgs<T> extends BaseSingleSelectArgs<T> {
  /**
   * Determines the selection mode of the select component.
   * - 'single': Only one item can be selected at a time.
   */
  selectionMode: 'single';

  /**
   * Not applicable in single selection mode.
   */
  selectedItemsDisplay?: never;

  /**
   * Not applicable in single selection mode.
   */
  chip?: never;
}

// Single selection mode interface (when selectionMode is omitted - default behavior)
interface DefaultSingleSelectArgs<T> extends BaseSingleSelectArgs<T> {
  /**
   * Determines the selection mode of the select component.
   * - 'single': Only one item can be selected at a time.
   * @defaultValue 'single'
   */
  selectionMode?: undefined;

  /**
   * Not applicable in single selection mode.
   */
  selectedItemsDisplay?: never;

  /**
   * Not applicable in single selection mode.
   */
  chip?: never;
}

// Multiple selection mode interface
interface MultipleSelectArgs<T> extends BaseSelectArgs<T> {
  /**
   * Determines the selection mode of the select component.
   * - 'multiple': Allows multiple selections.
   */
  selectionMode: 'multiple';

  /**
   * How the selected options are presented in the trigger.
   *
   * - `'chips'`: each selection renders as a removable {@link Chip}.
   * - `'text'`: the selections render as a comma-joined string.
   *
   * @defaultValue 'chips'
   */
  selectedItemsDisplay?: 'chips' | 'text';

  /**
   * Appearance of the chips rendered for each selected option.
   * Only applies when `@selectedItemsDisplay` is `'chips'` (the default).
   *
   * Options are the same ones {@link Chip} itself accepts (`appearance`,
   * `intent`, `size`, `radius`, `withDot`), but Select applies its own
   * defaults tuned for sitting inside a field, rather than Chip's:
   * - `appearance` defaults to `'faded'`
   * - `intent` defaults to the Select's own `@intent`, so `@intent="primary"`
   *   colors the listbox items and the chips together
   * - `size` defaults to `'sm'`
   * - `radius` and `withDot` fall back to Chip's own defaults
   *
   * @example
   * ```gts
   * <Select
   *   @selectionMode="multiple"
   *   @chip={{hash appearance="outlined" size="md" radius="full"}}
   * />
   * ```
   */
  chip?: SelectChipOptions;

  /**
   * @deprecated Use selectedKeys for multiple selection mode
   */
  selectedKey?: never;

  /**
   * The currently selected keys for multiple selection mode.
   *
   * **Data Flow:**
   * - Pass this to set the initial selection (array of keys)
   * - Update this in your `onSelectionChange` handler to maintain two-way binding
   * - The component calls `onSelectionChange` whenever the user changes the selection
   *
   * @example
   * ```gts
   * import { tracked } from '@glimmer/tracking';
   *
   * class MyComponent {
   *   @tracked selectedKeys = ['option1', 'option2'];
   *
   *   handleSelectionChange = (keys: string[]) => {
   *     this.selectedKeys = keys; // Update parent state
   *   }
   *
   *   <template>
   *     <Select
   *       @selectionMode="multiple"
   *       @selectedKeys={{this.selectedKeys}}
   *       @onSelectionChange={{this.handleSelectionChange}}
   *       @items={{this.items}}
   *     />
   *   </template>
   * }
   * ```
   */
  selectedKeys?: string[];

  /**
   * Callback fired when the selection changes in multiple mode.
   *
   * Update your `@selectedKeys` state in this callback to maintain two-way binding.
   *
   * @param keys - The newly selected keys (empty array if all selections cleared)
   */
  onSelectionChange?: (keys: string[]) => void;
}

// Proper discriminated union type that handles all cases
type SelectArgs<T> = (
  | ExplicitSingleSelectArgs<T>
  | DefaultSingleSelectArgs<T>
  | MultipleSelectArgs<T>
) & {
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
   * - 'trigger': Same size as the trigger
   *
   * @defaultValue 'trigger'
   */
  popoverSize?: 'sm' | 'md' | 'lg' | 'trigger';

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
   * Callback fired when the select component loses focus.
   */
  onBlur?: () => void;
};

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

/*
 * Internal: selection state architecture
 *
 * This component uses a **two-way data binding pattern** for managing selection state:
 *
 * ### Data Flow
 * 1. **External → Internal (Initialization & Updates)**
 *    - Parent passes `@selectedKey` or `@selectedKeys` as arguments
 *    - Constructor initializes internal tracked properties (`_selectedKey` or `_selectedKeys`)
 *    - Modifiers (`updateSingleSelectValue`, `updateMultipleSelectValue`) sync internal state
 *      when parent updates the arguments
 *
 * 2. **Internal State Management**
 *    - `_selectedKey` / `_selectedKeys`: Internal tracked state (prefixed with underscore)
 *    - These serve as the "source of truth" for rendering and reactivity
 *    - Getters (`getSelectedKey`, `selectedKeys`) expose this internal state to the template
 *
 * 3. **Internal → External (User Interactions)**
 *    - User interactions trigger selection change handlers
 *    - Handlers update internal `_selectedKey` / `_selectedKeys` for immediate UI update
 *    - Handlers call parent's `@onSelectionChange` callback to notify of state change
 *    - Parent updates its state, which flows back through step 1
 *
 * ### Why Both Internal State AND Callbacks?
 * - **Internal state:** Enables immediate, responsive UI updates (`_selectedKey` / `_selectedKeys`)
 * - **Parent callback:** Enables parent to take action when changes occur (`@onSelectionChange`)
 * - This pattern provides both responsive UX and parent inclusion over state
 *
 * ### Example Flow
 * ```
 * User clicks item
 *   → onSelectionChange handler
 *   → Updates _selectedKey (immediate UI update)
 *   → Calls parent's @onSelectionChange callback
 *   → Parent updates its @selectedKey state
 *   → updateSingleSelectValue modifier syncs _selectedKey with new arg value
 * ```
 */
/**
 * A dropdown selection component: a custom listbox in a popover, backed by a
 * visually hidden native `<select>` so the value submits with a form.
 *
 * Selection can be controlled with `@selectedKey` / `@selectedKeys` plus
 * `@onSelectionChange`, or left uncontrolled.
 */
class Select<T = unknown> extends Component<SelectSignature<T>> {
  /**
   * Every item registered by the hidden native `<select>`, in item order.
   *
   * The hidden select is deliberately given the *unfiltered* `@items` — it
   * carries the form value, which must not shrink to the filter — so this
   * covers the whole list even while the listbox is filtered down. Chips and
   * the joined text value can therefore be resolved straight from it.
   */
  @tracked nodes: ListItem[] = [];

  @tracked isOpen = false;
  /**
   * Internal tracked state for single selection mode.
   * Source of truth for rendering. Synced with @selectedKey via the updateSingleSelectValue modifier.
   */
  @tracked _selectedKey: string | null = null;

  /**
   * Internal tracked state for multiple selection mode.
   * Source of truth for rendering. Synced with @selectedKeys via the updateMultipleSelectValue modifier.
   */
  @tracked _selectedKeys: string[] = [];

  /**
   * Initializes the component and sets up initial selection state.
   *
   * **Initialization:**
   * 1. Determines selection mode (single vs multiple)
   * 2. Copies external arg values (@selectedKey or @selectedKeys) to internal tracked state
   * 3. Logs warnings if incorrect args are used for the selection mode
   *
   * Note: After instantiation, modifiers keep internal state synced with external arguments.
   */
  constructor(owner: Owner, args: SelectArgs<T>) {
    super(owner, args);

    // Initialize based on mode
    if (this.args.selectionMode === 'multiple') {
      this._selectedKeys = this.args.selectedKeys || [];
    } else {
      this._selectedKey =
        (this.args as ExplicitSingleSelectArgs<T> | DefaultSingleSelectArgs<T>)
          .selectedKey || null;
    }

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

  @tracked filterValue?: string;

  containerRef = ref<HTMLDivElement>();
  triggerRef = ref<HTMLInputElement | HTMLButtonElement>();
  chipsContainerRef = ref<HTMLDivElement>();

  /**
   * Handles selection changes from the Listbox component.
   *
   * **Flow:**
   * 1. Updates internal state (`_selectedKey` or `_selectedKeys`) for immediate UI updates
   * 2. Calls parent's `@onSelectionChange` callback to notify of the change
   * 3. Parent updates its state, which flows back via modifier to complete the cycle
   *
   * **Side effects:**
   * - Clears filter value (for searchable selects)
   * - Triggers form input event for native form integration
   *
   * @param keys - Array of selected keys from Listbox (converted to single value in single mode)
   */
  onSelectionChange = (keys: string[]) => {
    if (this.args.selectionMode === 'multiple') {
      this._selectedKeys = keys;
      if (typeof this.args.onSelectionChange === 'function') {
        (this.args.onSelectionChange as (keys: string[]) => void)(keys);
      }
    } else {
      const singleKey: string | null = keys.length > 0 ? keys[0] || null : null;
      this._selectedKey = singleKey;
      if (typeof this.args.onSelectionChange === 'function') {
        (this.args.onSelectionChange as (key: string | null) => void)(
          singleKey
        );
      }
    }

    this.filterValue = undefined;
    triggerFormInputEvent(this.containerRef.current);
  };

  /**
   * Handles selection changes from the native <select> element.
   *
   * This is similar to `onSelectionChange` but accepts a single key directly
   * rather than an array, matching the native select's single-value API.
   *
   * **Flow:**
   * 1. Updates internal `_selectedKey` for immediate UI update
   * 2. Calls parent's `@onSelectionChange` callback
   *
   * @param key - The selected key, or null if cleared
   */
  onSingleSelectionChange = (key: string | null) => {
    this._selectedKey = key;
    if (typeof this.args.onSelectionChange === 'function') {
      (this.args.onSelectionChange as (key: string | null) => void)(key);
    }

    this.filterValue = undefined;
    triggerFormInputEvent(this.containerRef.current);
  };

  onOpenChange = (isOpen: boolean) => {
    this.isOpen = isOpen;
  };

  onFilterChange = (event: Event) => {
    const target = event.target as HTMLInputElement;
    this.filterValue = target.value;
  };

  /**
   * Backspace on an empty filter removes the last chip — the familiar tag-input
   * gesture. With text in the filter, Backspace edits the text as usual.
   */
  handleFilterKeydown = (event: KeyboardEvent) => {
    if (event.key !== 'Backspace' || !this.showChips) {
      return;
    }
    const target = event.target as HTMLInputElement;
    if (target.value !== '') {
      return;
    }
    this.removeLastSelectedKey();
  };

  /**
   * The non-filterable counterpart of {@link handleFilterKeydown}.
   *
   * Chip close buttons are deliberately outside the tab order (they would
   * otherwise cost a Tab stop each before the combobox is reached), so
   * Backspace/Delete on the trigger is the *only* keyboard route to removing a
   * chip here. There is no text to edit on a button trigger, so both keys act
   * immediately; `preventDefault` keeps Backspace from navigating back.
   */
  handleTriggerKeydown = (event: KeyboardEvent) => {
    if (!this.showChips || this.args.isDisabled) {
      return;
    }
    if (event.key !== 'Backspace' && event.key !== 'Delete') {
      return;
    }
    event.preventDefault();
    this.removeLastSelectedKey();
  };

  /**
   * Removes the trailing chip. `removeSelectedKey` applies the same
   * `@allowEmpty` rule the chip close buttons follow, so the last required
   * selection stays put.
   */
  removeLastSelectedKey(): void {
    const items = this.selectedItems;
    const last = items[items.length - 1];
    if (last) {
      this.removeSelectedKey(last.key);
    }
  }

  /**
   * Returns current selection as an array for template rendering.
   *
   * Normalizes both single and multiple selection modes to a consistent array interface:
   * - Multiple mode: Returns `_selectedKeys` directly
   * - Single mode: Converts `_selectedKey` to array format (or empty array if null)
   *
   * Note: Always returns internal tracked state rather than arguments. External updates
   * sync through modifiers to maintain consistency.
   *
   * @returns Array of selected keys (empty array if none selected)
   */
  get selectedKeys(): string[] {
    if (this.args.selectionMode === 'multiple') {
      return this._selectedKeys;
    } else {
      // Single mode: convert selectedKey to array for internal use
      const key = this.getSelectedKey;
      return key ? [key] : [];
    }
  }

  /**
   * Returns the selected key for single selection mode.
   *
   * **Returns:**
   * - Single mode: Returns `_selectedKey` (string or null)
   * - Multiple mode: Returns null (not applicable)
   *
   * Note: Always returns internal tracked state rather than arguments. External updates
   * sync through modifiers to maintain consistency.
   *
   * @returns The selected key, or null if none selected or in multiple mode
   */
  get getSelectedKey(): string | null {
    return this._selectedKey;
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

    // wait a beat for any side effects to complete before calling onBlur
    later(() => {
      this.args.onBlur?.();
    }, 150);
  };

  @action
  handleBlur() {
    later(() => {
      this.args.onBlur?.();
    }, 150);
  }

  /**
   * In chips mode the trigger is only as wide as the room left over beside the
   * chips, so the field's padding -- and the strip under the chevron -- are not
   * part of it, and with a single selection the trigger can be a narrow sliver.
   * Without this, clicking anywhere else in the field would do nothing, while
   * the same click anywhere on a non-chips field opens the dropdown (there the
   * trigger *is* the whole field). Forwards such a click to the trigger,
   * including clicks on a chip's own body, so the whole field is a click
   * target. The one exception is a chip's close button: within the chips
   * container the only `<button>` elements a chip ever renders are its close
   * button (see chip.gts / close-button.gts), so `closest('button')` combined
   * with containment against `chipsContainerRef` identifies it without relying
   * on any test-only attribute. Clicks on the trigger itself are left alone
   * too, since it already handles its own clicks.
   */
  handleFieldClick = (event: MouseEvent): void => {
    if (!this.showChips || this.args.isDisabled) {
      return;
    }

    const trigger = this.triggerRef.current;
    const target = event.target;

    if (!trigger || !(target instanceof Element)) {
      return;
    }

    // The trigger handles its own clicks; this listener also sees them bubble.
    if (trigger === target || trigger.contains(target)) {
      return;
    }

    const chipsContainer = this.chipsContainerRef.current;

    if (chipsContainer && chipsContainer.contains(target)) {
      const closeButton = target.closest('button');
      if (closeButton && chipsContainer.contains(closeButton)) {
        return;
      }
    }

    trigger.focus();
    trigger.click();
  };

  clearSelectedKeys = () => {
    this.onSelectionChange([]);
  };

  /**
   * Resolved chip appearance: `@chip` wins, then the Select's own `@intent`,
   * then chip defaults tuned for sitting inside a field.
   */
  get chipOptions(): {
    appearance: NonNullable<SelectChipOptions['appearance']>;
    intent: NonNullable<SelectChipOptions['intent']>;
    size: NonNullable<SelectChipOptions['size']>;
    radius: SelectChipOptions['radius'];
    withDot: boolean;
  } {
    const chip =
      this.args.selectionMode === 'multiple' ? this.args.chip : undefined;
    return {
      appearance: chip?.appearance ?? 'faded',
      intent: chip?.intent ?? this.args.intent ?? 'default',
      size: chip?.size ?? 'sm',
      radius: chip?.radius,
      withDot: chip?.withDot ?? false
    };
  }

  /**
   * Whether chips may be removed. Mirrors the listbox: with `@allowEmpty`
   * false — the default — the final selection cannot be deselected, so its
   * chip renders without a close button rather than with a dead one.
   */
  get chipsRemovable(): boolean {
    // Counts `selectedItems` — the same collection the chips render from —
    // rather than `selectedKeys`, so this decision can never disagree with
    // what is actually on screen (a selected key with no remembered item
    // would otherwise be counted here but never render a chip at all).
    return this.args.allowEmpty === true || this.selectedItems.length > 1;
  }

  /**
   * Removes a single selection from a chip's close button. Routes through
   * `onSelectionChange`, which already syncs internal state, notifies the
   * parent and dispatches the form input event.
   */
  removeSelectedKey = (key: string) => {
    if (this.args.isDisabled || !this.chipsRemovable) {
      return;
    }
    this.onSelectionChange(this.selectedKeys.filter((k) => k !== key));
  };

  onItemsChange = (nodes: ListItem[], _: 'add' | 'remove') => {
    // `onItemsChange` runs while a modifier installs, i.e. inside a render
    // pass. Reading a tracked field here and writing it in the same
    // computation would trip Glimmer's read-then-write assertion, so `nodes`
    // is only ever written, never read, in this callback.
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

  /**
   * Whether selections render as chips. Chips are the default presentation for
   * multiple selection mode; `@selectedItemsDisplay="text"` opts back out to the
   * comma-joined string.
   */
  get showChips(): boolean {
    return (
      this.args.selectionMode === 'multiple' &&
      this.args.selectedItemsDisplay !== 'text'
    );
  }

  get hasSelection(): boolean {
    return this.selectedKeys.length > 0;
  }

  /**
   * The accessible name for the trigger while chips are shown.
   *
   * In every other mode the trigger names itself from its own text -- the
   * selected label, or the placeholder. In chips mode it renders nothing (the
   * chips are its siblings, so they are read separately), which would leave the
   * combobox announced as an unnamed button. This names the *control*, never the
   * selection.
   */
  get triggerAccessibleName(): string {
    return this.args.label || this.args.placeholder || 'Select options';
  }

  /**
   * The selected options in item order (not click order) so chips do not
   * reorder underneath the user as they select.
   *
   * Resolved against `nodes`, which the hidden native `<select>` populates from
   * the unfiltered `@items`, so a chip stays put while a filter hides the item
   * it came from.
   */
  get selectedItems(): SelectedItem[] {
    const keys = this.selectedKeys;
    return this.nodes
      .filter((node) => keys.includes(node.key))
      .map((node) => ({ key: node.key, textValue: node.textValue }));
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
      size: this.args.inputSize,
      hasChips: this.showChips,
      isFilterable: !!this.args.isFilterable
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
    // With chips, the selection is already visible beside the input. Echoing
    // the joined text here would fill the box and block typing.
    if (this.showChips) {
      return '';
    }
    return this.selectedTextValue;
  }

  get filteredItems() {
    if (this.filterValue === undefined) {
      return this.args.items;
    }

    let filter = this.args.filter || defaultFilter;

    return this.args.items?.filter((item) =>
      filter(keyAndLabelForItem(item).label, this.filterValue || '')
    );
  }

  get showEmptyContent() {
    return this.filteredItems?.length === 0 && !this.args.hideEmptyContent;
  }

  get autoActivateMode(): 'first' | 'selected' {
    if (this.filterValue === undefined || this.filterValue === '') {
      return 'selected';
    }
    return 'first';
  }

  /**
   * Syncs internal `_selectedKeys` with external `@selectedKeys` argument.
   *
   * Runs whenever `@selectedKeys` changes:
   * - Updates `_selectedKeys` to match the new external value
   * - Normalizes undefined/null to empty array
   *
   * This enables UI updates when the external value changes.
   */
  updateMultipleSelectValue = modifier(
    (_: HTMLDivElement, [selectedKeys]: [string[] | null | undefined]) => {
      if (selectedKeys !== undefined && selectedKeys !== null) {
        this._selectedKeys = selectedKeys;
      } else {
        // NOTE: is this the right behavior?
        this._selectedKeys = [];
      }
    }
  );

  /**
   * Syncs internal `_selectedKey` with external `@selectedKey` argument.
   *
   * Runs whenever `@selectedKey` changes:
   * - Updates `_selectedKey` to match the new external value
   * - Handles null values for cleared selections
   *
   * This enables UI updates when the external value changes.
   */
  updateSingleSelectValue = modifier(
    (_: HTMLDivElement, [selectedKey]: [string | null | undefined]) => {
      if (selectedKey !== undefined) {
        this._selectedKey = selectedKey;
      }
    }
  );

  <template>
    <div
      {{this.updateMultipleSelectValue @selectedKeys}}
      {{this.updateSingleSelectValue @selectedKey}}
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
            {{#if (eq @selectionMode "multiple")}}
              <NativeSelect
                @items={{@items}}
                @allowEmpty={{@allowEmpty}}
                @disabledKeys={{@disabledKeys}}
                @onSelectionChange={{this.onSelectionChange}}
                @selectedKeys={{this.selectedKeys}}
                @selectionMode="multiple"
                @onItemsChange={{this.onItemsChange}}
                @placeholder={{@placeholder}}
                @id={{c.id}}
                @name={{@name}}
                tabindex="-1"
                disabled={{@isDisabled}}
              >
                <:item as |l|>
                  {{#if (has-block "item")}}
                    <l.Item @key={{l.key}}>
                      {{l.label}}
                    </l.Item>
                  {{else}}
                    <l.Item @key={{l.key}}>
                      {{l.label}}
                    </l.Item>
                  {{/if}}
                </:item>
                <:default as |l|>
                  {{! @glint-expect-error: the signature of the native select is not the same as the listbox}}
                  {{yield l to="default"}}
                </:default>
              </NativeSelect>
            {{else}}
              <NativeSelect
                @items={{@items}}
                @allowEmpty={{@allowEmpty}}
                @disabledKeys={{@disabledKeys}}
                @onSelectionChange={{this.onSingleSelectionChange}}
                @selectedKey={{this.getSelectedKey}}
                @selectionMode="single"
                @onItemsChange={{this.onItemsChange}}
                @placeholder={{@placeholder}}
                @id={{c.id}}
                @name={{@name}}
                tabindex="-1"
                disabled={{@isDisabled}}
              >
                <:item as |l|>
                  {{#if (has-block "item")}}
                    <l.Item @key={{l.key}}>
                      {{l.label}}
                    </l.Item>
                  {{else}}
                    <l.Item @key={{l.key}}>
                      {{l.label}}
                    </l.Item>
                  {{/if}}
                </:item>
                <:default as |l|>
                  {{! @glint-expect-error: the signature of the native select is not the same as the listbox}}
                  {{yield l to="default"}}
                </:default>
              </NativeSelect>
            {{/if}}
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
            {{! The wrapper, not the trigger, is the popover's width reference:
            in chips mode the trigger is only as wide as the space left over
            inside the field. The wrapper is a real full-width box in both
            modes, so the dropdown matches the field either way. }}
            <div
              {{p.anchor}}
              {{p.measureWidth}}
              {{on "click" this.handleFieldClick}}
              data-test-id={{if this.showChips "chips-field"}}
              data-has-chips={{this.showChips}}
              data-invalid={{c.isInvalid}}
              data-disabled={{if @isDisabled "true" "false"}}
              class={{this.classes.chipsField
                class=@classes.chipsField
                hasStartContent=(has-block "startContent")
                hasEndContent=true
              }}
            >
              {{#if (and this.showChips this.hasSelection)}}
                <div
                  {{this.chipsContainerRef.setup}}
                  data-test-id="selected-chips"
                  class={{this.classes.chipsContainer
                    class=@classes.chipsContainer
                  }}
                >
                  {{#each this.selectedItems key="key" as |item|}}
                    <Chip
                      data-test-id="selected-chip"
                      data-key={{item.key}}
                      @class={{this.classes.chip class=@classes.chip}}
                      @appearance={{this.chipOptions.appearance}}
                      @intent={{this.chipOptions.intent}}
                      @size={{this.chipOptions.size}}
                      @radius={{this.chipOptions.radius}}
                      @withDot={{this.chipOptions.withDot}}
                      @isDisabled={{@isDisabled}}
                      @closeButtonTitle={{concat "Remove " item.textValue}}
                      @closeButtonTabIndex="-1"
                      @onClose={{if
                        this.chipsRemovable
                        (fn this.removeSelectedKey item.key)
                      }}
                    >
                      {{item.textValue}}
                    </Chip>
                  {{/each}}
                </div>
              {{/if}}
              {{#if @isFilterable}}
                <input
                  type="text"
                  {{p.trigger}}
                  {{this.triggerRef.setup}}
                  data-test-id="trigger"
                  data-component="select-trigger"
                  disabled={{@isDisabled}}
                  aria-label={{if this.showChips this.triggerAccessibleName}}
                  placeholder={{valueUnless
                    (and this.showChips this.hasSelection)
                    @placeholder
                  }}
                  class={{this.classes.input
                    class=@classes.input
                    hasStartContent=(has-block "startContent")
                    hasEndContent=true
                    hasChips=this.showChips
                  }}
                  value={{this.filterFieldValue}}
                  {{on "input" this.onFilterChange}}
                  {{on "keydown" this.handleFilterKeydown}}
                  {{on "blur" this.handleBlur}}
                />
              {{else}}
                <button
                  type="button"
                  {{p.trigger}}
                  {{this.triggerRef.setup}}
                  data-test-id="trigger"
                  data-component="select-trigger"
                  disabled={{@isDisabled}}
                  aria-label={{if this.showChips this.triggerAccessibleName}}
                  class={{this.classes.input
                    class=@classes.input
                    hasStartContent=(has-block "startContent")
                    hasEndContent=true
                    hasChips=this.showChips
                  }}
                  {{on "keydown" this.handleTriggerKeydown}}
                  {{on "blur" this.handleBlur}}
                >
                  {{#if this.hasSelection}}
                    {{#unless this.showChips}}
                      <span>
                        {{this.selectedTextValue}}
                      </span>
                    {{/unless}}
                  {{else}}
                    <span
                      class={{this.classes.placeholder
                        class=@classes.placeholder
                      }}
                    >
                      {{#if @placeholder}}{{@placeholder}}{{else}}&nbsp;{{/if}}
                    </span>
                  {{/if}}
                </button>
              {{/if}}
            </div>
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
              @selectedKeys={{this.selectedKeys}}
              @selectionMode={{if @selectionMode @selectionMode "single"}}
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
            {{#if this.showEmptyContent}}
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

const isSm = (size: SelectVariants['size']) => size === 'sm';

export { Select, type SelectSignature, type SelectChipOptions };
export default Select;
