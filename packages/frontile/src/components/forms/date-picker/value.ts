import { toDayKey, fromDayKey } from '../../collections/calendar/utils';
import type { Granularity } from '../date-input/types';
import type {
  CalendarMode,
  CalendarValue,
  DateRange
} from '../../collections/calendar/types';

/**
 * A date as accepted from a consumer: a `Date`, or the same `yyyy-MM-dd` (or,
 * with a time, local `yyyy-MM-ddTHH:mm`) string this component writes to its
 * hidden inputs.
 *
 * Strings are accepted because `Field` feeds form data — which is always
 * strings — straight back into `@value`. It also means a value hydrated from
 * JSON or an API needs no adapter. Output is always a `Date`: strings are an
 * accepted input, never an output mode.
 */
type DatePickerInput = Date | string;

interface DatePickerRangeInput {
  start: DatePickerInput;
  end: DatePickerInput | null;
}

const ISO_DAY = /^\d{4}-\d{2}-\d{2}$/;

/**
 * A day with a local wall-clock time, as `<input type="datetime-local">`
 * writes it: `T` or a space between, seconds optional. No offset -- a time
 * here is the user's own, never converted.
 */
const ISO_DATE_TIME =
  /^(\d{4}-\d{2}-\d{2})[T ](\d{2}):(\d{2})(?::(\d{2})(?:\.\d+)?)?$/;

const pad = (n: number): string => String(n).padStart(2, '0');

/**
 * Normalizes one end of a value to a `Date`, or `null` when there is nothing
 * usable there.
 *
 * An `Invalid Date` is treated as absent rather than passed along: it would
 * otherwise reach `Intl.DateTimeFormat` and render the literal text
 * "Invalid Date" inside the trigger.
 */
function parseDate(value: DatePickerInput | null | undefined): Date | null {
  if (value === null || value === undefined || value === '') return null;

  if (value instanceof Date) {
    return Number.isNaN(value.getTime()) ? null : value;
  }

  const withTime = ISO_DATE_TIME.exec(value);
  if (withTime?.[1]) {
    const [, , hours, minutes, seconds] = withTime;
    const parsed = fromDayKey(withTime[1]);
    parsed.setHours(Number(hours), Number(minutes), Number(seconds ?? 0));
    return Number.isNaN(parsed.getTime()) ? null : parsed;
  }

  // `fromDayKey` splits on `-` and would happily turn anything into a Date of
  // NaN parts, so the shape is checked before it is trusted.
  if (!ISO_DAY.test(value)) return null;

  const parsed = fromDayKey(value);
  return Number.isNaN(parsed.getTime()) ? null : parsed;
}

/**
 * Normalizes a range. A `null` end is preserved rather than collapsed — that
 * is a range mid-selection, with its anchor set and the second click pending,
 * and the trigger must still show the anchor.
 */
function parseRange(
  value: DatePickerRangeInput | null | undefined
): DateRange | null {
  if (!value) return null;

  const start = parseDate(value.start);
  // Without a usable start there is no range at all: a `{ start: null }` would
  // not satisfy `DateRange`, whose start is non-nullable.
  if (!start) return null;

  return { start, end: parseDate(value.end) };
}

/**
 * The value as it is submitted: `yyyy-MM-dd` from local calendar fields, and
 * under an `hour` or `minute` granularity the local `yyyy-MM-ddTHH:mm` that
 * `datetime-local` uses too.
 */
function toWire(
  date: Date | null | undefined,
  granularity: Granularity = 'day'
): string {
  if (!date || Number.isNaN(date.getTime())) return '';
  const day = toDayKey(date);
  if (granularity === 'day') return day;
  return `${day}T${pad(date.getHours())}:${pad(date.getMinutes())}`;
}

/**
 * Copies the wall-clock time of `from` onto the day of `day`. Picking a day in
 * the calendar keeps the time the field already holds.
 */
function withTimeOf(day: Date, from: { hours: number; minutes: number }): Date {
  const next = new Date(day);
  next.setHours(from.hours, from.minutes, 0, 0);
  return next;
}

const DEFAULT_FORMAT: Intl.DateTimeFormatOptions = { dateStyle: 'medium' };

/** The button trigger's default once the value carries a time. */
const DEFAULT_TIME_FORMAT: Intl.DateTimeFormatOptions = {
  dateStyle: 'medium',
  timeStyle: 'short'
};

function formatDate(
  date: Date,
  locale: string,
  options?: Intl.DateTimeFormatOptions
): string {
  return new Intl.DateTimeFormat(locale, options ?? DEFAULT_FORMAT).format(
    date
  );
}

function isRange(value: unknown): value is DateRange {
  return (
    typeof value === 'object' &&
    value !== null &&
    'start' in value &&
    (value as DateRange).start instanceof Date
  );
}

/**
 * The trigger's text for a value in either mode. An en dash (not a hyphen)
 * joins a range, matching how date ranges are set in running text.
 */
function formatValue<M extends CalendarMode>(
  value: CalendarValue<M> | null | undefined,
  locale: string,
  options?: Intl.DateTimeFormatOptions
): string {
  if (!value) return '';

  if (isRange(value)) {
    const start = formatDate(value.start, locale, options);
    // A half-open range renders as the anchor alone: "Jan 20, 2026 – " would
    // read as an unfinished sentence while the user picks the second end.
    if (!value.end) return start;
    return `${start} – ${formatDate(value.end, locale, options)}`;
  }

  if (value instanceof Date) return formatDate(value, locale, options);

  return '';
}

/**
 * Whether the trigger should show its placeholder. An anchored range is *not*
 * empty — its start is already chosen and must be visible.
 */
function isEmptyValue(value: unknown): boolean {
  if (value === null || value === undefined) return true;
  if (value instanceof Date) return Number.isNaN(value.getTime());
  if (isRange(value)) return false;
  return true;
}

export {
  parseDate,
  parseRange,
  toWire,
  withTimeOf,
  DEFAULT_TIME_FORMAT,
  formatValue,
  isEmptyValue,
  type DatePickerInput,
  type DatePickerRangeInput
};
