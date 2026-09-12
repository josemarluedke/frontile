import { toDayKey, fromDayKey } from '../../collections/calendar/utils';
import type {
  CalendarMode,
  CalendarValue,
  DateRange
} from '../../collections/calendar/types';

/**
 * A date as accepted from a consumer: a `Date`, or the same `yyyy-MM-dd`
 * string this component writes to its hidden inputs.
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

/** The value as it is submitted: `yyyy-MM-dd`, from local calendar fields. */
function toWire(date: Date | null | undefined): string {
  if (!date || Number.isNaN(date.getTime())) return '';
  return toDayKey(date);
}

const DEFAULT_FORMAT: Intl.DateTimeFormatOptions = { dateStyle: 'medium' };

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
  formatDate,
  formatValue,
  isEmptyValue,
  type DatePickerInput,
  type DatePickerRangeInput
};
