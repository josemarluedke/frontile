import type {
  ClassValue,
  DateInputSlots,
  SlotsToClasses,
  useStyles
} from '@frontile/theme';
import type { FormControlSharedArgs } from '../form-control';

/** The resolved Tailwind Variants slot functions for this component. */
type DateInputClasses = ReturnType<ReturnType<typeof useStyles>['dateInput']>;

/** One resolved Tailwind Variants slot function, called as `slot(class=...)`. */
type SegmentSlotFn = (props?: { class?: ClassValue }) => string;

/**
 * The slots `SegmentGroup` renders, named structurally rather than by recipe.
 * `DateInput` hands it `useStyles().dateInput(...)` and `DatePicker` hands it
 * `useStyles().datePicker(...)`: two separate `tv()` calls, because tv() loses
 * slot types across a two-level `extend` and so neither recipe can extend the
 * other. Naming either one here would make the other a type error, so the
 * group asks only for the three slots it actually uses -- which both recipes
 * have.
 */
interface SegmentGroupClasses {
  group: SegmentSlotFn;
  segment: SegmentSlotFn;
  literal: SegmentSlotFn;
}

/** The consumer overrides for those same three slots. */
type SegmentGroupUserClasses = SlotsToClasses<'group' | 'segment' | 'literal'>;

/**
 * The editable units. The time ones appear only under an `hour` or `minute`
 * {@link Granularity}; `dayPeriod` (AM/PM) only on a 12-hour cycle.
 */
type SegmentType = 'year' | 'month' | 'day' | 'hour' | 'minute' | 'dayPeriod';

/** The smallest unit a field edits. `day` has no time segments at all. */
type Granularity = 'day' | 'hour' | 'minute';

/**
 * How the hour segment counts, as `Intl` resolves it: `h11` runs 0-11 and
 * `h12` 1-12 (both with AM/PM), `h23` runs 0-23 and `h24` 1-24.
 */
type HourCycle = 'h11' | 'h12' | 'h23' | 'h24';

/** What {@link buildParts} adds to the date segments. */
interface TimeOptions {
  /** @defaultValue 'day' */
  granularity?: Granularity;
  /** Forces a 12- or 24-hour clock. @defaultValue the locale's */
  hourCycle?: 12 | 24;
}

interface Segment {
  kind: 'segment';
  type: SegmentType;
  /** `null` until the user has entered something. */
  value: number | null;
  min: number;
  max: number;
  /**
   * Digits typed into this segment so far. Distinct from `value` because
   * typing `0` must show `00` and wait, which no number can represent.
   */
  buffer: string;
  /**
   * Whether `value` is the user's finished answer for this segment rather than
   * a number they are still typing through. A year typed digit by digit passes
   * through 2, 20 and 202 on its way to 2026, and none of those are a year
   * anybody meant -- so an uncommitted segment composes no date at all. A
   * segment commits when it can take no further digit, or when focus leaves it
   * (which is what turns a typed `26` into 2026).
   */
  isCommitted: boolean;
  /** How many digits the segment shows when filled: 2, or 4 for a year. */
  width: number;
  /** Rendered when `value` is null: 'mm', 'dd', 'yyyy'. */
  placeholder: string;
  /**
   * A textual segment's names, indexed by `value`: the locale's AM and PM for
   * `dayPeriod`. A segment with labels is typed by letter, not by digit, and
   * shows its label rather than its number.
   */
  labels?: string[];
  /** The hour segment's cycle, which its bounds and its value depend on. */
  hourCycle?: HourCycle;
}

interface LiteralPart {
  kind: 'literal';
  text: string;
}

type Part = Segment | LiteralPart;

/**
 * Every text the field renders itself. Override any of them with `@labels`,
 * e.g. to translate them; the rest keep these English defaults. The
 * segments' names are `@segmentLabels`.
 */
interface DateInputLabels {
  /** Accessible name of the clear button (`@isClearable`). */
  clear: string;
}

