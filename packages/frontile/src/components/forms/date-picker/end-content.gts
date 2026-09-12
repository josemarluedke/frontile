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
    class={{@classes.endContent class=@userClasses.endContent}}
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
