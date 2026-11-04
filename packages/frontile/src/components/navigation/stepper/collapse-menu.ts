import { tracked } from '@glimmer/tracking';
import { schedule } from '@ember/runloop';
import { modifier } from 'ember-modifier';
import {
  autoUpdate,
  computePosition,
  flip,
  offset,
  shift
} from '@floating-ui/dom';

/**
 * The floating menu a collapsed Stepper turns its list into: a native
 * `popover` (top layer, so no ancestor's `overflow` can clip it; Escape and
 * click-away come with it), positioned under a trigger button.
 *
 * Positioning uses `@floating-ui/dom` directly rather than the `Velcro`
 * modifier `Popover` uses: this list is already a native top-layer popover
 * whose open state comes from the browser's `toggle` event, and the position
 * only needs computing while it is open.
 *
 * It owns the two elements and the open state, and nothing about steps. The
 * list stays mounted whether or not the menu is active, which is why the steps
 * stay registered while it is closed.
 */
class CollapseMenu {
  /** Mirrors the popover's state, for the trigger's `aria-expanded`. */
  @tracked isOpen = false;

  #trigger: HTMLElement | undefined;
  #list: HTMLElement | undefined;

  /** Closes the menu if it is open. */
  close(): void {
    const list = this.#list;
    if (list?.matches(':popover-open')) {
      list.hidePopover();
    }
  }

  /** Install on the trigger button. */
  registerTrigger = modifier((element: HTMLElement) => {
    this.#trigger = element;

    return (): void => {
      if (this.#trigger === element) {
        this.#trigger = undefined;
      }
    };
  });

  /**
   * Install on the list, passing whether the menu is active. While it is, the
   * list becomes a popover; otherwise this does nothing.
   */
  list = modifier((list: HTMLElement, [active]: [boolean]) => {
    if (!active || typeof list.showPopover !== 'function') {
      return;
    }

    this.#list = list;
    list.setAttribute('popover', 'auto');

    let stopPositioning: (() => void) | undefined;
    // `computePosition` resolves later; it must not write to a list that has
    // since been torn down.
    let isLive = true;

    const place = (): void => {
      const trigger = this.#trigger;
      if (!trigger) {
        return;
      }
      void computePosition(trigger, list, {
        strategy: 'fixed',
        placement: 'bottom-start',
        middleware: [offset(8), flip(), shift({ padding: 8 })]
      }).then(({ x, y }) => {
        if (!isLive) {
          return;
        }
        list.style.left = `${x}px`;
        list.style.top = `${y}px`;
        list.style.minWidth = `${trigger.offsetWidth}px`;
      });
    };

    const focusCurrent = (): void => {
      const target =
        list.querySelector<HTMLElement>('[aria-current="step"]') ??
        list.querySelector<HTMLElement>(
          '[data-part="step"]:not([aria-disabled="true"])'
        );
      target?.focus();
    };

    const onBeforeToggle = (event: Event): void => {
      const { newState } = event as Event & { newState?: string };
      // Focus inside the panel is about to vanish with it; hand it back to the
      // trigger, as a menu button does.
      if (newState === 'closed' && list.contains(document.activeElement)) {
        const trigger = this.#trigger;
        queueMicrotask(() => trigger?.focus());
      }
    };

    const onToggle = (event: Event): void => {
      const { newState } = event as Event & { newState?: string };
      this.isOpen = newState === 'open';

      stopPositioning?.();
      stopPositioning = undefined;

      if (newState === 'open' && this.#trigger) {
        place();
        stopPositioning = autoUpdate(this.#trigger, list, place);
        focusCurrent();
      }
    };

    list.addEventListener('beforetoggle', onBeforeToggle);
    list.addEventListener('toggle', onToggle);

    return (): void => {
      isLive = false;
      stopPositioning?.();
      list.removeEventListener('beforetoggle', onBeforeToggle);
      list.removeEventListener('toggle', onToggle);
      if (list.matches(':popover-open')) {
        list.hidePopover();
      }
      list.removeAttribute('popover');
      list.style.removeProperty('left');
      list.style.removeProperty('top');
      list.style.removeProperty('min-width');
      if (this.#list === list) {
        this.#list = undefined;
      }
      // Torn down inside the render transaction that read `isOpen`, so the
      // write waits for `afterRender`.
      schedule('afterRender', () => {
        this.isOpen = false;
      });
    };
  });
}

export { CollapseMenu };
