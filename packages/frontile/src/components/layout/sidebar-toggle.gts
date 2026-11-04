import Component from '@glimmer/component';
import { on } from '@ember/modifier';
import { AppLayoutState } from './app-layout-state';
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
   * an `AppLayout` it defaults to the layout's sidebar.
   */
  controls?: string;

  /**
   * The state to toggle. Only used outside an `AppLayout`; inside one the
   * layout's state is toggled.
   */
  state?: AppLayoutState;

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
 * while the sidebar is expanded.
 */
class SidebarToggle extends Component<SidebarToggleSignature> {
  fallbackState = new AppLayoutState();

  get state(): AppLayoutState {
    return this.args.layout?.state ?? this.args.state ?? this.fallbackState;
  }

  get label(): string {
    return this.args.label ?? 'Toggle sidebar';
  }

  get expanded(): 'true' | 'false' {
    return this.state.sidebarCollapsed ? 'false' : 'true';
  }

  get controls(): string | undefined {
    return this.args.controls ?? this.args.layout?.sidebarId;
  }

  get classNames(): string {
    const styles = this.args.layout?.styles ?? standaloneStyles();
    return styles.sidebarToggle({
      class: this.args.layout?.classes?.sidebarToggle
    });
  }

  toggle = (): void => {
    this.state.toggleSidebar();
  };

  <template>
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
          <rect x="3" y="4" width="18" height="16" rx="2" />
          <path d="M9 4v16" />
        </svg>
      {{/if}}
    </button>
  </template>
}

export { SidebarToggle, type SidebarToggleSignature, type SidebarToggleArgs };
export default SidebarToggle;
