import Component from '@glimmer/component';
import { on } from '@ember/modifier';
import { fn } from '@ember/helper';
import { modifier } from 'ember-modifier';

export interface YearGridSignature {
  Args: {
    years: number[];
    currentYear: number;
    onSelect: (year: number) => void;
    onDismiss: () => void;
    classes: { yearGrid: string; yearCell: string };
  };
  Element: HTMLDivElement;
}

/** The grid is three columns wide, so vertical movement is by three. */
const COLUMNS = 3;

export default class YearGrid extends Component<YearGridSignature> {
  #element: HTMLElement | undefined;

  isCurrent = (year: number): boolean => year === this.args.currentYear;

  /**
   * A year grid is opened by a deliberate action, so unlike the day grid it
   * *should* take focus -- otherwise a keyboard user opens a panel they cannot
   * reach.
   */
  setup = modifier((element: HTMLElement) => {
    this.#element = element;

    const selected = element.querySelector<HTMLElement>(
      '[data-fr-calendar-year][data-selected="true"]'
    );

    // The list spans a century, so the selected year is usually far down a
    // scrolling panel. Bring it into view before focusing, or the panel opens
    // showing whichever decade happens to be at the top.
    selected?.scrollIntoView({ block: 'center' });
    selected?.focus();
  });

  /**
   * The panel is a single tab stop: only the year focus currently rests on is
   * tabbable, and arrow keys move both focus and that tabbability together.
   * Without this, tabbing through the calendar walks all hundred-odd years.
   *
   * Written imperatively from the keydown handler rather than derived from
   * tracked state, so focus and `tabindex` change in the same turn and neither
   * waits on a render.
   */
  #setActive(buttons: HTMLElement[], next: HTMLElement): void {
    for (const button of buttons) {
      button.tabIndex = -1;
    }
    next.tabIndex = 0;
    next.focus();
  }

  handleKeydown = (event: KeyboardEvent): void => {
    if (event.key === 'Escape') {
      event.preventDefault();
      this.args.onDismiss();
      return;
    }

    const step =
      event.key === 'ArrowRight'
        ? 1
        : event.key === 'ArrowLeft'
          ? -1
          : event.key === 'ArrowDown'
            ? COLUMNS
            : event.key === 'ArrowUp'
              ? -COLUMNS
              : 0;

    if (step === 0) {
      return;
    }

    event.preventDefault();

    const buttons = Array.from(
      this.#element?.querySelectorAll<HTMLElement>('[data-fr-calendar-year]') ??
        []
    );
    const index = buttons.indexOf(document.activeElement as HTMLElement);
    const next = buttons[index + step];

    if (next) {
      this.#setActive(buttons, next);
    }
  };

  <template>
    {{! template-lint-disable no-invalid-interactive }}
    {{! The keydown listener implements the year grid's own roving keyboard
         behavior (arrow keys, Enter, Escape); the container itself stays a
         plain, non-focusable listbox role. }}
    <div
      role="listbox"
      aria-label="Year"
      data-fr-calendar-year-grid
      class={{@classes.yearGrid}}
      {{this.setup}}
      {{on "keydown" this.handleKeydown}}
      ...attributes
    >
      {{#each @years key="@identity" as |year|}}
        <button
          type="button"
          role="option"
          data-fr-calendar-year
          data-year={{year}}
          data-selected={{if (this.isCurrent year) "true" "false"}}
          aria-selected={{if (this.isCurrent year) "true" "false"}}
          tabindex={{if (this.isCurrent year) "0" "-1"}}
          class={{@classes.yearCell}}
          {{on "click" (fn @onSelect year)}}
        >{{year}}</button>
      {{/each}}
    </div>
  </template>
}

export { YearGrid };
