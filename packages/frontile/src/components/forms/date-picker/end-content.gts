import type { TOC } from '@ember/component/template-only';
import type { SlotsToClasses, DatePickerSlots } from '@frontile/theme';
import type { DatePickerClasses } from './types';
import { CloseButton } from '../../buttons/close-button';
import { IconCalendar } from '../icons';

interface DatePickerEndContentSignature {
  Args: {
    classes: DatePickerClasses;
    userClasses?: SlotsToClasses<DatePickerSlots>;
    isClearable: boolean;
    onClear: () => void;

    /**
     * Defaults to `none` so clicks fall through to the trigger; content that
     * needs its own events opts back in per element.
     *
     * The theme declares no default for this variant, so leaving it unset
     * yields neither class and the browser default (`auto`) wins -- which
     * makes the cluster sit over the right edge of the field and swallow
     * clicks on the calendar icon.
     */
    endContentPointerEvents?: 'none' | 'auto';
  };
  Element: HTMLDivElement;
}

/**
 * The cluster at the end of the field: exactly one of the clear button or the
 * calendar icon. Pointer events are off so a click anywhere in the field still
 * reaches the trigger; the clear button opts back in.
 */
const DatePickerEndContent: TOC<DatePickerEndContentSignature> = <template>
  <div
    data-part="end-content"
    class={{@classes.endContent
      class=@userClasses.endContent
      endContentPointerEvents=(if
        @endContentPointerEvents @endContentPointerEvents "none"
      )
    }}
    ...attributes
  >
    {{#if @isClearable}}
      <CloseButton
        @title="Clear"
        @variant="subtle"
        @size="xs"
        @class={{@classes.clearButton class=@userClasses.clearButton}}
        data-part="clear-button"
        @onPress={{@onClear}}
      />
    {{else}}
      <IconCalendar
        data-part="icon"
        class={{@classes.icon class=@userClasses.icon}}
      />
    {{/if}}
  </div>
</template>;

export { DatePickerEndContent, type DatePickerEndContentSignature };
