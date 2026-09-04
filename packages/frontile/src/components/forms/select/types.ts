import type { ListboxSignature } from '../../collections/listbox';
import type { FilterFn } from '../../../utils/filter';
import type {
  SelectSlots,
  SelectVariants,
  SlotsToClasses
} from '@frontile/theme';
import type { useStyles } from '@frontile/theme';
import type {
  PopoverSignature,
  ContentSignature
} from '../../overlays/popover';
import type { FormControlSharedArgs } from '../form-control';
import type { ChipSignature } from '../../buttons/chip';

/**
 * One selected option: the single description of a selection every
 * presentation of it reads -- the chips, the comma-joined text, and any custom
 * content a consumer renders per selection.
 */
interface SelectedItem {
  key: string;
  textValue: string;

  /**
   * The entry of `@items` this selection came from, so a consumer can reach
   * their own object and not just its key and label.
   *
   * Undefined when the option was written out in block form rather than
   * rendered from `@items`: there is no collection entry behind it.
   */
  item?: unknown;
}

/**
 * What the `:selectedItem` block is handed for one selected option.
 *
 * Deliberately the same `{ item, key, label }` shape the `:item` block yields,
 * so markup can move between the two blocks without being renamed. It is the
 * public face of {@link SelectedItem}: `label` is that projection's
 * `textValue`.
 */
interface SelectedItemBlockArg<T = unknown> {
  /**
   * The entry of `@items` this selection came from.
   *
   * Undefined for an option written out in block form rather than rendered
   * from `@items` -- there is no collection entry behind it, so only `key` and
   * `label` are available there.
   */
  item?: T;

  key: string;

  /** The option's text, i.e. what would be rendered without this block. */
  label: string;
}

/**
 * Appearance options forwarded to the {@link Chip} rendered for each selected
 * option in multiple selection mode. Derived from {@link ChipSignature} so the
 * two can never drift apart; see {@link MultipleSelectArgs.chip} for the
 * Select-specific defaults applied on top of Chip's own.
 */
interface SelectChipOptions extends Pick<
  ChipSignature['Args'],
  'radius' | 'withDot'
> {
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
   *
   * The default implementation ranks by relevance, so the closest match is
   * listed first rather than whichever match came first in `@items`.
   *
   * @param itemValue - The value of an item in the dropdown.
   * @param filterValue - The user's input in the filter/search box.
   * @returns A number to rank (higher first, `0` means no match) or a boolean
   * to filter only, preserving the order of `@items`.
   */
  filter?: FilterFn;

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
   *
   * This option deliberately overrides `allowEmpty`: that argument governs
   * deselecting an *option* (the listbox and the chips both refuse to remove
   * the last one without it), while this is a separate affordance you opt into
   * for exactly the purpose of emptying the field. Since `allowEmpty` defaults
   * to false, honouring it here would render the button dead by default.
   *
   * No clear button is rendered on a disabled Select, or with nothing selected.
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
   * Callback fired when focus leaves the Select.
   *
   * "Leaves the Select" means the whole control: the field *and* its dropdown,
   * which is rendered outside the field in the DOM. Moving focus between them
   * -- which is what clicking an option does -- is not a blur, so this does not
   * fire while the user is picking options, in either selection mode. It fires
   * once, when focus lands somewhere outside the control (or nowhere, with the
   * dropdown closed).
   *
   * This is what `Field` drives blur validation from.
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

    /**
     * Custom content for each *selected* option, in place of its plain text.
     *
     * Renders wherever the selection is drawn as markup: inside the
     * single-mode trigger, inside each chip in multiple mode (the chip chrome,
     * `@chip` options and close button are kept), and once per selection --
     * comma-separated -- under `@selectedItemsDisplay="text"`.
     *
     * **Not** inside a filterable trigger: that is an `<input>`, which cannot
     * hold markup, so a filterable Select still shows the selection as plain
     * text there. The chips beside the input do use the block.
     *
     * Yields the same `{ item, key, label }` the `:item` block does, so the
     * same markup works in both. `item` is undefined for options written in
     * block form rather than rendered from `@items`.
     *
     * Because a block rendering only graphics would otherwise leave the
     * single-mode trigger with no accessible name, supplying this block also
     * gives that (button) trigger an `aria-label` composed from the field
     * label and the selected options' text. That name replaces what the block
     * renders, so a block whose visible text is not the option's `label`
     * should carry the label too, or set `@label`/`@placeholder` to the
     * wording that is visible -- see the guide.
     *
     * @example
     * ```gts
     * <Select @items={{this.users}} as |s|>
     *   <:selectedItem as |selected|>
     *     <Avatar @src={{selected.item.avatar}} />
     *     {{selected.label}}
     *   </:selectedItem>
     * </Select>
     * ```
     */
    selectedItem: [SelectedItemBlockArg<T>];
  };
}

/**
 * The resolved Tailwind Variants slot functions for the Select, as produced by
 * `useStyles().select(...)`. Passed down to the pieces of the field so every
 * one of them styles itself from the same `tv()` call.
 */
type SelectClasses = ReturnType<ReturnType<typeof useStyles>['select']>;

/**
 * {@link SelectChipOptions} with every Select-specific default already applied,
 * so the chips do not have to restate them.
 */
interface ResolvedSelectChipOptions {
  appearance: NonNullable<SelectChipOptions['appearance']>;
  intent: NonNullable<SelectChipOptions['intent']>;
  size: NonNullable<SelectChipOptions['size']>;
  radius: SelectChipOptions['radius'];
  withDot: boolean;
}

export {
  type SelectClasses,
  type ResolvedSelectChipOptions,
  type SelectedItem,
  type SelectedItemBlockArg,
  type SelectChipOptions,
  type BaseSelectArgs,
  type ExplicitSingleSelectArgs,
  type DefaultSingleSelectArgs,
  type MultipleSelectArgs,
  type SelectArgs,
  type SelectSignature
};
