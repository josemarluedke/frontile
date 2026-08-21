import Component from '@glimmer/component';
import { action } from '@ember/object';
import { on } from '@ember/modifier';
import { service } from '@ember/service';
import config from 'site/config/environment';
import type RouterService from '@ember/routing/router-service';

export interface Signature {
  Args: {
    /** A Docfy page path, e.g. "/docs/components/forms/select". */
    to: string;
    /**
     * Applied while the current URL is at or below `@to` — matched on the URL
     * rather than the route name, again to avoid resolving the route.
     */
    activeClass?: string;
  };
  Blocks: { default: [] };
  Element: HTMLAnchorElement;
}

/**
 * A link to a documentation page that does not pull the page's bundle in
 * order to render itself.
 *
 * `<DocfyLink>` is addressed by URL, so its `href` getter reads `routeName`,
 * which calls `RouterService#recognize()` to map the URL to a route. Recognising
 * resolves the matched route handlers, and resolving a route inside a
 * `splitAtRoutes` bundle is what makes `@embroider/router` fetch that bundle.
 * The homepage links to roughly forty docs pages spread across every section,
 * so rendering it downloaded the entire documentation site up front — exactly
 * what the split was meant to avoid.
 *
 * Plain `<LinkTo @route="...">` is *not* affected: it is addressed by route
 * name, needs no `recognize()`, and renders without loading anything. The
 * trouble is specific to resolving a URL, which is how Docfy pages are known.
 *
 * Docfy URLs already are the router's paths, so `href` needs no resolution at
 * all here, and the recognise-and-transition can wait for an actual click.
 */
export default class DocsLink extends Component<Signature> {
  @service declare router: RouterService;

  get href(): string {
    const rootURL = config.rootURL.replace(/\/$/, '');

    return `${rootURL}${this.args.to}`;
  }

  get isActive(): boolean {
    const currentURL = this.router.currentURL;

    if (!currentURL) {
      return false;
    }

    const target = this.args.to.replace(/\/$/, '');

    return currentURL === target || currentURL.startsWith(`${target}/`);
  }

  @action navigate(event: MouseEvent): void {
    // Leave modified clicks and anything but the primary button to the
    // browser, so "open in new tab" keeps working.
    if (
      event.button !== 0 ||
      event.ctrlKey ||
      event.metaKey ||
      event.shiftKey ||
      event.altKey
    ) {
      return;
    }

    event.preventDefault();
    this.router.transitionTo(this.args.to);
  }

  <template>
    <a
      href={{this.href}}
      class={{if this.isActive @activeClass}}
      ...attributes
      {{on "click" this.navigate}}
    >
      {{yield}}
    </a>
  </template>
}
