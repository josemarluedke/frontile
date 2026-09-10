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
  isSameMonth,
  isAfter,
  isBefore
} from 'date-fns';
import { useStyles, type SlotsToClasses } from '@frontile/theme';
import { MonthGrid } from './month-grid';
import { CalendarHeader, type CalendarHeaderContext } from './header';
import { YearGrid } from './year-grid';
import { VisuallyHidden } from '../../utilities/visually-hidden';
import {
  buildMonthGrid,
  formatMonthCaption,
  formatWeekdays,
  resolveWeekStart,
  fromDayKey,
  isSameDay,
  isWithinBounds,
  normalizeRange,
  rangeLimits,
  startOfDay
} from './utils';
import type { CalendarSlots, CalendarVariants } from '@frontile/theme';
import type {
  CalendarDay,
  CalendarMode,
  CalendarMonthData,
  CalendarValue,
  DateRange,
  DayState,
  WeekDay,
  WeekdayLabel
} from './types';

export interface CalendarArgs<M extends CalendarMode = 'single'> {
  /** @defaultValue 'single' */
  mode?: M;

  /**
   * Seeds the visible month when uncontrolled -- the *first* month of the
   * window when `@visibleMonths` is greater than one.
   */
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

  /** Called with the new selection when the user picks or clears a day. */
  onChange?: (value: CalendarValue<M>) => void;

  /** BCP-47 tag. All human-readable text is produced by `Intl` from this. */
  locale?: string;

  /** Overrides the first day of week implied by `@locale`. */
  weekStartsOn?: WeekDay;

  /**
   * Whether days from the adjacent month fill out a grid's leading/trailing
   * weeks. @defaultValue `true` when a single month is visible, `false`
   * once `@visibleMonths` is greater than one -- otherwise a boundary date
   * would render twice, once per adjacent grid.
   */
  showOutsideDays?: boolean;

  /** @defaultValue false */
  fixedWeeks?: boolean;

  /**
   * How many months to render side by side, starting from the visible
   * month. @defaultValue 1
   */
  visibleMonths?: number;

  /**
   * How far prev/next paging advances. `'visible'` moves by the whole
   * window (`@visibleMonths`); `'single'` always moves by one month.
   *
   * @defaultValue 'visible'
   */
  pageBehavior?: 'visible' | 'single';

  /**
   * The color used for the selected day and the range band.
   *
   * @defaultValue 'primary'
   */
  intent?: CalendarVariants['intent'];

  /**
   * The size of the calendar cells and caption text.
   *
   * @defaultValue 'md'
   */
  size?: CalendarVariants['size'];

  /**
   * Blocks navigation and selection entirely.
   *
   * @defaultValue false
   */
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

  /**
   * The id of an element naming this calendar, forwarded to each month grid's
   * `aria-labelledby`. Use it when something outside the calendar already
   * names it -- a date picker's own label, say -- so the grid is announced
   * with that name instead of its month caption.
   *
   * An `aria-labelledby` passed through `...attributes` lands on the root
   * element, which has no role, so it would not reach the grid.
   */
  labelledBy?: string;

  /** Overrides the classes applied to individual slots. */
  classes?: SlotsToClasses<CalendarSlots>;

  /**
   * `'label'` renders the plain month/year caption; `'dropdown'` swaps it for
   * a native month `<select>` plus a year trigger that opens a year-grid
   * picker.
   *
   * @defaultValue 'label'
   */
  captionLayout?: 'label' | 'dropdown';
}

export interface CalendarSignature<M extends CalendarMode = 'single'> {
  Args: CalendarArgs<M>;
  Blocks: {
    day: [DayState];
    header: [CalendarHeaderContext];
    weekday: [WeekdayLabel];
    footer: [];
  };
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

  /**
   * Default is `true` for a single visible month, `false` once more than
   * one month is visible -- a boundary date would otherwise render twice
   * (once as a trailing/leading outside day, once as a real day in the
   * neighbouring grid). An explicit `@showOutsideDays` always wins, in
   * either direction.
   */
  get showOutsideDays(): boolean {
    return this.args.showOutsideDays ?? this.visibleMonths === 1;
  }

  get captionLayout(): 'label' | 'dropdown' {
    return this.args.captionLayout ?? 'label';
  }

