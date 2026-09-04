import { service } from '@ember/service';
import Component from '@glimmer/component';
import { VisuallyHidden } from 'frontile';
import type RouteLoadingService from 'site/services/route-loading';

/**
 * The line that marks a route transition in flight.
 *
 * It rides the very top edge of the viewport, above every piece of chrome.
 * Anywhere lower is unreliable: the docs section nav is `sticky top-16 z-10`,
 * which sits on the same line as the header's bottom border and outranks the
 * header's own stacking context, so a line drawn there is covered on every
 * docs page.
 *
 * The movement is Table's loading hairline — `animate-swing` sweeping a
 * half-width bar — so a wait looks the same everywhere on the site. It is a
 * touch heavier than Table's hairline (and carries a glow) because it has the
 * whole window to be noticed in, rather than one component's header.
 *
 * Nothing is unmounted while it shows: the reader keeps the page they were on
 * until the next one's bundle arrives.
 */
export default class DocfyRouteLoadingBar extends Component {
  @service declare routeLoading: RouteLoadingService;

  <template>
    <div
      class="pointer-events-none fixed inset-x-0 top-0 z-50 h-0.5 overflow-hidden"
      role="status"
      aria-live="polite"
    >
      {{#if this.routeLoading.isLoading}}
        <VisuallyHidden>Loading page</VisuallyHidden>
        {{! The bar is decorative; the text above is what gets announced. }}
        <div
          class="h-full w-1/2 animate-swing bg-primary shadow-[0_0_8px_1px_var(--color-primary)] motion-reduce:animate-none"
          aria-hidden="true"
          data-test-id="route-loading-bar"
        ></div>
      {{/if}}
    </div>
  </template>
}
