import Component from '@glimmer/component';
import { cached } from '@glimmer/tracking';
import { service } from '@ember/service';
import { LinkTo } from '@ember/routing';
import { isLinkActive, normalizeRouteArgs } from '../../utils/route-active';
import type RouterService from '@ember/routing/router-service';

interface NavLinkArgs {
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
   * Marks the link as disabled. The href is dropped as well, so the link
   * cannot be followed; a button also gets the native `disabled` attribute.
   *
   * @defaultValue false
   */
  isDisabled?: boolean;

  /**
   * Renders nothing at all. For links the current user may not see.
   *
   * @defaultValue false
   */
  isHidden?: boolean;
}

interface NavLinkSignature {
  Args: NavLinkArgs;
  Blocks: {
    /** The link's content. */
    default: [];
  };
  Element: HTMLAnchorElement | HTMLButtonElement;
}

/**
 * The headless element behind a navigation item: it handles routing, active
 * state, ARIA, disabled and hidden, and renders no styling of its own.
 * `@route` renders a `LinkTo`, `@href` a plain anchor, and neither a
 * `<button type="button">`. Attributes, classes and modifiers are spread onto
 * the rendered element.
 */
class NavLink extends Component<NavLinkSignature> {
  // Resolved only when `isActive` below reads it, i.e. when `@route` is given
  // and `@isActive` is not. An application that does not route never touches
  // the router.
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
    return isLinkActive(this.args, () => this.router);
  }

  get isDisabled(): boolean {
    return this.args.isDisabled ?? false;
  }

  /**
   * `LinkTo` cannot be talked out of a real, navigable href, so a disabled
   * route link falls through to the plain anchor, where dropping the href is
   * what disables it.
   */
  get rendersLink(): boolean {
    return Boolean(this.args.route) && !this.isDisabled;
  }

  get rendersAnchor(): boolean {
    return Boolean(this.args.route || this.args.href);
  }

  <template>
    {{#unless @isHidden}}
      {{#if this.rendersLink}}
        <LinkTo
          @route={{@route}}
          @models={{this.models}}
          @query={{this.query}}
          aria-current={{if this.isActive "page"}}
          aria-disabled="false"
          data-active="{{this.isActive}}"
          data-disabled="false"
          ...attributes
        >{{yield}}</LinkTo>
      {{else if this.rendersAnchor}}
        {{! An anchor with no href keeps aria-disabled; the rule cannot see
            that the href is conditional. }}
        {{! template-lint-disable no-unsupported-role-attributes }}
        <a
          href={{unless this.isDisabled @href}}
          aria-current={{if this.isActive "page"}}
          aria-disabled="{{this.isDisabled}}"
          data-active="{{this.isActive}}"
          data-disabled="{{this.isDisabled}}"
          ...attributes
        >{{yield}}</a>
      {{else}}
        <button
          type="button"
          disabled={{this.isDisabled}}
          aria-current={{if this.isActive "page"}}
          aria-disabled="{{this.isDisabled}}"
          data-active="{{this.isActive}}"
          data-disabled="{{this.isDisabled}}"
          ...attributes
        >{{yield}}</button>
      {{/if}}
    {{/unless}}
  </template>
}

export { NavLink, type NavLinkSignature, type NavLinkArgs };
export default NavLink;
