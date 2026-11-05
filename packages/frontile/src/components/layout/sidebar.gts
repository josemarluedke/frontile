import Component from '@glimmer/component';
import { cached } from '@glimmer/tracking';
import { hash } from '@ember/helper';
import { registerDestructor } from '@ember/destroyable';
import { guidFor } from '@ember/object/internals';
import { useStyles } from '@frontile/theme';
import Drawer from '../overlays/drawer';
import NavItem from './nav-item';
import NavFolder from './nav-folder';
import SidebarGroup from './sidebar-group';
import SidebarBrand from './sidebar-brand';
import { AppLayoutState } from './app-layout-state';
import type { AppLayoutContext } from './context';
import type { NavItemClasses } from './nav-item';
import type { NavFolderClasses } from './nav-folder';
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
   * The accessible name of the sidebar's `nav` landmark. Give each navigation
   * on the page a distinct name.
   *
   * @defaultValue 'Main'
   */
  label?: string;

  /**
   * The layout variant, `inset` or `attached`. Only used when the sidebar is
   * rendered outside an `AppLayout`; inside one it follows the layout.
   *
   * @defaultValue 'attached'
   */
  variant?: AppLayoutVariants['variant'];

  /**
   * The state that drives collapse. Only used when the sidebar is rendered
   * outside an `AppLayout`; inside one it follows the layout's state.
   */
  state?: AppLayoutState;

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
     * for a collapsible set of items, `Group`
     * to label a set of items, and `Brand` for a logo and name in the header. In the icon rail, `Item` labels are visually
     * hidden but still read by screen readers; for your own markup, wrap the
     * text in `<span data-sidebar-label>` to get the same behavior.
     */
    default: [
      {
        Header: WithBoundArgs<typeof SidebarHeader, 'class'>;
        Body: WithBoundArgs<typeof SidebarBody, 'class'>;
        Footer: WithBoundArgs<typeof SidebarFooter, 'class'>;
        Item: WithBoundArgs<
          typeof NavItem,
          'classes' | 'rail' | 'tooltipPlacement'
        >;
        Folder: WithBoundArgs<
          typeof NavFolder,
          | 'classes'
          | 'itemClasses'
          | 'rail'
          | 'tooltipPlacement'
          | 'inDrawer'
          | 'onActivate'
        >;
        Group: WithBoundArgs<typeof SidebarGroup, 'classes'>;
        Brand: WithBoundArgs<typeof SidebarBrand, 'classes'>;
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
 * so the sidebar is written once. It also works on its own when given
 * `@state` (always inline; no drawer).
 */
class Sidebar extends Component<SidebarSignature> {
  fallbackState = new AppLayoutState();

  constructor(owner: Owner, args: SidebarArgs) {
    super(owner, args);
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
   * `Drawer` placements are physical, so `start` is resolved against the
   * layout's direction: left in a left-to-right document, right in RTL.
   */
  get placement(): 'left' | 'right' {
    const layout = this.args.layout;
    const atEnd = layout?.config.sidebarSide === 'end';
    const rtl = layout?.isRtl() ?? false;
    return atEnd !== rtl ? 'right' : 'left';
  }

  /**
   * Closes the drawer. Also handed to each `Item` while the sidebar is in the
   * drawer, so picking a destination closes it.
   */
  closeDrawer = (): void => {
    this.state.closeMobileSidebar();
  };

  /**
   * Return focus to whatever opened the drawer: `MenuToggle`, or the element
   * focused when the shortcut was pressed. With nothing focused (the body),
   * fall back to the layout's `MenuToggle` when it is on screen.
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

  get state(): AppLayoutState {
    return this.args.layout?.state ?? this.args.state ?? this.fallbackState;
  }

  get collapsible(): 'icon' | 'offcanvas' | 'none' {
    return this.args.collapsible ?? 'icon';
  }

  /** Collapse applies unless the sidebar opted out of it. */
  get collapsed(): boolean {
    return this.collapsible !== 'none' && this.state.sidebarCollapsed;
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
      collapsed: this.collapsed
    });
  }

  @cached
  get classNames(): string {
    return this.styles.sidebar({ class: this.args.layout?.classes?.sidebar });
  }

  @cached
  get mobileClassNames(): string {
    return this.styles.mobileSidebar({
      class: this.args.layout?.classes?.mobileSidebar
    });
  }

  /**
   * Item styling comes from the `navItem` theme, not from `AppLayout`'s
   * `@classes`: consumers style an item with `@class` / `@classes` on it.
   */
  @cached
  get itemClasses(): NavItemClasses {
    const styles = useStyles().navItem();
    return {
      navItem: styles.navItem(),
      navItemIcon: styles.navItemIcon(),
      navItemLabel: styles.navItemLabel()
    };
  }

  @cached
  get folderClasses(): NavFolderClasses {
    const styles = useStyles().navItem();
    return {
      navFolder: styles.navFolder(),
      navFolderTrigger: styles.navFolderTrigger(),
      navFolderChevron: styles.navFolderChevron(),
      navFolderPanel: styles.navFolderPanel(),
      navFolderFlyout: styles.navFolderFlyout()
    };
  }

  @cached
  get slotClasses() {
    const custom = this.args.layout?.classes;
    return {
      header: this.styles.sidebarHeader({ class: custom?.sidebarHeader }),
      body: this.styles.sidebarBody({ class: custom?.sidebarBody }),
      footer: this.styles.sidebarFooter({ class: custom?.sidebarFooter }),
      item: this.itemClasses,
      folder: this.folderClasses,
      group: {
        sidebarGroup: this.styles.sidebarGroup({ class: custom?.sidebarGroup }),
        sidebarGroupLabel: this.styles.sidebarGroupLabel({
          class: custom?.sidebarGroupLabel
        })
      },
      brand: {
        sidebarBrand: this.styles.sidebarBrand({ class: custom?.sidebarBrand }),
        sidebarBrandLogo: this.styles.sidebarBrandLogo({
          class: custom?.sidebarBrandLogo
        }),
        sidebarBrandText: this.styles.sidebarBrandText({
          class: custom?.sidebarBrandText
        }),
        sidebarBrandTitle: this.styles.sidebarBrandTitle({
          class: custom?.sidebarBrandTitle
        }),
        sidebarBrandSubtitle: this.styles.sidebarBrandSubtitle({
          class: custom?.sidebarBrandSubtitle
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
    {{#if this.inDrawer}}
      <Drawer
        @isOpen={{this.state.mobileSidebarOpen}}
        @onClose={{this.closeDrawer}}
        @placement={{this.placement}}
        @size="xs"
        @variant="flat"
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
                classes=this.slotClasses.item
                rail=this.rail
                tooltipPlacement=this.tooltipPlacement
                onActivate=this.closeDrawer
              )
              Folder=(component
                NavFolder
                classes=this.slotClasses.folder
                itemClasses=this.slotClasses.item
                rail=this.rail
                tooltipPlacement=this.tooltipPlacement
                inDrawer=true
                onActivate=this.closeDrawer
              )
              Group=(component SidebarGroup classes=this.slotClasses.group)
              Brand=(component SidebarBrand classes=this.slotClasses.brand)
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
              NavItem
              classes=this.slotClasses.item
              rail=this.rail
              tooltipPlacement=this.tooltipPlacement
            )
            Folder=(component
              NavFolder
              classes=this.slotClasses.folder
              itemClasses=this.slotClasses.item
              rail=this.rail
              tooltipPlacement=this.tooltipPlacement
              inDrawer=false
            )
            Group=(component SidebarGroup classes=this.slotClasses.group)
            Brand=(component SidebarBrand classes=this.slotClasses.brand)
          )
        }}
      </nav>
    {{/if}}
  </template>
}

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
