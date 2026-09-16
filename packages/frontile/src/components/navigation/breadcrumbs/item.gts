import Component from '@glimmer/component';
import { cached } from '@glimmer/tracking';
import { service } from '@ember/service';
import { LinkTo } from '@ember/routing';
import { ChevronRightIcon } from '../../../-private/icons';
import type RouterService from '@ember/routing/router-service';
import type { ComponentLike, ModifierLike } from '@glint/template';

interface BreadcrumbsItemArgs {
  /**
   * Renders a `LinkTo` for this route and derives the current state from the
   * router. Omit it (and pass `@href`) to stay entirely router-free.
   */
  route?: string;

  /** Dynamic segments for `@route`. */
  models?: unknown[];

  /** A single dynamic segment for `@route`. */
  model?: unknown;

  /** Query params for `@route`. */
  query?: Record<string, unknown>;

  /** Renders a plain anchor. */
  href?: string;

  /**
   * Overrides the current-page state. Wins over every other rule.
   */
  isCurrent?: boolean;

  /**
   * Marks the crumb as disabled. An anchor cannot be natively disabled, so the
   * href is dropped as well -- `aria-disabled` alone still leaves it
   * clickable. Only affects a linked crumb: an unlinked crumb (no `@route` or
   * `@href`) renders as a `<span>` and never receives `aria-disabled` or
   * `data-disabled` regardless of this arg.
   *
   * @defaultValue false
   */
  isDisabled?: boolean;

  /** Class names appended to this crumb's theme classes. */
  class?: string;

  /**
   * Supplied by Breadcrumbs. Not part of the public API.
   *
   * @internal
   */
  itemClass: string;

  /** @internal */
  linkClass: string;

  /** @internal */
  separatorClass: string;

  /** @internal */
  separator?: ComponentLike<{ Element: SVGElement }>;

  /** @internal */
  setupItem: ModifierLike<{
    Element: HTMLElement;
    Args: { Positional: [boolean] };
  }>;
}

interface BreadcrumbsItemSignature {
  Args: BreadcrumbsItemArgs;
  Blocks: { default: [] };
  /**
   * Not `HTMLAnchorElement`: this component's crumb element varies -- an `<a>`
   * or a `<span>` for an unlinked current crumb -- so the signature has to name
   * the common supertype or `...attributes` is mistyped for the span case.
   */
  Element: HTMLElement;
}

/**
 * One crumb: its `<li>`, the crumb itself, and the separator that follows it.
 *
 * The separator is rendered here rather than by the root, and hidden on the
 * last crumb by CSS. That is what lets both authoring forms work without
 * either one knowing an item's position.
 */
class BreadcrumbsItem extends Component<BreadcrumbsItemSignature> {
  // Ember's service injection is getter-based, so this resolves only when
  // `isCurrent` below actually reads it -- which happens only when `@route` was
  // passed and `@isCurrent` was not. An application that does not route never
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

  get isDisabled(): boolean {
    return this.args.isDisabled ?? false;
  }

  /** Whether this crumb points anywhere at all. */
  get hasTarget(): boolean {
    return Boolean(this.args.route || this.args.href);
  }

  /**
   * A `LinkTo` is only rendered for a route the crumb can actually navigate
   * to. `LinkTo` cannot be talked out of a real, navigable href -- its
   * `@disabled` only short-circuits the click handler and tags on an un-themed
   * `disabled` class -- so a disabled route crumb falls through to the plain
   * anchor instead, where dropping the href is what actually disables it.
   */
  get rendersLink(): boolean {
    return Boolean(this.args.route) && !this.isDisabled;
  }

  /**
   * Precedence, highest first: an explicit `@isCurrent`; the router, for a
   * `@route` crumb; then the rule that a crumb with no link target is the page
   * you are on -- which is what lets `<b.Item>Title</b.Item>` be correct with
   * no arguments.
   */
  get isCurrent(): boolean {
    if (this.args.isCurrent !== undefined) {
      return this.args.isCurrent;
    }

    if (this.args.route) {
      // Redundant belt-and-braces: `RouterService#isActive` already entangles
      // itself with `currentURL`'s tag internally, so this getter recomputes on
      // every transition even without the read below. Kept anyway as a
      // documented, version-independent guarantee -- and covered by the
      // transition test in `breadcrumbs-routing-test.gts` -- in case that
      // internal entanglement is ever dropped.
      void this.router.currentURL;

      try {
        return this.router.isActive(this.args.route, ...this.models, {
          queryParams: this.query
        } as never);
      } catch {
        // `isActive` throws for a route that is not currently reachable -- an
        // unentered engine, or a dynamic segment whose model is not loaded.
        // Not being reachable is not being current.
        return false;
      }
    }

    return !this.hasTarget;
  }

  <template>
    <li data-part="item" class={{@itemClass}}>
      {{#if this.rendersLink}}
        <LinkTo
          @route={{@route}}
          @models={{this.models}}
          @query={{this.query}}
          data-part="link"
          class="{{@linkClass}} {{@class}}"
          aria-disabled="false"
          data-disabled="false"
          {{@setupItem this.isCurrent}}
          ...attributes
        >
          {{yield}}
        </LinkTo>
      {{else if this.hasTarget}}
        {{! template-lint-disable no-unsupported-role-attributes }}
        <a
          data-part="link"
          href={{unless this.isDisabled @href}}
          class="{{@linkClass}} {{@class}}"
          aria-disabled="{{this.isDisabled}}"
          data-disabled="{{this.isDisabled}}"
          {{@setupItem this.isCurrent}}
          ...attributes
        >
          {{yield}}
        </a>
      {{else}}
        <span
          data-part="link"
          class="{{@linkClass}} {{@class}}"
          {{@setupItem this.isCurrent}}
          ...attributes
        >
          {{yield}}
        </span>
      {{/if}}

      <span data-part="separator" aria-hidden="true" class={{@separatorClass}}>
        {{#if @separator}}<@separator />{{else}}<ChevronRightIcon />{{/if}}
      </span>
    </li>
  </template>
}

export {
  BreadcrumbsItem,
  type BreadcrumbsItemSignature,
  type BreadcrumbsItemArgs
};
export default BreadcrumbsItem;
