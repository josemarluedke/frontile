import {
  addDays,
  addWeeks,
  startOfDay,
  startOfMonth,
  endOfMonth,
  startOfWeek,
  isBefore,
  isAfter,
  isSameDay
} from 'date-fns';
import type {
  CalendarMonthData,
  CalendarWeek,
  CalendarDay,
  DateRange,
  WeekDay,
  WeekdayLabel
} from './types';

/**
 * A machine key, not display text -- built from the local calendar fields
 * rather than any formatter, so it never drifts with locale or timezone.
 */
export function toDayKey(date: Date): string {
  const y = date.getFullYear();
  const m = String(date.getMonth() + 1).padStart(2, '0');
  const d = String(date.getDate()).padStart(2, '0');
  return `${y}-${m}-${d}`;
}

/**
 * A machine key for a month, not display text -- same rationale as
 * {@link toDayKey}: stable across recomputes so `{{#each}}` can key on it
 * instead of a `Date` object's `guidFor` identity.
 */
export function toMonthKey(date: Date): string {
  const y = date.getFullYear();
  const m = String(date.getMonth() + 1).padStart(2, '0');
  return `${y}-${m}`;
}

/**
 * Inverse of {@link toDayKey}. Parsed from local calendar fields (never
 * `new Date(key)`, which reads the string as UTC and can land on the wrong
 * local day near midnight), so it round-trips exactly.
 */
export function fromDayKey(key: string): Date {
  const [year, month, day] = key.split('-').map(Number) as [
    number,
    number,
    number
  ];
  return new Date(year, month - 1, day);
}

/**
 * `getWeekInfo()` is the standard API but shipped late; older Safari exposes
 * the same data as a `weekInfo` property. Sunday is the last resort.
 */
export function resolveWeekStart(locale: string, explicit?: WeekDay): WeekDay {
  if (explicit !== undefined) {
    return explicit;
  }

  try {
    const loc = new Intl.Locale(locale) as Intl.Locale & {
      getWeekInfo?: () => { firstDay: number };
      weekInfo?: { firstDay: number };
    };
    const info = loc.getWeekInfo?.() ?? loc.weekInfo;

    if (info) {
      // Intl counts Monday as 1 … Sunday as 7; we count Sunday as 0.
      return (info.firstDay % 7) as WeekDay;
    }
  } catch {
    // An unparseable locale tag falls through to the default.
  }

  return 0;
}

export function buildMonthGrid(opts: {
  month: Date;
  weekStartsOn: WeekDay;
  fixedWeeks: boolean;
}): CalendarMonthData {
  const month = startOfMonth(opts.month);
  const last = endOfMonth(month);
  const gridStart = startOfWeek(month, { weekStartsOn: opts.weekStartsOn });

  const weeks: CalendarWeek[] = [];
  let cursor = gridStart;

  // `addWeeks`/`addDays` are calendar-aware, so a DST transition inside the
  // month neither skips nor repeats a day -- which a `+24h` walk would.
  while (weeks.length < 6) {
    const days: CalendarDay[] = [];

    for (let i = 0; i < 7; i++) {
      const date = startOfDay(addDays(cursor, i));
      days.push({
        date,
        dayOfMonth: date.getDate(),
        isOutside:
          date.getMonth() !== month.getMonth() ||
          date.getFullYear() !== month.getFullYear(),
        key: toDayKey(date)
      });
    }

    weeks.push({ key: toDayKey(cursor), days });
    cursor = addWeeks(cursor, 1);

    if (!opts.fixedWeeks && isAfter(startOfDay(cursor), startOfDay(last))) {
      break;
    }
  }

  return { month, weeks, key: toMonthKey(month) };
}

/**
 * `Intl.DateTimeFormat` is expensive to construct and cheap to reuse, and the
 * calendar re-renders on every hover while a range is being dragged. Cache one
 * formatter per locale-and-options rather than building a new one per render.
 *
 * The key set is bounded by the locales and option shapes a page actually
 * uses, so this cannot grow without bound.
 */
const formatterCache = new Map<string, Intl.DateTimeFormat>();

function formatter(
  locale: string,
  options: Intl.DateTimeFormatOptions
): Intl.DateTimeFormat {
  const key = `${locale}|${JSON.stringify(options)}`;
  let cached = formatterCache.get(key);

  if (!cached) {
    cached = new Intl.DateTimeFormat(locale, options);
    formatterCache.set(key, cached);
  }

  return cached;
}

export function formatMonthCaption(month: Date, locale: string): string {
  return formatter(locale, { month: 'long', year: 'numeric' }).format(month);
}

export function formatWeekdays(
  locale: string,
  weekStartsOn: WeekDay
): WeekdayLabel[] {
  const short = formatter(locale, { weekday: 'short' });
  const long = formatter(locale, { weekday: 'long' });
  const narrow = formatter(locale, { weekday: 'narrow' });

  // 2026-11-01 is a Sunday, so offsetting from it lands on each weekday in turn.
  const sunday = new Date(2026, 10, 1);

  return Array.from({ length: 7 }, (_, column) => {
    const index = ((weekStartsOn + column) % 7) as WeekDay;
    const sample = addDays(sunday, index);

    return {
      short: short.format(sample),
      long: long.format(sample),
      narrow: narrow.format(sample),
      index
    };
  });
}

export function isWithinBounds(date: Date, min?: Date, max?: Date): boolean {
  const day = startOfDay(date);

  if (min && isBefore(day, startOfDay(min))) {
    return false;
  }
  if (max && isAfter(day, startOfDay(max))) {
    return false;
  }
  return true;
}

export function normalizeRange(a: Date, b: Date): DateRange {
  return isAfter(a, b) ? { start: b, end: a } : { start: a, end: b };
}

/**
 * How far a range anchored at `anchor` may reach in each direction. It stops
 * one day short of the nearest unavailable date, which is what stops a booking
 * range from straddling an already-booked night.
 *
 * The 366-day walk is a real limit on selection, not just on the search: when
 * nothing else blocks, the returned bounds are `anchor ± 366` and the calendar
 * refuses endpoints beyond them. A range longer than a year is not a calendar
 * interaction, and walking unbounded would mean an open-ended loop per hover.
 *
 * Both bounds are always dates -- the walk starts at the anchor itself, so
 * there is no "unbounded" result to represent.
 */
export function rangeLimits(
  anchor: Date,
  isDateUnavailable?: (date: Date) => boolean,
  min?: Date,
  max?: Date
): { min: Date; max: Date } {
  const walk = (direction: 1 | -1): Date => {
    let furthest = startOfDay(anchor);

    for (let i = 1; i <= 366; i++) {
      const candidate = startOfDay(addDays(anchor, i * direction));

      if (!isWithinBounds(candidate, min, max)) {
        break;
      }
      if (isDateUnavailable?.(candidate)) {
        break;
      }
      furthest = candidate;
    }

    return furthest;
  };

  return { min: walk(-1), max: walk(1) };
}

export { isSameDay, startOfDay };
