/**
 * When an overlay's enter animation is worth playing, and what to do when it
 * is not.
 *
 * An overlay that is already open the first time it renders -- one that is
 * deep-linked open, or that a page refresh restored -- has nothing to animate
 * away from. Its enter transition starts before the browser has painted
 * anything at all, so the first pixels the user ever sees already contain a
 * half-faded overlay, and the backdrop fades in at the same moment as the page
 * it is meant to be dimming. Measured on a cold load, the transition ran from
 * 126ms to 311ms while first paint landed at 152ms: technically animated,
 * perceptually absent -- and on a heavier app the whole 200ms can be spent
 * before first paint, at which point it really is invisible.
 *
 * So the overlay waits for that first paint before mounting, and the animation
 * then plays against a page the user has already seen. Consumers who would
 * rather an already-open overlay simply be there can opt out with
 * `@animateOnMount={{false}}`.
 */

interface MountAnimationState {
  /** Whether `@isOpen` was already true the first time the overlay rendered. */
  isOpenAtMount: boolean;

  /**
   * Whether transitions run at all -- false in tests and when
   * `@disableTransitions` is set.
   */
  animationsEnabled: boolean;

  /** The `@animateOnMount` argument, `undefined` when not passed. */
  animateOnMount: boolean | undefined;

  /**
   * Whether there is a frame to wait for. False without
   * `requestAnimationFrame` (prerendering), where there is no paint to animate
   * against and waiting would mean never rendering.
   */
  canWaitForFrame: boolean;

  /**
   * Whether the browser has already painted. True for the overlay of a slow
   * boot that rendered well after the page appeared -- there is nothing left
   * to wait for, and its animation is already visible.
   */
  hasPainted: boolean;
}

/**
 * Whether to hold the overlay out of the DOM until the browser has painted.
 *
 * Only the mount-open case waits, and only before the first paint: an overlay
 * opened by interaction, or rendered by a boot slow enough that the page is
 * already on screen, is animating against something the user can see.
 * Turning the animation off, by argument or because animations are disabled
 * entirely, means rendering immediately -- there is nothing to make visible,
 * and in tests a deferred mount would expose a frame of empty DOM that
 * `settled` does not wait for.
 */
function shouldDeferMount(state: MountAnimationState): boolean {
  return (
    state.isOpenAtMount &&
    state.animationsEnabled &&
    state.animateOnMount !== false &&
    state.canWaitForFrame &&
    !state.hasPainted
  );
}

/**
 * Whether the enter half of the transition should be neutered for this mount.
 */
function shouldSkipEnterTransition(state: MountAnimationState): boolean {
  return (
    state.isOpenAtMount &&
    state.animationsEnabled &&
    state.animateOnMount === false
  );
}

/**
 * How long to wait for a paint that may never be recorded -- a page loaded in
 * a background tab paints nothing until it is looked at, and the overlay still
 * has to exist in the DOM before then.
 */
const FIRST_PAINT_TIMEOUT = 300;

/** Whether the browser records paint timings, which Safari does not. */
function supportsPaintTiming(): boolean {
  return (
    typeof PerformanceObserver === 'function' &&
    Array.isArray(PerformanceObserver.supportedEntryTypes) &&
    PerformanceObserver.supportedEntryTypes.includes('paint')
  );
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
 * Where paint timings exist they are the honest signal, because a frame is
 * not a paint: two frames can pass on a page that has drawn nothing yet, which
 * puts the overlay back in the very first painted frame -- exactly what the
 * wait is for avoiding. Browsers without paint timings fall back to two
 * frames, which is the best approximation available there.
 */
function afterFirstPaint(callback: () => void): () => void {
  let isDone = false;
  let observer: PerformanceObserver | undefined;

  const finish = (): void => {
    if (isDone) {
      return;
    }
    isDone = true;
    observer?.disconnect();
    callback();
  };

  const timer = setTimeout(finish, FIRST_PAINT_TIMEOUT);

  const nextFrame = (fn: () => void): void => {
    if (typeof requestAnimationFrame === 'function') {
      requestAnimationFrame(() => fn());
    } else {
      fn();
    }
  };

  // One frame past the paint, so the overlay mounts into a frame after the one
  // the user saw the page in.
  const settle = (): void => {
    clearTimeout(timer);
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
  hasPainted,
  shouldDeferMount,
  shouldSkipEnterTransition,
  withoutEnterTransition,
  INERT_ENTER_TRANSITION,
  type MountAnimationState
};
