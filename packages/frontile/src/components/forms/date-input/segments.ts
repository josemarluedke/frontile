import { warn } from '@ember/debug';
import type { Part, Segment, SegmentType } from './types';

/**
 * The format an editable field uses when the consumer supplies none.
 * Deliberately not `{ dateStyle: 'medium' }` -- DatePicker's button default --
 * which renders a month name and has no numeric segment to type into.
 */
const DEFAULT_FORMAT: Intl.DateTimeFormatOptions = {
  year: 'numeric',
  month: '2-digit',
  day: '2-digit'
};

const BOUNDS: Record<
  SegmentType,
  { min: number; max: number; width: number; placeholder: string }
> = {
  // Upper bound for the day is the widest any month gets; `toDate` clamps to
  // the real length of the chosen month, which is not known segment-locally.
  day: { min: 1, max: 31, width: 2, placeholder: 'dd' },
  month: { min: 1, max: 12, width: 2, placeholder: 'mm' },
  year: { min: 1, max: 9999, width: 4, placeholder: 'yyyy' }
};

function isSegment(part: Part): part is Segment {
  return part.kind === 'segment';
}

function emptySegment(type: SegmentType): Segment {
  const { min, max, width, placeholder } = BOUNDS[type];
  return {
    kind: 'segment',
    type,
    value: null,
    min,
    max,
    width,
    placeholder,
    buffer: '',
    isCommitted: false
  };
}

/**
 * Derives the segments and their separators from the locale, so `mm/dd/yyyy`,
 * `dd/mm/yyyy` and `yyyy年mm月dd日` all fall out of `Intl` rather than being
 * hardcoded.
 *
 * A format producing a textual month ('Jan') has no editable numeric
 * representation, so that part becomes a numeric month segment anyway. The
 * component warns; this function stays pure.
 */
function buildParts(
  locale: string,
  formatOptions: Intl.DateTimeFormatOptions = DEFAULT_FORMAT
): Part[] {
  const formatter = new Intl.DateTimeFormat(locale, formatOptions);
  // A reference date, only ever used to make the formatter emit its parts.
  const parts = formatter.formatToParts(new Date(2026, 0, 20));

  const out: Part[] = [];
  for (const part of parts) {
    if (part.type === 'year' || part.type === 'month' || part.type === 'day') {
      out.push(emptySegment(part.type));
    } else if (part.type === 'literal') {
      out.push({ kind: 'literal', text: part.value });
    }
    // Everything else -- era, weekday, relatedYear -- is dropped: day
    // granularity has no segment for it.
  }

  return out;
}

/**
 * A bare `yy` resolves into the hundred years running from 80 back to 19
 * forward -- so a birth date reaches the past while a card expiry reaches the
 * near future. Three or four digits are a year the user spelled out and are
 * taken literally.
 */
function resolveTwoDigitYear(digits: string, now: Date = new Date()): number {
  const n = Number(digits);
  if (digits.length > 2) return n;

  const currentYear = now.getFullYear();
  const start = currentYear - 80;
  const century = Math.floor(start / 100) * 100;
  const candidate = century + n;
  return candidate < start ? candidate + 100 : candidate;
}

/**
 * The numeric value a buffer represents, or null when it represents none.
 *
 * A buffer is always its literal number, including a year's: `26` is the year
 * 26 here, not 2026. The two-digit window is applied once, by `commitSegment`,
 * at the moment the user is finished with the segment -- applying it per
 * keystroke would make the first digit of `2026` compose the year 2002 and
 * push a date nobody typed out to `@onChange` and the calendar.
 */
function bufferValue(segment: Segment, buffer: string): number | null {
  if (buffer === '') return null;
  const n = Number(buffer);
  return n < segment.min ? null : n;
}

/**
 * Appends one typed digit.
 *
 * `isFull` is the signal to advance focus. It is true when the segment cannot
 * take another digit -- either it has reached its width, or any further digit
 * would exceed `max`. That is what makes typing `5` into a month jump straight
 * to the day, while typing `1` waits to see whether `12` is coming.
 */
