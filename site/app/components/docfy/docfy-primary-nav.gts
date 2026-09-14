import Component from '@glimmer/component';
import { service } from '@ember/service';
import { DocfyLink } from '@docfy/ember';
import type RouterService from '@ember/routing/router-service';

/**
 * The header's two primary destinations, and the one place that decides which
 * of them is current.
 *
 * The split is by *kind*, not by section: everything under `/docs/components`
 * is reference material you arrive at knowing the component's name, and
 * everything else is a guide you read front to back. The section nav below the
 * header narrows within whichever kind is active, so these two never repeat
 * what that bar already shows.
 *
 * `DocfyLink`'s own `@activeClass` matches a single page, which is the wrong
 * granularity here — "Guides" has to stay lit across four sections and dozens
 * of pages. Hence the URL-prefix test below rather than per-link route state.
 *
 * Only `aria-current` is set; the header's link class styles the current link
 * off that attribute, so the announced state and the painted state are one
 * fact rather than two that can disagree.
 */

const DOCS_PREFIX = '/docs';
const COMPONENTS_PREFIX = '/docs/components';

interface Signature {
  Args: {
    /** Applied to every link; carries its own `aria-current` styling. */
    itemClass: string;
  };
  Element: null;
}

export default class DocfyPrimaryNav extends Component<Signature> {
  @service declare router: RouterService;

  get isComponents(): boolean {
    return (this.router.currentURL ?? '').startsWith(COMPONENTS_PREFIX);
  }

  /**
   * Guides owns everything under `/docs` that Components does not — but not
   * pages outside `/docs` at all. "Not Components" is not the same test: it
   * would light Guides on the home page, which belongs to neither.
   */
  get isGuides(): boolean {
    return (
      (this.router.currentURL ?? '').startsWith(DOCS_PREFIX) &&
      !this.isComponents
    );
  }

  <template>
    <DocfyLink
      @to="/docs/get-started"
      class={{@itemClass}}
      aria-current={{if this.isGuides "page"}}
    >
      Guides
    </DocfyLink>

    <DocfyLink
      @to="/docs/components/overview"
      class={{@itemClass}}
      aria-current={{if this.isComponents "page"}}
    >
      Components
    </DocfyLink>
  </template>
}
