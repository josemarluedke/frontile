import Component from '@glimmer/component';
import { cached, tracked } from '@glimmer/tracking';
import { on } from '@ember/modifier';
import { modifier } from 'ember-modifier';
import { warn } from '@ember/debug';
import { useStyles } from '@frontile/theme';
import { FormControl } from '../form-control';
import { SegmentGroup } from './segment-group';
import { buildParts, toDate, fromDate, isSegment } from './segments';
import { parseDate, toWire } from '../date-picker/value';
import { ref } from '../../../utils/ref';
import { triggerFormInputEvent } from '../../../utils/forms-utils-index';
import type { Part, DateInputArgs, DateInputClasses } from './types';

interface DateInputSignature {
  Args: DateInputArgs;
  Element: HTMLDivElement;
}

/**
 * A date typed into segments rather than picked from a grid. `DatePicker`
 * renders the same segments and adds a calendar.
 */
class DateInput extends Component<DateInputSignature> {
  containerRef = ref<HTMLElement>();

  /**
   * The segments are the state, not the value: mid-entry they hold digits that
   * compose to no date at all, which no `Date` can represent.
   */
  @tracked private trackedParts: Part[] = [];

  /**
   * An untracked mirror of {@link parts}. The sync modifiers below need to
   * read the current segments in order to rebuild them, and reading the
   * tracked field inside a modifier would put it in that modifier's own
   * tracking frame -- which the same modifier then writes to, re-running
   * itself forever.
   */
  #currentParts: Part[] = [];

  constructor(owner: unknown, args: DateInputArgs) {
    super(owner as never, args);

    const seed = args.defaultValue;
    this.setParts(
      fromDate(
        buildParts(this.locale, this.formatOptions),
        seed === undefined ? null : parseDate(seed)
      )
    );
  }

  get parts(): Part[] {
    return this.trackedParts;
  }

  private setParts(parts: Part[]): void {
    this.#currentParts = parts;
    this.trackedParts = parts;
  }

  get locale(): string {
    return this.args.locale ?? navigator.language;
  }

  get formatOptions(): Intl.DateTimeFormatOptions | undefined {
    const given = this.args.formatOptions;
    if (!given) return undefined;

    // A textual month has no numeric segment to type into, so it is refused
    // rather than rendered unusable. `dateStyle: 'medium'` is the common way
    // to hit this -- it is DatePicker's button-trigger default.
    const isTextual =
      given.dateStyle !== undefined ||
      given.month === 'long' ||
      given.month === 'short' ||
      given.month === 'narrow';

    if (isTextual) {
      warn(
        '<DateInput> needs numeric segments; ' +
          'a textual @formatOptions month falls back to a numeric one.',
        false,
        { id: 'frontile.date-input.textual-format' }
      );
      return undefined;
    }

    return given;
  }

  /** The composed value, or null while any segment is empty. */
  get value(): Date | null {
    return toDate(this.parts);
  }

  get wireValue(): string {
    return toWire(this.value);
  }

  get isEmpty(): boolean {
    return this.parts.filter(isSegment).every((p) => p.value === null);
  }

  get placeholderValue(): Date {
    return this.args.placeholderValue ?? new Date();
  }

  /**
   * Whether the composed value is outside the allowed range. Never blocks a
   * keystroke -- typing toward 2020 passes through 2, 20 and 202 on the way,
   * and a field that refused those could not be typed into at all.
   */
  get isOutOfRange(): boolean {
    const value = this.value;
    if (!value) return false;

    if (this.args.minValue && value < this.args.minValue) return true;
    if (this.args.maxValue && value > this.args.maxValue) return true;
    return this.args.isDateUnavailable?.(value) ?? false;
  }

  get isInvalid(): boolean {
    return Boolean(this.args.isInvalid) || this.isOutOfRange;
  }

  /**
   * Pushes `@value` into the segments when the argument changes. `undefined`
   * is ignored, so a field bound by `Field` before the form holds anything for
   * it keeps what the user typed -- the rule `DatePicker` documents.
   */
  syncValue = modifier(
    (_: HTMLElement, [raw]: [Date | string | null | undefined]) => {
      if (raw === undefined) return;
      this.setParts(fromDate(this.#currentParts, parseDate(raw)));
    }
  );

  /**
   * Rebuilds the segment order when the locale or format changes, carrying the
   * current value across so switching en-US to en-GB reorders the field
   * without emptying it.
   */
  syncLocale = modifier(
    (
      _: HTMLElement,
      [locale, format]: [string, Intl.DateTimeFormatOptions | undefined]
    ) => {
      const current = toDate(this.#currentParts);
      this.setParts(fromDate(buildParts(locale, format), current));
    }
  );

  handlePartsChange = (parts: Part[]): void => {
    const before = toDate(this.#currentParts);
    this.setParts(parts);
    const after = toDate(parts);

    // Only value transitions are reported. The four keystrokes that fill a
    // month and a day compose no date at all, and report nothing.
    const changed =
      (before === null) !== (after === null) ||
      (before !== null &&
        after !== null &&
        before.getTime() !== after.getTime());

    if (changed) {
      this.args.onChange?.(after);
      triggerFormInputEvent(this.containerRef.current);
    }
  };

  /**
   * `@onBlur` means "the user left the field", not "the user left a segment",
   * so a move between segments is filtered out by asking whether focus landed
   * inside the container. `DatePicker` needs `ControlBlurTracker` for this
   * because its focus can legitimately be in a popover outside its own DOM;
   * this field has no popover, so containment is the whole question.
   */
  handleFocusOut = (event: FocusEvent): void => {
    const container = this.containerRef.current;
    const next = event.relatedTarget;

    if (container && next instanceof Node && container.contains(next)) return;

    this.args.onBlur?.();
  };

  clear = (): void => {
    this.handlePartsChange(fromDate(this.#currentParts, null));
  };

  @cached
  get classes(): DateInputClasses {
    const { dateInput } = useStyles();
    return dateInput({ size: this.args.inputSize });
  }

  <template>
    <div
      {{this.syncLocale this.locale this.formatOptions}}
      {{this.syncValue @value}}
      {{this.containerRef.setup}}
      {{on "focusout" this.handleFocusOut}}
      class={{this.classes.base class=@classes.base}}
      data-component="date-input"
      data-part="base"
      ...attributes
    >
      {{#if @name}}
        <input type="hidden" name={{@name}} value={{this.wireValue}} />
      {{/if}}

      <FormControl
        @id={{@id}}
        @size={{@inputSize}}
        @label={{@label}}
        @isRequired={{@isRequired}}
        @description={{@description}}
        @errors={{@errors}}
        @isInvalid={{this.isInvalid}}
        @isDisabled={{@isDisabled}}
        as |c|
      >
        <div
          class={{this.classes.innerContainer class=@classes.innerContainer}}
          data-part="inner-container"
        >
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
          />
        </div>
      </FormControl>
    </div>
  </template>
}

export { DateInput, type DateInputSignature };
export default DateInput;
