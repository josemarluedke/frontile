import Component from '@glimmer/component';
import { cached } from '@glimmer/tracking';
import { useStyles, type SlotsToClasses } from '@frontile/theme';
import { MonthGrid } from './month-grid';
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
  CalendarMonthData,
  DayState,
  WeekDay
} from './types';

export interface CalendarArgs {
  /** Seeds the visible month when uncontrolled. */
  defaultMonth?: Date;

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

export interface CalendarSignature {
  Args: CalendarArgs;
  Blocks: { day: [DayState] };
  Element: HTMLDivElement;
}

class Calendar extends Component<CalendarSignature> {
  get locale(): string {
    return this.args.locale ?? navigator.language;
  }

  get weekStartsOn(): WeekDay {
    return resolveWeekStart(this.locale, this.args.weekStartsOn);
  }

  get showOutsideDays(): boolean {
    return this.args.showOutsideDays ?? true;
  }

  get visibleMonth(): Date {
    return this.args.defaultMonth ?? new Date();
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
      isSelected: false,
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
      <div
        data-fr-calendar-header
        class={{this.styles.header class=@classes.header}}
      >
        <div
          data-fr-calendar-title
          class={{this.styles.title class=@classes.title}}
        >{{this.caption}}</div>
      </div>

      <div class={{this.styles.monthsWrapper class=@classes.monthsWrapper}}>
        <MonthGrid
          @month={{this.monthData}}
          @weekdays={{this.weekdays}}
          @caption={{this.caption}}
          @stateFor={{this.stateFor}}
          @showOutsideDays={{this.showOutsideDays}}
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
