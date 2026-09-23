import Component from '@glimmer/component';
import { cached, tracked } from '@glimmer/tracking';
import { on } from '@ember/modifier';
import { modifier } from 'ember-modifier';
import { useStyles } from '@frontile/theme';
import { FormControl } from '../form-control';
import { CloseButton } from '../../buttons/close-button';
import { SegmentGroup } from './segment-group';
import {
  buildParts,
  toDate,
  fromDate,
  isSegment,
  carryOver,
  resolveSegmentFormat,
  hasDateChanged
} from './segments';
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
    // A textual month has no numeric segment to type into, so it falls back
    // to a numeric one. `dateStyle: 'medium'` is the common way to hit this --
    // it is DatePicker's button-trigger default. Only the month is replaced:
    // the rest of the format is the consumer's and stands.
    return resolveSegmentFormat(this.args.formatOptions, {
      message:
        '<DateInput> needs numeric segments; ' +
        'a textual @formatOptions month falls back to a numeric one.',
      id: 'frontile.date-input.textual-format'
    });
  }

  /**
   * The composed value, or null while any segment is empty.
   *
   * Cached because `wireValue`, `isOutOfRange` and the template all read it
   * independently, and each `toDate` walks the parts three times over.
   */
  @cached
  get value(): Date | null {
    return toDate(this.parts);
  }

  get wireValue(): string {
    return toWire(this.value);
  }

  get isEmpty(): boolean {
    return this.parts.every((p) => !isSegment(p) || p.value === null);
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

      const parsed = parseDate(raw);

      // Ignore the echo of our own `@onChange`. A controlled consumer writes
      // back the value this field just reported, and rewriting the segments
      // from it would destroy a partial entry: backspacing one digit of the
      // year un-commits it, so the field composes `null`, reports `null`, and
      // is handed `null` straight back -- which `fromDate` would spend on
      // clearing every other segment too. One keystroke would empty the field.
      if (!hasDateChanged(toDate(this.#currentParts), parsed)) return;

      this.setParts(fromDate(this.#currentParts, parsed));
    }
  );

  /**
   * Rebuilds the segment order when the locale or format changes, carrying
   * each segment's own state across so switching en-US to en-GB reorders the
   * field without emptying it -- half-typed digits included, which is why
   * this goes segment by segment rather than through the composed value.
   */
  syncLocale = modifier(
    (
      _: HTMLElement,
      [locale, format]: [string, Intl.DateTimeFormatOptions | undefined]
    ) => {
      this.setParts(carryOver(buildParts(locale, format), this.#currentParts));
    }
  );

  handlePartsChange = (parts: Part[]): void => {
    const before = toDate(this.#currentParts);
    this.setParts(parts);
    const after = toDate(parts);

    // Only value transitions are reported. The four keystrokes that fill a
    // month and a day compose no date at all, and report nothing.
    if (hasDateChanged(before, after)) {
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

  /**
   * A disabled or read-only field never offers it: it carries no disabled
   * state of its own and would be a live button clearing a field the user may
   * not change.
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
   * false the instant the value is gone), so focus must be handed somewhere
   * explicitly or it falls to `<body>` and a keyboard user loses their place.
   */
  clear = (): void => {
    this.handlePartsChange(fromDate(this.#currentParts, null));
    this.containerRef.current
      ?.querySelector<HTMLElement>('[data-part="segment"]')
      ?.focus();
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
          {{! The field shell lives here, not on the segment row, so the clear
          button sits inside the border. `role="group"` supports neither
          aria-invalid nor aria-disabled, so the shell styles off these. }}
          data-invalid={{if c.isInvalid "true" "false"}}
          data-disabled={{if @isDisabled "true" "false"}}
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
          {{#if this.isClearable}}
            <div
              data-part="end-content"
              class={{this.classes.endContent class=@classes.endContent}}
            >
              <CloseButton
                @title="Clear"
                @variant="soft"
                @size="xs"
                @class={{this.classes.clearButton class=@classes.clearButton}}
                data-part="clear-button"
                @onPress={{this.clear}}
              />
            </div>
          {{/if}}
        </div>
      </FormControl>
    </div>
  </template>
}

export { DateInput, type DateInputSignature };
export default DateInput;
