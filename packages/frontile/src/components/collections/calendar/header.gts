import Component from '@glimmer/component';
import { on } from '@ember/modifier';
import { ChevronDownIcon, ChevronLeftIcon, ChevronRightIcon } from './icons';

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
    months: { value: number; label: string; isDisabled: boolean }[];
    isYearGridOpen: boolean;
    onToggleYearGrid: () => void;
    classes: {
      header: string;
      title: string;
      nav: string;
      navButton: string;
      monthSelectWrapper: string;
      monthSelect: string;
      monthSelectValue: string;
      monthSelectIcon: string;
      yearTrigger: string;
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

  /**
   * The visible caption for the month picker. Read from the same `@months`
   * list the `<select>` is built from, so the label a user sees and the option
   * that is selected can never disagree -- and it is already localized.
   */
  get monthLabel(): string {
    const current = this.args.context.month.getMonth();
    return this.args.months.find((m) => m.value === current)?.label ?? '';
  }

  onMonthSelect = (event: Event): void => {
    const target = event.target as HTMLSelectElement;
    this.args.context.setMonth(Number(target.value));
  };

  <template>
    <div data-part="header" class={{@classes.header}} ...attributes>
      <button
        type="button"
        data-part="nav-button"
        class={{@classes.navButton}}
        disabled={{if @context.canGoPrevious false true}}
        data-disabled={{if @context.canGoPrevious "false" "true"}}
        aria-label="Previous month"
        {{on "click" @context.goToPrevious}}
      ><ChevronLeftIcon /></button>

      {{#if this.isDropdown}}
        <div data-part="nav" class={{@classes.nav}}>
          {{! The visible label sizes this box to the current month; the real
              <select> is laid transparently over it, so the control stays
              native without dictating the width. }}
          <span
            data-part="month-select-wrapper"
            class={{@classes.monthSelectWrapper}}
          >
            <span
              aria-hidden="true"
              data-part="month-select-value"
              class={{@classes.monthSelectValue}}
            >{{this.monthLabel}}</span>

            <ChevronDownIcon
              data-part="month-select-icon"
              class={{@classes.monthSelectIcon}}
            />

            <select
              data-part="month-select"
              aria-label="Month"
              class={{@classes.monthSelect}}
              {{on "change" this.onMonthSelect}}
            >
              {{#each @months key="value" as |m|}}
                <option
                  value={{m.value}}
                  selected={{this.isCurrentMonth m.value}}
                  disabled={{m.isDisabled}}
                >
                  {{m.label}}
                </option>
              {{/each}}
            </select>
          </span>

          <button
            type="button"
            data-part="year-trigger"
            aria-expanded={{if @isYearGridOpen "true" "false"}}
            class={{@classes.yearTrigger}}
            {{on "click" @onToggleYearGrid}}
          >{{this.year}}</button>
        </div>
      {{else}}
        <div data-part="title" class={{@classes.title}}>{{@context.title}}</div>
      {{/if}}

      <button
        type="button"
        data-part="nav-button"
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
