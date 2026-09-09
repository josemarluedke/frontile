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

/**
 * Travel, in px, a press on a scroll container must cover before the
 * modifier decides whether it is a dismiss drag or a native scroll. Below
 * this, a tap's inherent jitter (and a real scroll's own initial wobble)
 * would otherwise read as a direction. 10px sits in the middle of the 8-12px
 * range typical of touch "slop" thresholds (e.g. the ~10px many browsers use
 * before committing a touch gesture to panning) -- large enough to filter
 * jitter, small enough that the decision still feels immediate.
 */
const CLAIM_THRESHOLD_PX = 10;

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

  // A press that landed on the scroll container (rather than the handle)
  // does not claim the gesture on pointerdown. It waits here, undecided,
  // until handlePointerMove sees enough travel to tell a dismiss drag from a
  // native scroll -- see the pending branch there for the decision itself.
  let pendingPointerId: number | null = null;
  let pendingStartX = 0;
  let pendingStartY = 0;
  let pendingTarget: EventTarget | null = null;
  let exitTimeoutId: number | undefined;
  // Set once the gesture has committed to dismissing. After that point the
  // off-screen transform must survive teardown -- see the note in the
  // destructor for why clearing it is visible even though the element is on
  // its way out.
  let hasCommitted = false;

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
      // The press did not land in the scroll container at all -- e.g. a
      // header or footer area outside it. There's nothing there to protect
      // from a hijacked scroll, so it's always draggable. This used to be
      // riskier than it sounds, since the old pointerdown-time claim
      // preventDefault'd every subsequent move unconditionally; now it only
      // matters once handlePointerMove's own along-axis/toward-dismiss gate
      // agrees, so a header press that wiggles sideways or the wrong way no
      // longer hijacks anything either.
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

  // Claim the gesture immediately -- this is only ever right for a press
  // that needs no further evidence: the handle (an explicit affordance, see
  // below), or any press at all when there's no scroll container configured
  // to protect (free-drag, nothing native can conflict with).
  const claimDrag = (event: PointerEvent): void => {
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

  const handlePointerDown = (event: PointerEvent): void => {
    if (
      !named.isEnabled ||
      pointerId !== null ||
      pendingPointerId !== null ||
      !event.isPrimary ||
      event.button !== 0
    ) {
      return;
    }

    if (isHandle(event.target)) {
      claimDrag(event);
      return;
    }

    if (!named.scrollSelector) {
      // Nothing scrollable is configured at all, so there's no native
      // scroll to protect -- the whole element is free-drag, same as
      // always.
      claimDrag(event);
      return;
    }

    // A scroll container exists somewhere in this element. Claiming here
    // (the old behaviour) meant every press that landed at the scroll
    // edge -- including the extremely common case of content shorter than
    // the container, where scrollHeight === clientHeight so it is *always*
    // at the edge -- immediately took over the gesture and preventDefault'd
    // every subsequent move, which silently broke native scrolling. Instead,
    // wait: record where the press started and decide once handlePointerMove
    // sees enough travel to tell a scroll from a dismiss drag.
    pendingPointerId = event.pointerId;
    pendingStartX = event.clientX;
    pendingStartY = event.clientY;
    pendingTarget = event.target;
    samples = [{ position: axisPosition(event), time: event.timeStamp }];
  };

  const applyDragOffset = (event: PointerEvent): void => {
    const position = axisPosition(event);
    const raw = (position - start) * named.direction;

    // Toward the dismiss edge tracks 1:1; away from it rubber-bands, so the
    // panel still acknowledges the gesture without appearing to detach.
    offset = raw >= 0 ? raw : raw * RUBBER_BAND;

    // Once we own the gesture the browser must not also scroll or select.
    if (event.cancelable) {
      event.preventDefault();
    }

    setTransform(offset * named.direction);
  };

  const handlePointerMove = (event: PointerEvent): void => {
    const isActive = pointerId === event.pointerId;
    const isPending = !isActive && pendingPointerId === event.pointerId;

    if (!isActive && !isPending) {
      return;
    }

    samples.push({ position: axisPosition(event), time: event.timeStamp });
    samples = samples.filter(
      (sample) => event.timeStamp - sample.time <= VELOCITY_WINDOW_MS
    );

    if (isPending) {
      const dx = event.clientX - pendingStartX;
      const dy = event.clientY - pendingStartY;

      if (Math.hypot(dx, dy) < CLAIM_THRESHOLD_PX) {
        // Not enough travel yet to tell a scroll from a dismiss drag. Leave
        // the event alone -- no preventDefault -- so native scrolling (if
        // any) is free to happen.
        return;
      }

      // Enough travel to decide, once and for all: never re-evaluate this
      // gesture again after this point.
      const axisDelta = named.axis === 'y' ? dy : dx;
      const crossDelta = named.axis === 'y' ? dx : dy;
      const movesTowardDismiss = axisDelta * named.direction > 0;
      const isAlongAxis = Math.abs(axisDelta) > Math.abs(crossDelta);
      const target = pendingTarget;

      pendingPointerId = null;
      pendingTarget = null;

      if (!isAlongAxis || !movesTowardDismiss || !scrollerAllowsDrag(target)) {
        // Abandoned permanently for this gesture: never preventDefault, let
        // the browser scroll (or do nothing) natively. Nothing was ever
        // claimed or captured, so there's nothing to undo.
        return;
      }

      pointerId = event.pointerId;
      start = named.axis === 'y' ? pendingStartY : pendingStartX;
      offset = 0;

      try {
        element.setPointerCapture(event.pointerId);
      } catch {
        // ignore
      }

      element.style.transition = 'none';
    }

    applyDragOffset(event);
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
    hasCommitted = true;

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
    if (pendingPointerId === event.pointerId) {
      // The gesture never crossed the claim threshold: a tap, or a press
      // that stayed a native scroll for its whole life. This also covers
      // `pointercancel`, which the browser fires on a pending gesture when
      // it takes over to scroll -- either way, nothing was ever claimed or
      // captured, so resetting is all there is to do; it must not be
      // mistaken for a dismiss.
      pendingPointerId = null;
      pendingTarget = null;
      return;
    }

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

    // Never clear the transform once the gesture has committed. It looks
    // safe to -- the element is being destroyed -- but ember-css-transitions
    // does not animate this element out, it animates a CLONE of it, and the
    // clone is taken during teardown. Measured: with the reset in place, the
    // drawer slid off-screen under its own exit animation, then the clone
    // appeared back at the resting position and slid out a second time. That
    // is the "jumps back to the open position, then closes" report; the
    // transform has to still be on the element at the moment it is cloned.
    //
    // The remaining case is a drag that never committed -- disabled
    // mid-drag, spring-back, or the consumer unmounting the drawer some
    // other way -- where the drag styling should indeed be undone. The
    // `exitTimeoutId` guard additionally covers an unmount racing an
    // in-flight exit animation, where clearing would abort it visibly.
    if (!hasCommitted && exitTimeoutId === undefined) {
      element.style.transform = '';
      element.style.transition = '';
    }
  };
});

export { dragToDismiss };
export default dragToDismiss;
