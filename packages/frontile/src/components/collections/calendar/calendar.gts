import Component from '@glimmer/component';
import { tracked, cached } from '@glimmer/tracking';
import { addMonths, startOfMonth, isSameMonth } from 'date-fns';
import { useStyles, type SlotsToClasses } from '@frontile/theme';
import { MonthGrid } from './month-grid';
import { CalendarHeader, type CalendarHeaderContext } from './header';
import { VisuallyHidden } from '../../utilities/visually-hidden';
import {
  buildMonthGrid,
  formatMonthCaption,
  formatWeekdays,
  resolveWeekStart,
  isSameDay,
  startOfDay
} from './utils';
import type { CalendarSlots, CalendarVariants } from '@frontile/theme';
import type {
  CalendarDay,
  CalendarMode,
  CalendarMonthData,
  CalendarValue,
  DayState,
  WeekDay
} from './types';

export interface CalendarArgs<M extends CalendarMode = 'single'> {
  /** @defaultValue 'single' */
  mode?: M;

  /** Seeds the visible month when uncontrolled. */
  defaultMonth?: Date;

  /**
   * Controlled visible month -- the *first* month of the window when
   * `@visibleMonths` is greater than one.
   *
   * *Passing* this argument at all puts the month axis in controlled mode --
   * passing it as `undefined` included. Omit it entirely to let `Calendar`
   * track the visible month itself.
   */
  month?: Date;

  /** Called with the month the user asked to move to. */
  onMonthChange?: (month: Date) => void;

  /**
   * Controlled selection. *Passing* this argument at all puts selection in
   * controlled mode -- passing it as `undefined` included.
   */
  value?: CalendarValue<M>;

  /** Seeds the selection when uncontrolled. */
  defaultValue?: CalendarValue<M>;

  onChange?: (value: CalendarValue<M>) => void;

  /** BCP-47 tag. All human-readable text is produced by `Intl` from this. */
  locale?: string;

  /** Overrides the first day of week implied by `@locale`. */
  weekStartsOn?: WeekDay;

  /** @defaultValue true */
  showOutsideDays?: boolean;

  /** @defaultValue false */
  fixedWeeks?: boolean;

  intent?: CalendarVariants['intent'];
  size?: CalendarVariants['size'];
  isDisabled?: boolean;
  classes?: SlotsToClasses<CalendarSlots>;
}

export interface CalendarSignature<M extends CalendarMode = 'single'> {
  Args: CalendarArgs<M>;
  Blocks: { day: [DayState] };
  Element: HTMLDivElement;
}

class Calendar<M extends CalendarMode = 'single'> extends Component<
  CalendarSignature<M>
