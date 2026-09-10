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
    element
      .querySelector<HTMLElement>(
        '[data-fr-calendar-year][data-selected="true"]'
      )
      ?.focus();
  });

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
    buttons[index + step]?.focus();
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
          class={{@classes.yearCell}}
          {{on "click" (fn @onSelect year)}}
        >{{year}}</button>
      {{/each}}
    </div>
  </template>
}

export { YearGrid };
