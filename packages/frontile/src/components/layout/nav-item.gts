import Component from '@glimmer/component';
import { cached } from '@glimmer/tracking';
import { service } from '@ember/service';
import { on } from '@ember/modifier';
import { registerDestructor } from '@ember/destroyable';
import { twMerge, useStyles } from '@frontile/theme';
import Tooltip from '../overlays/tooltip';
import NavLink from './nav-link';
import { isLinkActive } from '../../utils/route-active';
import type { NavFolderContext } from './nav-context';
import type RouterService from '@ember/routing/router-service';
import type { ComponentLike } from '@glint/template';

/** How the item lays out its icon and label. */
type NavItemLayout = 'inline' | 'stacked' | 'icon';

interface NavItemArgs {
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
   * cannot be followed; an item with neither `@href` nor `@route` is a
   * button, which gets the native `disabled` attribute.
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

  /**
   * How the item lays out its icon and label. `inline` puts the label beside
   * the icon and follows the sidebar's icon rail; `stacked` puts a small label
   * under the icon; `icon` shows the icon alone, with the label as a tooltip.
   * `stacked` and `icon` ignore the sidebar's collapsed state.
   *
   * @defaultValue 'inline'
   */
  layout?: NavItemLayout;

  /**
   * Shorter text shown in place of the label in the `stacked` layout. The
   * full label stays the link's accessible name.
   */
  shortLabel?: string;

  /**
   * A count or short status shown as a pill on the icon. Nothing is shown
   * for `undefined`, `null`, `0` or an empty string.
   */
  badge?: string | number;

  /**
   * Screen-reader text for the badge, read after the label. Defaults to the
   * badge value.
   */
  badgeLabel?: string;

  /**
   * Class names added to this item's theme classes. Merged with Tailwind
   * Merge, so a class that conflicts with a theme class wins.
   */
  class?: string;

  /**
   * Supplied by `Sidebar`: whether the sidebar is drawn as the icon rail.
   * Not part of the public API.
   *
   * @internal
   */
  rail?: boolean;

  /**
   * Supplied by `Sidebar` (or `BottomNav`): the side of the item its
   * tooltip opens on.
   * Not part of the public API.
   *
   * @internal
   */
  tooltipPlacement?: 'left' | 'right' | 'top';

  /**
   * Supplied by `Sidebar` while it renders in the mobile drawer: called when
   * the item's link is clicked, so the drawer closes. Not called for a
   * disabled item. Not part of the public API.
   *
   * @internal
   */
  onActivate?: () => void;

  /**
   * Supplied by `NavFolder`: the folder this item belongs to. The item
   * registers itself with it so the folder can follow its active and hidden
   * state. Not part of the public API.
   *
   * @internal
   */
  folder?: NavFolderContext;

  /**
   * Supplied by `BottomNav.More`: shows the badge as a small dot with no
   * text, whatever `@badge` is. `@badgeLabel` is its screen-reader text.
   * Not part of the public API.
   *
   * @internal
   */
  badgeDot?: boolean;
}

interface NavItemSignature {
  Args: NavItemArgs;
  Blocks: {
    /** The item's label. */
    default: [];
  };
  // Like `NavLink`: a button when neither `@route` nor `@href` is given. The
  // element type has to match it, or Glint rejects `...attributes` flowing
  // from here onto `NavLink`.
  Element: HTMLAnchorElement | HTMLButtonElement;
}

/**
 * A styled navigation link. It takes the same routing arguments as
 * `TabNav.Item`: `@route` renders a `LinkTo` and the router decides whether it
 * is active; `@href` renders a plain anchor and needs no router. The active
 * item carries `aria-current="page"`. In the icon rail the label is visually
 * hidden but keeps naming the link, and shows as a tooltip on hover or focus.
 */
class NavItem extends Component<NavItemSignature> {
  // Resolved only when the handle's `isActive` needs the router (`@route`
  // given, `@isActive` not), same as in `NavLink`.
  @service declare router: RouterService;

  constructor(owner: unknown, args: NavItemSignature['Args']) {
    super(owner as never, args);

    const getRouter = (): RouterService => this.router;
    const folder = this.args.folder;
    if (folder) {
      // The handle reads the args lazily, so the folder always sees the
      // item's current state.
      const unregister = folder.registerItem({
        // What the link renders as active, router included.
        get isActive() {
          return isLinkActive(args, getRouter);
        },
        get isHidden() {
          return args.isHidden ?? false;
        },
        get hasBadge() {
          return Boolean(args.badge) && args.badge !== 0 && !args.isHidden;
        }
      });
      registerDestructor(this, unregister);
    }
  }

