import { modifier } from 'ember-modifier';
import { deferredWork } from './deferred-work';

const READY_ATTRIBUTE = 'data-fr-si-ready';

/**
 * Measures whichever element is currently selected and publishes its geometry
 * on the container as CSS custom properties. It never paints anything: the
 * theme decides whether that geometry becomes a full pill or a bar pinned to
 * one edge, which is what lets one primitive serve a segmented control and
 * tabs alike.
 *
 * Offsets are physical (`offsetLeft` / `offsetTop`), not logical, and that is
 * deliberate. The browser has already laid the items out for the container's
 * direction, so a physical offset fed to `translate` is correct in both LTR
 * and RTL. Reaching for `inset-inline-start` here would flip an already
 * flipped value.
 */
class SelectionIndicator {
  #container?: HTMLElement;
  #target?: HTMLElement;
  #observer?: ResizeObserver;
  #ready = deferredWork('@frontile/utils:selection-indicator:ready');
  #remeasure = deferredWork('@frontile/utils:selection-indicator:remeasure');
  #resize = deferredWork('@frontile/utils:selection-indicator:resize');
  #isReady = false;

  /**
   * Modifier to place on the container element. Observes its size and, once
   * a target is selected, publishes that target's geometry as CSS custom
   * properties on this element.
   */
  setupContainer = modifier((element: HTMLElement) => {
    this.#container = element;
    // Coalesced to one measurement per frame: the container and the target are
    // both observed, and resizing the container usually resizes the target too,
    // so a single layout change delivers two entries. Measuring reads layout
    // and then writes four custom properties, and a window drag fires this
    // continuously.
    this.#observer = new ResizeObserver(() =>
      this.#resize.schedule(() => this.#measure())
    );
    this.#observer.observe(element);

    if (this.#target) {
      this.#observer.observe(this.#target);
    }
    this.#measure();

    return (): void => {
      this.#shutDown();
    };
  });

  /**
   * Claims `element` as the measured target. Exposed alongside `setupTarget`
   * so a consumer composing its own modifier -- a navigation bar that also has
   * to write `aria-current` -- can delegate here rather than reimplement the
   * handover rules below.
   */
  claim(element: HTMLElement): void {
    this.#target = element;
    this.#observer?.observe(element);
    this.#measure();
  }

  /**
   * Releases `element` if it is still the target. Only clear if this element
   * is still the target. When selection moves backwards, the incoming item's
   * setup runs before the outgoing item's teardown, and without this guard
   * that teardown would wipe the new target.
   */
  release(element: HTMLElement): void {
    if (this.#target !== element) {
      return;
    }
    this.#observer?.unobserve(element);
    this.#target = undefined;

    // Do not re-measure synchronously. When selection moves forwards the
    // order is reversed -- ember-modifier tears down before re-running
    // setup, and Glimmer revalidates in tree order -- so the outgoing
    // teardown lands first and the incoming target is still moments away
    // in this same render. Measuring now would strip the ready attribute,
    // and the theme gates both opacity and the transition on it, so the
    // indicator would blink out and jump to its new position instead of
    // sliding. Defer instead, and only fall through to the not-ready path
    // if nothing has claimed the target by then.
    this.#scheduleRemeasure();
  }

  /**
   * Modifier to place on each candidate target element, passing whether it
   * is currently selected as the sole positional argument. Only the
   * currently-selected target's geometry is measured and published.
   */
  setupTarget = modifier((element: HTMLElement, [isSelected]: [boolean]) => {
    if (isSelected) {
      this.claim(element);
    }

    return (): void => {
      this.release(element);
    };
  });

  /**
   * Recomputes and republishes the current target's geometry. Called
   * automatically on setup, selection change, and container/target resize;
   * exposed for callers that need to force a recomputation.
   */
  #measure = (): void => {
    const container = this.#container;
    if (!container) {
      return;
    }

    const target = this.#target;
    if (!target) {
      this.#markNotReady();
      return;
    }

    const width = target.offsetWidth;
    const height = target.offsetHeight;

    // A control inside a hidden ancestor -- a closed drawer, an inactive tab
    // panel -- measures zero. Publishing that would collapse the indicator and,
    // worse, mark it ready, so the first real measurement once it is shown
    // would animate in from the container origin. Stay un-ready instead; the
    // ResizeObserver fires when it becomes visible.
    if (width === 0 && height === 0) {
      this.#markNotReady();
      return;
    }

    container.style.setProperty('--fr-si-x', `${target.offsetLeft}px`);
    container.style.setProperty('--fr-si-y', `${target.offsetTop}px`);
    container.style.setProperty('--fr-si-width', `${width}px`);
    container.style.setProperty('--fr-si-height', `${height}px`);

    if (!this.#isReady) {
      this.#isReady = true;
      this.#scheduleReady(container);
    }
  };

  /**
   * Everything the container modifier's destructor undoes. The target is not
   * reset here: it belongs to `setupTarget`, whose own destructor clears it.
   */
  #shutDown(): void {
    this.#observer?.disconnect();
    this.#observer = undefined;
    this.#ready.cancel();
    this.#remeasure.cancel();
    this.#resize.cancel();
    this.#container = undefined;
    this.#isReady = false;
  }

  #markNotReady(): void {
    this.#ready.cancel();
    this.#isReady = false;
    this.#container?.removeAttribute(READY_ATTRIBUTE);
  }

  // The ready flag is set a frame after the first real measurement so the
  // theme can hold transitions off until the indicator is already in place.
  #scheduleReady(container: HTMLElement): void {
    this.#ready.schedule(() => container.setAttribute(READY_ATTRIBUTE, ''));
  }

  // Re-measures once the current render has settled, so a target being handed
  // from one element to another is never observed mid-handover.
  #scheduleRemeasure(): void {
    this.#remeasure.schedule(() => {
      // A new target claimed the slot in the meantime and measured itself.
      if (this.#target) {
        return;
      }
      this.#measure();
    }, 'microtask');
  }
}

/**
 * Creates a selection indicator.
 *
 * Mirrors the shape of `ref` and `toggleState`: the class stays internal and
 * the public surface is this lowercase factory, since this is a utility rather
 * than a component.
 */
function selectionIndicator(): SelectionIndicator {
  return new SelectionIndicator();
}

export { selectionIndicator, READY_ATTRIBUTE };
export type { SelectionIndicator };
