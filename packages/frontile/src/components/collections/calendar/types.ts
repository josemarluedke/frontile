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
}
