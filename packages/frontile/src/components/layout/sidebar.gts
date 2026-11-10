import Component from '@glimmer/component';
import { cached, tracked } from '@glimmer/tracking';
import { hash } from '@ember/helper';
import { registerDestructor } from '@ember/destroyable';
import { guidFor } from '@ember/object/internals';
import { useStyles } from '@frontile/theme';
import Drawer from '../overlays/drawer';
import NavItem from './nav-item';
import NavFolder from './nav-folder';
import SidebarGroup from './sidebar-group';
import SidebarToggle, { type SidebarToggleSignature } from './sidebar-toggle';
import type { AppLayoutContext } from './context';
import type Owner from '@ember/owner';
import type { AppLayoutVariants } from '@frontile/theme';
import type { WithBoundArgs } from '@glint/template';
import type { TOC } from '@ember/component/template-only';

interface SidebarSectionSignature {
  Args: { class?: string };
  Blocks: { default: [] };
  Element: HTMLElement;
}

interface SidebarArgs {
  /**
   * How the sidebar collapses. `icon` shrinks it to a rail where item labels
   * are visually hidden but stay available to assistive technology;
   * `offcanvas` hides it entirely while collapsed; `none` ignores collapse.
   *
   * @defaultValue 'icon'
   */
  collapsible?: 'icon' | 'offcanvas' | 'none';

  /**
   * The sidebar's width preset. `default` is the standard sidebar; `rail` is
   * a narrow column (80px) for a stack of icon-over-label items, usually with
   * `@collapsible="none"`. It is a named preset, not a length: for any other
   * width, pass a width utility as `@class` (and set `--app-sidebar-width`
   * yourself if you read the token).
   *
   * @defaultValue 'default'
   */
  size?: 'default' | 'rail';

  /**
   * Classes for the sidebar, merged with the theme's so a conflicting class
   * wins: `@class="w-72"` replaces the width. A width given this way applies
   * whether or not the sidebar is collapsed, so pair it with
   * `@collapsible="none"`. Applies to the inline sidebar, not the drawer.
   */
  class?: string;

  /**
   * The accessible name of the sidebar's `nav` landmark. Give each navigation
   * on the page a distinct name.
   *
   * @defaultValue 'Main'
   */
  label?: string;

  /**
   * The layout variant, `inset` or `attached`, which sets the sidebar's
   * widths and the gutter around its rows. Only used when the sidebar is
   * rendered outside an `AppLayout`; inside one it follows the layout.
   *
   * @defaultValue 'attached'
   */
  variant?: AppLayoutVariants['variant'];

  /**
   * Whether the sidebar is collapsed, for a sidebar you control. `Toggle`
   * and the yielded actions then call `@onCollapsedChange` and leave the
   * change to you. Without it the sidebar keeps its own state, starting from
   * `@defaultCollapsed`. Only used outside an `AppLayout`; inside one, use the
   * layout's `@sidebarCollapsed`.
   */
  collapsed?: boolean;

  /**
   * Whether the sidebar starts collapsed when it keeps its own state (no
   * `@collapsed`). Only used outside an `AppLayout`.
   *
   * @defaultValue false
   */
  defaultCollapsed?: boolean;

  /**
   * Called with the requested collapsed state when `Toggle` or a yielded
   * action changes it. Only used outside an `AppLayout`.
   */
  onCollapsedChange?: (collapsed: boolean) => void;

  /**
   * Supplied by `AppLayout`. Not part of the public API.
   *
   * @internal
   */
  layout?: AppLayoutContext;
}