> {
  get locale(): string {
    return this.args.locale ?? navigator.language;
  }

  get weekStartsOn(): WeekDay {
    return resolveWeekStart(this.locale, this.args.weekStartsOn);
  }

  get showOutsideDays(): boolean {
    return this.args.showOutsideDays ?? true;
  }

  /**
   * Uncontrolled mode's own state. `undefined` means "not navigated yet",
   * which is what lets the seed getters below resolve without a tracked
   * write during render.
   */
  @tracked private _month: Date | undefined;

  private get isMonthControlled(): boolean {
    return 'month' in this.args;
  }

  get visibleMonth(): Date {
    if (this.isMonthControlled) {
      return startOfMonth(this.args.month ?? this.seedMonth);
    }
    if (this._month) {
      return startOfMonth(this._month);
    }
    return startOfMonth(this.seedMonth);
  }

  /**
   * A calendar seeded with a selection should open showing that selection,
   * not today.
   */
  private get seedMonth(): Date {
    if (this.args.defaultMonth) {
      return this.args.defaultMonth;
    }

    const seed = this.args.defaultValue ?? this.args.value;

    if (seed instanceof Date) {
      return seed;
    }
    if (seed && 'start' in seed) {
      return seed.start;
    }
    return new Date();
  }

  goToMonth = (month: Date): void => {
    const next = startOfMonth(month);

    if (!this.isMonthControlled) {
      this._month = next;
    }
    this.args.onMonthChange?.(next);
  };

  /**
   * Uncontrolled mode's own selection. `undefined` means "not selected yet",
   * mirroring `_month` above so the seed getter can resolve without a
   * tracked write during render.
   */
  @tracked private _value: CalendarValue<M> | undefined;

  private get isValueControlled(): boolean {
    return 'value' in this.args;
  }

  get selection(): CalendarValue<M> | null {
    if (this.isValueControlled) {
      return (this.args.value ?? null) as CalendarValue<M>;
    }
    if (this._value !== undefined) {
      return this._value;
    }
    return (this.args.defaultValue ?? null) as CalendarValue<M>;
  }

  private commit(value: CalendarValue<M>): void {
    if (!this.isValueControlled) {
      this._value = value;
    }
    this.args.onChange?.(value);
  }

  selectDay = (date: Date): void => {
    // An outside day belongs to a neighbouring month; follow it so the
    // newly selected day is never left off screen.
    if (!isSameMonth(date, this.visibleMonth)) {
      this.goToMonth(date);
    }

    this.commit(startOfDay(date) as CalendarValue<M>);
  };

  private isDaySelected(date: Date): boolean {
    const selected = this.selection;

    if (selected instanceof Date) {
      return isSameDay(selected, date);
    }
    return false;
  }

  goToPrevious = (): void => this.goToMonth(addMonths(this.visibleMonth, -1));
  goToNext = (): void => this.goToMonth(addMonths(this.visibleMonth, 1));

  get canGoPrevious(): boolean {
    return true;
  }

  get canGoNext(): boolean {
    return true;
  }

  @cached
  get headerContext(): CalendarHeaderContext {
    return {
      month: this.visibleMonth,
      title: this.caption,
      goToPrevious: this.goToPrevious,
      goToNext: this.goToNext,
      canGoPrevious: this.canGoPrevious,
      canGoNext: this.canGoNext,
      setMonth: (monthIndex: number) =>
        this.goToMonth(
          new Date(this.visibleMonth.getFullYear(), monthIndex, 1)
        ),
      setYear: (year: number) =>
        this.goToMonth(new Date(year, this.visibleMonth.getMonth(), 1))
    };
  }

  @cached
  get monthData(): CalendarMonthData {
    return buildMonthGrid({
      month: this.visibleMonth,
      weekStartsOn: this.weekStartsOn,
      fixedWeeks: this.args.fixedWeeks ?? false
    });
  }

  @cached
  get weekdays() {
    return formatWeekdays(this.locale, this.weekStartsOn);
  }

  get caption(): string {
    return formatMonthCaption(this.visibleMonth, this.locale);
  }

  @cached
  get styles() {
    const { calendar } = useStyles();
    return calendar({
      intent: this.args.intent,
      size: this.args.size,
      isDisabled: this.args.isDisabled
    });
  }

  @cached
  get headerClasses() {
    const s = this.styles;
    const c = this.args.classes ?? {};

    return {
      header: s.header({ class: c.header }),
      title: s.title({ class: c.title }),
      nav: s.nav({ class: c.nav }),
      navButton: s.navButton({ class: c.navButton })
    };
  }

  @cached
  get gridClasses() {
    const s = this.styles;
    const c = this.args.classes ?? {};

    return {
      monthGrid: s.monthGrid({ class: c.monthGrid }),
      weekdaysRow: s.weekdaysRow({ class: c.weekdaysRow }),
      weekday: s.weekday({ class: c.weekday }),
      week: s.week({ class: c.week }),
      cell: s.cell({ class: c.cell }),
      cellBand: s.cellBand({ class: c.cellBand }),
      day: s.day({ class: c.day }),
      dayContent: s.dayContent({ class: c.dayContent }),
      indicator: s.indicator({ class: c.indicator })
    };
  }

  stateFor = (day: CalendarDay): DayState => {
    return {
      date: day.date,
      dayOfMonth: day.dayOfMonth,
      isOutside: day.isOutside,
      isToday: isSameDay(day.date, startOfDay(new Date())),
      isSelected: this.isDaySelected(day.date),
      isDisabled: false,
      isUnavailable: false,
      isRangeStart: false,
      isRangeEnd: false,
      isInRange: false,
      isPreview: false,
      isFocused: false,
      isOutsideRange: false
    };
  };

  <template>
    <div
      data-fr-calendar
      class={{this.styles.base class=@classes.base}}
      ...attributes
    >
      <CalendarHeader
        @context={{this.headerContext}}
        @classes={{this.headerClasses}}
      />

      <VisuallyHidden>
        <div data-fr-calendar-live aria-live="polite">{{this.caption}}</div>
      </VisuallyHidden>

      <div class={{this.styles.monthsWrapper class=@classes.monthsWrapper}}>
        <MonthGrid
          @month={{this.monthData}}
          @weekdays={{this.weekdays}}
          @caption={{this.caption}}
          @stateFor={{this.stateFor}}
          @showOutsideDays={{this.showOutsideDays}}
          @onSelect={{this.selectDay}}
          @hasDayContent={{has-block "day"}}
          @classes={{this.gridClasses}}
        >
          <:day as |day|>{{yield day to="day"}}</:day>
        </MonthGrid>
      </div>
    </div>
  </template>
}

export default Calendar;
export { Calendar };
