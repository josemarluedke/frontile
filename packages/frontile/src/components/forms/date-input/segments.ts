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
    buffer: ''
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

/** The numeric value a buffer represents, or null when it represents none. */
function bufferValue(segment: Segment, buffer: string): number | null {
  if (buffer === '') return null;
  const n =
    segment.type === 'year' ? resolveTwoDigitYear(buffer) : Number(buffer);
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

  // The accumulated digits overflow the segment, so this keystroke starts a
  // fresh entry instead of being discarded.
  if (value !== null && value > segment.max) {
    buffer = digit;
    value = bufferValue(segment, buffer);
    // A single digit that still overflows cannot be entered at all.
    if (value !== null && value > segment.max)
      return { segment, isFull: false };
  }

  const next: Segment = { ...segment, buffer, value };

  const atWidth = buffer.length >= segment.width;
  // Would any digit 0-9 appended here still fit? If not, there is nothing
  // left to wait for. `bufferValue` returning null (below `min`) behaves like
  // 0 here, same as the original non-null-assertion-based comparison did.
  const extended = bufferValue(segment, buffer + '0') ?? 0;
  const canExtend = !atWidth && extended <= segment.max;

  return { segment: next, isFull: atWidth || !canExtend };
}

/** Clears both the value and the digits behind it. */
function clearSegment(segment: Segment): Segment {
  return { ...segment, value: null, buffer: '' };
}

/** Drops the last digit typed, for Backspace. */
function deleteDigit(segment: Segment): Segment {
  const buffer = segment.buffer.slice(0, -1);
  return { ...segment, buffer, value: bufferValue(segment, buffer) };
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
    const seeded = seedFrom(segment.type, placeholderValue);
    return {
      ...segment,
      value: seeded,
      buffer: String(seeded).padStart(segment.width, '0')
    };
  }

  const span = segment.max - segment.min + 1;
  const offset = segment.value - segment.min + delta;
  // Modulo twice: JavaScript's % keeps the sign of the dividend, so a
  // decrement past the floor would otherwise land on a negative value.
  const wrapped = ((offset % span) + span) % span;
  const value = wrapped + segment.min;

  return {
    ...segment,
    value,
    buffer: String(value).padStart(segment.width, '0')
  };
}

function findSegment(parts: Part[], type: SegmentType): Segment | undefined {
  return parts.find((p): p is Segment => isSegment(p) && p.type === type);
}

/** Days in a month, via the zeroth day of the next one. */
function daysInMonth(year: number, month: number): number {
  return new Date(year, month, 0).getDate();
}

/**
 * The composed value, or `null` while any segment is still empty. The day is
 * clamped to the chosen month's real length: a 31 left over from January must
 * resolve to the 28th in February, not roll forward into March the way the
 * `Date` constructor would.
 */
function toDate(parts: Part[]): Date | null {
  const year = findSegment(parts, 'year')?.value ?? null;
  const month = findSegment(parts, 'month')?.value ?? null;
  const day = findSegment(parts, 'day')?.value ?? null;

  if (year === null || month === null || day === null) return null;

  const clamped = Math.min(day, daysInMonth(year, month));
  return new Date(year, month - 1, clamped);
}

/** Writes a value across the segments, leaving literals untouched. */
function fromDate(parts: Part[], date: Date | null): Part[] {
  return parts.map((part) => {
    if (!isSegment(part)) return part;
    if (!date) return clearSegment(part);

    const value = seedFrom(part.type, date);
    return { ...part, value, buffer: String(value).padStart(part.width, '0') };
  });
}

export {
  buildParts,
  isSegment,
  emptySegment,
  DEFAULT_FORMAT,
  BOUNDS,
  applyDigit,
  clearSegment,
  deleteDigit,
  step,
  toDate,
  fromDate,
  findSegment,
  resolveTwoDigitYear,
  daysInMonth
};
