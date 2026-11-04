import Component from '@glimmer/component';
import { cached } from '@glimmer/tracking';
import { fn } from '@ember/helper';
import { on } from '@ember/modifier';
import { htmlSafe } from '@ember/template';
import { modifier } from 'ember-modifier';
import { isSegment, seedFrom } from '../date-input/segments';
import { revealWithin } from '../../../-private/reveal-within';
import type { Part, Segment, SegmentType } from '../date-input/types';
import type { DatePickerClasses } from './types';
import type { SlotsToClasses, DatePickerSlots } from '@frontile/theme';

const TIME_TYPES: SegmentType[] = ['hour', 'minute', 'dayPeriod'];

/** How far PageUp and PageDown move, in options. */
const PAGE_STEP = 5;

/** How long typed characters keep adding up to one search, in ms. */
const TYPEAHEAD_TIMEOUT = 1000;

interface TimeOption {
  value: number;
  label: string;
  isSelected: boolean;
  /** The column's one tab stop. */
  isTabbable: boolean;
}

interface TimeColumn {
  type: SegmentType;
  label: string;
  labelId: string;
  /** The value the column shows as picked, or `null`. Re-reveals on change. */
  selected: number | null;
  options: TimeOption[];
  /** Picking here finishes the time, so a click on it closes the popover. */
  isLast: boolean;
}

interface DatePickerTimeColumnsSignature {
  Args: {
    /** The field's segments; the columns render its time ones. */
    parts: Part[];
    /** The minutes offered, as a step from :00. */
    minuteStep: number;
    /** What an empty column offers to start from. */
    placeholderValue: Date;
    /** The group's accessible name. */
    label: string;
    /** Each column's visible name, which is also its accessible one. */
    columnLabel: (type: SegmentType) => string;
    /** Prefix for the column names' ids. */
    idPrefix: string;
    isReadOnly?: boolean;
    /**
     * An option was picked. `commit` is true when the pick finishes the
     * time -- Enter, or a click in the last column -- and the popover should
     * close.
     */
    onSelect: (type: SegmentType, value: number, commit: boolean) => void;
    classes: DatePickerClasses;
    userClasses?: SlotsToClasses<DatePickerSlots>;
  };
}

const pad = (value: number): string => String(value).padStart(2, '0');

function range(min: number, max: number, step = 1): number[] {
  const out: number[] = [];
  for (let value = min; value <= max; value += step) out.push(value);
  return out;
}

/**
 * The values a column offers, in the order they are listed.
 *
 * A 12-hour clock lists 12 first, the way it reads from midnight. Minutes
 * follow `minuteStep`, plus the current minute when it is off the step: a
 * 10:07 typed into the segments must still show as picked, not as nothing.
 */
function valuesFor(segment: Segment, minuteStep: number): number[] {
  if (segment.type === 'hour' && segment.hourCycle === 'h12') {
    return [12, ...range(1, 11)];
  }

  if (segment.type === 'minute') {
    const values = range(segment.min, segment.max, minuteStep);
    const current = segment.value;
    if (current !== null && !values.includes(current)) {
      values.push(current);
      values.sort((a, b) => a - b);
    }
    return values;
  }

  return range(segment.min, segment.max);
}

/**
 * The option an empty column starts from: the placeholder's, or for minutes
 * the step at or before it, so a keyboard user tabbing in lands near now
 * rather than at the top of the list.
 */
function startingValue(
  segment: Segment,
  values: number[],
  placeholderValue: Date
): number | undefined {
  const seed = seedFrom(segment, placeholderValue);
  if (values.includes(seed)) return seed;
  return values.filter((value) => value <= seed).pop() ?? values[0];
}

/** One column's options, in order. */
function optionsOf(list: HTMLElement): HTMLElement[] {
  return [...list.querySelectorAll<HTMLElement>('[data-part="time-option"]')];
}

/**
 * The time part of a date picker's popover: a scrolling list per time
 * segment -- hours, minutes, and AM/PM on a 12-hour clock -- in the order the
 * locale writes them.
 *
 * Each list is a single-select `listbox` with roving focus, the same pattern
 * as the calendar's year panel: one tab stop per column, the arrow keys move
 * and pick together (selection follows focus, as in a native `<select>`),
 * and typing jumps to a value. The columns edit the very segments the field
 * renders, so there is still one value: picking here shows there at once,
 * and what was typed there is what is picked here.
 */