  get layout(): NavItemLayout {
    return this.args.layout ?? 'inline';
  }

  /** The item's theme slots for its layout. */
  @cached
  get classes() {
    const styles = useStyles().navItem({
      layout: this.layout,
      shortLabel: this.hasShortLabel,
      badgePlacement: this.args.icon ? 'icon' : 'end',
      badgeDot: Boolean(this.args.badgeDot)
    });
    return {
      navItem: styles.navItem(),
      navItemIcon: styles.navItemIcon(),
      navItemLabel: styles.navItemLabel(),
      navItemShortLabel: styles.navItemShortLabel(),
      navItemBadge: styles.navItemBadge(),
      navItemBadgeLabel: styles.navItemBadgeLabel()
    };
  }

  /**
   * Only the inline layout follows the sidebar's collapsed state, which hides
   * `[data-sidebar-label]` elements.
   */
  get isInline(): true | undefined {
    return this.layout === 'inline' ? true : undefined;
  }

  get hasShortLabel(): boolean {
    return this.layout === 'stacked' && Boolean(this.args.shortLabel);
  }

  /**
   * Whether a badge is shown: not for `undefined`, `null`, `0` or `''`.
   * Always for `@badgeDot`.
   */
  get hasBadge(): boolean {
    if (this.args.badgeDot) {
      return true;
    }
    const badge = this.args.badge;
    return badge !== undefined && badge !== null && badge !== 0 && badge !== '';
  }

  /** The label is not otherwise visible, so a tooltip names the item. */
  get showTooltip(): boolean {
    return (
      (Boolean(this.args.rail) && this.layout === 'inline') ||
      this.layout === 'icon'
    );
  }

  get badgeText(): string | number | undefined {
    return this.args.badgeLabel ?? this.args.badge;
  }

  /** The pill's visible text: none for a dot. */
  get badgeValue(): string | number | undefined {
    return this.args.badgeDot ? undefined : this.args.badge;
  }

  /** Merged, so a consumer class wins over a conflicting theme class. */
  get className(): string {
    return twMerge(this.classes.navItem, this.args.class) ?? '';
  }

  activate = (): void => {
    if (!this.args.isDisabled) {
      this.args.onActivate?.();
    }
  };

  <template>
    {{#unless @isHidden}}
      <Tooltip
        @isDisabled={{if this.showTooltip false true}}
        @placement={{if @tooltipPlacement @tooltipPlacement "right"}}
        as |t|
      >
        <NavLink
          @route={{@route}}
          @model={{@model}}
          @models={{@models}}
          @query={{@query}}
          @href={{@href}}
          @isActive={{@isActive}}
          @isDisabled={{@isDisabled}}
          data-component="nav-item"
          data-part="nav-item"
          data-layout={{this.layout}}
          class={{this.className}}
          {{t.trigger}}
          {{on "click" this.activate}}
          ...attributes
        >
          {{#if @icon}}
            <span
              data-part="nav-item-icon"
              class={{this.classes.navItemIcon}}
              aria-hidden="true"
            ><@icon />{{#if this.hasBadge}}<span
                  data-part="nav-item-badge"
                  class={{this.classes.navItemBadge}}
                  aria-hidden="true"
                >{{this.badgeValue}}</span>{{/if}}</span>
          {{/if}}
          {{#if this.hasShortLabel}}
            <span
              data-part="nav-item-short-label"
              class={{this.classes.navItemShortLabel}}
              aria-hidden="true"
            >{{@shortLabel}}</span>
          {{/if}}
          <span
            data-part="nav-item-label"
            data-sidebar-label={{this.isInline}}
            class={{this.classes.navItemLabel}}
          >{{yield}}{{#if this.hasBadge}}<span
                data-part="nav-item-badge-label"
                class={{this.classes.navItemBadgeLabel}}
              >, {{this.badgeText}}</span>{{/if}}</span>
          {{#if this.hasBadge}}{{#unless @icon}}<span
                data-part="nav-item-badge"
                class={{this.classes.navItemBadge}}
                aria-hidden="true"
              >{{this.badgeValue}}</span>{{/unless}}{{/if}}
        </NavLink>
        <t.Content>{{yield}}</t.Content>
      </Tooltip>
    {{/unless}}
  </template>
}

export { NavItem, type NavItemSignature, type NavItemArgs, type NavItemLayout };
export default NavItem;
