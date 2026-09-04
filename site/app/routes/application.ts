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
   *
   * **This hook also runs while prerendering**, on every page: `ssr/prerender.mjs`
   * visits each route in Node, so `didTransition` fires there too, and
   * `config.environment` is `production` in that build — the test guard is no
   * help. `window` itself exists (prerender.mjs installs it before the app
   * bundle is imported), but linkedom supplies none of the three functions used
   * below. Each is therefore checked at its own use, which is the pattern
   * `ssr/README.md` prescribes: letting one check stand in for the others would
   * quietly couple this hook to which globals the shim list happens to carry.
   */
  @action
  didTransition(): void {
    if (
      config.environment === 'test' ||
      typeof window.scrollTo !== 'function'
    ) {
      return;
    }

    const behavior = window.matchMedia?.('(prefers-reduced-motion: reduce)')
      .matches
      ? 'auto'
      : 'smooth';

    const scrollToTop = (): void => {
      window.scrollTo({ top: 0, behavior });
    };

    if (typeof window.requestAnimationFrame === 'function') {
      window.requestAnimationFrame(scrollToTop);
    } else {
      scrollToTop();
    }
  }
}