class DatePickerTimeColumns extends Component<DatePickerTimeColumnsSignature> {
  #typed = '';
  #typedAt = 0;

  /**
   * The key that is about to click an option, if any. Enter and Space are
   * left to the button, which clicks on Enter's keydown and Space's keyup in
   * every browser; preventing them on keydown instead does not stop Space's
   * click everywhere. The click then knows how it came about.
   */
  #activationKey: string | null = null;

  @cached
  get columns(): TimeColumn[] {
    const segments = this.args.parts.filter(
      (part): part is Segment =>
        isSegment(part) && TIME_TYPES.includes(part.type)
    );

    return segments.map((segment, index) => {
      const values = valuesFor(segment, this.args.minuteStep);
      const selected =
        segment.value !== null && values.includes(segment.value)
          ? segment.value
          : null;
      const tabbable =
        selected ?? startingValue(segment, values, this.args.placeholderValue);

      return {
        type: segment.type,
        label: this.args.columnLabel(segment.type),
        labelId: `${this.args.idPrefix}-${segment.type}`,
        selected,
        isLast: index === segments.length - 1,
        options: values.map((value) => ({
          value,
          label: segment.labels?.[value] ?? pad(value),
          isSelected: value === selected,
          isTabbable: value === tabbable
        }))
      };
    });
  }

  /** Reserves the columns' width; see the `time` slot. */
  get style() {
    return htmlSafe(`--time-columns: ${this.columns.length}`);
  }

  /**
   * Keeps the picked option in view: centred when the popover opens, and
   * just far enough when it moves after that. Runs again whenever the
   * column's pick changes, whoever changed it.
   */
  reveal = modifier((list: HTMLElement, [selected]: [number | null]) => {
    const target =
      optionsOf(list).find((option) => option.tabIndex === 0) ??
      optionsOf(list)[0];
    if (!target) return;

    const isFirstRun = !list.dataset['revealed'];
    list.dataset['revealed'] = 'true';
    revealWithin(list, target, isFirstRun);
    // `selected` is read only to re-run on a change.
    void selected;
  });

  select = (column: TimeColumn, value: number, commit: boolean): void => {
    if (this.args.isReadOnly) return;
    this.args.onSelect(column.type, value, commit);
  };

  /**
   * Picks the option. Enter also finishes the time, from any column; Space
   * only picks; a pointer finishes it in the last column, so hour then minute
   * is two clicks and done.
   */
  handleClick = (column: TimeColumn, value: number): void => {
    const key = this.#activationKey;
    this.#activationKey = null;

    const commit = key === 'Enter' ? true : key === ' ' ? false : column.isLast;
    this.select(column, value, commit);
  };

  /**
   * Moves focus, and with it the tab stop. Set imperatively, as the year
   * panel does, so focus and `tabindex` move in the same turn -- and so a
   * read-only column, where moving picks nothing, still moves.
   */
  #moveTo(options: HTMLElement[], next: HTMLElement): void {
    for (const option of options) option.tabIndex = -1;
    next.tabIndex = 0;
    next.focus({ preventScroll: true });