interface SidebarSignature {
  Args: SidebarArgs;
  Blocks: {
    /**
     * Yields `Header`, `Body` and `Footer` sections, `Item` links, `Folder`
     * for a collapsible set of items, `Group` to label a set of items, and
     * `Toggle`, the button that collapses and expands the sidebar. It also
     * yields the sidebar's state, `isCollapsed` and `isInDrawer`, and the
     * actions `toggle`, `collapse` and `expand`. Place
     * `Toggle` yourself, usually in `Header` or `Footer`; there is no default
     * toggle. In the phone drawer `Toggle` renders nothing (the drawer is
     * always expanded and has its own close button), so the same markup works
     * at every width. In the icon rail, `Item` labels are visually
     * hidden but still read by screen readers; for your own markup, wrap the
     * text in `<span data-sidebar-label>` to get the same behavior.
     */
    default: [
      {
        Header: WithBoundArgs<typeof SidebarHeader, 'class'>;
        Body: WithBoundArgs<typeof SidebarBody, 'class'>;
        Footer: WithBoundArgs<typeof SidebarFooter, 'class'>;
        Item: WithBoundArgs<typeof NavItem, 'rail' | 'tooltipPlacement'>;
        Folder: WithBoundArgs<
          typeof NavFolder,
          'rail' | 'tooltipPlacement' | 'onActivate'
        >;
        Group: WithBoundArgs<typeof SidebarGroup, 'classes'>;
        Toggle: WithBoundArgs<
          typeof SidebarToggle,
          'layout' | 'collapsed' | 'onToggle'
        >;
        /**
         * Whether the sidebar is drawn collapsed: the icon rail, or hidden
         * with `@collapsible="offcanvas"`. Never in the drawer, which is
         * always expanded.
         */
        isCollapsed: boolean;
        /** Whether the sidebar is rendered in the phone drawer. */
        isInDrawer: boolean;
        /** Collapses an expanded sidebar and expands a collapsed one. */
        toggle: () => void;
        collapse: () => void;
        expand: () => void;
      }
    ];
  };
  Element: HTMLElement;
}

/**
 * The sidebar navigation: a full-height `nav` landmark that can collapse to
 * an icon rail. Inside `AppLayout` it takes the first (or, with
 * `@sidebarSide="end"`, the last) column. Below the layout's `@breakpoint`
 * the same block renders inside a `Drawer` instead, opened by `MenuToggle`,
 * so the sidebar is written once. It also works on its own, always inline,
 * with `@collapsed` or its own state.
 */
class Sidebar extends Component<SidebarSignature> {
  @tracked localCollapsed: boolean;

  constructor(owner: Owner, args: SidebarArgs) {
    super(owner, args);
    this.localCollapsed = args.defaultCollapsed ?? false;
    const unregister = args.layout?.registerSidebar(this);
    if (unregister) {
      registerDestructor(this, unregister);
    }
  }

  /**
   * Below the breakpoint the content moves into the drawer. Only one of the
   * two is rendered, so the block (and any ids in it) exists once.
   */
  get inDrawer(): boolean {
    return this.args.layout?.belowBreakpoint ?? false;
  }

  /**
   * `@mobileNav="bottom"` below the breakpoint: the layout's `BottomNav`
   * replaces the sidebar, so nothing renders (no drawer, no block). The
   * sidebar stays registered, so the layout still knows about it.
   */
  get hiddenForBottomNav(): boolean {
    return this.args.layout?.bottomNavMode ?? false;
  }

  /**
   * `Drawer` placements are physical, so `start` is resolved against the
   * layout's direction: left in a left-to-right document, right in RTL.
   */
  get placement(): 'left' | 'right' {
    const layout = this.args.layout;
    const atEnd = layout?.config.sidebarSide === 'end';
    const rtl = layout?.isRtl() ?? false;
    return atEnd !== rtl ? 'right' : 'left';
  }

  /** Whether the phone drawer is open. */
  get drawerOpen(): boolean {
    return this.args.layout?.state.mobileSidebarOpen ?? false;
  }

  /**
   * Closes the drawer. Also handed to each `Item` while the sidebar is in the
   * drawer, so picking a destination closes it.
   */
  closeDrawer = (): void => {
    this.args.layout?.state.closeMobileSidebar();
  };

