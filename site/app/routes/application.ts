import Route from '@ember/routing/route';
import { action } from '@ember/object';
import config from 'site/config/environment';

/**
 * Where a page change should leave the reader: the heading the URL names, or
 * `'top'` when it names none.
 *
 * A URL carrying an anchor is a request for a position, and it arrives through
 * the same hook as an ordinary page change — both on a fresh load of
 * `/docs/…/button-group#accessibility` and on an in-app link to another page's
 * heading (`skeleton.md` links to `table#built-in-skeleton-rows`). Scrolling to
 * the top in either case throws away the position the reader asked for.
 *
 * Resolving the element covers both: on a fresh load the browser has already
 * put the heading there, so scrolling to it again changes nothing, and on an
 * in-app transition nothing else would have moved the page at all. An anchor
 * naming something this page doesn't have falls back to the top, which is what
 * the browser does with it too.
 */
export function scrollTargetFor(hash: string): Element | 'top' {
  const id = hash.replace(/^#/, '');

  if (!id) {
    return 'top';
  }

  return document.getElementById(id) ?? 'top';
}

export default class Application extends Route {
  /**
   * Send the reader to the top of the new page — or to the heading its URL
   * names, per `scrollTargetFor`.
   *
   * Smoothly, so the change of page reads as a movement rather than a jump —
   * the docs are long enough that an instant snap left no clue that anything
   * had moved. `requestAnimationFrame` defers to the next frame, by which
   * point the new page has rendered: scrolling against the outgoing page's
   * height gets clamped to the wrong position. Readers who ask for less
   * motion get the jump instead.
   *
   * In-page heading clicks do not come through here — they are plain anchors
   * handled by DocfyPageHeadings' own scrolling.
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

    const scroll = (): void => {
      // Resolved here rather than above, because the incoming page's headings
      // are only in the DOM once this frame runs.
      const target = scrollTargetFor(window.location.hash);

      if (target === 'top') {
        window.scrollTo({ top: 0, behavior });
      } else {
        target.scrollIntoView({ behavior, block: 'start' });
      }
    };

    if (typeof window.requestAnimationFrame === 'function') {
      window.requestAnimationFrame(scroll);
    } else {
      scroll();
    }
  }
}
