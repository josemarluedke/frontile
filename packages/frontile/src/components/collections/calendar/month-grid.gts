import type { TOC } from '@ember/component/template-only';
import { DayCell } from './day-cell';
import type {
  CalendarMonthData,
  WeekdayLabel,
  DayState,
  CalendarDay
} from './types';

export interface MonthGridSignature {
  Args: {
    month: CalendarMonthData;
    weekdays: WeekdayLabel[];
    caption: string;
    stateFor: (day: CalendarDay) => DayState;
    isReadOnly: boolean;
    /** Forwarded from the calendar's own `aria-labelledby`, if any. */
    labelledBy?: string;
    hasDayContent: boolean;
    hasWeekdayContent: boolean;
    onSelect: (date: Date) => void;
    onHover: (date: Date | null) => void;
    classes: {
      monthGrid: string;
      weekdaysRow: string;
      weekday: string;
      week: string;
      cell: string;
      cellBand: string;
      day: string;
      dayContent: string;
      indicator: string;
    };
  };
  Blocks: { day: [DayState]; weekday: [WeekdayLabel] };
  Element: HTMLTableElement;
}

const MonthGrid: TOC<MonthGridSignature> = <template>
  <table
    role="grid"
    data-part="month-grid"
    class={{@classes.monthGrid}}
    {{! aria-labelledby wins over aria-label, so a picker passing one on the
        calendar relabels every grid without this having to choose. }}
    aria-label={{@caption}}
    aria-labelledby={{@labelledBy}}
    aria-readonly={{if @isReadOnly "true" "false"}}
    ...attributes
  >
    <thead>
      <tr data-part="weekdays-row" class={{@classes.weekdaysRow}}>
        {{#each @weekdays key="index" as |weekday|}}
          <th
            scope="col"
            data-part="weekday"
            class={{@classes.weekday}}
            abbr={{weekday.long}}
          >
            {{#if @hasWeekdayContent}}
              {{yield weekday to="weekday"}}
            {{else}}
              {{weekday.short}}
            {{/if}}
          </th>
        {{/each}}
      </tr>
    </thead>

    <tbody>
      {{#each @month.weeks key="key" as |week|}}
        <tr data-part="week" class={{@classes.week}}>
          {{#each week.days key="key" as |day|}}
            {{#let (@stateFor day) as |state|}}
              <DayCell
                @day={{day}}
                @state={{state}}
                @hasCustomContent={{@hasDayContent}}
                @onSelect={{@onSelect}}
                @onHover={{@onHover}}
                @classes={{@classes}}
              >
                {{#if @hasDayContent}}
                  {{yield state to="day"}}
                {{/if}}
              </DayCell>
            {{/let}}
          {{/each}}
        </tr>
      {{/each}}
    </tbody>
  </table>
</template>;

export default MonthGrid;
export { MonthGrid };
