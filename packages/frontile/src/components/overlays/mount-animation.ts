/**
 * When an overlay's enter animation is worth playing, and what to do when it
 * is not.
 *
 * An overlay that is already open the first time it renders -- deep-linked
 * open, or restored by a page refresh -- starts its enter transition before
 * the browser has painted anything, so the first pixels the user sees already
 * contain a half-faded overlay over a page that is itself only appearing. It
 * waits for that first paint instead, and animates against a page the user has
 * already seen.
 */

interface MountAnimationState {
  /**
   * Whether this is the overlay's first open *and* it was already open when
   * the overlay first rendered.
   */
  isFirstOpen: boolean;

  /**
   * Whether transitions run at all -- false in tests and when
   * `@disableTransitions` is set.
   */
  animationsEnabled: boolean;

  /** The `@animateOnMount` argument, `undefined` when not passed. */
  animateOnMount: boolean | undefined;

  /**
   * Whether there is a frame to wait for. False without
   * `requestAnimationFrame` (prerendering), where waiting would mean never
   * rendering.
   */
  canWaitForFrame: boolean;

  /**
   * Whether the browser had already painted. True for the overlay of a boot
   * slow enough to render after the page appeared, which has nothing left to
   * wait for.
   */
  hasPainted: boolean;
}

/**
 * Whether a mount animation is in question at all. Everything below is a
 * choice about how to treat one, so an overlay opened by interaction, or one
 * whose transitions are off, is none of their business.
 */
function hasMountAnimation(state: MountAnimationState): boolean {
  return state.isFirstOpen && state.animationsEnabled;
}

/**
 * Whether to hold the overlay out of the DOM until the browser has painted.
 *
 * Turning the animation off means rendering immediately: there is nothing to
 * make visible, and in tests a deferred mount would expose a frame of empty
 * DOM that `settled` does not wait for.
 */
function shouldDeferMount(state: MountAnimationState): boolean {
  return (
    hasMountAnimation(state) &&
    state.animateOnMount !== false &&
    state.canWaitForFrame &&
    !state.hasPainted
  );
}

/** Whether the enter half of the transition is neutered for this mount. */
function shouldSkipEnterTransition(state: MountAnimationState): boolean {
  return hasMountAnimation(state) && state.animateOnMount === false;
}

// How long to wait for a paint that may never come: a page loaded in a
// background tab paints nothing until it is looked at, and the overlay still
// has to exist in the DOM before then.
const FIRST_PAINT_TIMEOUT = 300;

// Detection is cached: it cannot change within a page, and every overlay ever
// constructed asks.
let paintTimingSupport: boolean | undefined;

/** Whether the browser records paint timings, which Safari does not. */
function supportsPaintTiming(): boolean {
  paintTimingSupport ??=
    typeof PerformanceObserver === 'function' &&
    Array.isArray(PerformanceObserver.supportedEntryTypes) &&
    PerformanceObserver.supportedEntryTypes.includes('paint');

  return paintTimingSupport;
}

/** Whether the browser has painted already. */
function hasPainted(): boolean {
  if (typeof performance === 'undefined' || !supportsPaintTiming()) {
    return false;
  }

  return performance.getEntriesByType('paint').length > 0;
}

/**
 * Runs `callback` once the browser has painted, and returns a function that
 * cancels the wait.
 *
 * Paint timings are the signal where they exist, because a frame is not a
 * paint: two frames can pass on a page that has drawn nothing yet, which puts
 * the overlay back in the very first painted frame. Browsers without them fall
 * back to two frames.
 */
function afterFirstPaint(callback: () => void): () => void {
  let isDone = false;
  let observer: PerformanceObserver | undefined;

  const finish = (): void => {
    if (isDone) {
      return;
    }
    isDone = true;
    clearTimeout(timer);
    observer?.disconnect();
    callback();
  };

  // Deliberately left running by `settle`: the frame it waits on never arrives
  // in a hidden tab, and the overlay cannot be left unrendered until the tab
  // is looked at. `finish` runs once, for whichever gets there first.
  const timer = setTimeout(finish, FIRST_PAINT_TIMEOUT);

  const nextFrame = (fn: () => void): void => {
    if (typeof requestAnimationFrame === 'function') {
      requestAnimationFrame(() => fn());
    } else {
      fn();
    }
  };

  // One frame past the paint, so the overlay mounts after the frame the user
  // saw the page in.
  const settle = (): void => {
    nextFrame(finish);
  };

  if (supportsPaintTiming()) {
    observer = new PerformanceObserver(() => {
      settle();
    });
    observer.observe({ type: 'paint', buffered: true });
  } else {
    nextFrame(() => nextFrame(settle));
  }

  return () => {
    isDone = true;
    clearTimeout(timer);
    observer?.disconnect();
  };
}

/**
 * Class names that deliberately carry no CSS.
 *
 * `ember-css-transitions` decides whether an element animates *out* from
 * whether its enter transition ran (`finishedTransitionIn`), so skipping the
 * mount animation cannot be done by disabling the modifier -- that would take
 * the close animation with it. Pointing the enter half at inert class names
 * instead lets the modifier run its enter sequence and mark itself as entered,
 * while `computeTimeout` finds no duration to wait for and nothing moves.
 */
const INERT_ENTER_TRANSITION = {
  enterClass: 'overlay-transition--none-enter',
  enterActiveClass: 'overlay-transition--none-enter-active',
  enterToClass: 'overlay-transition--none-enter-to'
} as const;

/**
 * The given transition options with their enter half made inert, overriding
 * any enter classes the consumer supplied.
 */
function withoutEnterTransition<T extends object>(
  options: T
): T & typeof INERT_ENTER_TRANSITION {
  return { ...options, ...INERT_ENTER_TRANSITION };
}

export {
  afterFirstPaint,
  FIRST_PAINT_TIMEOUT,
  hasPainted,
  shouldDeferMount,
  shouldSkipEnterTransition,
  withoutEnterTransition,
  INERT_ENTER_TRANSITION,
  type MountAnimationState
};
