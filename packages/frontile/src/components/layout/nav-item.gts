import Component from '@glimmer/component';
import { cached } from '@glimmer/tracking';
import { on } from '@ember/modifier';
import { registerDestructor } from '@ember/destroyable';
import { useStyles } from '@frontile/theme';
import Tooltip from '../overlays/tooltip';
import NavLink from './nav-link';
import type { ComponentLike } from '@glint/template';

/** How the item lays out its icon and label. */
type NavItemLayout = 'inline';

/** Class names `Sidebar` hands each item, one per theme slot. */
export interface NavItemClasses {
  navItem: string;
  navItemIcon: string;
  navItemLabel: string;
}

/** What a `NavFolder` reads from each of its items. */
interface NavItemHandle {
  readonly isActive: boolean;
  readonly isHidden: boolean;
}

/** The part of a `NavFolder` an item talks to. */
interface NavItemFolder {
  registerItem(item: NavItemHandle): () => void;
}

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

  /**
   * How the item lays out its icon and label.
   *
   * @defaultValue 'inline'
   */
  layout?: NavItemLayout;

  /** Class names appended to this item's theme classes. */
  class?: string;

  /**
   * Supplied by `Sidebar`. Not part of the public API. Without it (an item
   * rendered on its own) the theme's classes are used.
   *
   * @internal
   */
  classes?: NavItemClasses;

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

  /**
   * Supplied by `NavFolder`: the folder this item belongs to. The item
   * registers itself with it so the folder can follow its active and hidden
   * state. Not part of the public API.
   *
   * @internal
   */
  folder?: NavItemFolder;
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
  constructor(owner: unknown, args: NavItemSignature['Args']) {
    super(owner as never, args);

    const folder = this.args.folder;
    if (folder) {
      // The handle reads the args lazily, so the folder always sees the
      // item's current state.
      const unregister = folder.registerItem({
        get isActive() {
          return args.isActive ?? false;
        },
        get isHidden() {
          return args.isHidden ?? false;
        }
      });
      registerDestructor(this, unregister);
    }
  }

  @cached
  get classes(): NavItemClasses {
    return this.args.classes ?? themeClasses();
  }

  get className(): string {
    return this.args.class
      ? `${this.classes.navItem} ${this.args.class}`
      : this.classes.navItem;
  }

  get layout(): NavItemLayout {
    return this.args.layout ?? 'inline';
  }

  activate = (): void => {
    if (!this.args.isDisabled) {
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
            ><@icon /></span>
          {{/if}}
          <span
            data-part="nav-item-label"
            data-sidebar-label
            class={{this.classes.navItemLabel}}
          >{{yield}}</span>
        </NavLink>
        <t.Content>{{yield}}</t.Content>
      </Tooltip>
    {{/unless}}
  </template>
}

/** An item's classes outside a `Sidebar`: the theme's own. */
function themeClasses(): NavItemClasses {
  const styles = useStyles().navItem();
  return {
    navItem: styles.navItem(),
    navItemIcon: styles.navItemIcon(),
    navItemLabel: styles.navItemLabel()
  };
}

export { NavItem, type NavItemSignature, type NavItemArgs, type NavItemLayout };
export default NavItem;
