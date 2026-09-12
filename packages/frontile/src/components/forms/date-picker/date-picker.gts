import Component from '@glimmer/component';
import { cached, tracked } from '@glimmer/tracking';
import { modifier } from 'ember-modifier';
import { concat, hash } from '@ember/helper';
import { useStyles } from '@frontile/theme';
import { FormControl } from '../form-control';
import { DatePickerTrigger } from './trigger';
import { DatePickerEndContent } from './end-content';
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
 * A date field: a button trigger showing the formatted value, and a calendar
 * in a popover. `@mode="range"` switches both the calendar and the value shape
 * to a `{ start, end }` range.
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

  constructor(owner: unknown, args: DatePickerArgs<M>) {
    super(owner as never, args as never);

    const seed = (args as { defaultValue?: unknown }).defaultValue;
    if (seed !== undefined) {
      this.internalValue = this.parseIncoming(seed);
    }
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
    if (raw !== undefined) {
      this.internalValue = this.parseIncoming(raw);
    }
  });

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
    trigger: () => this.triggerRef.current,
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
    this.internalValue = null;
    (this.args.onChange as ((v: null) => void) | undefined)?.(null);
    this.notifyForm();
    this.triggerRef.current?.focus();
  };

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

  handleChange = (value: CalendarValue<M>): void => {
    // Internal state updates even when controlled, so the calendar's own
    // rendering stays responsive; the `value` getter ignores it in that case,
    // so the consumer still has the last word.
    this.internalValue = value;
    (this.args.onChange as ((v: CalendarValue<M>) => void) | undefined)?.(
      value
    );
    this.notifyForm();

    if (this.isComplete(value)) this.close();
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
    this.triggerRef.current?.focus();
  };

  @cached
  get classes() {
    const { datePicker } = useStyles();
    return datePicker({ size: this.args.inputSize });
  }

  get isRangeMode(): boolean {
    return this.mode === 'range';
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
          >
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

            <DatePickerEndContent
              @classes={{this.classes}}
              @userClasses={{@classes}}
              @endContentPointerEvents={{@endContentPointerEvents}}
              @isClearable={{this.isClearable}}
              @onClear={{this.clear}}
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
            role="dialog"
            aria-label={{@label}}
          >
            {{#if (has-block "calendar")}}
              {{yield this.calendarBlockArg to="calendar"}}
            {{else}}
              <Calendar
                @mode={{this.mode}}
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
