import { modifier } from 'ember-modifier';

/**
 * Calls back the first time the element enters the viewport, then stops
 * observing.
 *
 * The homepage reveals content with scroll-driven CSS animations, which need no
 * JavaScript. This exists for the one case CSS cannot cover: opening a
 * component's state on arrival rather than restyling it.
 *
 * It also works around a real constraint in Popover. Rendering it with
 * `@isOpen={{true}}` asserts — its yielded `Content` reads `velcro.loop`, which
 * the anchor modifier has not installed yet on the first render pass, so the
 * component cannot be born open. Opening on arrival sidesteps that and is the
 * better moment anyway.
 *
 * Degrades to nothing: if the observer never fires, the element simply keeps
 * its initial state and its own trigger still works.
 */
export default modifier((element: Element, [onInView]: [() => void]) => {
  const observer = new IntersectionObserver(
    (entries) => {
      if (entries.some((entry) => entry.isIntersecting)) {
        observer.disconnect();
        onInView();
      }
    },
    // A little inside the edge, so it fires as the section settles rather
    // than the instant its first pixel appears.
    { rootMargin: '0px 0px -20% 0px' }
  );

  observer.observe(element);

  return (): void => observer.disconnect();
});
