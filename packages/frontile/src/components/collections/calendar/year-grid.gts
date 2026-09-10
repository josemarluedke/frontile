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

/**
 * Scroll `target` into view inside `panel` and nowhere else.
 *
 * `scrollIntoView` and a plain `focus()` both scroll *every* scrollable
 * ancestor up to the document, so either one makes the host page jump when the
 * panel opens or when arrow keys walk past its edge. Adjusting `scrollTop`
 * directly keeps the movement inside the panel.
 *
 * The measurements come from `offsetTop`, not `getBoundingClientRect()`:
 * client rects are in transformed pixels, so under any ancestor `scale()` they
 * would not agree with `scrollTop`. This relies on the panel being the
 * `offsetParent` -- the `yearGrid` slot is positioned for exactly that reason.
 *
 * `center` places the target mid-panel, for the opening jump to a year that is
 * usually a long way down the list; otherwise the target is brought just far
 * enough into view, which is what stepping key by key wants.
 */
function revealWithin(
  panel: HTMLElement,
  target: HTMLElement,
  center: boolean
): void {
  const top = target.offsetTop;
  const bottom = top + target.offsetHeight;

  if (center) {
    panel.scrollTop = top - (panel.clientHeight - target.offsetHeight) / 2;
    return;
  }

  if (top < panel.scrollTop) {
    panel.scrollTop = top;
  } else if (bottom > panel.scrollTop + panel.clientHeight) {
    panel.scrollTop = bottom - panel.clientHeight;
  }
}

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
    if (selected) {
      revealWithin(element, selected, true);
      selected.focus({ preventScroll: true });
    }
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
    next.focus({ preventScroll: true });

    if (this.#element) {
      revealWithin(this.#element, next, false);
    }
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

    // `indexOf` returns -1 when focus is not on a year button. Stepping from
    // -1 would land on `buttons[0]` or `buttons[2]` rather than doing nothing,
    // so bail before the arithmetic.
    if (index < 0) {
      return;
    }

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
