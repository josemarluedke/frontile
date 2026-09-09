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
    // The drag transform lives on this element, while the close animation
    // runs on the overlay wrapper above it. Animating this element back to 0
    // relies on that animation starting the same frame as the wrapper's
    // leave transition -- but onDismiss() -> onClose -> a tracked flag flip
    // -> Ember re-render -> ember-css-transitions applying `leave` and then
    // waiting a rAF before `leave-active`/`leave-to`. That gap runs several
    // frames after our own transition already started travelling back to 0,
    // so the drawer visibly snaps toward its resting position before the
    // wrapper's slide-out even begins.
    //
    // Instead, freeze the drag transform exactly where release left it --
    // no transition, no change to the transform value -- and hand off to
    // onDismiss(). The wrapper's own 0 -> 100% leave animation then carries
    // the drawer (dragged offset and all) the rest of the way off-screen, so
    // the whole motion is continuous from wherever the user let go. Because
    // this element never animates on its own after release, there is no
    // ordering between two animations left to race.
    element.style.transition = 'none';

    named.onDismiss();
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

    // The element is normally destroyed along with the rest of the drawer
    // once the leave animation finishes, so a frozen drag transform never
    // gets a chance to leak into a reopen. Clear it defensively anyway --
    // e.g. an element reused by a future modifier revision -- so nothing
    // outlives this instance.
    element.style.transform = '';
    element.style.transition = '';
  };
});

export { dragToDismiss };
export default dragToDismiss;
