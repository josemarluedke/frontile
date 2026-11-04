import Component from '@glimmer/component';
import { cached } from '@glimmer/tracking';
import { hash } from '@ember/helper';
import { registerDestructor } from '@ember/destroyable';
import { guidFor } from '@ember/object/internals';
import { useStyles } from '@frontile/theme';
import Drawer from '../overlays/drawer';
import { AppLayoutState } from './app-layout-state';
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
     * Yields `Header`, `Body` and `Footer`. In the icon rail, wrap each
     * item's text in `<span data-sidebar-label>` so it is visually hidden
     * while collapsed but still read by screen readers.
     */
    default: [
      {
        Header: WithBoundArgs<typeof SidebarHeader, 'class'>;
        Body: WithBoundArgs<typeof SidebarBody, 'class'>;
        Footer: WithBoundArgs<typeof SidebarFooter, 'class'>;
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

  closeDrawer = (): void => {
    this.state.closeMobileSidebar();
  };

  /** Return focus to the layout's `MenuToggle` when it is on screen. */
  get focusTrapOptions() {
    const toggleId = this.args.layout?.menuToggleId;
    return {
      setReturnFocus: (previous: HTMLElement | SVGElement) => {
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

  get slotClasses() {
    const custom = this.args.layout?.classes;
    return {
      header: this.styles.sidebarHeader({ class: custom?.sidebarHeader }),
      body: this.styles.sidebarBody({ class: custom?.sidebarBody }),
      footer: this.styles.sidebarFooter({ class: custom?.sidebarFooter })
    };
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
