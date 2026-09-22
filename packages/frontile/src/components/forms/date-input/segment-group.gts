import Component from '@glimmer/component';
import { cached } from '@glimmer/tracking';
import { fn } from '@ember/helper';
import { on } from '@ember/modifier';
import {
  isSegment,
  applyDigit,
  step,
  clearSegment,
  deleteDigit
} from './segments';
import type { Part, Segment, SegmentType, DateInputClasses } from './types';
import type { SlotsToClasses, DateInputSlots } from '@frontile/theme';

interface SegmentGroupSignature {
  Args: {
    parts: Part[];
    /** Hands the whole list back; the group holds no state of its own. */
    onPartsChange: (parts: Part[]) => void;
    locale: string;
    placeholderValue: Date;
    isDisabled?: boolean;
    isReadOnly?: boolean;
    isInvalid?: boolean;
    /** Rendered as the group's own id, so a `<label for>` can target it. */
    id?: string;
    /**
     * The field's name. A `role="group"` is not a labelable element, so a
     * sibling `<label for>` does not name it on its own -- this does.
     */
    label?: string;
    labelledBy?: string;
    describedBy?: string;
    segmentLabels?: Partial<Record<SegmentType, string>>;
    classes: DateInputClasses;
    userClasses?: SlotsToClasses<DateInputSlots>;
    onFocusOut?: (event: FocusEvent) => void;
  };
  Element: HTMLDivElement;
}

const DEFAULT_LABELS: Record<SegmentType, string> = {
  year: 'year',
  month: 'month',
  day: 'day'
};

/** How much PageUp/PageDown moves, per segment. */
const PAGE_STEP: Record<SegmentType, number> = { day: 7, month: 3, year: 10 };

/**
 * Everything one rendered part needs, resolved to primitives.
 *
 * The template cannot narrow the `Part` union -- `eq` is unavailable and Glint
 * does not carry a type predicate through `{{#if}}` -- so the narrowing happens
 * here, in TypeScript, and the template only ever reads optional primitives.
 * That keeps `part.type` off a `LiteralPart` without a cast anywhere.
 */
interface Cell {
  index: number;
  isSegment: boolean;
  /** The segment's display text, or the literal's text. */
  text: string;
  type?: SegmentType;
  isEmpty: boolean;
  label?: string;
  valueNow?: number;
  valueMin?: number;
  valueMax?: number;
  valueText?: string;
}

/**
 * One row of date segments. Private: `DateInput` and `DatePicker` both render
 * it, and neither wants the other's `FormControl` wrapper.
 */
class SegmentGroup extends Component<SegmentGroupSignature> {
  get isEditable(): boolean {
    return !this.args.isDisabled && !this.args.isReadOnly;
  }

  labelFor = (type: SegmentType): string =>
    this.args.segmentLabels?.[type] ?? DEFAULT_LABELS[type];

  /**
   * What a screen reader reads instead of the raw number. A month is read by
   * name -- "January", not "1" -- which is the whole point of `aria-valuetext`.
   */
  valueTextFor = (segment: Segment): string | undefined => {
    if (segment.value === null) return undefined;
    if (segment.type !== 'month') return String(segment.value);

    return new Intl.DateTimeFormat(this.args.locale, { month: 'long' }).format(
      new Date(2026, segment.value - 1, 1)
    );
  };

  /**
   * What the segment shows. The digits the user typed are the display where
   * there are any, so backspacing 2026 reads `202` rather than jumping to
   * `0202`; a two-digit segment is still padded, so a lone `1` in the month
   * reads `01` and the field does not reflow as it is typed. A year is never
   * padded mid-entry: its value is a two-digit year already resolved to four,
   * and showing `2002` the moment `2` is pressed would be a lie about what has
   * been entered.
   */
  displayFor = (segment: Segment): string => {
    if (segment.value === null) return segment.placeholder;

    const digits =
      segment.buffer === '' ? String(segment.value) : segment.buffer;

    return segment.type === 'year'
      ? digits
      : digits.padStart(segment.width, '0');
  };

  @cached
  get cells(): Cell[] {
    return this.args.parts.map((part, index) => {
      if (!isSegment(part)) {
        return { index, isSegment: false, isEmpty: false, text: part.text };
      }

      return {
        index,
        isSegment: true,
        text: this.displayFor(part),
        type: part.type,
        isEmpty: part.value === null,
        label: this.labelFor(part.type),
        // `undefined` rather than `null`: an empty segment has no current
        // value, and `aria-valuenow="null"` would be a value of sorts.
        valueNow: part.value ?? undefined,
        valueMin: part.min,
        valueMax: part.max,
        valueText: this.valueTextFor(part)
      };
    });
  }

  /** The segment elements, in document order -- the focus order too. */
  private segmentElements(from: HTMLElement): HTMLElement[] {
    const group = from.closest('[data-part="group"]');
    return group
      ? Array.from(group.querySelectorAll<HTMLElement>('[data-part="segment"]'))
      : [];
  }