    const list = next.closest<HTMLElement>('[data-part="time-list"]');
    if (list) revealWithin(list, next, false);
  }

  /** The option typing points at: an exact value first, then a prefix. */
  #match(column: TimeColumn, typed: string): TimeOption | undefined {
    const text = typed.toLocaleLowerCase();
    const number = /^\d+$/.test(text) ? Number(text) : NaN;

    return (
      column.options.find((option) => option.value === number) ??
      column.options.find(
        (option) =>
          option.label.toLocaleLowerCase().startsWith(text) ||
          String(option.value).startsWith(text)
      )
    );
  }

  #typeahead(column: TimeColumn, key: string): TimeOption | undefined {
    const now = Date.now();
    this.#typed =
      now - this.#typedAt > TYPEAHEAD_TIMEOUT ? key : this.#typed + key;
    this.#typedAt = now;

    const match = this.#match(column, this.#typed);
    if (match || this.#typed.length === 1) return match;

    // `1` then `7` finds no 17 in a list stepping by five: start over from
    // the `7` rather than ignoring every key from here on.
    this.#typed = key;
    return this.#match(column, key);
  }

  handleKeydown = (column: TimeColumn, event: KeyboardEvent): void => {
    const list = event.currentTarget as HTMLElement;
    const options = optionsOf(list);
    const index = options.indexOf(event.target as HTMLElement);
    if (index < 0) return;

    if (event.key === 'ArrowLeft' || event.key === 'ArrowRight') {
      this.#focusColumn(list, event.key === 'ArrowLeft' ? -1 : 1, event);
      return;
    }

    if (event.key === 'Enter' || event.key === ' ') {
      this.#activationKey = event.key;
      return;
    }

    let next: number | undefined;
    const last = options.length - 1;

    switch (event.key) {
      case 'ArrowDown':
        next = Math.min(index + 1, last);
        break;
      case 'ArrowUp':
        next = Math.max(index - 1, 0);
        break;
      case 'PageDown':
        next = Math.min(index + PAGE_STEP, last);
        break;
      case 'PageUp':
        next = Math.max(index - PAGE_STEP, 0);
        break;
      case 'Home':
        next = 0;
        break;
      case 'End':
        next = last;
        break;
      default:
        if (
          event.key.length === 1 &&
          !event.metaKey &&
          !event.ctrlKey &&
          !event.altKey
        ) {
          const match = this.#typeahead(column, event.key);
          if (match) next = column.options.indexOf(match);
        }
    }

    if (next === undefined) return;
    event.preventDefault();

    this.#moveTo(options, options[next]!);
    this.select(column, column.options[next]!.value, false);
  };

  /** ArrowLeft and ArrowRight go to the neighbouring column's tab stop. */
  #focusColumn(list: HTMLElement, delta: number, event: KeyboardEvent): void {
    const group = list.closest('[data-part="time-columns"]');
    if (!group) return;

    const lists = [
      ...group.querySelectorAll<HTMLElement>('[data-part="time-list"]')
    ];
    const neighbour = lists[lists.indexOf(list) + delta];
    if (!neighbour) return;

    event.preventDefault();
    const target =
      optionsOf(neighbour).find((option) => option.tabIndex === 0) ??
      optionsOf(neighbour)[0];
    target?.focus({ preventScroll: true });
  }

  <template>
    <div
      data-part="time"
      class={{@classes.time class=@userClasses.time}}
      style={{this.style}}
    >
      <div
        role="group"
        aria-label={{@label}}
        data-part="time-columns"
        class={{@classes.timeColumns class=@userClasses.timeColumns}}
      >
        {{#each this.columns key="type" as |column|}}
          <div
            data-part="time-column"
            data-type={{column.type}}
            class={{@classes.timeColumn class=@userClasses.timeColumn}}
          >
            <div
              id={{column.labelId}}
              data-part="time-column-label"
              class={{@classes.timeColumnLabel
                class=@userClasses.timeColumnLabel
              }}
            >{{column.label}}</div>
            {{! template-lint-disable no-invalid-interactive }}
            {{! The keydown listener is the listbox's roving keyboard
            behavior; the options themselves are the focusable elements. }}
            <div
              role="listbox"
              aria-labelledby={{column.labelId}}
              aria-readonly={{if @isReadOnly "true"}}
              data-part="time-list"
              data-type={{column.type}}
              class={{@classes.timeList class=@userClasses.timeList}}
              {{this.reveal column.selected}}
              {{on "keydown" (fn this.handleKeydown column)}}
            >
              {{#each column.options key="value" as |option|}}
                <button
                  type="button"
                  role="option"
                  data-part="time-option"
                  data-value={{option.value}}
                  data-selected={{if option.isSelected "true" "false"}}
                  aria-selected={{if option.isSelected "true" "false"}}
                  tabindex={{if option.isTabbable "0" "-1"}}
                  class={{@classes.timeOption class=@userClasses.timeOption}}
                  {{on "click" (fn this.handleClick column option.value)}}
                >{{option.label}}</button>
              {{/each}}
            </div>
          </div>
        {{/each}}
      </div>
    </div>
  </template>
}

export { DatePickerTimeColumns, type DatePickerTimeColumnsSignature };
export default DatePickerTimeColumns;
