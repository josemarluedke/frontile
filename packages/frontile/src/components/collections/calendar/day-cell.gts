import type { TOC } from '@ember/component/template-only';
import { on } from '@ember/modifier';
import { fn } from '@ember/helper';
import type { CalendarDay, DayCellClasses, DayState } from './types';

export interface DayCellSignature {
  Args: {
    day: CalendarDay;
    state: DayState;
    hasCustomContent: boolean;
    onSelect: (date: Date) => void;
    onHover: (date: Date | null) => void;
    classes: DayCellClasses;
  };
  Blocks: { default: [DayState] };
  Element: HTMLTableCellElement;
}

const DayCell: TOC<DayCellSignature> = <template>
  {{! template-lint-disable no-redundant-role no-unsupported-role-attributes }}
  {{! role="gridcell" and aria-selected are explicit here because this
       template can't see the ancestor table[role=grid] in month-grid.gts
       that implies them. Both are omitted entirely on an empty outside-day
       placeholder cell, since it renders no selectable content. }}
  <td
    data-fr-calendar-cell
    class={{@classes.cell}}
    role={{if @state.rendersDay "gridcell"}}
    aria-selected={{if @state.rendersDay (if @state.isSelected "true" "false")}}
    ...attributes
  >
    {{#if @state.rendersDay}}
      <span
        data-fr-calendar-band
        class={{@classes.cellBand}}
        data-in-range={{if @state.isInRange "true" "false"}}
        data-preview={{if @state.isPreview "true" "false"}}
        data-range-start={{if @state.isRangeStart "true" "false"}}
        data-range-end={{if @state.isRangeEnd "true" "false"}}
      ></span>

      <button
        type="button"
        data-fr-calendar-day
        class={{@classes.day}}
        data-key={{@day.key}}
        data-outside={{if @state.isOutside "true" "false"}}
        data-selected={{if @state.isSelected "true" "false"}}
        data-today={{if @state.isToday "true" "false"}}
        data-disabled={{if @state.isDisabled "true" "false"}}
        data-unavailable={{if @state.isUnavailable "true" "false"}}
        data-outside-range={{if @state.isOutsideRange "true" "false"}}
        data-in-range={{if @state.isInRange "true" "false"}}
        data-preview={{if @state.isPreview "true" "false"}}
        data-range-start={{if @state.isRangeStart "true" "false"}}
        data-range-end={{if @state.isRangeEnd "true" "false"}}
        data-focused={{if @state.isFocused "true" "false"}}
        aria-disabled={{if @state.isDisabled "true" "false"}}
        aria-current={{if @state.isToday "date"}}
        aria-label={{@state.ariaLabel}}
        tabindex={{if @state.isFocused "0" "-1"}}
        {{on "click" (fn @onSelect @day.date)}}
        {{on "mouseenter" (fn @onHover @day.date)}}
      >
        {{! The content wrapper is layout, not content: it stacks and
            centres whatever sits inside it. A day block goes inside it
            rather than replacing it, so a block rendering a numeral plus a
            price gets that column for free instead of laying out inline. }}
        <span data-fr-calendar-day-content class={{@classes.dayContent}}>
          {{#if @hasCustomContent}}
            {{yield @state}}
          {{else}}
            {{@day.dayOfMonth}}
          {{/if}}
        </span>

        {{! Default content only: a day block owns its own affordances,
            which is what the docs promise. }}
        {{#if @state.isToday}}
          {{#unless @hasCustomContent}}
            <span
              data-fr-calendar-indicator
              class={{@classes.indicator}}
            ></span>
          {{/unless}}
        {{/if}}
      </button>
    {{/if}}
  </td>
  {{! template-lint-enable no-redundant-role no-unsupported-role-attributes }}
</template>;

export default DayCell;
export { DayCell };
