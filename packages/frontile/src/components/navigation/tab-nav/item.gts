import Component from '@glimmer/component';
import { cached } from '@glimmer/tracking';
import { service } from '@ember/service';
import { LinkTo } from '@ember/routing';
import type RouterService from '@ember/routing/router-service';
import type { ModifierLike } from '@glint/template';

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
    // `!= null` (not truthiness) so a legitimate falsy dynamic segment --
    // `@model={{0}}` or `@model=""` -- is not silently dropped.
    return (
      this.args.models ?? (this.args.model != null ? [this.args.model] : [])
    );
  }

  // `LinkTo`'s `@query` throws when given `undefined` rather than treating it
  // as "no query params" -- so this must default to an empty object, the same
  // way `models` defaults to an empty array.
  @cached
  get query(): Record<string, unknown> {
    return this.args.query ?? {};
  }

  get isActive(): boolean {
    if (this.args.isActive !== undefined) {
      return this.args.isActive;
    }
    if (!this.args.route) {
      return false;
    }

    // Redundant belt-and-braces: `RouterService#isActive` already entangles
    // itself with `currentURL`'s tag internally (see
    // `consumeTag(tagFor(this._router, 'currentURL'))` in ember-source's
    // `router-service.js`), so this getter recomputes on every transition even
    // without the read below. Kept anyway as a documented, version-independent
    // guarantee -- and covered by the transition test in
    // `tab-nav-routing-test.gts` -- in case that internal entanglement is ever
    // dropped.
    void this.router.currentURL;

    try {
      return this.router.isActive(this.args.route, ...this.models, {
        queryParams: this.query
      } as never);
    } catch {
      // `isActive` throws for a route that is not currently reachable -- an
      // unentered engine, or a dynamic segment whose model is not loaded. Not
      // being reachable is not being active.
      return false;
    }
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
