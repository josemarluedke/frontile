import { on } from '@ember/modifier';
import type { TOC } from '@ember/component/template-only';
import type { ModifierLike } from '@glint/template';
import type { SlotsToClasses, SelectSlots } from '@frontile/theme';
import { SelectedText } from './selected-items';
import type {
  SelectClasses,
  SelectedItem,
  SelectedItemBlockArg
} from './types';

const and = (a: unknown, b: unknown) => Boolean(a) && Boolean(b);
const or = (a: unknown, b: unknown) => Boolean(a) || Boolean(b);
const valueUnless = <T,>(condition: unknown, value: T): T | undefined =>
  condition ? undefined : value;

interface SelectTriggerSignature {
  Args: {
    /** Whether the trigger is a filter input rather than a button. */
    isFilterable?: boolean;

    /** The popover's `trigger` modifier: what opens the dropdown. */
    trigger: ModifierLike<{ Element: HTMLElement }>;

    /**
     * Records the trigger element. The field click forwarder and the listbox's
     * keyboard-event host both need the live element.
     */
    triggerRef: ModifierLike<{
      Element: HTMLInputElement | HTMLButtonElement;
    }>;

    isDisabled?: boolean;
    showChips: boolean;

    /**
     * Names the trigger when its own text cannot.
     *
     * In chips mode the trigger renders no text of its own (the chips are its
     * siblings and are read separately), so without this the combobox would be
     * announced unnamed. The same is true whenever `@hasCustomContent` is set:
     * the block may render nothing readable at all.
     */
    accessibleName: string;

    /**
     * Whether the consumer supplied a `:selectedItem` block, i.e. whether the
     * text inside the trigger is theirs rather than the option's label.
     *
     * Two things hang off this: the `<button>` trigger stops trusting its own
     * text content for its accessible name, and {@link SelectedText} switches
     * from the joined string to a per-selection loop. The filterable
     * `<input>` trigger ignores it -- the block never renders there, so the
     * input's own value still names it.
     */
    hasCustomContent?: boolean;

    placeholder?: string;
    hasSelection: boolean;
    hasStartContent: boolean;

    classes: SelectClasses;
    userClasses?: SlotsToClasses<SelectSlots>;

    /** The selection, for the text presentation inside a button trigger. */
    items: SelectedItem[];

    /** Current value of the filter input. */
    filterValue: string;
    onFilterInput: (event: Event) => void;
    onFilterKeydown: (event: KeyboardEvent) => void;
    onKeydown: (event: KeyboardEvent) => void;
    onBlur: () => void;
  };
  Blocks: {
    /**
     * Content for one selected option, forwarded straight through to
     * {@link SelectedText}. Always supplied by the Select -- a block cannot be
     * passed conditionally -- so `@hasCustomContent` is what says whether it
     * holds the consumer's markup or the plain-label fallback.
     */
    selectedItem: [SelectedItemBlockArg<never>];
  };
}

/**
 * The Select's trigger: a filter `<input>` when `@isFilterable`, otherwise a
 * `<button>`.
 *
 * Both carry `data-component="select-trigger"` and the same `input` slot, whose
 * `hasChips` variant is what gives the trigger a hittable box when it has to
 * share a flex line with the chips instead of being the whole field.
 */
const SelectTrigger: TOC<SelectTriggerSignature> = <template>
  {{#if @isFilterable}}
    {{! The filterable trigger is an input: the selectedItem block cannot
    render here, so the input always has its own value as its accessible text.
    Naming it from the selection as well would duplicate that value and make
    the combobox name change as the user types, so only chips mode, where the
    input shows nothing of the selection, names it. }}
    <input
      type="text"
      {{@trigger}}
      {{@triggerRef}}
      data-test-id="trigger"
      data-component="select-trigger"
      disabled={{@isDisabled}}
      aria-label={{if @showChips @accessibleName}}
      placeholder={{valueUnless (and @showChips @hasSelection) @placeholder}}
      class={{@classes.input
        class=@userClasses.input
        hasStartContent=@hasStartContent
        hasEndContent=true
        hasChips=@showChips
      }}
      value={{@filterValue}}
      {{on "input" @onFilterInput}}
      {{on "keydown" @onFilterKeydown}}
      {{on "blur" @onBlur}}
    />
  {{else}}
    <button
      type="button"
      {{@trigger}}
      {{@triggerRef}}
      data-test-id="trigger"
      data-component="select-trigger"
      disabled={{@isDisabled}}
      aria-label={{if (or @showChips @hasCustomContent) @accessibleName}}
      class={{@classes.input
        class=@userClasses.input
        hasStartContent=@hasStartContent
        hasEndContent=true
        hasChips=@showChips
      }}
      {{on "keydown" @onKeydown}}
      {{on "blur" @onBlur}}
    >
      {{#if @hasSelection}}
        {{#unless @showChips}}
          <SelectedText
            @items={{@items}}
            @hasCustomContent={{@hasCustomContent}}
          >
            <:item as |selected|>{{yield selected to="selectedItem"}}</:item>
          </SelectedText>
        {{/unless}}
      {{else}}
        <span class={{@classes.placeholder class=@userClasses.placeholder}}>
          {{#if @placeholder}}{{@placeholder}}{{else}}&nbsp;{{/if}}
        </span>
      {{/if}}
    </button>
  {{/if}}
</template>;

export { SelectTrigger, type SelectTriggerSignature };
export default SelectTrigger;
