import Component from '@glimmer/component';
import { cached } from '@glimmer/tracking';
import { service } from '@ember/service';
import { LinkTo } from '@ember/routing';
import type RouterService from '@ember/routing/router-service';
import type { ModifierLike } from '@glint/template';
import { isRouteActive, normalizeRouteArgs } from '../../../utils/route-active';

interface TabNavItemArgs {
  /**
   * Renders a `LinkTo` for this route and derives the active state from the
   * router. Omit it (and pass `@href`) to stay entirely router-free.
   */
  route?: string;

  /** Dynamic segments for `@route`. */
  models?: unknown[];

  /** A single dynamic segment for `@route`. */
  model?: unknown;

  /** Query params for `@route`. */
  query?: Record<string, unknown>;

  /** Renders a plain anchor. Ignored when `@route` is given. */
  href?: string;

  /**
   * Overrides the active state. Always wins over anything derived from the
   * router, and is the only source of truth when `@route` is not used.
   */
  isActive?: boolean;

  /**
   * Marks the link as disabled. An anchor cannot be natively disabled, so the
   * href is dropped as well -- `aria-disabled` alone still leaves it
   * clickable.
   *
   * @defaultValue false
   */
  isDisabled?: boolean;

  /** Class names appended to this item's theme classes. */
  class?: string;

  /**
   * Supplied by TabNav. Not part of the public API.
   *
   * @internal
   */
  itemClass: string;

  /**
   * Supplied by TabNav. Not part of the public API.
   *
   * @internal
   */
  setupItem: ModifierLike<{
    Element: HTMLElement;
    Args: { Positional: [boolean] };
  }>;
}

interface TabNavItemSignature {
  Args: TabNavItemArgs;
  Blocks: { default: [] };
  Element: HTMLAnchorElement;
}

class TabNavItem extends Component<TabNavItemSignature> {
  // Ember's service injection is getter-based, so this resolves only when
  // `isActive` below actually reads it -- which happens only when `@route` was
  // passed and `@isActive` was not. An application that does not route never
  // touches the router.
  @service declare router: RouterService;

  @cached
  get models(): unknown[] {
    return normalizeRouteArgs(this.args).models;
  }

  @cached
  get query(): Record<string, unknown> {
    return normalizeRouteArgs(this.args).query;
  }

  get isActive(): boolean {
    return isRouteActive(this.router, this.args);
  }

  get isDisabled(): boolean {
    return this.args.isDisabled ?? false;
  }

  /**
   * A `LinkTo` is only rendered for a route the item can actually navigate to.
   * `LinkTo` cannot be talked out of a real, navigable href -- its `@disabled`
   * only short-circuits the click handler and tags on an un-themed `disabled`
   * class -- so a disabled route item falls through to the plain anchor
   * instead, where dropping the href is what actually disables it.
   *
   * That anchor keeps `aria-disabled` even with no href at all, per this
   * component's documented contract. `no-unsupported-role-attributes` is
   * disabled over it for exactly that pairing: the rule cannot see that the
   * href is conditional.
   */
  get rendersLink(): boolean {
    return Boolean(this.args.route) && !this.isDisabled;
  }

  <template>
    {{#if this.rendersLink}}
      <LinkTo
        @route={{@route}}
        @models={{this.models}}
        @query={{this.query}}
        data-part="tab"
        class="{{@itemClass}} {{@class}}"
        aria-disabled="false"
        data-disabled="false"
        {{@setupItem this.isActive}}
        ...attributes
      >
        {{yield}}
      </LinkTo>
    {{else}}
      {{! template-lint-disable no-unsupported-role-attributes }}
      <a
        data-part="tab"
        href={{unless this.isDisabled @href}}
        class="{{@itemClass}} {{@class}}"
        aria-disabled="{{this.isDisabled}}"
        data-disabled="{{this.isDisabled}}"
        {{@setupItem this.isActive}}
        ...attributes
      >
        {{yield}}
      </a>
    {{/if}}
  </template>
}

export { TabNavItem, type TabNavItemSignature, type TabNavItemArgs };
export default TabNavItem;
