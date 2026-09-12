import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { hash } from '@ember/helper';
import { useStyles } from '@frontile/theme';
import { FormControl } from '../form-control';
import { DatePickerTrigger } from './trigger';
import { Popover } from '../../overlays/popover';
import { Calendar } from '../../collections/calendar/calendar';
import { ref } from '../../../utils/ref';
import { formatValue, isEmptyValue, parseDate, parseRange } from './value';
import type {
  CalendarMode,
  CalendarValue,
  DateRange
} from '../../collections/calendar/types';
import type { DatePickerArgs, DatePickerValueBlockArg } from './types';

interface DatePickerSignature<M extends CalendarMode = 'single'> {
  Args: DatePickerArgs<M>;
  Blocks: {
    value: [DatePickerValueBlockArg<M>];
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

  /**
   * Uncontrolled selection. `@value` is only consulted when the consumer
   * passes it; passing it at all — `undefined` included — is what puts
   * selection in controlled mode, matching Calendar's own convention.
   */
  @tracked internalValue: CalendarValue<M> | null = null;

  @tracked isOpen = false;

  get isControlled(): boolean {
    return 'value' in this.args;
  }

  constructor(owner: unknown, args: DatePickerArgs<M>) {
    super(owner as never, args as never);

    const seed = (args as { defaultValue?: unknown }).defaultValue;
    if (seed !== undefined) {
      this.internalValue = (
        this.mode === 'range'
          ? parseRange(seed as never)
          : parseDate(seed as never)
      ) as CalendarValue<M> | null;
    }
  }

  get mode(): M {
    return (this.args as { mode?: M }).mode ?? ('single' as M);
  }

  get locale(): string {
    return this.args.locale ?? navigator.language;
  }

  /**
   * The value as `Date`s. Consumers may pass `yyyy-MM-dd` strings — `Field`
   * always does, since form data is strings — so every read of the value goes
   * through here rather than touching `@value` directly.
   */
  get value(): CalendarValue<M> | null {
    if (!this.isControlled) return this.internalValue;

    const raw = (this.args as { value?: unknown }).value;
    if (this.mode === 'range') {
      return parseRange(raw as never) as CalendarValue<M> | null;
    }
    return parseDate(raw as never) as CalendarValue<M> | null;
  }

  get formatted(): string {
    return formatValue(this.value, this.locale, this.args.formatOptions);
  }

  get isEmpty(): boolean {
    return isEmptyValue(this.value);
  }

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
   * string when there is no `@label`.
   */
  get accessibleName(): string {
    return [this.args.label, this.formatted].filter(Boolean).join(', ');
  }

  handleFocusOut = (): void => {
    // Replaced by ControlBlurTracker in Task 7, once there is a popover that
    // focus can legitimately move into.
    this.args.onBlur?.();
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

    if (this.isComplete(value)) this.close();
  };

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

  get classes() {
    const { datePicker } = useStyles();
    return datePicker({ size: this.args.inputSize });
  }

  <template>
    <div
      class={{this.classes.base class=@classes.base}}
      data-component="date-picker"
      data-part="base"
      ...attributes
    >
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
              @onFocusOut={{this.handleFocusOut}}
            >
              <:value>
                {{#if (has-block "value")}}
                  {{yield this.valueBlockArg to="value"}}
                {{/if}}
              </:value>
            </DatePickerTrigger>
          </div>

          {{! preventAutoFocus: overlay's default focus grab runs later()
          after Calendar's autofocus already focused the day; turned off so
          Calendar's autofocus is the only thing moving focus into the grid. }}
          <p.Content
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
          </p.Content>
        </Popover>
      </FormControl>
    </div>
  </template>
}

export { DatePicker, type DatePickerSignature };
export default DatePicker;