function applyDigit(
  segment: Segment,
  digit: string
): { segment: Segment; isFull: boolean } {
  if (!/^\d$/.test(digit)) return { segment, isFull: false };

  let buffer = segment.buffer + digit;
  let value = bufferValue(segment, buffer);

  // The accumulated digits no longer fit the segment, so this keystroke starts
  // a fresh entry instead of being discarded. Width is checked as well as the
  // bound because leading zeros pile up without ever exceeding it: `00` then
  // `1` in a month is the buffer `001`, which is still only January and would
  // render three characters wide in a two-character segment.
  if (
    buffer.length > segment.width ||
    (value !== null && value > segment.max)
  ) {
    buffer = digit;
    value = bufferValue(segment, buffer);
    // A single digit that still overflows cannot be entered at all.
    if (value !== null && value > segment.max)
      return { segment, isFull: false };
  }

  const atWidth = buffer.length >= segment.width;
  // Would any digit 0-9 appended here still fit? If not, there is nothing
  // left to wait for. `bufferValue` returning null (below `min`) behaves like
  // 0 here, same as the original non-null-assertion-based comparison did.
  const extended = bufferValue(segment, buffer + '0') ?? 0;
  const isFull = atWidth || extended > segment.max;

  // A segment that can take no further digit is finished, so it commits here
  // rather than waiting for focus to leave.
  const next: Segment = { ...segment, buffer, value, isCommitted: isFull };

  return { segment: next, isFull };
}

/**
 * Marks a segment as the user's finished answer, expanding a one- or
 * two-digit year through the sliding window on the way: typing `26` and
 * moving on means 2026, while `0026` typed in full means the year 26.
 *
 * An empty segment has nothing to commit and stays uncommitted, so leaving a
 * blank field does not invent a value for it.
 */
function commitSegment(segment: Segment): Segment {
  if (segment.value === null) return segment;

  if (
    segment.type === 'year' &&
    segment.buffer.length > 0 &&
    segment.buffer.length <= 2
  ) {
    return withValue(segment, resolveTwoDigitYear(segment.buffer));
  }

  return { ...segment, isCommitted: true };
}

/**
 * A segment holding `value` as a finished answer.
 *
 * The zero-padded buffer is the paired invariant of `displaySegment`, which
 * reads the buffer back out -- so every path that sets a value goes through
 * here rather than restating the padding and risking the two drifting.
 */
function withValue(segment: Segment, value: number): Segment {
  return {
    ...segment,
    value,
    buffer: String(value).padStart(segment.width, '0'),
    isCommitted: true
  };
}

/** Clears both the value and the digits behind it. */
function clearSegment(segment: Segment): Segment {
  return { ...segment, value: null, buffer: '', isCommitted: false };
}

/** Drops the last digit typed, for Backspace. */
function deleteDigit(segment: Segment): Segment {
  const buffer = segment.buffer.slice(0, -1);
  // Un-commits: a year being backspaced through is being typed again, and the
  // 202 it passes through must not compose a date.
  return {
    ...segment,
    buffer,
    value: bufferValue(segment, buffer),
    isCommitted: false
  };
}

/** The unit of `placeholderValue` this segment seeds from when empty. */
function seedFrom(type: SegmentType, placeholderValue: Date): number {
  if (type === 'year') return placeholderValue.getFullYear();
  if (type === 'month') return placeholderValue.getMonth() + 1;
  return placeholderValue.getDate();
}

/**
 * Arrow and page keys. An empty segment does not step from zero -- it adopts
 * `placeholderValue`, so ArrowUp on a blank year offers this year rather than
 * the year 1.
 */
function step(
  segment: Segment,
  delta: number,
  placeholderValue: Date
): Segment {
  if (segment.value === null) {
    return withValue(segment, seedFrom(segment.type, placeholderValue));
  }

  const span = segment.max - segment.min + 1;
  const offset = segment.value - segment.min + delta;
  // Modulo twice: JavaScript's % keeps the sign of the dividend, so a
  // decrement past the floor would otherwise land on a negative value.
  const wrapped = ((offset % span) + span) % span;

  return withValue(segment, wrapped + segment.min);
}

/**
 * The segment's display text: the digits behind it, or its placeholder when
 * empty. A year still being typed shows exactly what has been typed --
 * `26` on the way to `2026` -- because padding it would claim digits the
 * user has not entered. Every other segment, and a committed year, is padded
 * to its full width.
 *
 * This is the single source of truth for "what does this segment read as
 * right now" -- both the rendered cell text and `formatForClipboard` call
 * it, so a mid-entry copy always matches what is on screen.
 */
function displaySegment(segment: Segment): string {
  if (segment.value === null) return segment.placeholder;

  const digits = segment.buffer;

  return segment.type === 'year' && !segment.isCommitted
    ? digits
    : digits.padStart(segment.width, '0');
}

