import { on } from '@ember/modifier';
import type { TOC } from '@ember/component/template-only';
import type { ModifierLike } from '@glint/template';
import type { SlotsToClasses, SelectSlots } from '@frontile/theme';
import { SelectedText } from './selected-items';
import type { SelectClasses, SelectedItem } from './types';

const and = (a: unknown, b: unknown) => Boolean(a) && Boolean(b);
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
     * Names the *control* while chips are shown. In chips mode the trigger
     * renders no text of its own, so without this the combobox would be
     * announced unnamed.
     */
    accessibleName: string;

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
      aria-label={{if @showChips @accessibleName}}
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
          <SelectedText @items={{@items}} />
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