interface DateInputArgs extends FormControlSharedArgs {
  /** The unique identifier for the control. */
  id?: string;

  /**
   * The value submits under this name as `yyyy-MM-dd`, or as the local
   * `yyyy-MM-ddTHH:mm` under an `hour` or `minute` granularity.
   */
  name?: string;

  /**
   * A `Date`, or the same `yyyy-MM-dd` string this component writes to its
   * hidden input.
   *
   * The field keeps its own segments and syncs *from* this argument: setting
   * it replaces what is displayed, while typing updates the field immediately
   * rather than waiting for `@value` to come back. `undefined` is ignored,
   * which is why a `<form.Field>`-bound input still honors `@defaultValue`
   * before form data exists.
   */
  value?: Date | string | null;

  /**
   * The smallest unit the field edits. `hour` and `minute` add time segments
   * after the date ones, in the locale's order.
   *
   * @defaultValue 'day'
   */
  granularity?: Granularity;

  /**
   * Forces a 12- or 24-hour clock. A 12-hour one adds an AM/PM segment.
   *
   * @defaultValue the locale's
   */
  hourCycle?: 12 | 24;

  /** Seeds the value before any `@value` is supplied. */
  defaultValue?: Date | string | null;

  /**
   * Fires with the composed `Date`, or `null` once a complete value is no
   * longer complete. A partially typed date composes nothing and reports
   * nothing.
   */
  onChange?: (value: Date | null) => void;

  /** Fires when focus leaves the field, not when it moves between segments. */
  onBlur?: () => void;

  /** @defaultValue navigator.language */
  locale?: string;

  /**
   * Decides which segments appear, their order, and their literals.
   *
   * @defaultValue { year: 'numeric', month: '2-digit', day: '2-digit' }
   */
  formatOptions?: Intl.DateTimeFormatOptions;

  /** Where ArrowUp on an empty segment starts. @defaultValue today */
  placeholderValue?: Date;

  /** The earliest allowed date. A value before it marks the field invalid. */
  minValue?: Date;

  /** The latest allowed date. A value after it marks the field invalid. */
  maxValue?: Date;

  /**
   * Marks individual dates disallowed. A value it returns `true` for marks
   * the field invalid. Like `@minValue` and `@maxValue`, it never blocks a
   * keystroke.
   */
  isDateUnavailable?: (date: Date) => boolean;

  /**
   * Whether the value can be read and copied but not edited. The segments
   * stay focusable and navigable.
   *
   * @defaultValue false
   */
  isReadOnly?: boolean;

  /**
   * Whether a clear button appears at the end of the field once any segment
   * holds a digit. Never rendered on a disabled or read-only field.
   *
   * @defaultValue false
   */
  isClearable?: boolean;

  /**
   * The size of the field. Matches `Input`'s and `Select`'s `@inputSize`.
   *
   * @defaultValue 'md'
   */
  inputSize?: 'sm' | 'md' | 'lg';

  /**
   * The accessible names of the segments, for localizing them.
   *
   * @defaultValue { year: 'year', month: 'month', day: 'day', hour: 'hour', minute: 'minute', dayPeriod: 'AM/PM' }
   */
  segmentLabels?: Partial<Record<SegmentType, string>>;

  /**
   * Replaces any of the texts the field renders, e.g. to translate them.
   * Anything left out keeps its English default; see `DateInputLabels`.
   */
  labels?: Partial<DateInputLabels>;

  /** Per-slot class overrides. */
  classes?: SlotsToClasses<DateInputSlots>;
}

export type {
  DateInputLabels,
  SegmentType,
  Granularity,
  HourCycle,
  TimeOptions,
  SegmentSlotFn,
  SegmentGroupClasses,
  SegmentGroupUserClasses,
  Segment,
  LiteralPart,
  Part,
  DateInputArgs,
  DateInputClasses
};