function findSegment(parts: Part[], type: SegmentType): Segment | undefined {
  return parts.find((p): p is Segment => isSegment(p) && p.type === type);
}

/** Days in a month, via the zeroth day of the next one. */
function daysInMonth(year: number, month: number): number {
  return new Date(year, month, 0).getDate();
}

/** A segment holding a finished value, as opposed to one mid-entry. */
function isReady(
  segment: Segment | undefined
): segment is Segment & { value: number } {
  return segment !== undefined && segment.value !== null && segment.isCommitted;
}

/**
 * The composed value, or `null` while any segment is still empty or still
 * being typed. The day is clamped to the chosen month's real length: a 31 left
 * over from January must resolve to the 28th in February, not roll forward
 * into March the way the `Date` constructor would.
 */
function toDate(parts: Part[]): Date | null {
  const year = findSegment(parts, 'year');
  const month = findSegment(parts, 'month');
  const day = findSegment(parts, 'day');

  // Uncommitted counts as empty: half a year is not a date.
  if (!isReady(year) || !isReady(month) || !isReady(day)) return null;

  const clamped = Math.min(day.value, daysInMonth(year.value, month.value));
  return new Date(year.value, month.value - 1, clamped);
}

/**
 * Carries the segments' state onto a freshly built list, matching by type.
 *
 * Used when the locale or the format changes under a field that is already
 * holding something. Going via `toDate` instead would discard a half-typed
 * entry, because a partial entry composes no date -- and losing the user's
 * digits to a locale switch is exactly the failure this component exists to
 * avoid. A segment the new format has no place for is simply dropped.
 */
function carryOver(next: Part[], previous: Part[]): Part[] {
  return next.map((part) => {
    if (!isSegment(part)) return part;

    const was = findSegment(previous, part.type);
    if (!was || was.value === null) return part;

    return {
      ...part,
      value: was.value,
      buffer: was.buffer,
      isCommitted: was.isCommitted
    };
  });
}

/**
 * Whether a format would render a month no one can type into -- either a
 * textual month outright, or a `dateStyle` preset, which picks its own and
 * cannot be reasoned about field by field.
 */
function hasTextualMonth(options: Intl.DateTimeFormatOptions): boolean {
  return (
    options.dateStyle !== undefined ||
    options.month === 'long' ||
    options.month === 'short' ||
    options.month === 'narrow'
  );
}

/**
 * The nearest typeable format to the one asked for.
 *
 * A textual month is swapped for a numeric one and *everything else is left
 * alone*: a format asking for month and day keeps exactly those two segments
 * rather than growing a year the consumer never requested. A `dateStyle`
 * preset names no fields at all, so there is nothing to preserve and the
 * default numeric format stands in for the whole thing.
 */
function toNumericFormat(
  options: Intl.DateTimeFormatOptions
): Intl.DateTimeFormatOptions {
  if (options.dateStyle !== undefined) return DEFAULT_FORMAT;
  return { ...options, month: 'numeric' };
}

/**
 * The format the segments should actually be built from, warning when that is
 * not the one asked for.
 *
 * Both hosts need the identical policy and differ only in what they call
 * themselves, so the message is passed in rather than the rule being written
 * out twice and left to drift.
 */
function resolveSegmentFormat(
  given: Intl.DateTimeFormatOptions | undefined,
  warning: { message: string; id: string }
): Intl.DateTimeFormatOptions | undefined {
  if (!given || !hasTextualMonth(given)) return given;

  warn(warning.message, false, { id: warning.id });

  return toNumericFormat(given);
}

/** Whether two composed values differ -- `null` (no date) included. */
function hasDateChanged(before: Date | null, after: Date | null): boolean {
  if (before === null || after === null) return before !== after;
  return before.getTime() !== after.getTime();
}

/** Writes a value across the segments, leaving literals untouched. */
function fromDate(parts: Part[], date: Date | null): Part[] {
  return parts.map((part) => {
    if (!isSegment(part)) return part;
    if (!date) return clearSegment(part);

    return withValue(part, seedFrom(part.type, date));
  });
}

export {
  buildParts,
  isSegment,
  emptySegment,
  DEFAULT_FORMAT,
  BOUNDS,
  applyDigit,
  commitSegment,
  clearSegment,
  deleteDigit,
  step,
  toDate,
  fromDate,
  findSegment,
  resolveTwoDigitYear,
  daysInMonth,
  displaySegment,
  withValue,
  carryOver,
  hasTextualMonth,
  toNumericFormat,
  resolveSegmentFormat,
  hasDateChanged
};
