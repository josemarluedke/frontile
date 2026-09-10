import Component from '@glimmer/component';
import { on } from '@ember/modifier';
import { ChevronLeftIcon, ChevronRightIcon } from './icons';

export interface CalendarHeaderContext {
  month: Date;
  title: string;
  goToPrevious: () => void;
  goToNext: () => void;
  canGoPrevious: boolean;
  canGoNext: boolean;
  setMonth: (monthIndex: number) => void;
  setYear: (year: number) => void;
  isYearGridOpen: boolean;
  toggleYearGrid: () => void;
}

export interface CalendarHeaderSignature {
  Args: {
    context: CalendarHeaderContext;
    captionLayout: 'label' | 'dropdown';
    months: { value: number; label: string }[];
    isYearGridOpen: boolean;
    onToggleYearGrid: () => void;
    classes: {
      header: string;
      title: string;
      nav: string;
      navButton: string;
    };
  };
  Element: HTMLDivElement;
}

export default class CalendarHeader extends Component<CalendarHeaderSignature> {
  get isDropdown(): boolean {
    return this.args.captionLayout === 'dropdown';
  }

  /**
   * A getter, not a bare `{{@context.month.getFullYear}}` in the template --
   * Glimmer does not auto-invoke a plain method reference in content
   * position, it would render the function itself.
   */
  get year(): number {
    return this.args.context.month.getFullYear();
  }

  isCurrentMonth = (value: number): boolean =>
    this.args.context.month.getMonth() === value;

  onMonthSelect = (event: Event): void => {
    const target = event.target as HTMLSelectElement;
    this.args.context.setMonth(Number(target.value));
  };

  <template>
    <div data-fr-calendar-header class={{@classes.header}} ...attributes>
      <button
        type="button"
        data-fr-calendar-prev
        class={{@classes.navButton}}
        disabled={{if @context.canGoPrevious false true}}
        data-disabled={{if @context.canGoPrevious "false" "true"}}
        aria-label="Previous month"
        {{on "click" @context.goToPrevious}}
      ><ChevronLeftIcon /></button>

      {{#if this.isDropdown}}
        <div class={{@classes.nav}}>
          <select
            data-fr-calendar-month-select
            aria-label="Month"
            {{on "change" this.onMonthSelect}}
          >
            {{#each @months key="value" as |m|}}
              <option
                value={{m.value}}
                selected={{this.isCurrentMonth m.value}}
              >
                {{m.label}}
              </option>
            {{/each}}
          </select>

          <button
            type="button"
            data-fr-calendar-year-trigger
            aria-expanded={{if @isYearGridOpen "true" "false"}}
            class={{@classes.navButton}}
            {{on "click" @onToggleYearGrid}}
          >{{this.year}}</button>
        </div>
      {{else}}
        <div
          data-fr-calendar-title
          class={{@classes.title}}
        >{{@context.title}}</div>
      {{/if}}

      <button
        type="button"
        data-fr-calendar-next
        class={{@classes.navButton}}
        disabled={{if @context.canGoNext false true}}
        data-disabled={{if @context.canGoNext "false" "true"}}
        aria-label="Next month"
        {{on "click" @context.goToNext}}
      ><ChevronRightIcon /></button>
    </div>
  </template>
}

export { CalendarHeader };
