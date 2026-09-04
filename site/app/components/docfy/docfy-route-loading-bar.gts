import { service } from '@ember/service';
import Component from '@glimmer/component';
import { VisuallyHidden } from 'frontile';
import type RouteLoadingService from 'site/services/route-loading';

/**
 * The hairline that marks a route transition in flight.
 *
 * It sits on the header's bottom edge and is the same line Table draws under
 * its `thead` while loading — `animate-swing` on a `h-px` half-width bar — so a
 * wait looks the same everywhere on the site. Nothing is unmounted while it
 * shows: the reader keeps the page they were on until the next one's bundle
 * arrives.
 */
export default class DocfyRouteLoadingBar extends Component {
  @service declare routeLoading: RouteLoadingService;

  <template>
    <div
      class="pointer-events-none absolute top-full left-0 z-10 h-px w-full overflow-hidden"
      role="status"
      aria-live="polite"
    >
      {{#if this.routeLoading.isLoading}}
        <VisuallyHidden>Loading page</VisuallyHidden>
        {{! The bar is decorative; the text above is what gets announced. }}
        <div
          class="h-px w-1/2 animate-swing bg-primary motion-reduce:animate-none"
          aria-hidden="true"
          data-test-id="route-loading-bar"
        ></div>
      {{/if}}
    </div>
  </template>
}
