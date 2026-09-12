import type { TOC } from '@ember/component/template-only';
import { on } from '@ember/modifier';
import type { ModifierLike } from '@glint/template';
import type { SlotsToClasses, DatePickerSlots } from '@frontile/theme';
import type { DatePickerClasses } from './types';

interface DatePickerTriggerSignature {
  Args: {
    /** Records the element, for focus restoration and blur tracking. */
    triggerRef: ModifierLike<{ Element: HTMLButtonElement }>;

    /** The popover's `trigger` modifier: what opens the calendar. */
    trigger: ModifierLike<{ Element: HTMLElement }>;

    id?: string;
    placeholder?: string;
    formatted: string;
    isEmpty: boolean;
    isDisabled?: boolean;
    isInvalid?: boolean;
    hasCustomContent: boolean;

    /**
     * Names the trigger when a `:value` block owns its content — that block
     * may render nothing readable at all, which would leave an unnamed button.
     */
    accessibleName: string;

    classes: DatePickerClasses;
    userClasses?: SlotsToClasses<DatePickerSlots>;
    onFocusOut: (event: FocusEvent) => void;
  };
  Blocks: { value: [] };
  Element: HTMLButtonElement;
}

const DatePickerTrigger: TOC<DatePickerTriggerSignature> = <template>
  <button
    type="button"
    id={{@id}}
    {{@trigger}}
    {{@triggerRef}}
    disabled={{@isDisabled}}
    data-part="input"
    data-invalid={{if @isInvalid "true" "false"}}
    data-disabled={{if @isDisabled "true" "false"}}
    aria-label={{if @hasCustomContent @accessibleName}}
    aria-haspopup="dialog"
    class={{@classes.input class=@userClasses.input}}
    {{on "focusout" @onFocusOut}}
    ...attributes
  >
    {{#if @hasCustomContent}}
      {{yield to="value"}}
    {{else if @isEmpty}}
      <span
        data-part="placeholder"
        class={{@classes.placeholder class=@userClasses.placeholder}}
      >{{@placeholder}}</span>
    {{else}}
      {{@formatted}}
    {{/if}}
  </button>
</template>;

export { DatePickerTrigger, type DatePickerTriggerSignature };
export default DatePickerTrigger;
