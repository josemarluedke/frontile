import type { TOC } from '@ember/component/template-only';
import type { CalendarDay, DayState } from './types';

export interface DayCellSignature {
  Args: {
    day: CalendarDay;
    state: DayState;
    showOutsideDays: boolean;
    hasCustomContent: boolean;
    cellClass: string;
    bandClass: string;
    dayClass: string;
    contentClass: string;
    indicatorClass: string;
  };
  Blocks: { default: [DayState] };
  Element: HTMLTableCellElement;
}

const DayCell: TOC<DayCellSignature> = <template>
  {{#let (if @day.isOutside @showOutsideDays true) as |showsContent|}}
    {{! template-lint-disable no-redundant-role no-unsupported-role-attributes }}
    {{! role="gridcell" and aria-selected are explicit here because this
         template can't see the ancestor table[role=grid] in month-grid.gts
         that implies them. Both are omitted entirely on an empty outside-day
         placeholder cell, since it renders no selectable content. }}
    <td
      data-fr-calendar-cell
      class={{@cellClass}}
      role={{if showsContent "gridcell"}}
      aria-selected={{if showsContent (if @state.isSelected "true" "false")}}
      ...attributes
    >
      {{#if showsContent}}
        <span
          data-fr-calendar-band
          class={{@bandClass}}
          data-in-range={{if @state.isInRange "true" "false"}}
          data-preview={{if @state.isPreview "true" "false"}}
          data-range-start={{if @state.isRangeStart "true" "false"}}
          data-range-end={{if @state.isRangeEnd "true" "false"}}
        ></span>

        <button
          type="button"
          data-fr-calendar-day
          class={{@dayClass}}
          data-key={{@day.key}}
          data-outside={{if @state.isOutside "true" "false"}}
          data-selected={{if @state.isSelected "true" "false"}}
          data-today={{if @state.isToday "true" "false"}}
          data-disabled={{if @state.isDisabled "true" "false"}}
          data-unavailable={{if @state.isUnavailable "true" "false"}}
          data-in-range={{if @state.isInRange "true" "false"}}
          data-preview={{if @state.isPreview "true" "false"}}
          data-focused={{if @state.isFocused "true" "false"}}
          aria-disabled={{if @state.isDisabled "true" "false"}}
          aria-current={{if @state.isToday "date"}}
          tabindex={{if @state.isFocused "0" "-1"}}
        >
          {{#if @hasCustomContent}}
            {{yield @state}}
          {{else}}
            <span data-fr-calendar-day-content class={{@contentClass}}>
              {{@day.dayOfMonth}}
            </span>
            {{#if @state.isToday}}
              <span data-fr-calendar-indicator class={{@indicatorClass}}></span>
            {{/if}}
          {{/if}}
        </button>
      {{/if}}
    </td>
    {{! template-lint-enable no-redundant-role no-unsupported-role-attributes }}
  {{/let}}
</template>;

export default DayCell;
export { DayCell };
