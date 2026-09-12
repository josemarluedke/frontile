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
  DateRange
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

export type {
  DatePickerArgs,
  SingleDatePickerArgs,
  RangeDatePickerArgs,
  DatePickerValueBlockArg,
  DatePickerClasses
};
