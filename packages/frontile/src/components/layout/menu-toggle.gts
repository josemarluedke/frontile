import Component from '@glimmer/component';
import { on } from '@ember/modifier';
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

  get controls(): string | undefined {
    return this.args.controls ?? this.args.layout?.sidebarId;
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
        <svg
          aria-hidden="true"
          viewBox="0 0 24 24"
          width="20"
          height="20"
          fill="none"
          stroke="currentColor"
          stroke-width="2"
          stroke-linecap="round"
          stroke-linejoin="round"
        >
          <path d="M4 6h16M4 12h16M4 18h16" />
        </svg>
      {{/if}}
    </button>
  </template>
}

export { MenuToggle, type MenuToggleSignature, type MenuToggleArgs };
export default MenuToggle;
