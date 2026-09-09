import { modifier } from 'ember-modifier';

export type DragAxis = 'x' | 'y';

/** 1 dismisses by moving positive along the axis (down / right); -1 negative. */
export type DragDirection = 1 | -1;

export interface DragToDismissOptions {
  axis: DragAxis;
  direction: DragDirection;
  isEnabled: boolean;
  onDismiss: () => void;
  /** Scroll container that may start a drag when already at its edge. */
  scrollSelector?: string;
  /** Always-draggable handle. */
  handleSelector?: string;
}

/** Fraction of the element's size along the axis that commits a dismiss. */
const DISTANCE_THRESHOLD = 0.25;

/** px/ms that commits a dismiss regardless of distance. */
const VELOCITY_THRESHOLD = 0.4;

/** Window over which velocity is measured. */
const VELOCITY_WINDOW_MS = 100;

/** Minimum elapsed time trusted for a velocity estimate; see velocity(). */
const MIN_VELOCITY_ELAPSED_MS = 4;

const SETTLE_MS = 200;
const EASING = 'cubic-bezier(0.37, 0, 0.63, 1)';

/** Resistance applied to movement away from the dismiss direction. */
const RUBBER_BAND = 0.2;

function prefersReducedMotion(): boolean {
  return (
    typeof window.matchMedia === 'function' &&
    window.matchMedia('(prefers-reduced-motion: reduce)').matches
  );
}

interface Sample {
  position: number;
  time: number;
}

