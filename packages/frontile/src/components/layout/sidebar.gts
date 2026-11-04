import Component from '@glimmer/component';
import { cached } from '@glimmer/tracking';
import { hash } from '@ember/helper';
import { guidFor } from '@ember/object/internals';
import { useStyles } from '@frontile/theme';
import { AppLayoutState } from './app-layout-state';
import type { AppLayoutContext } from './context';
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
 * `@sidebarSide="end"`, the last) column. It also works on its own when given
 * `@state`.
 */
class Sidebar extends Component<SidebarSignature> {
  fallbackState = new AppLayoutState();

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

  get slotClasses() {
    const custom = this.args.layout?.classes;
    return {
      header: this.styles.sidebarHeader({ class: custom?.sidebarHeader }),
      body: this.styles.sidebarBody({ class: custom?.sidebarBody }),
      footer: this.styles.sidebarFooter({ class: custom?.sidebarFooter })
    };
  }

  <template>
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
