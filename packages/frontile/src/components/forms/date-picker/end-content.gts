import type { TOC } from '@ember/component/template-only';
import { concat } from '@ember/helper';
import type { ModifierLike } from '@glint/template';
import type { SlotsToClasses, DatePickerSlots } from '@frontile/theme';
import type { DatePickerClasses } from './types';
import { CloseButton } from '../../buttons/close-button';
import { IconCalendar } from '../../../-private/icons';

interface DatePickerEndContentSignature {
  Args: {
    classes: DatePickerClasses;
    userClasses?: SlotsToClasses<DatePickerSlots>;
    isClearable: boolean;
    onClear: () => void;

    /**
     * Whether the field is segmented. There is no button trigger on that path,
     * so the calendar icon becomes the button that opens the popover -- the
     * one thing a segmented field cannot do by clicking the value itself,
     * because clicking a segment has to put the caret in it.
     */
    isEditable?: boolean;

    /**
     * The popover's `trigger` modifier, for the calendar button. Required
     * rather than optional because the calendar button is unreachable without
     * it, and an unapplied modifier is a silent dead control.
     */
    trigger: ModifierLike<{ Element: HTMLElement }>;

    /** Names the calendar button, which has no text of its own. */
    label?: string;
    isDisabled?: boolean;

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
 * The cluster at the end of the field.
 *
 * The segmented field shows the clear button *and* the calendar button: the
 * calendar button is the only way to open the popover on that path, so
 * swapping it out for a clear button would mean a clearable picker holding a
 * value could not be picked from at all.
 *
 * The button-trigger path keeps the either/or it shipped with. There the
 * trigger itself opens the popover and the calendar icon is decorative, so the
 * clear button takes its place with nothing lost.
 *
 * Pointer events are off on that path so a click anywhere in the field still
 * reaches the trigger; the clear button opts back in per element, and the
 * segmented field turns them on for the whole cluster.
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
        @variant="soft"
        @size="xs"
        @class={{@classes.clearButton class=@userClasses.clearButton}}
        data-part="clear-button"
        @onPress={{@onClear}}
      />
    {{/if}}

    {{#if @isEditable}}
      <button
        type="button"
        data-part="calendar-button"
        aria-haspopup="dialog"
        aria-label={{if @label (concat "Choose date, " @label) "Choose date"}}
        disabled={{@isDisabled}}
        class={{@classes.calendarButton class=@userClasses.calendarButton}}
        {{@trigger}}
      >
        <IconCalendar
          data-part="icon"
          class={{@classes.icon class=@userClasses.icon}}
        />
      </button>
    {{else}}
      {{! On the button-trigger path the icon is decorative and the clear
          button takes its place, so it only renders when there is no clear
          button to show. }}
      {{#unless @isClearable}}
        <IconCalendar
          data-part="icon"
          class={{@classes.icon class=@userClasses.icon}}
        />
      {{/unless}}
    {{/if}}
  </div>
</template>;

export { DatePickerEndContent, type DatePickerEndContentSignature };
