import Component from '@glimmer/component';
import { cached, tracked } from '@glimmer/tracking';
import { modifier } from 'ember-modifier';
import { concat, hash } from '@ember/helper';
import { on } from '@ember/modifier';
import { warn } from '@ember/debug';
import { useStyles } from '@frontile/theme';
import { FormControl } from '../form-control';
import { DatePickerTrigger } from './trigger';
import { DatePickerEndContent } from './end-content';
import { SegmentGroup } from '../date-input/segment-group';
import {
  buildParts,
  toDate,
  fromDate,
  carryOver,
  hasTextualMonth,
  toNumericFormat,
  hasDateChanged
} from '../date-input/segments';
import { Popover } from '../../overlays/popover';
import { Calendar } from '../../collections/calendar/calendar';
import { ref } from '../../../utils/ref';
import { ControlBlurTracker } from '../../../-private/control-blur';
import { triggerFormInputEvent } from '../../../utils/forms-utils-index';
import {
  formatValue,
  isEmptyValue,
  parseDate,
  parseRange,
  toWire
} from './value';
import type {
  CalendarMode,
  CalendarValue,
  DateRange
} from '../../collections/calendar/types';
import type { Part } from '../date-input/types';
import type {
  DatePickerArgs,
  DatePickerValueBlockArg,
  DatePickerCalendarArgs,
  DatePickerFooterArg
} from './types';

interface DatePickerSignature<M extends CalendarMode = 'single'> {
  Args: DatePickerArgs<M>;
  Blocks: {
    value: [DatePickerValueBlockArg<M>];
    calendar: [DatePickerCalendarArgs<M>];
    footer: [DatePickerFooterArg<M>];
  };
  Element: HTMLDivElement;
}

/**
 * A date field: segments the value can be typed into, a calendar button that
 * opens a calendar in a popover, and -- under `@isEditable={{false}}` -- the
 * older button trigger showing the formatted value instead. `@mode="range"`
 * switches both the calendar and the value shape to a `{ start, end }` range,
 * and -- when editable -- renders two groups of segments with a separator
 * between them.
 */
class DatePicker<M extends CalendarMode = 'single'> extends Component<
  DatePickerSignature<M>
