import Component from '@glimmer/component';
import { cached } from '@glimmer/tracking';
import { fn } from '@ember/helper';
import { on } from '@ember/modifier';
import {
  isSegment,
  applyDigit,
  commitSegment,
  step,
  clearSegment,
  deleteDigit,
  displaySegment
} from './segments';
import { parsePasted, formatForClipboard } from './clipboard';
import type {
  Part,
  Segment,
  SegmentType,
  SegmentGroupClasses,
  SegmentGroupUserClasses
} from './types';

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
    /**
     * Only the three slots this group renders, so that `DateInput`'s
     * `dateInput` recipe and `DatePicker`'s `datePicker` recipe both satisfy
     * it. See {@link SegmentGroupClasses}.
     */
    classes: SegmentGroupClasses;
    userClasses?: SegmentGroupUserClasses;
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

  @cached
  get cells(): Cell[] {
    return this.args.parts.map((part, index) => {
      if (!isSegment(part)) {
        return { index, isSegment: false, isEmpty: false, text: part.text };
      }

      return {
        index,
        isSegment: true,
        text: displaySegment(part),
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

  /**
   * Left and right are *visual* directions, so in an RTL locale they run
   * against document order: pressing the left arrow in `yyyy/mm/dd` laid out
   * right-to-left should move to the segment drawn to the left, which is the
   * later one in the DOM.
   */
  private focusSibling(from: HTMLElement, delta: number): void {
    const all = this.segmentElements(from);
    const step = this.isRtl(from) ? -delta : delta;
    const next = all[all.indexOf(from) + step];
    next?.focus();
  }

  private isRtl(from: HTMLElement): boolean {
    const group = from.closest<HTMLElement>('[data-part="group"]') ?? from;
    return getComputedStyle(group).direction === 'rtl';
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
   * Leaving a segment finishes it: the digits in it stop being something the
   * user is still typing and become their answer, which is what turns a typed
   * `26` into 2026. Tab, arrow-key navigation and a click elsewhere all arrive
   * here, because moving focus is the one thing they have in common.
   */
  handleFocusOut = (index: number): void => {
    if (!this.isEditable) return;

    const part = this.args.parts[index];
    if (!part || !isSegment(part) || part.isCommitted) return;

    const committed = commitSegment(part);
    // An empty segment commits to itself; reporting it would be churn.
    if (committed !== part) this.replace(index, committed);
  };

  /**
   * `contenteditable`'s hazard: anything not handled above arrives here and
   * would be written into the span's DOM, desynchronising the display from the
   * model. Every input type is refused; the model is the only writer.
   */
  handleBeforeInput = (event: Event): void => {
    event.preventDefault();
  };

  /**
   * Always `preventDefault`: the browser would otherwise write the pasted text
   * into the contenteditable span, and the model would no longer describe what
   * is on screen. Unparseable text is dropped silently -- a date field that
   * guessed would be worse than one that declined.
   */
  handlePaste = (event: ClipboardEvent): void => {
    event.preventDefault();
    if (!this.isEditable) return;

    const text = event.clipboardData?.getData('text/plain') ?? '';
    const parsed = parsePasted(text, this.args.parts);
    if (parsed) this.args.onPartsChange(parsed);
  };

  handleCopy = (event: ClipboardEvent): void => {
    event.preventDefault();
    event.clipboardData?.setData(
      'text/plain',
      formatForClipboard(this.args.parts)
    );
  };

  handleCut = (event: ClipboardEvent): void => {
    this.handleCopy(event);
    if (!this.isEditable) return;

    this.args.onPartsChange(
      this.args.parts.map((p) => (isSegment(p) ? clearSegment(p) : p))
    );
  };

  <template>
    <div
      role="group"
      data-part="group"
      id={{@id}}
      aria-label={{@label}}
      aria-labelledby={{@labelledBy}}
      aria-describedby={{@describedBy}}
      aria-disabled={{if @isDisabled "true"}}
      {{! `role="group"` supports neither aria-readonly nor aria-invalid --
          neither is global in ARIA 1.2, and ember-template-lint's
          no-unsupported-role-attributes is right to reject them here (its
          autofixer deletes them silently, which is how they went missing
          once already). Both live on the spinbuttons below instead, where
          the role does support them and where assistive technology actually
          lands. These data attributes carry the same state for styling and
          for tests. }}
      data-readonly={{if @isReadOnly "true" "false"}}
      data-invalid={{if @isInvalid "true" "false"}}
      class={{@classes.group class=@userClasses.group}}
      {{on "paste" this.handlePaste}}
      {{on "copy" this.handleCopy}}
      {{on "cut" this.handleCut}}
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
            aria-readonly={{if @isReadOnly "true"}}
            aria-invalid={{if @isInvalid "true"}}
            aria-label={{cell.label}}
            aria-valuenow={{cell.valueNow}}
            aria-valuemin={{cell.valueMin}}
            aria-valuemax={{cell.valueMax}}
            aria-valuetext={{cell.valueText}}
            class={{@classes.segment class=@userClasses.segment}}
            {{on "keydown" (fn this.handleKeyDown cell.index)}}
            {{on "focusout" (fn this.handleFocusOut cell.index)}}
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
