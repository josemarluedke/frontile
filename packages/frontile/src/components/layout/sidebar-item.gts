import Component from '@glimmer/component';
import { cached } from '@glimmer/tracking';
import { service } from '@ember/service';
import { on } from '@ember/modifier';
import { LinkTo } from '@ember/routing';
import { useStyles } from '@frontile/theme';
import Tooltip from '../overlays/tooltip';
import { isRouteActive, normalizeRouteArgs } from '../../utils/route-active';
import type RouterService from '@ember/routing/router-service';
import type { ComponentLike } from '@glint/template';

/** Class names `Sidebar` hands each item. */
export interface SidebarItemClasses {
  sidebarItem: string;
  sidebarItemIcon: string;
  sidebarLabel: string;
}

interface SidebarItemArgs {
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
   * cannot be followed.
   *
   * @defaultValue false
   */
  isDisabled?: boolean;

  /**
   * Renders nothing at all. For items the current user may not see.
   *
   * @defaultValue false
   */
  isHidden?: boolean;

  /**
   * An icon component, shown before the label. In the icon rail it is the
   * only visible part of the item. It is hidden from assistive technology.
   */
  icon?: ComponentLike;

  /** Class names appended to this item's theme classes. */
  class?: string;

  /**
   * Supplied by `Sidebar`. Not part of the public API. Without it (an item
   * rendered on its own) the standalone sidebar's classes are used.
   *
   * @internal
   */
  classes?: SidebarItemClasses;

  /**
   * Supplied by `Sidebar`: whether the sidebar is drawn as the icon rail.
   * Not part of the public API.
   *
   * @internal
   */
  rail?: boolean;

  /**
   * Supplied by `Sidebar`: the side of the item its rail tooltip opens on.
   * Not part of the public API.
   *
   * @internal
   */
  tooltipPlacement?: 'left' | 'right';

  /**
   * Supplied by `Sidebar` while it renders in the mobile drawer: called when
   * the item's link is clicked, so the drawer closes. Not called for a
   * disabled item. Not part of the public API.
   *
   * @internal
   */
  onActivate?: () => void;
}

interface SidebarItemSignature {
  Args: SidebarItemArgs;
  Blocks: {
    /** The item's label. */
    default: [];
  };
  Element: HTMLAnchorElement;
}

/**
 * A link in the sidebar. It takes the same routing arguments as
 * `TabNav.Item`: `@route` renders a `LinkTo` and the router decides whether it
 * is active; `@href` renders a plain anchor and needs no router. The active
 * item carries `aria-current="page"`. In the icon rail the label is visually
 * hidden but keeps naming the link, and shows as a tooltip on hover or focus.
 */
class SidebarItem extends Component<SidebarItemSignature> {
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
    // The early returns come first on purpose: `this.router` is read only
    // once `@route` is given and `@isActive` is not.
    if (this.args.isActive !== undefined) {
      return this.args.isActive;
    }
    if (!this.args.route) {
      return false;
    }

    return isRouteActive(this.router, this.args);
  }

  get isDisabled(): boolean {
    return this.args.isDisabled ?? false;
  }

  /**
   * `LinkTo` cannot be talked out of a real, navigable href, so a disabled
   * route item falls through to the plain anchor, where dropping the href is
   * what disables it. Same reasoning as `TabNav.Item`.
   */
  get rendersLink(): boolean {
    return Boolean(this.args.route) && !this.isDisabled;
  }

  @cached
  get classes(): SidebarItemClasses {
    return this.args.classes ?? standaloneItemClasses();
  }

  get className(): string {
    return this.args.class
      ? `${this.classes.sidebarItem} ${this.args.class}`
      : this.classes.sidebarItem;
  }

  activate = (): void => {
    if (!this.isDisabled) {
      this.args.onActivate?.();
    }
  };

  <template>
    {{#unless @isHidden}}
      <Tooltip
        @isDisabled={{if @rail false true}}
        @placement={{if @tooltipPlacement @tooltipPlacement "right"}}
        as |t|
      >
        {{#if this.rendersLink}}
          <LinkTo
            @route={{@route}}
            @models={{this.models}}
            @query={{this.query}}
            data-part="sidebar-item"
            class={{this.className}}
            aria-current={{if this.isActive "page"}}
            aria-disabled="false"
            data-active="{{this.isActive}}"
            data-disabled="false"
            {{t.trigger}}
            {{on "click" this.activate}}
            ...attributes
          >
            {{#if @icon}}
              <span
                data-part="sidebar-item-icon"
                class={{this.classes.sidebarItemIcon}}
                aria-hidden="true"
              ><@icon /></span>
            {{/if}}
            <span
              data-part="sidebar-label"
              data-sidebar-label
              class={{this.classes.sidebarLabel}}
            >{{yield}}</span>
          </LinkTo>
        {{else}}
          {{! An anchor with no href keeps aria-disabled; the rule cannot see
              that the href is conditional. }}
          {{! template-lint-disable no-unsupported-role-attributes }}
          <a
            data-part="sidebar-item"
            href={{unless this.isDisabled @href}}
            class={{this.className}}
            aria-current={{if this.isActive "page"}}
            aria-disabled="{{this.isDisabled}}"
            data-active="{{this.isActive}}"
            data-disabled="{{this.isDisabled}}"
            {{t.trigger}}
            {{on "click" this.activate}}
            ...attributes
          >
            {{#if @icon}}
              <span
                data-part="sidebar-item-icon"
                class={{this.classes.sidebarItemIcon}}
                aria-hidden="true"
              ><@icon /></span>
            {{/if}}
            <span
              data-part="sidebar-label"
              data-sidebar-label
              class={{this.classes.sidebarLabel}}
            >{{yield}}</span>
          </a>
        {{/if}}
        <t.Content>{{yield}}</t.Content>
      </Tooltip>
    {{/unless}}
  </template>
}

/** An item's classes outside a `Sidebar`: the standalone sidebar's. */
function standaloneItemClasses(): SidebarItemClasses {
  const styles = useStyles().appLayout({
    variant: 'attached',
    standalone: true
  });
  return {
    sidebarItem: styles.sidebarItem(),
    sidebarItemIcon: styles.sidebarItemIcon(),
    sidebarLabel: styles.sidebarLabel()
  };
}

export { SidebarItem, type SidebarItemSignature, type SidebarItemArgs };
export default SidebarItem;