const dragToDismiss = modifier<{
  Args: { Positional: []; Named: DragToDismissOptions };
  Element: HTMLElement;
}>((element, _positional, named) => {
  let pointerId: number | null = null;
  let start = 0;
  let offset = 0;
  let samples: Sample[] = [];
  let isDestroyed = false;
  let exitTimeoutId: number | undefined;

  const axisPosition = (event: PointerEvent): number =>
    named.axis === 'y' ? event.clientY : event.clientX;

  const elementSize = (): number =>
    named.axis === 'y' ? element.offsetHeight : element.offsetWidth;

  const setTransform = (value: number): void => {
    element.style.transform =
      named.axis === 'y' ? `translateY(${value}px)` : `translateX(${value}px)`;
  };

  // Whether a drag started inside the body should take over from native
  // scrolling: only when the scroller is already at the edge the drag pulls
  // away from, so a half-scrolled list still scrolls normally.
  const scrollerAllowsDrag = (target: EventTarget | null): boolean => {
    if (!named.scrollSelector) {
      return false;
    }

    const scroller =
      target instanceof Element
        ? target.closest<HTMLElement>(named.scrollSelector)
        : null;

    if (!scroller) {
      // The press did not land in the scroll container at all.
      return true;
    }

    const position =
      named.axis === 'y' ? scroller.scrollTop : scroller.scrollLeft;
    const max =
      named.axis === 'y'
        ? scroller.scrollHeight - scroller.clientHeight
        : scroller.scrollWidth - scroller.clientWidth;

    return named.direction === 1 ? position <= 0 : position >= max;
  };

  const isHandle = (target: EventTarget | null): boolean =>
    Boolean(
      named.handleSelector &&
      target instanceof Element &&
      target.closest(named.handleSelector)
    );

  // Without either selector configured, the whole element is free-drag: any
  // pointerdown on it starts a drag. Once a handleSelector and/or
  // scrollSelector is configured, they're the only ways in — a handle press
  // always qualifies, and a scroll container only yields once it's already
  // scrolled to the edge the drag pulls away from (or the press landed
  // outside it entirely).
  const pointerDownStartsDrag = (target: EventTarget | null): boolean => {
    if (!named.handleSelector && !named.scrollSelector) {
      return true;
    }

    return isHandle(target) || scrollerAllowsDrag(target);
  };

  const handlePointerDown = (event: PointerEvent): void => {
    if (
      !named.isEnabled ||
      pointerId !== null ||
      !event.isPrimary ||
      event.button !== 0
    ) {
      return;
    }

    if (!pointerDownStartsDrag(event.target)) {
      return;
    }

    pointerId = event.pointerId;
    start = axisPosition(event);
    offset = 0;
    samples = [{ position: start, time: event.timeStamp }];

    // A synthetic PointerEvent carries an id the browser never issued, so
    // capture throws in tests. The drag works without it; capture only
    // makes real pointers keep tracking outside the element.
    try {
      element.setPointerCapture(event.pointerId);
    } catch {
      // ignore
    }

    element.style.transition = 'none';
  };

  const handlePointerMove = (event: PointerEvent): void => {
    if (pointerId !== event.pointerId) {
      return;
    }

    const position = axisPosition(event);
    const raw = (position - start) * named.direction;

    // Toward the dismiss edge tracks 1:1; away from it rubber-bands, so the
    // panel still acknowledges the gesture without appearing to detach.
    offset = raw >= 0 ? raw : raw * RUBBER_BAND;

    samples.push({ position, time: event.timeStamp });
    samples = samples.filter(
      (sample) => event.timeStamp - sample.time <= VELOCITY_WINDOW_MS
    );

    // Once we own the gesture the browser must not also scroll or select.
    if (event.cancelable) {
      event.preventDefault();
    }

    setTransform(offset * named.direction);
  };

  const settle = (): void => {
    if (prefersReducedMotion()) {
      element.style.transition = '';
      element.style.transform = '';
      return;
    }

    element.style.transition = `transform ${SETTLE_MS}ms ${EASING}`;
    element.style.transform = '';
  };

  const commit = (): void => {
    // We own the exit motion ourselves rather than handing off to the
    // overlay wrapper's leave animation. onDismiss() -> onClose -> a tracked
    // flag flip -> Ember re-render -> ember-css-transitions applying `leave`
    // happens several frames later, and in that gap Ember's re-render (or
    // this modifier's own teardown, which runs once `isOpen` flips) clears
    // this element's inline transform -- so freezing the transform and
    // waiting for the wrapper's animation let the drawer visibly snap back
    // to rest before sliding out.
    //
    // Instead, animate this element from its current dragged offset the
    // rest of the way off-screen (its own size along the axis), and only
    // call onDismiss() once that animation finishes. While onDismiss has
    // not fired, `isOpen` is still true, so nothing re-renders or destroys
    // this element and nothing can clear its inline style out from under
    // the animation -- the motion is continuous from wherever the user let
    // go, and by the time onDismiss finally runs the element is already
    // off-screen, so whatever the wrapper's leave animation does next is
    // invisible.
    if (prefersReducedMotion()) {
      named.onDismiss();
      return;
    }

    const size = elementSize();
    const distance = Math.max(size, Math.abs(offset));

    const finish = (): void => {
      if (exitTimeoutId !== undefined) {
        window.clearTimeout(exitTimeoutId);
        exitTimeoutId = undefined;
      }
      element.removeEventListener('transitionend', onTransitionEnd);

      if (isDestroyed) {
        return;
      }

      named.onDismiss();
    };

    const onTransitionEnd = (event: TransitionEvent): void => {
      if (event.target !== element || event.propertyName !== 'transform') {
        return;
      }
      finish();
    };

    element.addEventListener('transitionend', onTransitionEnd);
    // transitionend can fail to fire (e.g. the element is hidden mid
    // transition), so a timeout guarantees onDismiss still runs.
    exitTimeoutId = window.setTimeout(finish, SETTLE_MS + 50);

    element.style.transition = `transform ${SETTLE_MS}ms ${EASING}`;
    setTransform(distance * named.direction);
  };

  const velocity = (event: PointerEvent): number => {
    const oldest = samples[0];
    if (!oldest) {
      return 0;
    }

    const elapsed = event.timeStamp - oldest.time;
    // Real pointer input arrives no faster than the device's sampling rate
    // (~8ms for a 120Hz touch digitizer, ~16ms for a 60Hz mouse poll), so an
    // elapsed time below that floor is measurement noise rather than a
    // signal of gesture speed — dividing by it would produce a physically
    // implausible velocity. Below the floor, fall back to the distance
    // check alone.
    if (elapsed < MIN_VELOCITY_ELAPSED_MS) {
      return 0;
    }

    return (
      ((axisPosition(event) - oldest.position) * named.direction) / elapsed
    );
  };

  const handlePointerUp = (event: PointerEvent): void => {
    if (pointerId !== event.pointerId) {
      return;
    }

    pointerId = null;

    try {
      element.releasePointerCapture(event.pointerId);
    } catch {
      // ignore
    }

    const size = elementSize();
    const passedDistance = size > 0 && offset > size * DISTANCE_THRESHOLD;
    const passedVelocity = velocity(event) > VELOCITY_THRESHOLD;

    if (passedDistance || passedVelocity) {
      commit();
    } else {
      settle();
    }
  };

  element.addEventListener('pointerdown', handlePointerDown);
  element.addEventListener('pointermove', handlePointerMove, {
    passive: false
  });
  element.addEventListener('pointerup', handlePointerUp);
  element.addEventListener('pointercancel', handlePointerUp);

  return () => {
    element.removeEventListener('pointerdown', handlePointerDown);
    element.removeEventListener('pointermove', handlePointerMove);
    element.removeEventListener('pointerup', handlePointerUp);
    element.removeEventListener('pointercancel', handlePointerUp);

    // Mark torn down first so a pending exit animation's finish() (from
    // transitionend or its setTimeout fallback) sees it and skips calling
    // onDismiss() again -- the caller that tore this modifier down has
    // already moved on, and firing onDismiss after teardown could re-enter
    // logic that no longer expects it.
    isDestroyed = true;

    // Because commit() defers onDismiss() until the exit animation finishes,
    // isOpen is still true (and this element still mounted) for the whole
    // animation -- so teardown here only ever runs for a drag that never
    // committed (disabled mid-drag, spring-back, or the consumer unmounting
    // the drawer some other way), or for a rare unmount that races an
    // in-flight exit animation. Only reset the drag styling when there is no
    // exit animation pending -- clearing `transform`/`transition` out from
    // under a pending one would abort it visibly (snap the element back)
    // for no reason, since finish() above already made sure onDismiss()
    // itself is a no-op after teardown.
    if (exitTimeoutId === undefined) {
      element.style.transform = '';
      element.style.transition = '';
    }
  };
});

export { dragToDismiss };
export default dragToDismiss;
