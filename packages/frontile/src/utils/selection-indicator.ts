import { modifier } from 'ember-modifier';
import { buildWaiter } from '@ember/test-waiters';

const READY_ATTRIBUTE = 'data-fr-si-ready';
const waiter = buildWaiter('@frontile/utils:selection-indicator');

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
  #frame?: number;
  #waiterToken?: unknown;
  #remeasureToken?: unknown;
  #isReady = false;

  /**
   * Modifier to place on the container element. Observes its size and, once
   * a target is selected, publishes that target's geometry as CSS custom
   * properties on this element.
   */
  setupContainer = modifier((element: HTMLElement) => {
    this.#container = element;
    this.#observer = new ResizeObserver(() => this.measure());
    this.#observer.observe(element);

    if (this.#target) {
      this.#observer.observe(this.#target);
    }
    this.measure();

    return (): void => {
      this.#observer?.disconnect();
      this.#observer = undefined;
      this.#cancelReady();
      this.#cancelRemeasure();
      this.#container = undefined;
      this.#isReady = false;
    };
  });

  /**
   * Modifier to place on each candidate target element, passing whether it
   * is currently selected as the sole positional argument. Only the
   * currently-selected target's geometry is measured and published.
   */
  setupTarget = modifier((element: HTMLElement, [isSelected]: [boolean]) => {
    if (isSelected) {
      this.#target = element;
      this.#observer?.observe(element);
      this.measure();
    }

    return (): void => {
      // Only clear if this element is still the target. When selection moves
      // backwards, the incoming item's setup runs before the outgoing item's
      // teardown, and without this guard that teardown would wipe the new
      // target.
      if (this.#target === element) {
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
    };
  });

  /**
   * Recomputes and republishes the current target's geometry. Called
   * automatically on setup, selection change, and container/target resize;
   * exposed for callers that need to force a recomputation.
   */
  measure = (): void => {
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
   * Tears down the observer and any pending ready scheduling. Call when the
   * consumer is done with this instance outside of modifier teardown.
   */
  destroy = (): void => {
    this.#observer?.disconnect();
    this.#observer = undefined;
    this.#cancelReady();
    this.#cancelRemeasure();
    this.#container = undefined;
    this.#target = undefined;
    this.#isReady = false;
  };

  #markNotReady(): void {
    this.#cancelReady();
    this.#isReady = false;
    this.#container?.removeAttribute(READY_ATTRIBUTE);
  }

  // The ready flag is set a frame after the first real measurement so the
  // theme can hold transitions off until the indicator is already in place.
  // Wrapped in a test waiter so `settled()` covers it.
  #scheduleReady(container: HTMLElement): void {
    this.#waiterToken = waiter.beginAsync();
    this.#frame = requestAnimationFrame(() => {
      this.#frame = undefined;
      container.setAttribute(READY_ATTRIBUTE, '');
      if (this.#waiterToken) {
        waiter.endAsync(this.#waiterToken);
        this.#waiterToken = undefined;
      }
    });
  }

  // Re-measures once the current render has settled, so a target that is
  // being handed from one element to another is never observed mid-handover.
  // Wrapped in the same test waiter so it cannot outlive a `settled()`.
  #scheduleRemeasure(): void {
    if (this.#remeasureToken) {
      return;
    }

    const token = waiter.beginAsync();
    this.#remeasureToken = token;

    queueMicrotask(() => {
      // Cancelled by teardown, or superseded by a later schedule.
      if (this.#remeasureToken !== token) {
        return;
      }
      this.#remeasureToken = undefined;
      waiter.endAsync(token);

      // A new target claimed the slot in the meantime and measured itself.
      if (this.#target) {
        return;
      }
      this.measure();
    });
  }

  #cancelRemeasure(): void {
    if (this.#remeasureToken) {
      waiter.endAsync(this.#remeasureToken);
      this.#remeasureToken = undefined;
    }
  }

  #cancelReady(): void {
    if (this.#frame !== undefined) {
      cancelAnimationFrame(this.#frame);
      this.#frame = undefined;
    }
    if (this.#waiterToken) {
      waiter.endAsync(this.#waiterToken);
      this.#waiterToken = undefined;
    }
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
