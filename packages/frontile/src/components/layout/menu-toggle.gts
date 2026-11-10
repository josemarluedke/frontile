import Component from '@glimmer/component';
import { on } from '@ember/modifier';
import { MenuIcon } from '../../-private/icons';
import { AppLayoutState } from './app-layout-state';
import { standaloneStyles, type AppLayoutContext } from './context';

interface MenuToggleArgs {
  /**
   * The accessible name of the button.
   *
   * @defaultValue 'Open menu'
   */
  label?: string;

  /**
   * The id of the sidebar this button opens, for `aria-controls`. Inside an
   * `AppLayout` it defaults to the layout's sidebar.
   */
  controls?: string;

  /**
   * The state whose `mobileSidebarOpen` the button sets. Only used outside an
   * `AppLayout`; inside one the layout's state is used.
   */
  state?: AppLayoutState;

  /**
   * Supplied by `AppLayout`. Not part of the public API.
   *
   * @internal
   */
  layout?: AppLayoutContext;
}

interface MenuToggleSignature {
  Args: MenuToggleArgs;
  Blocks: {
    /** Replaces the default icon with your own content. */
    default: [];
  };
  Element: HTMLButtonElement;
}

/**
 * The mobile menu button: opens the sidebar drawer. It is shown only below
 * the layout's `@breakpoint`, typically at the top-left of the navbar. A
 * `SidebarToggle` also opens the drawer below the breakpoint, so a layout can
 * use either one there; with both in the navbar, both show on narrow
 * screens. Closing the drawer returns focus to the button that opened it.
 * With `@mobileNav="bottom"` there is no drawer, so below the breakpoint it
 * renders nothing; nor does it in a layout with no `Sidebar`.
 */
class MenuToggle extends Component<MenuToggleSignature> {
  fallbackState = new AppLayoutState();

  get state(): AppLayoutState {
    return this.args.layout?.state ?? this.args.state ?? this.fallbackState;
  }

  get label(): string {
    return this.args.label ?? 'Open menu';
  }

  get expanded(): 'true' | 'false' {
    return this.state.mobileSidebarOpen ? 'true' : 'false';
  }

  /** The drawer, which only exists while it is open. */
  get controls(): string | undefined {
    const layout = this.args.layout;
    if (this.args.controls || !layout) {
      return this.args.controls;
    }
    return layout.state.mobileSidebarOpen ? layout.sidebarId : undefined;
  }

  get shown(): boolean {
    return this.args.layout?.canToggleSidebar ?? true;
  }

  get classNames(): string {
    const styles = this.args.layout?.styles ?? standaloneStyles();
    return styles.menuToggle({
      class: this.args.layout?.classes?.menuToggle
    });
  }

  open = (): void => {
    this.state.openMobileSidebar();
  };

  <template>
    {{#if this.shown}}
      <button
        type="button"
        id={{@layout.menuToggleId}}
        data-part="menu-toggle"
        aria-label={{this.label}}
        aria-expanded={{this.expanded}}
        aria-controls={{this.controls}}
        class={{this.classNames}}
        {{on "click" this.open}}
        ...attributes
      >
        {{#if (has-block)}}
          {{yield}}
        {{else}}
          <MenuIcon />
        {{/if}}
      </button>
    {{/if}}
  </template>
}

export { MenuToggle, type MenuToggleSignature, type MenuToggleArgs };
export default MenuToggle;
