import { isSegment, resolveTwoDigitYear, displaySegment } from './segments';
import type { Part, Segment, SegmentType } from './types';

const ISO_DAY = /^(\d{4})-(\d{2})-(\d{2})$/;

/** The digits destined for each segment, keyed by type. */
type Digits = Partial<Record<SegmentType, string>>;

/**
 * Writes digit strings onto the segments they name.
 *
 * Digits stay *strings* all the way in, because a year's leading zeros carry
 * meaning: `0045` is the year 45, while `45` runs through the sliding window.
 * Passing numbers here would erase that distinction and make a pasted `0045`
 * resolve differently from a typed one.
 *
 * A segment no key names is left untouched, which is what lets a partial paste
 * fill what it can. Out of bounds refuses the *whole* paste rather than
 * clamping: clamping would turn a paste of `99/99/2026` into a plausible
 * looking date the user never meant. The day is the exception by design -- its
 * bound is 31 and the real length of the month is applied later, by `toDate`,
 * so a pasted 31st of February shortens to the 28th exactly as a typed one
 * does.
 */
function fill(parts: Part[], digits: Digits): Part[] | null {
  let filled = 0;

  const next: Part[] = [];
  for (const part of parts) {
    if (!isSegment(part)) {
      next.push(part);
      continue;
    }

    const raw = digits[part.type];
    if (raw === undefined) {
      next.push(part);
      continue;
    }

    const value = part.type === 'year' ? resolveTwoDigitYear(raw) : Number(raw);
    if (Number.isNaN(value) || value < part.min || value > part.max) {
      return null;
    }

    filled++;
    next.push({
      ...part,
      value,
      buffer: String(value).padStart(part.width, '0'),
      // A paste is a finished answer for every segment it fills.
      isCommitted: true
    });
  }

  // Nothing landed anywhere -- treat that as a refusal rather than quietly
  // handing back an untouched field.
  return filled === 0 ? null : next;
}

/** Maps digit groups onto the segments in their rendered order. */
function byPosition(segments: Segment[], groups: string[]): Digits | null {
  if (groups.length === 0 || groups.length > segments.length) return null;

  const digits: Digits = {};
  groups.forEach((group, i) => {
    const segment = segments[i];
    if (segment) digits[segment.type] = group;
  });
  return digits;
}

/**
 * Reads pasted text into the segments, trying each strategy in turn and
 * stopping at the first that works.
 *
 * Every strategy lands in `fill`, so all three share one bounds policy. There
 * is deliberately no `new Date(text)` fallback: it parses differently in every
 * engine, and a date field that silently guesses wrong is worse than one that
 * declines.
 */
function parsePasted(text: string, parts: Part[]): Part[] | null {
  const trimmed = text.trim();
  if (trimmed === '') return null;

  // 1. ISO, which is unambiguous and so outranks the locale's own order.
  const iso = ISO_DAY.exec(trimmed);
  if (iso) {
    const [, year, month, day] = iso;
    return fill(parts, { year, month, day });
  }

  const segments = parts.filter(isSegment);

  // 2. A bare digit run, split by each segment's width. Checked before the
  //    separated form, because an unseparated run also splits into a single
  //    "group" and would otherwise be read as one enormous month.
  if (/^\d+$/.test(trimmed)) {
    const widths: string[] = [];
    let at = 0;
    for (const segment of segments) {
      if (at >= trimmed.length) break;
      widths.push(trimmed.slice(at, at + segment.width));
      at += segment.width;
    }

    // It has to end on a segment boundary, otherwise there is no telling
    // where the last number was meant to stop.
    if (at !== trimmed.length) return null;

    const digits = byPosition(segments, widths);
    return digits ? fill(parts, digits) : null;
  }

  // 3. Separated numbers, mapped positionally onto the locale's order. Fewer
  //    groups than segments is a partial date and fills a prefix of them.
  const groups = trimmed.split(/\D+/).filter(Boolean);
  const digits = byPosition(segments, groups);
  if (digits) return fill(parts, digits);

  return null;
}

/**
 * The field as it reads on screen, literals included. Copying the display
 * rather than an ISO string means the text round-trips through `parsePasted`
 * and still reads naturally when pasted into a document.
 *
 * Delegates each segment to `displaySegment`, the same function the group
 * renders from, so a mid-entry year (buffer `26`, uncommitted) copies as
 * `26` rather than being padded to `0026` -- padding would claim digits the
 * user never typed and would contradict what is on screen.
 */
function formatForClipboard(parts: Part[]): string {
  return parts
    .map((part) => (isSegment(part) ? displaySegment(part) : part.text))
    .join('');
}

/**
 * What separates the two halves of a pasted range.
 *
 * An en or em dash needs no surrounding space, because neither ever appears
 * inside a date. A plain hyphen does: it is the ISO separator, so splitting on
 * an unspaced one would tear `2026-01-20` into pieces. The same reasoning
 * applies to the words -- `\s+` on both sides keeps "to" from matching inside
 * "total".
 */
const RANGE_SEPARATOR = /\s*[\u2013\u2014]\s*|\s+(?:-|to|until|through)\s+/i;

/**
 * Splits pasted text into the two dates of a range, or returns `null` when it
 * does not read as two.
 *
 * Only the shape is decided here; neither half is parsed. The caller runs each
 * through {@link parsePasted} and keeps the result only when both halves are
 * dates -- so text that merely contains a dash falls through to the ordinary
 * single-date handling rather than being consumed.
 */
function splitRange(text: string): [string, string] | null {
  const trimmed = text.trim();
  const match = RANGE_SEPARATOR.exec(trimmed);
  if (!match) return null;

  const start = trimmed.slice(0, match.index).trim();
  const end = trimmed.slice(match.index + match[0].length).trim();
  if (start === '' || end === '') return null;

  // Three halves is not a range, and guessing which two were meant would be
  // exactly the silent wrong guess this module declines to make elsewhere.
  if (RANGE_SEPARATOR.test(end)) return null;

  return [start, end];
}

export { parsePasted, formatForClipboard, splitRange };