  /**
   * Return focus to the element that opened the drawer, `MenuToggle` or
   * otherwise. With nothing focused (the body), fall back to the layout's
   * `MenuToggle` when it is on screen.
   */
  get focusTrapOptions() {
    const toggleId = this.args.layout?.menuToggleId;
    return {
      setReturnFocus: (previous: HTMLElement | SVGElement) => {
        if (previous && previous !== document.body && previous.isConnected) {
          return previous;
        }
        const toggle = toggleId ? document.getElementById(toggleId) : null;
        return toggle && toggle.getClientRects().length > 0 ? toggle : previous;
      }
    };
  }

  /**
   * The collapse asked for, before `@collapsible="none"` overrides it: the
   * layout's state, `@collapsed`, or the sidebar's own.
   */
  get collapseRequested(): boolean {
    const layout = this.args.layout;
    if (layout) return layout.state.sidebarCollapsed;
    return this.args.collapsed ?? this.localCollapsed;
  }

  setCollapsed(collapsed: boolean): void {
    const layout = this.args.layout;
    if (layout) {
      if (collapsed) layout.state.collapseSidebar();
      else layout.state.expandSidebar();
      return;
    }
    if (this.args.collapsed === undefined) this.localCollapsed = collapsed;
    this.args.onCollapsedChange?.(collapsed);
  }

  toggle = (): void => {
    this.setCollapsed(!this.collapseRequested);
  };

  collapse = (): void => {
    this.setCollapsed(true);
  };

  expand = (): void => {
    this.setCollapsed(false);
  };

  get collapsible(): 'icon' | 'offcanvas' | 'none' {
    return this.args.collapsible ?? 'icon';
  }

  /** Collapse applies unless the sidebar opted out of it. */
  get collapsed(): boolean {
    return this.collapsible !== 'none' && this.collapseRequested;
  }

  /** As drawn: the drawer is always expanded. */
  get isCollapsed(): boolean {
    return !this.inDrawer && this.collapsed;
  }

  get size(): 'default' | 'rail' {
    return this.args.size ?? 'default';
  }

  get id(): string {
    return this.args.layout?.sidebarId ?? `${guidFor(this)}-sidebar`;
  }

  get label(): string {
    return this.args.label ?? 'Main';
  }

  @cached
  get styles() {
    const layout = this.args.layout;
    return useStyles().appLayout({
      variant: layout?.config.variant ?? this.args.variant ?? 'attached',
      navbarPlacement: layout?.config.navbarPlacement,
      breakpoint: layout?.config.breakpoint,
      scrollMode: layout?.config.scrollMode,
      sidebarSide: layout?.config.sidebarSide,
      standalone: !layout,
      inDrawer: this.inDrawer,
      collapsible: this.collapsible,
      collapsed: this.collapsed,
      sidebarSize: this.size
    });
  }

  @cached
  get classNames(): string {
    const custom = [this.args.layout?.classes?.sidebar, this.args.class]
      .filter(Boolean)
      .join(' ');
    return this.styles.sidebar({ class: custom || undefined });
  }

  @cached
  get drawerCloseButtonClass(): string {
    return this.styles.drawerCloseButton({
      class: this.args.layout?.classes?.drawerCloseButton
    });
  }

  get mobileClassNames(): string {
    return this.styles.mobileSidebar({
      class: this.args.layout?.classes?.mobileSidebar
    });
  }

  @cached
  get slotClasses() {
    const custom = this.args.layout?.classes;
    return {
      header: this.styles.sidebarHeader({ class: custom?.sidebarHeader }),
      body: this.styles.sidebarBody({ class: custom?.sidebarBody }),
      footer: this.styles.sidebarFooter({ class: custom?.sidebarFooter }),
      group: {
        sidebarGroup: this.styles.sidebarGroup({ class: custom?.sidebarGroup }),
        sidebarGroupLabel: this.styles.sidebarGroupLabel({
          class: custom?.sidebarGroupLabel
        })
      }
    };
  }

  /**
   * Whether the block is drawn as the icon rail, where item labels become
   * tooltips. Never in the drawer, which is always expanded.
   */
  get rail(): boolean {
    return !this.inDrawer && this.collapsible === 'icon' && this.collapsed;
  }

