import Component from '@glimmer/component';
import { useStyles } from '@frontile/theme';
import { FormControl } from '../form-control';
import { DatePickerTrigger } from './trigger';
import { ref } from '../../../utils/ref';
import { formatValue, isEmptyValue, parseDate, parseRange } from './value';
import type {
  CalendarMode,
  CalendarValue
} from '../../collections/calendar/types';
import type { DatePickerArgs, DatePickerValueBlockArg } from './types';

interface DatePickerSignature<M extends CalendarMode = 'single'> {
  Args: DatePickerArgs<M>;
  Blocks: {
    value: [DatePickerValueBlockArg<M>];
  };
  Element: HTMLDivElement;
}

/**
 * A date field: a button trigger showing the formatted value, and a calendar
 * in a popover. `@mode="range"` switches both the calendar and the value shape
 * to a `{ start, end }` range.
 */
class DatePicker<M extends CalendarMode = 'single'> extends Component<
  DatePickerSignature<M>
> {
  triggerRef = ref<HTMLButtonElement>();

  get mode(): CalendarMode {
    return (this.args as { mode?: CalendarMode }).mode ?? 'single';
  }

  get locale(): string {
    return this.args.locale ?? navigator.language;
  }

  /**
   * The value as `Date`s. Consumers may pass `yyyy-MM-dd` strings — `Field`
   * always does, since form data is strings — so every read of the value goes
   * through here rather than touching `@value` directly.
   */
  get value(): CalendarValue<M> | null {
    const raw = (this.args as { value?: unknown }).value;

    if (this.mode === 'range') {
      return parseRange(raw as never) as CalendarValue<M> | null;
    }
    return parseDate(raw as never) as CalendarValue<M> | null;
  }

  get formatted(): string {
    return formatValue(this.value, this.locale, this.args.formatOptions);
  }

  get isEmpty(): boolean {
    return isEmptyValue(this.value);
  }

  get valueBlockArg(): DatePickerValueBlockArg<M> {
    return {
      value: this.value,
      formatted: this.formatted,
      isEmpty: this.isEmpty
    };
  }

  /**
   * Names the trigger when a `:value` block owns its content. Falls back to
   * the formatted value alone rather than prefixing a hardcoded English
   * string when there is no `@label`.
   */
  get accessibleName(): string {
    return [this.args.label, this.formatted].filter(Boolean).join(', ');
  }

  handleFocusOut = (): void => {
    // Replaced by ControlBlurTracker in Task 7, once there is a popover that
    // focus can legitimately move into.
    this.args.onBlur?.();
  };

  get classes() {
    const { datePicker } = useStyles();
    return datePicker({ size: this.args.inputSize });
  }

  <template>
    <div
      class={{this.classes.base class=@classes.base}}
      data-component="date-picker"
      data-part="base"
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
        @isDisabled={{@isDisabled}}
        as |c|
      >
        <div
          class={{this.classes.innerContainer class=@classes.innerContainer}}
          data-part="inner-container"
        >
          <DatePickerTrigger
            @id={{c.id}}
            @placeholder={{@placeholder}}
            @formatted={{this.formatted}}
            @isEmpty={{this.isEmpty}}
            @isDisabled={{@isDisabled}}
            @isInvalid={{c.isInvalid}}
            @hasCustomContent={{has-block "value"}}
            @accessibleName={{this.accessibleName}}
            @triggerRef={{this.triggerRef.setup}}
            @classes={{this.classes}}
            @userClasses={{@classes}}
            @onFocusOut={{this.handleFocusOut}}
          >
            <:value>
              {{#if (has-block "value")}}
                {{yield this.valueBlockArg to="value"}}
              {{/if}}
            </:value>
          </DatePickerTrigger>
        </div>
      </FormControl>
    </div>
  </template>
}

export { DatePicker, type DatePickerSignature };
export default DatePicker;
