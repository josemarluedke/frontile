import Component from '@glimmer/component';
import { on } from '@ember/modifier';
import { SidebarLeftIcon } from '../../-private/icons';
import { standaloneStyles, type AppLayoutContext } from './context';

interface SidebarToggleArgs {
  /**
   * The accessible name of the button.
   *
   * @defaultValue 'Toggle sidebar'
   */
  label?: string;

  /**
   * The id of the sidebar this button controls, for `aria-controls`. Inside
   * an `AppLayout` it defaults to the layout's sidebar, which below the
   * breakpoint is the `nav` inside the drawer.
   */
  controls?: string;

  /**
   * Whether the sidebar it controls is collapsed, for `aria-expanded`. Only
   * used outside an `AppLayout`; inside one the button follows the layout.
   */
  collapsed?: boolean;

  /**
   * Called when the button is pressed. Only used outside an `AppLayout`,
   * where you flip the value you pass to the `Sidebar`'s `@collapsed`;
   * inside one the button changes the layout's state itself.
   */
  onToggle?: () => void;

  /**
   * Supplied by `AppLayout`. Not part of the public API.
   *
   * @internal
   */
  layout?: AppLayoutContext;
}

interface SidebarToggleSignature {
  Args: SidebarToggleArgs;
  Blocks: {
    /** Replaces the default icon with your own content. */
    default: [];
  };
  Element: HTMLButtonElement;
}

/**
 * A button that collapses and expands the sidebar. `aria-expanded` is true
 * while the sidebar is expanded. Inside an `AppLayout`, below its
 * `@breakpoint` (where the sidebar is a drawer) it opens the drawer instead,
 * like `MenuToggle`, and `aria-expanded` follows the drawer. With
 * `@mobileNav="bottom"` there is no sidebar below the breakpoint, so there it
 * renders nothing; nor does it in a layout with no `Sidebar`.
 */
class SidebarToggle extends Component<SidebarToggleSignature> {
  get label(): string {
    return this.args.label ?? 'Toggle sidebar';
  }

  /** Below the layout's breakpoint the sidebar is a drawer. */
  get controlsDrawer(): boolean {
    return this.args.layout?.belowBreakpoint ?? false;
  }

  /**
   * Inside a layout, the sidebar's collapse as drawn, so a sidebar with
   * `@collapsible="none"` always reports expanded. Below the breakpoint,
   * whether the drawer is open.
   */
  get expanded(): 'true' | 'false' {
    const layout = this.args.layout;
    if (layout && this.controlsDrawer) {
      return layout.state.mobileSidebarOpen ? 'true' : 'false';
    }
    const collapsed = layout
      ? layout.sidebarCollapsed
      : (this.args.collapsed ?? false);
    return collapsed ? 'false' : 'true';
  }

  /**
   * The sidebar it controls. Below the breakpoint that is the drawer, which
   * only exists while it is open.
   */
  get controls(): string | undefined {
    const layout = this.args.layout;
    if (this.args.controls || !layout) {
      return this.args.controls;
    }
    if (this.controlsDrawer && !layout.state.mobileSidebarOpen) {
      return undefined;
    }
    return layout.sidebarId;
  }

  get shown(): boolean {
    return this.args.layout?.canToggleSidebar ?? true;
  }

  get classNames(): string {
    const styles = this.args.layout?.styles ?? standaloneStyles();
    return styles.sidebarToggle({
      class: this.args.layout?.classes?.sidebarToggle
    });
  }

  toggle = (): void => {
    const layout = this.args.layout;
    if (!layout) {
      this.args.onToggle?.();
    } else if (this.controlsDrawer) {
      layout.state.openMobileSidebar();
    } else {
      layout.state.toggleSidebar();
    }
  };

  <template>
    {{#if this.shown}}
      <button
        type="button"
        data-part="sidebar-toggle"
        aria-label={{this.label}}
        aria-expanded={{this.expanded}}
        aria-controls={{this.controls}}
        class={{this.classNames}}
        {{on "click" this.toggle}}
        ...attributes
      >
        {{#if (has-block)}}
          {{yield}}
        {{else}}
          <SidebarLeftIcon />
        {{/if}}
      </button>
    {{/if}}
  </template>
}

export { SidebarToggle, type SidebarToggleSignature, type SidebarToggleArgs };
export default SidebarToggle;