> {
  triggerRef = ref<HTMLButtonElement>();
  containerRef = ref<HTMLElement>();

  /**
   * The selection. Seeded from `@defaultValue`, updated by the user, and
   * synced from `@value` by {@link syncValue} whenever that argument changes.
   *
   * Everything renders from here rather than from `@value` directly -- see
   * {@link value} for why a read-through cannot work inside a `Form`.
   */
  @tracked internalValue: CalendarValue<M> | null = null;

  @tracked isOpen = false;

  /**
   * The segments, on the editable path. They are not a second source of truth
   * for the value -- {@link internalValue} is -- but they cannot be derived
   * from it either: mid-entry they hold digits that compose to no date at all,
   * which no `Date` can represent. The calendar writes here through
   * {@link commitValue}; typing writes there through {@link handlePartsChange}.
   */
  @tracked private trackedParts: Part[] = [];

  /**
   * The second group, in `@mode="range"` only. {@link trackedParts} is that
   * mode's *start* group, so every path that writes one writes both.
   */
  @tracked private trackedEndParts: Part[] = [];

  /**
   * An untracked mirror of {@link parts}. The sync modifiers below rebuild the
   * segments from the current ones, and reading the tracked field inside a
   * modifier would put it in that modifier's own tracking frame -- which the
   * same modifier then writes to, re-running itself forever. `DateInput`
   * carries the same pair for the same reason.
   */
  #currentParts: Part[] = [];

  /** The same mirror, for {@link trackedEndParts}. */
  #currentEndParts: Part[] = [];

  constructor(owner: unknown, args: DatePickerArgs<M>) {
    super(owner as never, args as never);

    const seed = (args as { defaultValue?: unknown }).defaultValue;
    if (seed !== undefined) {
      this.internalValue = this.parseIncoming(seed);
    }

    this.writeParts(this.internalValue, () =>
      buildParts(this.locale, this.segmentFormat)
    );
  }

  get parts(): Part[] {
    return this.trackedParts;
  }

  get endParts(): Part[] {
    return this.trackedEndParts;
  }

  private setParts(parts: Part[]): void {
    this.#currentParts = parts;
    this.trackedParts = parts;
  }

  private setEndParts(parts: Part[]): void {
    this.#currentEndParts = parts;
    this.trackedEndParts = parts;
  }

  /**
   * Writes a value across the segments, whichever mode is in play.
   *
   * `onto` supplies the list each group is written into -- the current
   * segments when a value moved, a freshly built row when the locale or the
   * format changed. It is a function because range mode needs two independent
   * lists and must not hand the same array to both groups.
   */
  private writeParts(
    value: CalendarValue<M> | null,
    onto: (edge: 'start' | 'end') => Part[]
  ): void {
    if (!this.isRangeMode) {
      this.setParts(fromDate(onto('start'), value as Date | null));
      return;
    }

    const range = value as DateRange | null;
    this.setParts(fromDate(onto('start'), range?.start ?? null));
    this.setEndParts(fromDate(onto('end'), range?.end ?? null));
  }

  /** Whether the value is typed rather than only picked. */
  get isSegmented(): boolean {
    return this.args.isEditable ?? true;
  }

  /**
   * The format the segments are built from. The editable default is numeric;
   * `{ dateStyle: 'medium' }` -- this component's own button default --
   * renders "Jan" and has no numeric segment to type into, so a textual
   * format falls back to the numeric default rather than rendering a field
   * nobody can type in.
   */
  get segmentFormat(): Intl.DateTimeFormatOptions | undefined {
    const given = this.args.formatOptions;
    if (!given) return undefined;

    if (!hasTextualMonth(given)) return given;

    warn(
      'An editable <DatePicker> needs numeric segments; ' +
        'a textual @formatOptions month falls back to a numeric one. ' +
        'Pass @isEditable={{false}} for the formatted button trigger.',
      false,
      { id: 'frontile.date-picker.textual-format' }
    );

    // Only the month is replaced; any other field the consumer named stands.
    return toNumericFormat(given);
  }

  get placeholderValue(): Date {
    return this.args.placeholderValue ?? new Date();
  }

  get mode(): M {
    return (this.args as { mode?: M }).mode ?? ('single' as M);
  }

  get locale(): string {
    return this.args.locale ?? navigator.language;
  }

  /**
   * The rendered value is always internal state, never a read-through to
   * `@value`; {@link syncValue} pushes `@value` into it whenever the argument
   * changes. This is the pattern `Select` uses, and reading through instead
   * deadlocks the component inside a `Form`: `Field` binds `@value` to the
   * form's data, the form's data comes from hidden inputs this component
   * renders, and those inputs would then render the very value they source.
   * Nothing could ever change it, so every pick after the first submit was
   * silently discarded.
   */
  get value(): CalendarValue<M> | null {
    return this.internalValue;
  }

  /** Normalizes whatever `@value` / `@defaultValue` was given to `Date`s. */
  private parseIncoming(raw: unknown): CalendarValue<M> | null {
    if (this.mode === 'range') {
      return parseRange(raw as never) as CalendarValue<M> | null;
    }
    return parseDate(raw as never) as CalendarValue<M> | null;
  }

  /**
   * Pushes `@value` into internal state when the argument changes. `undefined`
   * is ignored so that an uncontrolled picker -- and one bound by `Field`
   * before the form holds anything for it -- keeps whatever the user chose.
   */
  syncValue = modifier((_: HTMLDivElement, [raw]: [unknown]) => {
    if (raw === undefined) return;

    const parsed = this.parseIncoming(raw);
    this.internalValue = parsed;
    // The segments are a second rendering of the same value, so an argument
    // change has to reach them too; without this a `@value`-controlled picker
    // shows empty segments. `#currentParts` rather than `this.parts` -- see
    // the field's own comment.
    //
    // Unless the argument is merely the echo of our own `@onChange`: a
    // controlled consumer writes back what we just reported, and rewriting the
    // segments from it would destroy a partial entry. Backspacing one digit of
    // the year un-commits it, so the field composes `null`, reports `null`, and
    // is handed `null` straight back -- and `writeParts` would spend that on
    // clearing every other segment, both groups in range mode. One keystroke
    // would empty the field.
    if (this.isSegmented && this.segmentsWouldChange(parsed)) {
      this.writeParts(parsed, (edge) =>
        edge === 'start' ? this.#currentParts : this.#currentEndParts
      );
    }
  });

  /**
   * Rebuilds the segment order when the locale or format changes, carrying the
   * current value across so switching en-US to en-GB reorders the field
   * without emptying it. Reads no tracked state, so it runs on an argument
   * change and never on a keystroke.
   */
  syncSegmentFormat = modifier(
    (
      _: HTMLDivElement,
      [locale, format]: [string, Intl.DateTimeFormatOptions | undefined]
    ) => {
      if (!this.isSegmented) return;
      // Segment by segment rather than through the composed value, so a
      // half-typed entry survives the rebuild.
      this.setParts(carryOver(buildParts(locale, format), this.#currentParts));
      if (this.isRangeMode) {
        this.setEndParts(
          carryOver(buildParts(locale, format), this.#currentEndParts)
        );
      }
    }
  );

  get formatted(): string {
    return formatValue(this.value, this.locale, this.args.formatOptions);
  }

  get isEmpty(): boolean {
    return isEmptyValue(this.value);
  }

  @cached
  get valueBlockArg(): DatePickerValueBlockArg<M> {
    return {
      value: this.value,
      formatted: this.formatted,
      isEmpty: this.isEmpty
    };
  }

  /**
   * Names the trigger when a `:value` block owns its content. Falls back to
   * the formatted value alone rather than prefixing a hardcoded English
   * string when there is no `@label`. `undefined` (not `''`) when neither is
   * present, so the trigger omits `aria-label` entirely rather than setting
   * it to an empty string -- some assistive tech treats a present-but-empty
   * `aria-label` as overriding the visible text with nothing, leaving the
   * button unnamed.
   */
  get accessibleName(): string | undefined {
    const name = [this.args.label, this.formatted].filter(Boolean).join(', ');
    return name === '' ? undefined : name;
  }

  /**
   * Reports focus leaving the *whole* control -- the field and its portaled
   * popover -- rather than the trigger, which blurs on the way into the
   * calendar and on every day click.
   */
  blurTracker = new ControlBlurTracker({
    // Resolved through whichever element the popover's `trigger` modifier sits
    // on, because the tracker finds the portaled content by that element's
    // `aria-controls`. On the segmented path there is no button trigger: the
    // calendar button in the end content opens the popover instead, and
    // pointing this at nothing would make a click into the open calendar read
    // as a blur.
    trigger: () =>
      this.triggerRef.current ??
      this.containerRef.current?.querySelector<HTMLElement>(
        '[data-part="calendar-button"]'
      ),
    container: () => this.containerRef.current,
    isOpen: () => this.isOpen,
    isDestroyed: () => this.isDestroyed || this.isDestroying,
    onBlur: () => this.args.onBlur?.()
  });

  willDestroy(): void {
    super.willDestroy();
    // Nothing may resolve against a destroyed component.
    this.blurTracker.cancel();
  }

  /**
   * Whether the clear button takes the calendar icon's place. A disabled or
   * read-only field never shows it: the end-content cluster is not
   * pointer-transparent to it and it carries no disabled/read-only state of
   * its own, so it would otherwise be a live button that clears a field the
   * user may not change -- the same contract `Calendar` enforces for day
   * selection under `@isReadOnly`.
   */
  get isClearable(): boolean {
    return (
      Boolean(this.args.isClearable) &&
      !this.isEmpty &&
      !this.args.isDisabled &&
      !this.args.isReadOnly
    );
  }

  /**
   * Clearing removes the clear button from the DOM (`isClearable` flips
   * false the instant the value is gone), so -- like `close()` -- focus must
   * be handed back to the trigger explicitly or it falls to `<body>`.
   *
   * Unlike `close()`, clearing deliberately leaves an open popover open: the
   * clear button lives outside the popover entirely, so there is no
   * dangling-focus reason to dismiss the calendar, and a user who just
   * cleared the field is a user who likely wants to pick a new date right
   * away -- closing would just make them reopen it.
   */
  clear = (): void => {
    this.commitValue(null, { writeParts: true });
    this.focusField();
  };

  /**
   * Whatever the field's own focusable thing is: the button trigger, or --
   * when segmented -- the segment the user was last in, falling back to the
   * first one. A recorded segment that has left the DOM is not one focus can
   * go back to.
   */
  private focusTarget(): HTMLElement | null | undefined {
    if (!this.isSegmented) return this.triggerRef.current;

    const last = this.lastFocusedSegment;
    if (last && last.isConnected) return last;

    return this.containerRef.current?.querySelector<HTMLElement>(
      '[data-part="segment"]'
    );
  }

  private focusField(): void {
    this.focusTarget()?.focus();
  }

  /**
   * Whether the selection is finished, and the popover should therefore close.
   * A range with only its anchor set is not: the user still owes a second
   * click, and closing would throw away the half they just made.
   */
  private isComplete(value: CalendarValue<M> | null): boolean {
    if (!value) return false;
    if (this.mode !== 'range') return true;
    return (value as DateRange).end !== null;
  }

  /**
   * The one path a value change takes, whichever editor produced it.
   *
   * `writeParts` says whether the segments are that editor's output or its
   * input. The calendar, the `:footer` block and the clear button are all
   * *other* editors, and the segments have to be rewritten to show what they
   * did. Typing is the segments themselves: rewriting them there would
   * overwrite the buffer the user is still typing into, turning a half-typed
   * year back into a padded one on every completed keystroke.
   */
  private commitValue(
    value: CalendarValue<M> | null,
    { writeParts }: { writeParts: boolean }
  ): void {
    // Internal state updates even when controlled, so the calendar's own
    // rendering stays responsive; the `value` getter ignores it in that case,
    // so the consumer still has the last word.
    this.internalValue = value;

    if (writeParts && this.isSegmented) {
      this.writeParts(value, (edge) =>
        edge === 'start' ? this.#currentParts : this.#currentEndParts
      );
    }

    (
      this.args.onChange as ((v: CalendarValue<M> | null) => void) | undefined
    )?.(value);
    this.notifyForm();
  }

  handleChange = (value: CalendarValue<M>): void => {
    this.commitValue(value, { writeParts: true });

    if (this.isComplete(value)) this.close();
  };

  /**
   * The segments changed. Only value *transitions* are reported: the four
   * keystrokes that fill a month and a day compose no date at all, and report
   * nothing. The popover is deliberately left alone -- typing never opened it,
   * so completing a date by typing has nothing to close.
   */
  /**
   * Whether an incoming value differs from what the segments already compose.
   *
   * Compared edge by edge in range mode rather than by identity: the two are
   * distinct objects on every report, so an object comparison would always
   * say "changed" and defeat the guard entirely.
   */
  private segmentsWouldChange(incoming: CalendarValue<M> | null): boolean {
    if (!this.isRangeMode) {
      return hasDateChanged(
        toDate(this.#currentParts),
        incoming as Date | null
      );
    }

    const composed = this.rangeFromParts();
    const next = incoming as DateRange | null;

    return (
      hasDateChanged(composed?.start ?? null, next?.start ?? null) ||
      hasDateChanged(composed?.end ?? null, next?.end ?? null)
    );
  }

  handlePartsChange = (parts: Part[]): void => {
    const before = toDate(this.#currentParts);
    this.setParts(parts);
    const after = toDate(parts);

    if (!hasDateChanged(before, after)) return;

    this.commitValue(after as CalendarValue<M> | null, { writeParts: false });
  };

  /**
   * The two range groups report separately, but a range is one value: each
   * one recomposes the whole thing and reports only what moved.
   */
  handleStartParts = (parts: Part[]): void => {
    const before = this.rangeFromParts();
    this.setParts(parts);
    this.reportRange(before);
  };

  handleEndParts = (parts: Part[]): void => {
    const before = this.rangeFromParts();
    this.setEndParts(parts);
    this.reportRange(before);
  };

  /** Two dates pasted into the start group, which fill both. */
  handleRangePaste = (start: Part[], end: Part[]): void => {
    const before = this.rangeFromParts();
    this.setParts(start);
    this.setEndParts(end);
    this.reportRange(before);
  };

  /**
   * The range the two groups currently compose, or `null`.
   *
   * `DateRange.start` is a `Date`, not `Date | null`: a range is anchored at
   * its start, and the half-open shape the calendar produces mid-selection is
   * `{ start, end: null }` -- never the other way round. So segments that
   * compose no start compose no range at all, however complete the end group
   * is. That is what makes clearing the start report `null` rather than
   * leaving a consumer holding a range the field no longer shows; the end's
   * digits stay on screen, exactly as a half-typed single date's do.
   */
  private rangeFromParts(): DateRange | null {
    const start = toDate(this.#currentParts);
    if (!start) return null;

    return { start, end: toDate(this.#currentEndParts) };
  }

  /**
   * Reports the range only if it moved, which is the single-mode contract
   * applied to two ends: the keystrokes that fill a month and a day compose
   * nothing and report nothing, and either end changing is a change.
   */
  private reportRange(before: DateRange | null): void {
    const after = this.rangeFromParts();

    const moved =
      hasDateChanged(before?.start ?? null, after?.start ?? null) ||
      hasDateChanged(before?.end ?? null, after?.end ?? null);
    if (!moved) return;

    this.commitValue(after as CalendarValue<M> | null, { writeParts: false });
  }

  /**
   * The start and end groups' accessible names. Two `role="group"`s cannot
   * share one id or one name, and `FormControl`'s label can only be
   * associated with one element -- so each group names itself, deriving from
   * `@label` so that the visible label is contained in both names.
   */
  get startLabel(): string {
    return this.args.label ? `${this.args.label} start` : 'start date';
  }

  get endLabel(): string {
    return this.args.label ? `${this.args.label} end` : 'end date';
  }

  /**
   * The segment that last held focus, so that closing the calendar can hand
   * focus back to where the user was. Recorded from the group's `focusin`
   * rather than captured when the popover opens, because the calendar button
   * is clicked *after* focus has already left the segment.
   */
  private lastFocusedSegment: HTMLElement | null = null;

  handleSegmentFocusIn = (event: FocusEvent): void => {
    const target = event.target;
    if (
      target instanceof HTMLElement &&
      target.getAttribute('data-part') === 'segment'
    ) {
      this.lastFocusedSegment = target;
    }
  };

  /**
   * Tells an enclosing `Form` the value moved.
   *
   * The hidden inputs are written programmatically, and a programmatic value
   * change fires no `input` event -- so without this the form never learns
   * anything happened. That is worse than stale data: as soon as `Form` holds
   * any data for this field, `Field` binds `@value` back to it -- so without
   * this the form's copy of the value silently diverges from the field's, and
   * a later `@data` change would sync the stale value back in. `Select`
   * dispatches the same event for the same reason.
   */
  private notifyForm(): void {
    triggerFormInputEvent(this.containerRef.current);
  }

  /**
   * Wired to the popover's `@onOpenChange`, which also fires for Escape and
   * an outside click -- not only the explicit paths that already call
   * `close()` below. Routing every close through `close()` matters because
   * `Overlay`'s own focus-restore captures `document.activeElement` at the
   * moment its content mounts, which by then is already the day `@autofocus`
   * moved focus onto (that modifier runs before the overlay's own), not the
   * trigger. Left to it, closing would try to restore focus onto a day
   * button that has just been removed from the DOM -- a no-op -- and focus
   * would fall to `<body>`.
   */
  onOpenChange = (isOpen: boolean): void => {
    if (isOpen) {
      this.isOpen = true;
      return;
    }
    this.close();
  };

  /**
   * Closing removes the focused day from the DOM, so focus must be handed back
   * explicitly or it falls to `<body>` and the keyboard user loses their place.
   */
  close = (): void => {
    this.isOpen = false;
    this.focusField();
  };

  @cached
  get classes() {
    const { datePicker } = useStyles();
    return datePicker({
      size: this.args.inputSize,
      isSegmented: this.isSegmented,
      isRange: this.isSegmented && this.isRangeMode
    });
  }

  get isRangeMode(): boolean {
    return this.mode === 'range';
  }

  /**
   * The segmented field has no button trigger for a click to fall through to,
   * and its calendar icon is a real button, so the cluster has to take pointer
   * events. An explicit argument still wins.
   */
  get endContentPointerEvents(): 'none' | 'auto' {
    return (
      this.args.endContentPointerEvents ?? (this.isSegmented ? 'auto' : 'none')
    );
  }

  /**
   * The single-mode wire value, or `''` when there is nothing selected. Only
   * read from the single-mode branch of the template, so it does not repeat
   * that branch's mode check.
   */
  get wireValue(): string {
    return toWire(this.value as Date | null);
  }

  get wireRangeStart(): string {
    return toWire((this.value as DateRange | null)?.start ?? null);
  }

  get wireRangeEnd(): string {
    return toWire((this.value as DateRange | null)?.end ?? null);
  }

  @cached
  get calendarBlockArg(): DatePickerCalendarArgs<M> {
    return {
      mode: this.mode,
      color: this.args.color,
      value: this.value,
      onChange: this.handleChange,
      locale: this.locale,
      weekStartsOn: this.args.weekStartsOn,
      minValue: this.args.minValue,
      maxValue: this.args.maxValue,
      isDateUnavailable: this.args.isDateUnavailable,
      visibleMonths: this.args.visibleMonths,
      captionLayout: this.args.captionLayout,
      labelledBy: this.args.id,
      autofocus: true
    };
  }

  @cached
  get footerBlockArg(): DatePickerFooterArg<M> {
    return {
      // Deliberately `handleChange`, not a bare assignment: a preset must be
      // indistinguishable from a click, so it fires `@onChange` and closes on
      // a complete value exactly the way picking a day does.
      setValue: this.handleChange,
      close: this.close,
      value: this.value,
      isOpen: this.isOpen
    };
  }

  <template>
    <div
      {{this.syncSegmentFormat this.locale this.segmentFormat}}
      {{this.syncValue @value}}
      {{this.containerRef.setup}}
      class={{this.classes.base class=@classes.base}}
      data-component="date-picker"
      data-part="base"
      ...attributes
    >
      {{! A range's two names use dot notation, the convention Form documents
      for nested data -- so it arrives at a validator and at onSubmit as one
      { start, end } object rather than two loose keys. }}
      {{#if @name}}
        {{#if this.isRangeMode}}
          <input
            type="hidden"
            name={{concat @name ".start"}}
            value={{this.wireRangeStart}}
          />
          <input
            type="hidden"
            name={{concat @name ".end"}}
            value={{this.wireRangeEnd}}
          />
        {{else}}
          <input type="hidden" name={{@name}} value={{this.wireValue}} />
        {{/if}}
      {{/if}}
      <FormControl
        @id={{@id}}
        @size={{@inputSize}}
        @label={{@label}}
        @isRequired={{@isRequired}}
        @description={{@description}}
        @errors={{@errors}}
        @isInvalid={{@isInvalid}}
        @isDisabled={{@isDisabled}}
        as |c|
      >
        <Popover
          @placement={{@placement}}
          @flipOptions={{@flipOptions}}
          @middleware={{@middleware}}
          @shiftOptions={{@shiftOptions}}
          @offsetOptions={{@offsetOptions}}
          @strategy={{@strategy}}
          @didClose={{@didClose}}
          @isOpen={{this.isOpen}}
          @onOpenChange={{this.onOpenChange}}
          as |p|
        >
          <div
            {{p.anchor}}
            class={{this.classes.innerContainer class=@classes.innerContainer}}
            data-part="inner-container"
            {{! The shell is on this element when segmented, so its invalid and
            disabled styling has to read from here. `role="group"` inside
            cannot carry aria-invalid, which is why these are data
            attributes. }}
            data-invalid={{if c.isInvalid "true" "false"}}
            data-disabled={{if @isDisabled "true" "false"}}
          >
            {{#if this.isSegmented}}
              {{! Blur tracking and focus recording ride on splattributes:
              the group renders `...attributes` on its `role="group"` element,
              and both events bubble there from the segments. }}
              {{#if this.isRangeMode}}
                {{! Two groups, so neither can take `c.id` or `@label`: ids
                must be unique and a name shared by both would leave a screen
                reader unable to tell the ends apart. Each derives its own
                from the field's. }}
                <SegmentGroup
                  @parts={{this.parts}}
                  @onPartsChange={{this.handleStartParts}}
                  @onRangePaste={{this.handleRangePaste}}
                  @locale={{this.locale}}
                  @placeholderValue={{this.placeholderValue}}
                  @isDisabled={{@isDisabled}}
                  @isReadOnly={{@isReadOnly}}
                  @isInvalid={{c.isInvalid}}
                  @id={{concat c.id "-start"}}
                  @label={{this.startLabel}}
                  @describedBy={{c.describedBy @description c.isInvalid}}
                  @segmentLabels={{@segmentLabels}}
                  @classes={{this.classes}}
                  @userClasses={{@classes}}
                  {{on "focusin" this.handleSegmentFocusIn}}
                  {{on "focusout" this.blurTracker.handleFocusOut}}
                />
                <span
                  data-part="separator"
                  aria-hidden="true"
                  class={{this.classes.separator class=@classes.separator}}
                >&ndash;</span>
                {{! No `@onRangePaste`: pasting "20 Jan - 25 Jan" into the end
                of a range and having it rewrite the start would be
                surprising. }}
                <SegmentGroup
                  @parts={{this.endParts}}
                  @onPartsChange={{this.handleEndParts}}
                  @locale={{this.locale}}
                  @placeholderValue={{this.placeholderValue}}
                  @isDisabled={{@isDisabled}}
                  @isReadOnly={{@isReadOnly}}
                  @isInvalid={{c.isInvalid}}
                  @id={{concat c.id "-end"}}
                  @label={{this.endLabel}}
                  @describedBy={{c.describedBy @description c.isInvalid}}
                  @segmentLabels={{@segmentLabels}}
                  @classes={{this.classes}}
                  @userClasses={{@classes}}
                  {{on "focusin" this.handleSegmentFocusIn}}
                  {{on "focusout" this.blurTracker.handleFocusOut}}
                />
              {{else}}
                <SegmentGroup
                  @parts={{this.parts}}
                  @onPartsChange={{this.handlePartsChange}}
                  @locale={{this.locale}}
                  @placeholderValue={{this.placeholderValue}}
                  @isDisabled={{@isDisabled}}
                  @isReadOnly={{@isReadOnly}}
                  @isInvalid={{c.isInvalid}}
                  @id={{c.id}}
                  @label={{@label}}
                  @describedBy={{c.describedBy @description c.isInvalid}}
                  @segmentLabels={{@segmentLabels}}
                  @classes={{this.classes}}
                  @userClasses={{@classes}}
                  {{on "focusin" this.handleSegmentFocusIn}}
                  {{on "focusout" this.blurTracker.handleFocusOut}}
                />
              {{/if}}
            {{else}}
              <DatePickerTrigger
                @id={{c.id}}
                @trigger={{p.trigger}}
                @placeholder={{@placeholder}}
                @formatted={{this.formatted}}
                @isEmpty={{this.isEmpty}}
                @isDisabled={{@isDisabled}}
                @isInvalid={{c.isInvalid}}
                @hasCustomContent={{has-block "value"}}
                @accessibleName={{this.accessibleName}}
                @triggerRef={{this.triggerRef.setup}}
                @classes={{this.classes}}
                @userClasses={{@classes}}
                @onFocusOut={{this.blurTracker.handleFocusOut}}
              >
                <:value>
                  {{#if (has-block "value")}}
                    {{yield this.valueBlockArg to="value"}}
                  {{/if}}
                </:value>
              </DatePickerTrigger>
            {{/if}}

            <DatePickerEndContent
              @classes={{this.classes}}
              @userClasses={{@classes}}
              @endContentPointerEvents={{this.endContentPointerEvents}}
              @isClearable={{this.isClearable}}
              @onClear={{this.clear}}
              @isEditable={{this.isSegmented}}
              @trigger={{p.trigger}}
              @label={{@label}}
              @isDisabled={{@isDisabled}}
            />
          </div>

          {{! preventAutoFocus: overlay's default focus grab runs later()
          after Calendar's autofocus already focused the day; turned off so
          Calendar's autofocus is the only thing moving focus into the grid. }}
          <p.Content
            @size={{if @popoverSize @popoverSize "auto"}}
            @target={{@target}}
            @renderInPlace={{@renderInPlace}}
            @closeOnOutsideClick={{@closeOnOutsideClick}}
            @closeOnEscapeKey={{@closeOnEscapeKey}}
            @transitionDuration={{@transitionDuration}}
            @disableTransitions={{@disableTransitions}}
            @blockScroll={{false}}
            @preventAutoFocus={{true}}
            {{! Overlay captures document.activeElement when the content
            mounts -- the calendar button, on the segmented path -- and
            refocuses it on teardown, after close() has already put focus back
            on the segment. `close()` is the one answer; this stops the
            overlay giving a second. }}
            @preventFocusRestore={{this.isSegmented}}
            role="dialog"
            aria-label={{@label}}
          >
            {{#if (has-block "calendar")}}
              {{yield this.calendarBlockArg to="calendar"}}
            {{else}}
              <Calendar
                @mode={{this.mode}}
                @color={{@color}}
                @value={{this.value}}
                @onChange={{this.handleChange}}
                @locale={{@locale}}
                @weekStartsOn={{@weekStartsOn}}
                @minValue={{@minValue}}
                @maxValue={{@maxValue}}
                @isDateUnavailable={{@isDateUnavailable}}
                @visibleMonths={{@visibleMonths}}
                @captionLayout={{@captionLayout}}
                @fixedWeeks={{@fixedWeeks}}
                @showOutsideDays={{@showOutsideDays}}
                @isReadOnly={{@isReadOnly}}
                @isDisabled={{@isDisabled}}
                @labelledBy={{c.id}}
                @autofocus={{true}}
                @classes={{hash
                  base=(this.classes.calendar class=@classes.calendar)
                }}
                data-part="calendar"
              />
            {{/if}}

            {{#if (has-block "footer")}}
              <div
                data-part="footer"
                class={{this.classes.footer class=@classes.footer}}
              >
                {{yield this.footerBlockArg to="footer"}}
              </div>
            {{/if}}
          </p.Content>
        </Popover>
      </FormControl>
    </div>
  </template>
}

export { DatePicker, type DatePickerSignature };
export default DatePicker;