  /** Rail tooltips open toward the content, away from the sidebar's edge. */
  get tooltipPlacement(): 'left' | 'right' {
    return this.placement === 'left' ? 'right' : 'left';
  }

  <template>
    {{#if this.hiddenForBottomNav}}
      {{! Nothing: the BottomNav is the navigation here. }}
    {{else if this.inDrawer}}
      <Drawer
        @isOpen={{this.drawerOpen}}
        @onClose={{this.closeDrawer}}
        @placement={{this.placement}}
        @size="xs"
        @variant="flat"
        @closeButtonSize="md"
        @classes={{hash closeButton=this.drawerCloseButtonClass}}
        @focusTrapOptions={{this.focusTrapOptions}}
        id={{@layout.drawerId}}
        aria-label={{this.label}}
      >
        <nav
          id={{this.id}}
          aria-label={{this.label}}
          data-part="mobile-sidebar"
          data-collapsible={{this.collapsible}}
          data-collapsed="false"
          class={{this.mobileClassNames}}
          ...attributes
        >
          {{yield
            (hash
              Header=(component SidebarHeader class=this.slotClasses.header)
              Body=(component SidebarBody class=this.slotClasses.body)
              Footer=(component SidebarFooter class=this.slotClasses.footer)
              Item=(component
                NavItem
                rail=this.rail
                tooltipPlacement=this.tooltipPlacement
                onActivate=this.closeDrawer
              )
              Folder=(component
                NavFolder
                rail=this.rail
                tooltipPlacement=this.tooltipPlacement
                onActivate=this.closeDrawer
              )
              Group=(component SidebarGroup classes=this.slotClasses.group)
              Toggle=(component DrawerToggle)
              isCollapsed=false
              isInDrawer=true
              toggle=this.toggle
              collapse=this.collapse
              expand=this.expand
            )
          }}
        </nav>
      </Drawer>
    {{else}}
      <nav
        id={{this.id}}
        aria-label={{this.label}}
        data-part="sidebar"
        data-collapsible={{this.collapsible}}
        data-collapsed={{if this.collapsed "true" "false"}}
        class={{this.classNames}}
        ...attributes
      >
        {{yield
          (hash
            Header=(component SidebarHeader class=this.slotClasses.header)
            Body=(component SidebarBody class=this.slotClasses.body)
            Footer=(component SidebarFooter class=this.slotClasses.footer)
            Item=(component
              NavItem rail=this.rail tooltipPlacement=this.tooltipPlacement
            )
            Folder=(component
              NavFolder rail=this.rail tooltipPlacement=this.tooltipPlacement
            )
            Group=(component SidebarGroup classes=this.slotClasses.group)
            Toggle=(component
              SidebarToggle
              layout=@layout
              collapsed=this.collapsed
              onToggle=this.toggle
            )
            isCollapsed=this.isCollapsed
            isInDrawer=false
            toggle=this.toggle
            collapse=this.collapse
            expand=this.expand
          )
        }}
      </nav>
    {{/if}}
  </template>
}

// In the drawer there is nothing to collapse, so `Toggle` renders nothing.
// It takes `SidebarToggle`'s signature so the same invocation, arguments and
// attributes included, compiles in both places; they are dropped.
const DrawerToggle: TOC<SidebarToggleSignature> = <template>
  {{! No toggle in the drawer. }}
</template>;

const SidebarHeader: TOC<SidebarSectionSignature> = <template>
  <div data-part="sidebar-header" class={{@class}} ...attributes>{{yield}}</div>
</template>;

const SidebarBody: TOC<SidebarSectionSignature> = <template>
  <div data-part="sidebar-body" class={{@class}} ...attributes>{{yield}}</div>
</template>;

const SidebarFooter: TOC<SidebarSectionSignature> = <template>
  <div data-part="sidebar-footer" class={{@class}} ...attributes>{{yield}}</div>
</template>;

export { Sidebar, type SidebarSignature, type SidebarArgs };
export default Sidebar;
