import { isSegment, fromDate, resolveTwoDigitYear } from './segments';
import { parseDate } from '../date-picker/value';
import type { Part, Segment } from './types';

const ISO_DAY = /^\d{4}-\d{2}-\d{2}$/;

/** Writes a list of numbers onto the segments, in segment order. */
function fill(parts: Part[], numbers: number[]): Part[] | null {
  const segments = parts.filter(isSegment);
  if (numbers.length !== segments.length) return null;

  let i = 0;
  const next: Part[] = [];
  for (const part of parts) {
    if (!isSegment(part)) {
      next.push(part);
      continue;
    }

    const raw = numbers[i++];
    if (raw === undefined) return null;
    const value = part.type === 'year' ? resolveTwoDigitYear(String(raw)) : raw;

    // Out of bounds is refused outright. Clamping here would turn a paste of
    // "99/99/2026" into a plausible-looking date the user never meant.
    if (value < part.min || value > part.max) return null;

    next.push({
      ...part,
      value,
      buffer: String(value).padStart(part.width, '0')
    });
  }

  return next;
}

/**
 * Reads pasted text into the segments, trying each strategy in turn and
 * stopping at the first that works.
 *
 * There is deliberately no `new Date(text)` fallback: it parses differently in
 * every engine, and a date field that silently guesses wrong is worse than one
 * that declines.
 */
function parsePasted(text: string, parts: Part[]): Part[] | null {
  const trimmed = text.trim();
  if (trimmed === '') return null;

  // 1. ISO, which is unambiguous and so outranks the locale's own order.
  if (ISO_DAY.test(trimmed)) {
    const date = parseDate(trimmed);
    return date ? fromDate(parts, date) : null;
  }

  const segments = parts.filter(isSegment) as Segment[];

  // 2. Separated numbers, mapped positionally onto the locale's order.
  const groups = trimmed.split(/\D+/).filter(Boolean);
  if (groups.length === segments.length) {
    return fill(
      parts,
      groups.map((g) => Number(g))
    );
  }

  // 3. A bare digit run, split by each segment's width.
  if (/^\d+$/.test(trimmed)) {
    const width = segments.reduce((sum, s) => sum + s.width, 0);
    if (trimmed.length === width) {
      const numbers: number[] = [];
      let at = 0;
      for (const segment of segments) {
        numbers.push(Number(trimmed.slice(at, at + segment.width)));
        at += segment.width;
      }
      return fill(parts, numbers);
    }
  }

  return null;
}

/**
 * The field as it reads on screen, literals included. Copying the display
 * rather than an ISO string means the text round-trips through `parsePasted`
 * and still reads naturally when pasted into a document.
 */
function formatForClipboard(parts: Part[]): string {
  return parts
    .map((part) => {
      if (!isSegment(part)) return part.text;
      if (part.value === null) return part.placeholder;
      return String(part.value).padStart(part.width, '0');
    })
    .join('');
}

export { parsePasted, formatForClipboard };
