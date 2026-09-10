import Component from '@glimmer/component';
import { tracked, cached } from '@glimmer/tracking';
import { on } from '@ember/modifier';
import { modifier } from 'ember-modifier';
import {
  addDays,
  addMonths,
  addWeeks,
  addYears,
  startOfMonth,
  endOfMonth,
  endOfWeek,
  startOfWeek,
  isSameMonth
} from 'date-fns';
import { useStyles, type SlotsToClasses } from '@frontile/theme';
import { MonthGrid } from './month-grid';
import { CalendarHeader, type CalendarHeaderContext } from './header';
import { VisuallyHidden } from '../../utilities/visually-hidden';
import {
  buildMonthGrid,
  formatMonthCaption,
  formatWeekdays,
  resolveWeekStart,
  fromDayKey,
  isSameDay,
  isWithinBounds,
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

  /** Earliest selectable date. Also clamps month navigation. */
  minValue?: Date;

  /** Latest selectable date. Also clamps month navigation. */
  maxValue?: Date;

  /**
   * Marks a date as present but unselectable -- a holiday, a booked night.
   * Distinct from `@minValue`/`@maxValue`, which put a date out of range
   * entirely.
   */
  isDateUnavailable?: (date: Date) => boolean;

  /** @defaultValue false */
  isReadOnly?: boolean;

  /**
   * Moves DOM focus into the grid on insert. This is the *only* thing that
   * may focus the calendar on mount -- rendering a calendar must never
   * otherwise steal focus.
   *
   * @defaultValue false
   */
  autofocus?: boolean;

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
    if (this.args.isReadOnly || this.isDayDisabled(date)) {
      return;
    }

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

  isDayUnavailable = (date: Date): boolean => {
    return this.args.isDateUnavailable?.(date) ?? false;
  };

  isDayOutsideRange = (date: Date): boolean => {
    return !isWithinBounds(date, this.args.minValue, this.args.maxValue);
  };

  isDayDisabled = (date: Date): boolean => {
    return (
      (this.args.isDisabled ?? false) ||
      this.isDayOutsideRange(date) ||
      this.isDayUnavailable(date)
    );
  };

  /**
   * Focus management is hand-rolled rather than delegated to the repo's
   * `rovingFocus` utility (`packages/frontile/src/utils/roving-focus.ts`),
   * and the reason is structural: arrow keys must cross month boundaries --
   * Right on Sept 30 lands on Oct 1 -- and at the moment the key fires that
   * element does not exist in the DOM yet. `rovingFocus` navigates among
   * already-rendered siblings sorted by document position and cannot move
   * focus into an element a re-render has yet to create.
   */
  @tracked private _focusedDate: Date | undefined;

  /**
   * Only keyboard interaction (or `@autofocus`) sets this. Mounting
   * therefore never steals focus, and we never write to the DOM during a
   * render pass -- which is what caused the synchronous-focusout flake in
   * `ListManager`. This is deliberately a plain field, not `@tracked`: it is
   * read and cleared from inside the `applyFocus` modifier, which runs
   * after render, not during it, so tracking it would only invite a
   * backtracking-write assertion for no benefit.
   */
  #shouldFocus = false;

  get focusedDate(): Date {
    return this._focusedDate ?? this.defaultFocusedDate;
  }

  private get defaultFocusedDate(): Date {
    const selected = this.selection;

    if (selected instanceof Date) {
      return selected;
    }
    if (selected && 'start' in selected) {
      return selected.start;
    }

    const today = startOfDay(new Date());
    return isSameMonth(today, this.visibleMonth) ? today : this.visibleMonth;
  }

  private moveFocus(date: Date): void {
    const next = startOfDay(date);

    if (this.isDayOutsideRange(next)) {
      return;
    }

    this._focusedDate = next;
    this.#shouldFocus = true;

    if (!isSameMonth(next, this.visibleMonth)) {
      this.goToMonth(next);
    }
  }

  /**
   * The date to navigate *from*. Read off the actual DOM-focused day button
   * (via the event target) rather than trusting `this.focusedDate` alone --
   * that tracked value only advances when `moveFocus` runs, so it can lag
   * behind wherever the browser's real focus happens to be (a direct
   * `.focus()` call, or focus arriving by Tab into a cell this render
   * hasn't marked as the roving tabstop yet). The DOM is the source of
   * truth for "where is focus right now"; the tracked value exists only to
   * tell `applyFocus` which element to re-focus after a rerender.
   *
   * Returns `null` when the event did not originate from a day cell --
   * `handleKeydown` is bound on the calendar's root element, so it also
   * receives keydowns bubbling up from the header's nav buttons (and, later,
   * a month `<select>`). Those controls have their own keyboard behavior
   * (arrow keys operate a native `<select>`, for instance) and must not be
   * hijacked by the day-grid's roving-focus handling.
   */
  private focusOrigin(event: KeyboardEvent): Date | null {
    const key = (event.target as HTMLElement | null)?.closest<HTMLElement>(
      '[data-fr-calendar-day]'
    )?.dataset['key'];

    return key ? fromDayKey(key) : null;
  }

  handleKeydown = (event: KeyboardEvent): void => {
    if (this.args.isDisabled) {
      return;
    }

    const from = this.focusOrigin(event);
    if (!from) {
      return;
    }
    let next: Date | undefined;

    switch (event.key) {
      case 'ArrowLeft':
        next = addDays(from, -1);
        break;
      case 'ArrowRight':
        next = addDays(from, 1);
        break;
      case 'ArrowUp':
        next = addWeeks(from, -1);
        break;
      case 'ArrowDown':
        next = addWeeks(from, 1);
        break;
      case 'Home':
        next = startOfWeek(from, { weekStartsOn: this.weekStartsOn });
        break;
      case 'End':
        next = endOfWeek(from, { weekStartsOn: this.weekStartsOn });
        break;
      case 'PageUp':
        next = event.shiftKey ? addYears(from, -1) : addMonths(from, -1);
        break;
      case 'PageDown':
        next = event.shiftKey ? addYears(from, 1) : addMonths(from, 1);
        break;
      case 'Enter':
      case ' ':
        event.preventDefault();
        this.selectDay(from);
        return;
      default:
        return;
    }

    event.preventDefault();
    this.moveFocus(next);
  };

  /**
   * Applies DOM focus after a render, but only when a keypress asked for it
   * (or `@autofocus` did on insert). Never called from a getter or a
   * tracked setter -- only from this modifier, which Glimmer schedules
   * after the DOM has been updated.
   *
   * `ember-modifier`'s function-based modifiers only rerun when the
   * function actually *reads* one of its arguments during autotracking --
   * merely passing `this.focusedDate` from the template does nothing on
   * its own. The destructured `[]` here is what makes that read happen, so
   * every focus move (including one that crosses a month boundary) causes
   * this modifier to run again after the corresponding rerender.
   */
  applyFocus = modifier((element: HTMLElement, [focusedDate]: [Date]) => {
    // Referenced only to establish the autotracking dependency described
    // above -- the actual target element is looked up fresh below.
    void focusedDate;

    if (this.args.autofocus) {
      this.#shouldFocus = true;
    }
    if (!this.#shouldFocus) {
      return;
    }

    this.#shouldFocus = false;
    element
      .querySelector<HTMLElement>('[data-fr-calendar-day][tabindex="0"]')
      ?.focus();
  });

  goToPrevious = (): void => this.goToMonth(addMonths(this.visibleMonth, -1));
  goToNext = (): void => this.goToMonth(addMonths(this.visibleMonth, 1));

  get canGoPrevious(): boolean {
    if (this.args.isDisabled) {
      return false;
    }
    const previous = endOfMonth(addMonths(this.visibleMonth, -1));
    return isWithinBounds(previous, this.args.minValue, undefined);
  }

  get canGoNext(): boolean {
    if (this.args.isDisabled) {
      return false;
    }
    const next = startOfMonth(addMonths(this.visibleMonth, 1));
    return isWithinBounds(next, undefined, this.args.maxValue);
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
      isDisabled: this.isDayDisabled(day.date),
      isUnavailable: this.isDayUnavailable(day.date),
      isRangeStart: false,
      isRangeEnd: false,
      isInRange: false,
      isPreview: false,
      isFocused: isSameDay(day.date, this.focusedDate),
      isOutsideRange: this.isDayOutsideRange(day.date)
    };
  };

  <template>
    {{! template-lint-disable no-invalid-interactive }}
    {{! The keydown listener implements the roving-tabindex grid pattern for
         the day buttons nested inside; the root itself stays a plain,
         non-focusable container. }}
    <div
      data-fr-calendar
      class={{this.styles.base class=@classes.base}}
      {{on "keydown" this.handleKeydown}}
      {{this.applyFocus this.focusedDate}}
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
