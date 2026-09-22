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

export { buildParts, isSegment, emptySegment, DEFAULT_FORMAT, BOUNDS };
