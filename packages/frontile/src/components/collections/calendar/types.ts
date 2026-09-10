export type CalendarMode = 'single' | 'range';

/** 0 = Sunday … 6 = Saturday. */
export type WeekDay = 0 | 1 | 2 | 3 | 4 | 5 | 6;

/**
 * Deliberately `{ start, end }` rather than `{ from, to }`: this is exactly
 * date-fns's `Interval`, so a consumer's range value drops straight into
 * `eachDayOfInterval(range)` with no adapter.
 *
 * `end` is nullable so a half-committed range -- anchor set, second click
 * pending -- is representable in the same type.
 */
export interface DateRange {
  start: Date;
  end: Date | null;
}

export type CalendarValue<M extends CalendarMode> = M extends 'range'
  ? DateRange | null
  : Date | null;

export interface CalendarDay {
  date: Date;
  dayOfMonth: number;
  /** Belongs to an adjacent month but fills out this month's grid. */
  isOutside: boolean;
  /** `yyyy-MM-dd`, stable across renders -- used as the `{{#each}}` key. */
  key: string;
}

export interface CalendarWeek {
  key: string;
  days: CalendarDay[];
}

export interface CalendarMonthData {
  /** First day of the month this grid represents. */
  month: Date;
  weeks: CalendarWeek[];
  /**
   * `yyyy-MM`, stable across renders -- used as the `{{#each}}` key so a
   * month that stays visible after paging is reused rather than torn down
   * and rebuilt (Glimmer would otherwise key on `month`'s object identity,
   * and a fresh `Date` instance is produced on every recompute).
   */
  key: string;
}

export interface WeekdayLabel {
  short: string;
  long: string;
  narrow: string;
  /** 0 = Sunday … 6 = Saturday, regardless of column position. */
  index: WeekDay;
}

/** What the `<:day>` block receives. */
export interface DayState {
  date: Date;
  dayOfMonth: number;
  isSelected: boolean;
  isToday: boolean;
  isOutside: boolean;
  isDisabled: boolean;
  isUnavailable: boolean;
  isRangeStart: boolean;
  isRangeEnd: boolean;
  isInRange: boolean;
  isPreview: boolean;
  isFocused: boolean;
  /**
   * Outside `@minValue`/`@maxValue`. Distinct from `isUnavailable`, which is
   * in range but not selectable, and from `isOutside`, which is a
   * neighbouring month's day.
   */
  isOutsideRange: boolean;

  /**
   * Whether this cell renders a day at all. An outside-month day for which
   * `@showOutsideDays` is off keeps its `<td>` so the grid stays aligned, but
   * renders no band, no button and no gridcell role.
   *
   * Decided by `Calendar`, which is the only place that knows both
   * `@showOutsideDays` and how many months are on screen -- the cell template
   * must not re-derive it.
   */
  rendersDay: boolean;
  /**
   * The day's full human-readable date (weekday, month, day, year),
   * produced by `Intl.DateTimeFormat` from `@locale` -- the day button's
   * accessible name. Without it a screen reader announces only the bare
   * day-of-month number, so crossing a month boundary with the arrow keys
   * has nothing to distinguish "the 1st" of one month from another.
   */
  ariaLabel: string;
}

/** The slot classes a day cell needs, passed as one object rather than five. */
export interface DayCellClasses {
  cell: string;
  cellBand: string;
  day: string;
  dayContent: string;
  indicator: string;
}
