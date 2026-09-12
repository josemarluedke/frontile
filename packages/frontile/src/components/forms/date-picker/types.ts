import type {
  DatePickerSlots,
  DatePickerVariants,
  SlotsToClasses,
  useStyles
} from '@frontile/theme';
import type {
  PopoverSignature,
  ContentSignature
} from '../../overlays/popover';
import type { CalendarArgs } from '../../collections/calendar/calendar';
import type {
  CalendarMode,
  CalendarValue,
  DateRange,
  WeekDay
} from '../../collections/calendar/types';
import type { FormControlSharedArgs } from '../form-control';
import type { DatePickerInput, DatePickerRangeInput } from './value';

interface BaseDatePickerArgs
  extends
    Pick<
      CalendarArgs,
      | 'minValue'
      | 'maxValue'
      | 'isDateUnavailable'
      | 'locale'
      | 'weekStartsOn'
      | 'visibleMonths'
      | 'captionLayout'
      | 'fixedWeeks'
      | 'showOutsideDays'
      | 'isReadOnly'
    >,
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
      ContentSignature['Args'],
      | 'renderInPlace'
      | 'target'
      | 'closeOnOutsideClick'
      | 'closeOnEscapeKey'
      | 'transitionDuration'
      | 'disableTransitions'
    >,
    FormControlSharedArgs {
  /** The unique identifier for the control. */
  id?: string;

  /** The name the value submits under. See the hidden inputs in date-picker.gts. */
  name?: string;

  /** Text shown in the trigger when there is no value. */
  placeholder?: string;

  /**
   * How the value is rendered in the trigger. Localized with `@locale`.
   *
   * @defaultValue { dateStyle: 'medium' }
   */
  formatOptions?: Intl.DateTimeFormatOptions;

  /** The size of the field. Matches Select's `@inputSize`. */
  inputSize?: DatePickerVariants['size'];

  /**
   * Whether a clear button replaces the calendar icon when there is a value.
   *
   * @defaultValue false
   */
  isClearable?: boolean;

  /** Fires when focus leaves the trigger *and* the popover. */
  onBlur?: () => void;

  classes?: SlotsToClasses<DatePickerSlots>;
}

interface SingleDatePickerArgs extends BaseDatePickerArgs {
  /** @defaultValue 'single' */
  mode?: 'single' | undefined;
  value?: DatePickerInput | null;
  defaultValue?: DatePickerInput | null;
  onChange?: (value: Date | null) => void;
}

interface RangeDatePickerArgs extends BaseDatePickerArgs {
  mode: 'range';
  value?: DatePickerRangeInput | null;
  defaultValue?: DatePickerRangeInput | null;
  onChange?: (value: DateRange | null) => void;
}

type DatePickerArgs<M extends CalendarMode = 'single'> = M extends 'range'
  ? RangeDatePickerArgs
  : SingleDatePickerArgs;

/**
 * The resolved Tailwind Variants slot functions, as produced by
 * `useStyles().datePicker(...)`. Passed down to the pieces of the field so
 * every one of them styles itself from the same `tv()` call.
 */
type DatePickerClasses = ReturnType<ReturnType<typeof useStyles>['datePicker']>;

/** What the `:value` block receives. */
interface DatePickerValueBlockArg<M extends CalendarMode = 'single'> {
  /** The current value as `Date`s, whatever form it was passed in. */
  value: CalendarValue<M> | null;
  /** The same value as the trigger would render it. */
  formatted: string;
  /** Whether the placeholder would show. An anchored range is not empty. */
  isEmpty: boolean;
}

/**
 * The args the picker would otherwise have handed `Calendar`, so a `:calendar`
 * block can spread them onto its own calendar rather than re-deriving the
 * selection and focus wiring.
 *
 * `labelledBy` is only set when the consumer passed `@id` to the picker
 * themselves. The default `<Calendar>` rendered in the template instead uses
 * the id `FormControl` yields internally (`c.id`), which is generated when
 * `@id` is absent and is not reachable from this getter — so it is always
 * labelled. A consumer rendering their own calendar from this block must pass
 * `@id` to the picker if they want the grid labelled.
 */
interface DatePickerCalendarArgs<M extends CalendarMode = 'single'> {
  mode: CalendarMode;
  value: CalendarValue<M> | null;
  onChange: (value: CalendarValue<M>) => void;
  locale: string;
  weekStartsOn?: WeekDay;
  minValue?: Date;
  maxValue?: Date;
  isDateUnavailable?: (date: Date) => boolean;
  visibleMonths?: number;
  captionLayout?: 'label' | 'dropdown';
  labelledBy?: string;
  autofocus: boolean;
}

/** What the `:footer` block receives. Presets are built from these. */
interface DatePickerFooterArg<M extends CalendarMode = 'single'> {
  /** Sets the value as if the user had picked it, callbacks and all. */
  setValue: (value: CalendarValue<M>) => void;
  /** Closes the popover and returns focus to the trigger. */
  close: () => void;
  value: CalendarValue<M> | null;
  isOpen: boolean;
}

export type {
  DatePickerArgs,
  SingleDatePickerArgs,
  RangeDatePickerArgs,
  DatePickerValueBlockArg,
  DatePickerCalendarArgs,
  DatePickerFooterArg,
  DatePickerClasses
};
