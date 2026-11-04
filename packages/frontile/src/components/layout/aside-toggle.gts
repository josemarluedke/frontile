import Component from '@glimmer/component';
import { on } from '@ember/modifier';
import { AppLayoutState } from './app-layout-state';
import { standaloneStyles, type AppLayoutContext } from './context';

interface AsideToggleArgs {
  /**
   * The accessible name of the button.
   *
   * @defaultValue 'Toggle details'
   */
  label?: string;

  /**
   * The id of the aside this button controls, for `aria-controls`. Inside an
   * `AppLayout` it defaults to the layout's aside.
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

interface AsideToggleSignature {
  Args: AsideToggleArgs;
  Blocks: {
    /** Replaces the default icon with your own content. */
    default: [];
  };
  Element: HTMLButtonElement;
}

/**
 * A button that opens and closes the `Aside`. Conventionally placed at the
 * end of the `Navbar`. `aria-expanded` is true while the aside is open.
 */
class AsideToggle extends Component<AsideToggleSignature> {
  fallbackState = new AppLayoutState();

  get state(): AppLayoutState {
    return this.args.layout?.state ?? this.args.state ?? this.fallbackState;
  }

  get label(): string {
    return this.args.label ?? 'Toggle details';
  }

  get expanded(): 'true' | 'false' {
    return this.state.asideOpen ? 'true' : 'false';
  }

  get controls(): string | undefined {
    return this.args.controls ?? this.args.layout?.asideId;
  }

  get classNames(): string {
    const styles = this.args.layout?.styles ?? standaloneStyles();
    return styles.asideToggle({
      class: this.args.layout?.classes?.asideToggle
    });
  }

  toggle = (): void => {
    this.state.toggleAside();
  };

  <template>
    <button
      type="button"
      data-part="aside-toggle"
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
          <path d="M15 4v16" />
        </svg>
      {{/if}}
    </button>
  </template>
}

export { AsideToggle, type AsideToggleSignature, type AsideToggleArgs };
export default AsideToggle;