  private focusSibling(from: HTMLElement, delta: number): void {
    const all = this.segmentElements(from);
    const next = all[all.indexOf(from) + delta];
    next?.focus();
  }

  private focusEdge(from: HTMLElement, edge: 'first' | 'last'): void {
    const all = this.segmentElements(from);
    (edge === 'first' ? all[0] : all[all.length - 1])?.focus();
  }

  /** Replaces one segment by index and reports the new list. */
  private replace(index: number, segment: Segment): void {
    const next = this.args.parts.map((part, i) =>
      i === index ? segment : part
    );
    this.args.onPartsChange(next);
  }

  handleKeyDown = (index: number, event: KeyboardEvent): void => {
    const part = this.args.parts[index];
    if (!part || !isSegment(part)) return;

    const element = event.target as HTMLElement;
    const { key } = event;

    // Navigation works even when the field is read-only; editing does not.
    if (key === 'ArrowRight') {
      event.preventDefault();
      this.focusSibling(element, 1);
      return;
    }
    if (key === 'ArrowLeft') {
      event.preventDefault();
      this.focusSibling(element, -1);
      return;
    }
    if (key === 'Home') {
      event.preventDefault();
      this.focusEdge(element, 'first');
      return;
    }
    if (key === 'End') {
      event.preventDefault();
      this.focusEdge(element, 'last');
      return;
    }

    if (!this.isEditable) return;

    if (key === 'ArrowUp' || key === 'ArrowDown') {
      event.preventDefault();
      const delta = key === 'ArrowUp' ? 1 : -1;
      this.replace(index, step(part, delta, this.args.placeholderValue));
      return;
    }

    if (key === 'PageUp' || key === 'PageDown') {
      event.preventDefault();
      const magnitude = PAGE_STEP[part.type];
      const delta = key === 'PageUp' ? magnitude : -magnitude;
      this.replace(index, step(part, delta, this.args.placeholderValue));
      return;
    }

    if (key === 'Backspace') {
      event.preventDefault();
      this.replace(index, deleteDigit(part));
      return;
    }

    if (key === 'Delete') {
      event.preventDefault();
      this.replace(index, clearSegment(part));
      return;
    }

    if (/^\d$/.test(key)) {
      event.preventDefault();
      const { segment, isFull } = applyDigit(part, key);
      this.replace(index, segment);
      // Advancing before the DOM has caught up is safe: the segment elements
      // are keyed by index and are updated, never re-created.
      if (isFull) this.focusSibling(element, 1);
      return;
    }

    // Everything else -- letters, symbols -- would otherwise be inserted into
    // the contenteditable span as literal text.
    if (key.length === 1 && !event.metaKey && !event.ctrlKey) {
      event.preventDefault();
    }
  };

  /**
   * `contenteditable`'s hazard: anything not handled above arrives here and
   * would be written into the span's DOM, desynchronising the display from the
   * model. Every input type is refused; the model is the only writer.
   */
  handleBeforeInput = (event: Event): void => {
    event.preventDefault();
  };

  noop = (): void => {};

  <template>
    <div
      role="group"
      data-part="group"
      id={{@id}}
      aria-label={{@label}}
      aria-labelledby={{@labelledBy}}
      aria-describedby={{@describedBy}}
      aria-disabled={{if @isDisabled "true"}} class={{@classes.group class=@userClasses.group}}
      {{on "focusout" (if @onFocusOut @onFocusOut this.noop)}}
      ...attributes
    >
      {{#each this.cells key="index" as |cell|}}
        {{#if cell.isSegment}}
          <span
            role="spinbutton"
            tabindex={{unless @isDisabled "0"}}
            contenteditable={{if this.isEditable "true" "false"}}
            inputmode="numeric"
            spellcheck="false"
            autocorrect="off"
            data-part="segment"
            data-type={{cell.type}}
            data-placeholder={{if cell.isEmpty "true" "false"}}
            data-disabled={{if @isDisabled "true" "false"}}
            aria-label={{cell.label}}
            aria-valuenow={{cell.valueNow}}
            aria-valuemin={{cell.valueMin}}
            aria-valuemax={{cell.valueMax}}
            aria-valuetext={{cell.valueText}}
            class={{@classes.segment class=@userClasses.segment}}
            {{on "keydown" (fn this.handleKeyDown cell.index)}}
            {{on "beforeinput" this.handleBeforeInput}}
          >{{cell.text}}</span>
        {{else}}
          <span
            data-part="literal"
            aria-hidden="true"
            class={{@classes.literal class=@userClasses.literal}}
          >{{cell.text}}</span>
        {{/if}}
      {{/each}}
    </div>
  </template>
}

export { SegmentGroup, type SegmentGroupSignature };
export default SegmentGroup;
