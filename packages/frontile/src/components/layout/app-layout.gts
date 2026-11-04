import Component from '@glimmer/component';
import { cached } from '@glimmer/tracking';
import { hash } from '@ember/helper';
import { on } from '@ember/modifier';
import { guidFor } from '@ember/object/internals';
import { useStyles, type SlotsToClasses } from '@frontile/theme';
import { AppLayoutState } from './app-layout-state';
import { ControlledAppLayoutState, type AppLayoutContext } from './context';
import Main from './main';
import Navbar from './navbar';
import PageHeader from './page-header';
import type { AppLayoutSlots, AppLayoutVariants } from '@frontile/theme';
import type Owner from '@ember/owner';
import type { WithBoundArgs } from '@glint/template';

interface AppLayoutArgs {
  /**
   * `inset` draws the content in a rounded card on a tinted frame.
   * `attached` runs the content edge to edge, with no card.
   *
   * @defaultValue 'inset'
   */
  variant?: AppLayoutVariants['variant'];

  /**
   * Where the navbar sits in the `inset` variant. `frame` puts it on the
   * tinted frame above the card; `content` makes it the card's first row.
   *
   * @defaultValue 'frame'
   */
  navbarPlacement?: AppLayoutVariants['navbarPlacement'];

  /**
   * The viewport width (`sm` 40rem, `md` 48rem, `lg` 64rem) below which the
   * sidebar becomes a drawer.
   *
   * @defaultValue 'md'
   */
  breakpoint?: AppLayoutVariants['breakpoint'];

  /**
   * Which side the sidebar sits on. Logical, so `start` is the right side in
   * a right-to-left document.
   *
   * @defaultValue 'start'
   */
  sidebarSide?: 'start' | 'end';

  /**
   * `content` fills the viewport and scrolls `Main` on its own. `page` lets
   * the document scroll instead.
   *
   * @defaultValue 'content'
   */
  scrollMode?: AppLayoutVariants['scrollMode'];

  /**
   * The keyboard shortcut that toggles the sidebar, or `false` for none.
   *
   * @defaultValue 'mod+b'
   */
  toggleShortcut?: string | false;

  /**
   * Renders a "Skip to main content" link as the first focusable element.
   *
   * @defaultValue true
   */
  skipLink?: boolean;

  /**
   * The text of the skip link.
   *
   * @defaultValue 'Skip to main content'
   */
  skipLinkLabel?: string;

  /**
   * Whether the desktop sidebar is collapsed. Passing it makes the value
   * controlled: toggles call `@onSidebarCollapsedChange` and wait for the
   * argument to change. Ignored when `@state` is passed.
   */
  sidebarCollapsed?: boolean;

  /**
   * The initial `sidebarCollapsed` when uncontrolled.
   *
   * @defaultValue false
   */
  defaultSidebarCollapsed?: boolean;

  /** Called with the new value when the sidebar is collapsed or expanded. */
  onSidebarCollapsedChange?: (value: boolean) => void;

  /**
   * Whether the mobile sidebar drawer is open. Passing it makes the value
   * controlled. Ignored when `@state` is passed.
   */
  mobileSidebarOpen?: boolean;

  /**
   * The initial `mobileSidebarOpen` when uncontrolled.
   *
   * @defaultValue false
   */
  defaultMobileSidebarOpen?: boolean;

  /** Called with the new value when the mobile drawer opens or closes. */
  onMobileSidebarOpenChange?: (value: boolean) => void;

  /**
   * Whether the aside is open. Passing it makes the value controlled.
   * Ignored when `@state` is passed.
   */
  asideOpen?: boolean;

  /**
   * The initial `asideOpen` when uncontrolled.
   *
   * @defaultValue false
   */
  defaultAsideOpen?: boolean;

  /** Called with the new value when the aside opens or closes. */
  onAsideOpenChange?: (value: boolean) => void;

  /**
   * A shared `AppLayoutState` to drive the layout from elsewhere in the app.
   * When passed, it is the only source of state: the individual state
   * arguments and their callbacks are ignored.
   */
  state?: AppLayoutState;

  /** Class names for each slot of the component, merged with the theme's. */
  classes?: SlotsToClasses<AppLayoutSlots>;
}

