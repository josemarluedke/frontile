import Service, { service } from '@ember/service';
import { tracked } from '@glimmer/tracking';
import type Owner from '@ember/owner';
import type RouterService from '@ember/routing/router-service';

/**
 * How long a transition has to be in flight before the indicator appears.
 *
 * Routes whose bundle is already loaded settle in a few microtasks, and a bar
 * that flashed for one frame on those would read as a glitch rather than as
 * progress. Anything slower than this is a real wait, and the docs site has
 * plenty of those: every `splitAtRoutes` entry in `ember-cli-build.js` is a
 * separate lazily loaded bundle fetched at transition time.
 */
export const SHOW_DELAY = 100;

/**
 * Once shown, the indicator stays for at least this long.
 *
 * Without it, a transition that finishes just past `SHOW_DELAY` would show a
 * one-frame blip — the very thing the delay exists to prevent.
 */
export const MIN_VISIBLE = 320;

/**
 * Tracks whether the router is mid-transition, so the site chrome can show a
 * progress line instead of tearing the current page down.
 *
 * The site deliberately has no `loading` route templates: with lazily loaded
 * route bundles a loading substate would blank out the page the reader is
 * still looking at. Keeping the old page rendered and marking the wait at the
 * top of the window is the same trade Table makes while it refreshes — the
 * hairline under its `thead` — so the two use the same swinging line.
 */
export default class RouteLoadingService extends Service {
  @service declare router: RouterService;

  /** True while a transition has been in flight longer than `SHOW_DELAY`. */
  @tracked isLoading = false;

  /** A transition is in flight (whether or not the indicator is visible yet). */
  #isTransitioning = false;
  #showTimer?: ReturnType<typeof setTimeout>;
  #hideTimer?: ReturnType<typeof setTimeout>;
  #shownAt = 0;

  constructor(owner: Owner) {
    super(owner);

    this.router.on('routeWillChange', this.start);
    this.router.on('routeDidChange', this.finish);
  }

  willDestroy(): void {
    super.willDestroy();

    this.router.off('routeWillChange', this.start);
    this.router.off('routeDidChange', this.finish);
    this.#clearTimers();
  }

  /**
   * A transition started. Arrow-bound so it can be handed to `router.on`
   * and `router.off` as the same reference.
   */
  start = (): void => {
    // A redirect fires `routeWillChange` again before the first transition has
    // settled. That is still one wait from the reader's point of view, so the
    // timers already running are the right ones.
    if (this.#isTransitioning) {
      return;
    }
    this.#isTransitioning = true;

    // The previous transition is still serving out its minimum visible time.
    // Cancel the hide and let the line keep swinging rather than restarting
    // the delay, which would blink it off and on again.
    if (this.isLoading) {
      clearTimeout(this.#hideTimer);
      this.#hideTimer = undefined;
      return;
    }

    this.#showTimer = setTimeout(() => {
      this.#showTimer = undefined;
      this.#shownAt = Date.now();
      this.isLoading = true;
    }, SHOW_DELAY);
  };

  /** The transition settled (or errored into a substate). */
  finish = (): void => {
    this.#isTransitioning = false;

    clearTimeout(this.#showTimer);
    this.#showTimer = undefined;

    if (!this.isLoading) {
      return;
    }

    const remaining = MIN_VISIBLE - (Date.now() - this.#shownAt);
    if (remaining <= 0) {
      this.isLoading = false;
      return;
    }

    this.#hideTimer = setTimeout(() => {
      this.#hideTimer = undefined;
      this.isLoading = false;
    }, remaining);
  };

  #clearTimers(): void {
    clearTimeout(this.#showTimer);
    clearTimeout(this.#hideTimer);
    this.#showTimer = undefined;
    this.#hideTimer = undefined;
  }
}

declare module '@ember/service' {
  interface Registry {
    'route-loading': RouteLoadingService;
  }
}
