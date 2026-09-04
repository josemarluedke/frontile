import Route from '@ember/routing/route';
import { action } from '@ember/object';
import config from 'site/config/environment';

export default class Application extends Route {
  /**
   * Send the reader back to the top of the new page.
   *
   * Smoothly, so the change of page reads as a movement rather than a jump —
   * the docs are long enough that an instant snap left no clue that anything
   * had moved. `requestAnimationFrame` defers to the next frame, by which
   * point the new page has rendered: scrolling against the outgoing page's
   * height gets clamped to the wrong position. Readers who ask for less
   * motion get the jump instead.
   *
   * Heading links do not come through here — they are plain anchors handled by
   * DocfyPageHeadings' own scrolling — so this only fires on page changes.
   */
  @action
  didTransition(): void {
    // Prerendering has nothing to scroll, and linkedom supplies no `scrollTo`.
    // Guarding on the function itself is the pattern ssr/README.md prescribes;
    // `window` is always defined, since a missing global fails the SSR build.
    if (
      config.environment === 'test' ||
      typeof window.scrollTo !== 'function'
    ) {
      return;
    }

    const behavior = window.matchMedia('(prefers-reduced-motion: reduce)')
      .matches
      ? 'auto'
      : 'smooth';

    window.requestAnimationFrame(() => {
      window.scrollTo({ top: 0, behavior });
    });
  }
}