  @tracked isYearGridOpen = false;

  toggleYearGrid = (): void => {
    this.isYearGridOpen = !this.isYearGridOpen;
  };

  private returnFocusToYearTrigger(element: HTMLElement | null): void {
    const trigger = element?.querySelector<HTMLElement>(
      '[data-fr-calendar-year-trigger]'
    );

    if (trigger) {
      trigger.focus();
      return;
    }

    // A `<:header>` block replaces the default header entirely, so there is
    // no year trigger to find -- the selector above matches nothing and,
    // without this fallback, the just-removed year button leaves focus on
    // `<body>`. Fall back to the roving day cell instead, same element
    // `applyFocus` would target.
    //
    // Requesting focus rather than taking it: the year panel stands in for
    // the day grid, so at this moment there is no day cell in the DOM to
    // focus. `applyFocus` takes over once the grid is back -- it depends on
    // `isYearGridOpen`, so closing the panel is what wakes it, and the flag
    // is consumed on that same rerender rather than lingering.
    this.#shouldFocus = true;
  }

  dismissYearGrid = (): void => {
    this.isYearGridOpen = false;
    // Dismissing a panel that took focus must give it back, or focus falls to
    // the body and the keyboard user loses their place.
    this.returnFocusToYearTrigger(this.#root ?? null);
  };

  pickYear = (year: number): void => {
    this.headerContext.setYear(year);
    this.isYearGridOpen = false;
    // Same as `dismissYearGrid`: closing the grid removes the just-activated
    // year button from the DOM, so focus must be restored explicitly or it
    // falls to the body.
    this.returnFocusToYearTrigger(this.#root ?? null);
  };

  #root: HTMLElement | undefined;

  registerRoot = modifier((element: HTMLElement) => {
    this.#root = element;
  });

  @cached
  get monthOptions(): { value: number; label: string; isDisabled: boolean }[] {
    const fmt = this.monthNameFormatter;
    const year = this.visibleMonth.getFullYear();

    // A month is offered only when some day in it is in range. `yearOptions`
    // already clamps this way; without the same treatment the month picker is
    // a hole in the `@minValue`/`@maxValue` clamp, since it can navigate to a
    // month the prev/next buttons refuse to reach.
    return Array.from({ length: 12 }, (_, value) => {
      const month = new Date(year, value, 1);

      return {
        value,
        label: fmt.format(month),
        isDisabled: !this.canShowWindow(month)
      };
    });
  }

  /**
   * A getter, not a bare `{{this.visibleMonth.getFullYear}}` in the
   * template -- Glimmer does not auto-invoke a plain method reference in
   * argument position, it would pass the function itself instead of a
   * number.
   */
  get visibleYear(): number {
    return this.visibleMonth.getFullYear();
  }

  @cached
  get yearOptions(): number[] {
    const current = this.visibleMonth.getFullYear();

    // The visible year is always included, even when it sits outside
    // `@minValue`/`@maxValue`. The panel marks and scrolls to the *current*
    // year on open; omitting it leaves nothing to select, so the panel would
    // open unfocused and scrolled to an arbitrary decade. `Math.min`/`max`
    // also keep the range non-empty if the bounds are inverted, which would
    // otherwise render an empty listbox.
    const first = Math.min(
      this.args.minValue?.getFullYear() ?? current - 100,
      current
    );
    const last = Math.max(
      this.args.maxValue?.getFullYear() ?? current + 10,
      current
    );

    return Array.from({ length: last - first + 1 }, (_, i) => first + i);
  }

  @cached
  get yearGridClasses() {
    const s = this.styles;
    const c = this.args.classes ?? {};

    return {
      yearGrid: s.yearGrid({ class: c.yearGrid }),
      yearCell: s.yearCell({ class: c.yearCell })
    };
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

    // The clamp lives here, not only in `canGoPrevious`/`canGoNext`. Those
    // disable the default buttons, but `goToMonth` is also reachable through
    // `setMonth`/`setYear` and through the `goToPrevious`/`goToNext` yielded
    // to a `<:header>` block -- a custom header that ignores `canGoPrevious`
    // would otherwise page straight past `@minValue`.
    if (!this.canShowWindow(next)) {
      return;
    }

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

  /** The first endpoint of a range being built. `undefined` means idle. */
  @tracked private _anchor: Date | undefined;

  /** The day currently hovered or focused while anchored. */
  @tracked private _hovered: Date | undefined;

  private get isRange(): boolean {
    return this.args.mode === 'range';
  }

  /** How far the pending range may reach before it hits an unavailable day. */
  @cached
  private get pendingLimits(): { min: Date; max: Date } | null {
    // `null` means "no range being built", which is what confines these limits
    // to an anchored interaction -- idle browsing must not disable anything.
    if (!this._anchor) {
      return null;
    }
    return rangeLimits(
      this._anchor,
      this.args.isDateUnavailable,
      this.args.minValue,
      this.args.maxValue
    );
  }

  /** The range to paint: the pending preview if anchored, else the committed one. */
  @cached
  private get displayRange(): DateRange | null {
    if (this._anchor) {
      const to = this._hovered ?? this.focusedDate;
      // Neither `hoverDay` nor `moveFocus` consults `pendingLimits` -- only
      // `selectDay` does -- so an unclamped `to` would paint the band
      // straight through an unavailable day it cannot actually select
      // (the disabled cell would sit inside a band that promises it is
      // reachable). Clamp here, once, for both the pointer and keyboard
      // paths.
      // `_anchor` is set, so `pendingLimits` is never null here.
      const pending = this.pendingLimits;
      let clamped = startOfDay(to);
      if (pending && isBefore(clamped, pending.min)) {
        clamped = pending.min;
      }
      if (pending && isAfter(clamped, pending.max)) {
        clamped = pending.max;
      }
      return normalizeRange(this._anchor, clamped);
    }

    const selected = this.selection;
    // A committed selection only counts once it has a real `end` -- a
    // half-open `{ start, end: null }` (written by the anchor step below)
    // must not surface here, or it would outlive `cancelPending()` clearing
    // `_anchor`/`_hovered` and leave a stale single-day range painted after
    // Escape.
    return selected &&
      !(selected instanceof Date) &&
      (selected as DateRange).end
      ? (selected as DateRange)
      : null;
  }

  hoverDay = (date: Date | null): void => {
    this._hovered = date ?? undefined;
  };

  cancelPending = (): void => {
    // The anchor step below commits a half-open `{ start, end: null }`
    // range so a controlled consumer sees the anchor immediately. That
    // commit must be retracted here, or a half-open range stays selected
    // (and `@onChange`-reported) forever with no way to clear it: `Escape`
    // only clears `_anchor`/`_hovered`, and `isDaySelected`/`stateFor` do
    // *not* special-case a null `end` -- only `displayRange`'s idle-branch
    // fallback does, and that fallback only matters once `_anchor` is
    // already gone. Retracting to `null` is the one unambiguous rollback
    // that works the same in controlled and uncontrolled mode.
    if (this.isRange && this._anchor) {
      const selected = this.selection;
      if (
        selected &&
        !(selected instanceof Date) &&
        (selected as DateRange).end === null
      ) {
        this.commit(null as CalendarValue<M>);
      }
    }

    this._anchor = undefined;
    this._hovered = undefined;
  };

  selectDay = (date: Date): void => {
    if (this.args.isReadOnly || this.isDayDisabled(date)) {
      return;
    }

    const day = startOfDay(date);

    // An outside day belongs to a month outside the visible window; follow
    // it so the newly selected day is never left off screen.
    if (!this.isWithinWindow(day)) {
      this.goToMonth(day);
    }

    if (!this.isRange) {
      this.commit(day as CalendarValue<M>);
      return;
    }

    if (!this._anchor) {
      this._anchor = day;
      this._hovered = day;
      // Goes through the normal `commit()` path, same as the final commit
      // below -- there is no need to special-case the anchor step. A
      // half-open `{ start, end: null }` selection is filtered out of
      // `displayRange`'s idle-branch fallback above, but `isDaySelected`/
      // `stateFor` do *not* treat a null-`end` range as unselected -- they
      // paint `selected.start` regardless. That is only safe here because
      // `cancelPending()` explicitly retracts this half-open commit (see
      // its comment); if the anchor is abandoned any other way, this day
      // stays selected with no way to clear it.
      this.commit({ start: day, end: null } as CalendarValue<M>);
      return;
    }

    this.commit(normalizeRange(this._anchor, day) as CalendarValue<M>);
    this._anchor = undefined;
    this._hovered = undefined;
  };

  private isDaySelected(date: Date): boolean {
    const selected = this.selection;

    if (selected instanceof Date) {
      return isSameDay(selected, date);
    }
    if (selected && 'start' in selected) {
      return (
        isSameDay(selected.start, date) ||
        Boolean(selected.end && isSameDay(selected.end, date))
      );
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
    if (this.args.isDisabled) {
      return true;
    }
    if (this.isDayOutsideRange(date) || this.isDayUnavailable(date)) {
      return true;
    }

    const pending = this.pendingLimits;
    if (pending && !isWithinBounds(date, pending.min, pending.max)) {
      return true;
    }

    return false;
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

  @cached
  get focusedDate(): Date {
    return this._focusedDate ?? this.defaultFocusedDate;
  }

  @cached
  private get defaultFocusedDate(): Date {
    const selected = this.selection;

    if (selected instanceof Date) {
      return selected;
    }
    if (selected && 'start' in selected) {
      return selected.start;
    }

    const today = startOfDay(new Date());
    return this.isWithinWindow(today) ? today : this.visibleMonth;
  }

  private moveFocus(date: Date): void {
    const next = startOfDay(date);

    if (this.isDayOutsideRange(next)) {
      return;
    }

    this._focusedDate = next;
    this.#shouldFocus = true;

    // Keyboard movement takes over the range preview from pointer hover:
    // clear any hovered day so `displayRange` falls back to `focusedDate`.
    // Without this, `_hovered` (set once at anchor time, or by a prior
    // `mouseenter`) would permanently shadow `focusedDate` and arrow-key
    // navigation would never move the preview. A later `mouseenter` still
    // hands control right back to the pointer via `hoverDay`.
    this._hovered = undefined;

    if (!this.isWithinWindow(next)) {
      this.goToMonth(next);
    }
  }

  /** Is `date` inside any of the currently visible months' window? */
  private isWithinWindow(date: Date): boolean {
    return this.months.some((m) => isSameMonth(date, m.month));
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

    // Escape must cancel a pending range regardless of where focus is --
    // the Previous/Next buttons and the month `<select>` also live under
    // this listener, and a range can be left pending while focus is on any
    // of them. This runs before the origin guard below (and still without
    // calling `preventDefault()`, same as before), so it does not disturb
    // that guard's job of leaving arrow keys on non-day controls alone.
    if (event.key === 'Escape') {
      this.cancelPending();
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
  /**
   * Set the first time `applyFocus` runs, then left `true` forever after.
   * `@autofocus`'s contract is "focus the grid on insert", not "focus the
   * grid every time this modifier reruns" -- and it reruns on every
   * `focusedDate` change, including ones the calendar causes itself (e.g.
   * paging a month away moves `defaultFocusedDate`, since it depends on
   * whether today is still in the visible window). Without this guard,
   * `@autofocus` would re-steal focus off of whatever the user just
   * interacted with (a nav button, in that example) on every such change.
   */
  #autofocusApplied = false;

  applyFocus = modifier(
    (element: HTMLElement, [focusedDate, isYearGridOpen]: [Date, boolean]) => {
      // Referenced only to establish the autotracking dependencies described
      // above -- the actual target element is looked up fresh below.
      // `isYearGridOpen` is one of them because the day grid is unmounted
      // while the year panel is up: focus requested during that time has to
      // wait for the grid to come back, and this is what wakes the modifier
      // when it does.
      void focusedDate;
      void isYearGridOpen;

      if (this.args.autofocus && !this.#autofocusApplied) {
        this.#autofocusApplied = true;
        this.#shouldFocus = true;
      }
      if (!this.#shouldFocus) {
        return;
      }

      this.#shouldFocus = false;
      element
        .querySelector<HTMLElement>('[data-fr-calendar-day][tabindex="0"]')
        ?.focus();
    }
  );

  /** How many months to render, starting at `visibleMonth`. */
  get visibleMonths(): number {
    return Math.max(1, this.args.visibleMonths ?? 1);
  }

  /** How far prev/next paging moves the window. */
  private get pageSize(): number {
    return this.args.pageBehavior === 'single' ? 1 : this.visibleMonths;
  }

  goToPrevious = (): void =>
    this.goToMonth(addMonths(this.visibleMonth, -this.pageSize));
  goToNext = (): void =>
    this.goToMonth(addMonths(this.visibleMonth, this.pageSize));

  /**
   * Whether a window whose first month is `firstMonth` has any day inside
   * `@minValue`/`@maxValue`.
   *
   * The single source of truth for month-level bounds. Every entry point that
   * can move the window -- the prev/next buttons, `goToMonth` (and so the
   * `setMonth`/`setYear` and `<:header>` paths through it), and the month
   * picker's option list -- asks this, so an affordance can never offer a
   * month the enforcement would then refuse.
   *
   * The whole window is tested, not just its first month: with several months
   * visible a bound can fall inside a later month, which is still a legitimate
   * place to land.
   */
  private canShowWindow(firstMonth: Date): boolean {
    const first = startOfMonth(firstMonth);
    const last = endOfMonth(addMonths(first, this.visibleMonths - 1));

    return (
      isWithinBounds(last, this.args.minValue, undefined) &&
      isWithinBounds(first, undefined, this.args.maxValue)
    );
  }

  get canGoPrevious(): boolean {
    if (this.args.isDisabled) {
      return false;
    }
    return this.canShowWindow(addMonths(this.visibleMonth, -this.pageSize));
  }

  get canGoNext(): boolean {
    if (this.args.isDisabled) {
      return false;
    }
    return this.canShowWindow(addMonths(this.visibleMonth, this.pageSize));
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
        this.goToMonth(new Date(year, this.visibleMonth.getMonth(), 1)),
      isYearGridOpen: this.isYearGridOpen,
      toggleYearGrid: this.toggleYearGrid
    };
  }

  @cached
  get months(): CalendarMonthData[] {
    return Array.from({ length: this.visibleMonths }, (_, i) =>
      buildMonthGrid({
        month: addMonths(this.visibleMonth, i),
        weekStartsOn: this.weekStartsOn,
        fixedWeeks: this.args.fixedWeeks ?? false
      })
    );
  }

  captionFor = (month: Date): string => {
    return formatMonthCaption(month, this.locale);
  };

  @cached
  get weekdays() {
    return formatWeekdays(this.locale, this.weekStartsOn);
  }

  get caption(): string {
    return formatMonthCaption(this.visibleMonth, this.locale);
  }

  /**
   * Memoized per `@locale` rather than constructed fresh in `stateFor` --
   * `Intl.DateTimeFormat` construction is not free, and `stateFor` runs
   * once per rendered day.
   */
  /** Reused across all twelve options rather than rebuilt per render. */
  @cached
  private get monthNameFormatter(): Intl.DateTimeFormat {
    return new Intl.DateTimeFormat(this.locale, { month: 'long' });
  }

  @cached
  private get dayLabelFormatter(): Intl.DateTimeFormat {
    return new Intl.DateTimeFormat(this.locale, {
      weekday: 'long',
      year: 'numeric',
      month: 'long',
      day: 'numeric'
    });
  }

  /**
   * One `Date` per render rather than one per cell. `stateFor` runs for every
   * rendered day -- 35 to 42 of them, more with several months visible -- and
   * they all need the same "today".
   */
  @cached
  private get today(): Date {
    return startOfDay(new Date());
  }

  get isReadOnly(): boolean {
    return this.args.isReadOnly ?? false;
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
      navButton: s.navButton({ class: c.navButton }),
      monthSelectWrapper: s.monthSelectWrapper({ class: c.monthSelectWrapper }),
      monthSelect: s.monthSelect({ class: c.monthSelect }),
      monthSelectValue: s.monthSelectValue({ class: c.monthSelectValue }),
      monthSelectIcon: s.monthSelectIcon({ class: c.monthSelectIcon }),
      yearTrigger: s.yearTrigger({ class: c.yearTrigger })
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
    const range = this.displayRange;
    const inRange = Boolean(
      range?.end && isWithinBounds(day.date, range.start, range.end)
    );

    // With more than one month visible and an explicit
    // `@showOutsideDays={{true}}`, a boundary date renders twice: once as
    // a real day in its own month's grid, once as a leading/trailing
    // outside day in the neighbouring grid. Both copies would otherwise
    // get an identical `DayState`, producing two `tabindex="0"` day
    // buttons (breaking the single-tab-stop invariant) and two
    // `aria-selected="true"` gridcells for one date. Suppressing the
    // roving tabstop and selected state on the outside-month copy lets the
    // real in-month cell own both. This only matters when the outside
    // copy actually renders as a duplicate -- a single visible month never
    // reaches this branch with `isOutside` true and a matching in-month
    // cell elsewhere, since there is no neighbouring grid to duplicate
    // into.
    const isOutsideDuplicate = day.isOutside && this.visibleMonths > 1;

    return {
      // The one place that decides whether a cell renders a day. `DayCell`
      // cannot work this out: it sees neither `@showOutsideDays` nor how many
      // months are on screen.
      rendersDay: day.isOutside ? this.showOutsideDays : true,
      date: day.date,
      dayOfMonth: day.dayOfMonth,
      isOutside: day.isOutside,
      isToday: isSameDay(day.date, this.today),
      isSelected: isOutsideDuplicate ? false : this.isDaySelected(day.date),
      isDisabled: this.isDayDisabled(day.date),
      isUnavailable: this.isDayUnavailable(day.date),
      isRangeStart: Boolean(range && isSameDay(range.start, day.date)),
      isRangeEnd: Boolean(range?.end && isSameDay(range.end, day.date)),
      isInRange: inRange,
      isPreview: inRange && this._anchor !== undefined,
      isFocused: isOutsideDuplicate
        ? false
        : isSameDay(day.date, this.focusedDate),
      isOutsideRange: this.isDayOutsideRange(day.date),
      ariaLabel: this.dayLabelFormatter.format(day.date)
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
      {{this.applyFocus this.focusedDate this.isYearGridOpen}}
      {{this.registerRoot}}
      ...attributes
    >
      {{! Header, year panel and grids share one column sized to the grids,
          so a wide footer block cannot stretch the header and pull the paging
          arrows away from the days they page. }}
      <div class={{this.styles.body class=@classes.body}}>
        {{#if (has-block "header")}}
          {{yield this.headerContext to="header"}}
        {{else}}
          <CalendarHeader
            @context={{this.headerContext}}
            @captionLayout={{this.captionLayout}}
            @months={{this.monthOptions}}
            @isYearGridOpen={{this.isYearGridOpen}}
            @onToggleYearGrid={{this.toggleYearGrid}}
            @classes={{this.headerClasses}}
          />
        {{/if}}

        <VisuallyHidden>
          <div data-fr-calendar-live aria-live="polite">{{this.caption}}</div>
        </VisuallyHidden>

        {{! The year panel stands in for the grids rather than stacking
            above them; otherwise picking a year pushes the days off screen. }}
        {{#if this.isYearGridOpen}}
          <YearGrid
            @years={{this.yearOptions}}
            @currentYear={{this.visibleYear}}
            @onSelect={{this.pickYear}}
            @onDismiss={{this.dismissYearGrid}}
            @classes={{this.yearGridClasses}}
          />
        {{else}}
          <div class={{this.styles.monthsWrapper class=@classes.monthsWrapper}}>
            {{#each this.months key="key" as |monthData|}}
              <MonthGrid
                @month={{monthData}}
                @weekdays={{this.weekdays}}
                @caption={{this.captionFor monthData.month}}
                @stateFor={{this.stateFor}}
                @isReadOnly={{this.isReadOnly}}
                @labelledBy={{@labelledBy}}
                @onSelect={{this.selectDay}}
                @onHover={{this.hoverDay}}
                @hasDayContent={{has-block "day"}}
                @hasWeekdayContent={{has-block "weekday"}}
                @classes={{this.gridClasses}}
              >
                <:day as |day|>{{yield day to="day"}}</:day>
                <:weekday as |wd|>{{yield wd to="weekday"}}</:weekday>
              </MonthGrid>
            {{/each}}
          </div>
        {{/if}}
      </div>

      {{#if (has-block "footer")}}
        <div
          data-fr-calendar-footer
          class={{this.styles.footer class=@classes.footer}}
        >{{yield to="footer"}}</div>
      {{/if}}
    </div>
  </template>
}

export default Calendar;
export { Calendar };