interface AppLayoutSignature {
  Args: AppLayoutArgs;
  Blocks: {
    default: [
      {
        state: AppLayoutState;
        Main: WithBoundArgs<typeof Main, 'layout'>;
        Navbar: WithBoundArgs<typeof Navbar, 'layout'>;
        PageHeader: WithBoundArgs<typeof PageHeader, 'layout'>;
      }
    ];
  };
  Element: HTMLDivElement;
}

/**
 * The application shell. Its root is a grid that the yielded parts place
 * themselves in, so they can be written in any order.
 */
class AppLayout extends Component<AppLayoutSignature> {
  #controlled: ControlledAppLayoutState;

  constructor(owner: Owner, args: AppLayoutArgs) {
    super(owner, args);
    const own = new AppLayoutState({
      sidebarCollapsed: args.defaultSidebarCollapsed,
      mobileSidebarOpen: args.defaultMobileSidebarOpen,
      asideOpen: args.defaultAsideOpen
    });
    this.#controlled = new ControlledAppLayoutState(own, () => this.args);
  }

  get state(): AppLayoutState {
    return this.args.state ?? this.#controlled;
  }

  get mainId(): string {
    return `${guidFor(this)}-main`;
  }

  get variant(): 'inset' | 'attached' {
    return this.args.variant ?? 'inset';
  }

  get navbarPlacement(): 'frame' | 'content' {
    return this.args.navbarPlacement ?? 'frame';
  }

  get breakpoint(): 'sm' | 'md' | 'lg' {
    return this.args.breakpoint ?? 'md';
  }

  get scrollMode(): 'content' | 'page' {
    return this.args.scrollMode ?? 'content';
  }

  get sidebarSide(): 'start' | 'end' {
    return this.args.sidebarSide ?? 'start';
  }

  get hasCard(): boolean {
    return this.variant === 'inset';
  }

  get showSkipLink(): boolean {
    return this.args.skipLink ?? true;
  }

  @cached
  get styles() {
    const { appLayout } = useStyles();

    return appLayout({
      variant: this.variant,
      navbarPlacement: this.navbarPlacement,
      breakpoint: this.breakpoint,
      scrollMode: this.scrollMode,
      collapsed: this.state.sidebarCollapsed
    });
  }

  @cached
  get context(): AppLayoutContext {
    return {
      state: this.state,
      mainId: this.mainId,
      styles: this.styles,
      classes: this.args.classes
    };
  }

  focusMain = (event: Event): void => {
    const main = document.getElementById(this.mainId);
    if (main) {
      event.preventDefault();
      main.focus();
    }
  };

  <template>
    <div
      data-component="app-layout"
      data-part="base"
      data-variant={{this.variant}}
      data-navbar-placement={{this.navbarPlacement}}
      data-scroll-mode={{this.scrollMode}}
      data-breakpoint={{this.breakpoint}}
      data-sidebar-side={{this.sidebarSide}}
      data-sidebar-collapsed={{boolString this.state.sidebarCollapsed}}
      data-mobile-sidebar-open={{boolString this.state.mobileSidebarOpen}}
      data-aside-open={{boolString this.state.asideOpen}}
      class={{this.styles.base class=@classes.base}}
      ...attributes
    >
      {{#if this.showSkipLink}}
        <a
          href="#{{this.mainId}}"
          data-part="skip-link"
          class={{this.styles.skipLink class=@classes.skipLink}}
          {{on "click" this.focusMain}}
        >
          {{if @skipLinkLabel @skipLinkLabel "Skip to main content"}}
        </a>
      {{/if}}
      {{#if this.hasCard}}
        <div
          data-part="main-card"
          aria-hidden="true"
          class={{this.styles.mainCard class=@classes.mainCard}}
        ></div>
      {{/if}}
      {{yield
        (hash
          state=this.state
          Main=(component Main layout=this.context)
          Navbar=(component Navbar layout=this.context)
          PageHeader=(component PageHeader layout=this.context)
        )
      }}
    </div>
  </template>
}

function boolString(value: boolean): 'true' | 'false' {
  return value ? 'true' : 'false';
}

export { AppLayout, type AppLayoutSignature, type AppLayoutArgs };
export default AppLayout;
