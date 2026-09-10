import type { TOC } from '@ember/component/template-only';
import { on } from '@ember/modifier';

export interface CalendarHeaderContext {
  month: Date;
  title: string;
  goToPrevious: () => void;
  goToNext: () => void;
  canGoPrevious: boolean;
  canGoNext: boolean;
  setMonth: (monthIndex: number) => void;
  setYear: (year: number) => void;
}

export interface CalendarHeaderSignature {
  Args: {
    context: CalendarHeaderContext;
    classes: {
      header: string;
      title: string;
      nav: string;
      navButton: string;
    };
  };
  Element: HTMLDivElement;
}

const CalendarHeader: TOC<CalendarHeaderSignature> = <template>
  <div data-fr-calendar-header class={{@classes.header}} ...attributes>
    <button
      type="button"
      data-fr-calendar-prev
      class={{@classes.navButton}}
      disabled={{if @context.canGoPrevious false true}}
      data-disabled={{if @context.canGoPrevious "false" "true"}}
      aria-label="Previous month"
      {{on "click" @context.goToPrevious}}
    >&lsaquo;</button>

    <div
      data-fr-calendar-title
      class={{@classes.title}}
    >{{@context.title}}</div>

    <button
      type="button"
      data-fr-calendar-next
      class={{@classes.navButton}}
      disabled={{if @context.canGoNext false true}}
      data-disabled={{if @context.canGoNext "false" "true"}}
      aria-label="Next month"
      {{on "click" @context.goToNext}}
    >&rsaquo;</button>
  </div>
</template>;

export default CalendarHeader;
export { CalendarHeader };
