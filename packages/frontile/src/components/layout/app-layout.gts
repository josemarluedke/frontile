import Component from '@glimmer/component';
import { cached, tracked } from '@glimmer/tracking';
import { hash } from '@ember/helper';
import { on } from '@ember/modifier';
import { guidFor } from '@ember/object/internals';
import { schedule } from '@ember/runloop';
import { isDestroying } from '@ember/destroyable';
import { modifier } from 'ember-modifier';
import { useStyles, type SlotsToClasses } from '@frontile/theme';
import {
  isBelowBreakpoint,
  watchBreakpoint,
  type Breakpoint
} from '../../utils/breakpoint';
import { globalDocument } from '../../utils/document-listener';
import { AppLayoutState } from './app-layout-state';
import {
  ControlledAppLayoutState,
  type AppLayoutContext,
  type RegisteredSidebar
} from './context';
import Aside from './aside';
import AsideToggle from './aside-toggle';
import BottomNav from './bottom-nav';
import Main from './main';
import MenuToggle from './menu-toggle';
import Navbar from './navbar';
import PageHeader from './page-header';
import Sidebar from './sidebar';
import SidebarToggle from './sidebar-toggle';
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
   * The shell's color, one of the theme's semantic categories. It tints the
   * sidebar's rows (hover and the current page), colors a `solid` sidebar or
   * navbar, and is the frame gradient's tint. `neutral` is the plain shell.
   * A `Sidebar` or `Navbar` can take its own `@color`. Published as the
   * `--app-layout-color`, `--app-layout-color-strong` and
   * `--app-layout-on-color` properties on the root, which an app can set
   * itself for a color outside the theme.
   *
   * @defaultValue 'neutral'
   */
  color?: AppLayoutVariants['color'];

  /**
   * How the sidebar wears `@color`: `plain` keeps its ground and tints its
   * rows; `solid` fills it with the color, with rows in its contrast color.
   * The phone drawer always tints. A `Sidebar`'s own `@surface` wins.
   *
   * @defaultValue 'plain'
   */
  sidebarSurface?: AppLayoutVariants['sidebarSurface'];

  /**
   * How the navbar wears `@color`: `plain` keeps its ground; `solid` fills
   * it with the color. A `Navbar`'s own `@surface` wins.
   *
   * @defaultValue 'plain'
   */
  navbarSurface?: AppLayoutVariants['navbarSurface'];

  /**
   * Whether the frame carries a faint left-to-right tint of `@color`, fading
   * to a neutral grey across the content. The stops are the
   * `--app-frame-gradient-from` and `--app-frame-gradient-to` properties.
   *
   * @defaultValue false
   */
  frameGradient?: boolean;

  /**
   * Whether the `inset` card is opaque (`solid`) or lets the frame's gradient
   * show through (`translucent`, `surface-app` at 50%). No effect on
   * `attached`, which has no card.
   *
   * @defaultValue 'translucent' with `@frameGradient`, else 'solid'
   */
  cardSurface?: AppLayoutVariants['cardSurface'];

  /**
   * The viewport width (`sm` 40rem, `md` 48rem, `lg` 64rem) below which the
   * sidebar becomes a drawer opened by `MenuToggle`. Growing past it closes
   * an open drawer. Without `window.matchMedia` the layout stays desktop.
   *
   * @defaultValue 'md'
   */
  breakpoint?: AppLayoutVariants['breakpoint'];

  /**
   * How navigation is shown below `@breakpoint`. `drawer` moves the sidebar
   * into a drawer opened by `MenuToggle`. `bottom` shows the yielded
   * `BottomNav` as a bar along the bottom instead, and renders no sidebar,
   * `MenuToggle` or `SidebarToggle` there. At or above `@breakpoint` both are
   * the desktop sidebar, and `BottomNav` renders nothing. Place `BottomNav`
   * after `Main`.
   *
   * @defaultValue 'drawer'
   */
  mobileNav?: 'drawer' | 'bottom';

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
        Aside: WithBoundArgs<typeof Aside, 'layout'>;
        AsideToggle: WithBoundArgs<typeof AsideToggle, 'layout'>;
        BottomNav: WithBoundArgs<typeof BottomNav, 'layout'>;
        Main: WithBoundArgs<typeof Main, 'layout'>;
        MenuToggle: WithBoundArgs<typeof MenuToggle, 'layout'>;
        Navbar: WithBoundArgs<typeof Navbar, 'layout'>;
        PageHeader: WithBoundArgs<typeof PageHeader, 'layout'>;
        Sidebar: WithBoundArgs<typeof Sidebar, 'layout'>;
        SidebarToggle: WithBoundArgs<typeof SidebarToggle, 'layout'>;
      }
    ];
  };
  Element: HTMLDivElement;
}

/**
 * A part registered with the layout. It is written after render: the parts
 * that read it may already have rendered in this pass, and writing it
 * synchronously would trip Glimmer's backtracking assertion.
 */
class RegisteredPart<T extends object> {
  #owner: object;
  @tracked current?: T;

  constructor(owner: object) {
    this.#owner = owner;
  }

  register = (part: T): (() => void) => {
    schedule('afterRender', () => {
      if (!isDestroying(this.#owner)) {
        this.current = part;
      }
    });
    return () => {
      schedule('afterRender', () => {
        if (!isDestroying(this.#owner) && this.current === part) {
          this.current = undefined;
        }
      });
    };
  };
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

  willDestroy(): void {
    super.willDestroy();
    stopWatcher(watchers, this);
    stopWatcher(asideWatchers, this);
  }

  /**
   * The root's direction, read once it is in the DOM. Until then `isRtl`
   * falls back to the document's. Tracked so drawer placements computed on
   * the first render (an aside drawer mounts closed) pick up an RTL
   * ancestor of the root. Set after render, where changing state is safe.
   */
  @tracked rootRtl?: boolean;

  captureRoot = modifier((element: HTMLElement) => {
    schedule('afterRender', () => {
      if (this.isDestroying) {
        return;
      }
      const rtl = getComputedStyle(element).direction === 'rtl';
      if (rtl !== this.rootRtl) {
        this.rootRtl = rtl;
      }
    });
  });

  /**
   * Rebuilt only when `@breakpoint` changes; the previous watcher stops.
   */
  @cached
  get breakpointWatcher(): BreakpointWatcher {
    return replaceWatcher(
      watchers,
      this,
      this.breakpoint,
      this.closeDrawerWhenWide
    );
  }

  closeDrawerWhenWide = (below: boolean): void => {
    if (!below && this.state.mobileSidebarOpen) {
      this.state.mobileSidebarOpen = false;
    }
  };

  get belowBreakpoint(): boolean {
    return this.breakpointWatcher.below;
  }

  /** The aside is a drawer below `lg`, whatever `@breakpoint` is. */
  @cached
  get asideWatcher(): BreakpointWatcher {
    return replaceWatcher(asideWatchers, this, 'lg', this.closeAsideWhenNarrow);
  }

  /**
   * An aside open beside `Main` closes when the viewport narrows below `lg`,
   * rather than reappearing as a modal drawer the user did not ask for.
   */
  closeAsideWhenNarrow = (below: boolean): void => {
    if (below && this.state.asideOpen) {
      this.state.asideOpen = false;
    }
  };

  get belowAsideBreakpoint(): boolean {
    return this.asideWatcher.below;
  }

  // The Sidebar, BottomNav and Aside register with the layout; see
  // `RegisteredPart`. The toggles read the Sidebar and Aside, the root the
  // BottomNav for its bottom row.
  sidebarPart = new RegisteredPart<RegisteredSidebar>(this);
  bottomNavPart = new RegisteredPart<object>(this);
  asidePart = new RegisteredPart<object>(this);

  registerSidebar = this.sidebarPart.register;
  registerBottomNav = this.bottomNavPart.register;
  registerAside = this.asidePart.register;

  get registeredSidebar(): RegisteredSidebar | undefined {
    return this.sidebarPart.current;
  }

  get registeredBottomNav(): object | undefined {
    return this.bottomNavPart.current;
  }

  get registeredAside(): object | undefined {
    return this.asidePart.current;
  }

  get mobileNav(): 'drawer' | 'bottom' {
    return this.args.mobileNav ?? 'drawer';
  }

  /** The bottom bar replaces the sidebar: bottom mode, below the breakpoint. */
  get bottomNavMode(): boolean {
    return this.mobileNav === 'bottom' && this.belowBreakpoint;
  }

  /**
   * There is no drawer in bottom mode below the breakpoint, so an open flag
   * (seeded, set through `@state`, or left over) is cleared rather than
   * opening a drawer later. Deferred to after render, where changing state
   * is safe.
   */
  closeDrawerInBottomMode = modifier(
    (_element: HTMLElement, [active, open]: [boolean, boolean]) => {
      if (active && open) {
        schedule('afterRender', () => {
          if (!this.isDestroying && this.bottomNavMode) {
            this.state.mobileSidebarOpen = false;
          }
        });
      }
    }
  );

  get bottomNavShown(): boolean {
    return this.bottomNavMode && this.registeredBottomNav !== undefined;
  }

  get effectiveSidebarCollapsed(): boolean {
    return this.registeredSidebar
      ? this.registeredSidebar.collapsed
      : this.state.sidebarCollapsed;
  }

  isRtl = (): boolean => {
    if (this.rootRtl !== undefined) {
      return this.rootRtl;
    }
    const element = globalDocument()?.documentElement;
    return element ? getComputedStyle(element).direction === 'rtl' : false;
  };

  get state(): AppLayoutState {
    return this.args.state ?? this.#controlled;
  }

  get mainId(): string {
    return `${guidFor(this)}-main`;
  }

  get sidebarId(): string {
    return `${guidFor(this)}-sidebar`;
  }

  get menuToggleId(): string {
    return `${guidFor(this)}-menu-toggle`;
  }

  get drawerId(): string {
    return `${guidFor(this)}-drawer`;
  }

  get asideId(): string {
    return `${guidFor(this)}-aside`;
  }

  get asideDrawerId(): string {
    return `${guidFor(this)}-aside-drawer`;
  }

  get variant(): 'inset' | 'attached' {
    return this.args.variant ?? 'inset';
  }

  get navbarPlacement(): 'frame' | 'content' {
    return this.args.navbarPlacement ?? 'frame';
  }

  get color(): NonNullable<AppLayoutVariants['color']> {
    return this.args.color ?? 'neutral';
  }

  get sidebarSurface(): NonNullable<AppLayoutVariants['sidebarSurface']> {
    return this.args.sidebarSurface ?? 'plain';
  }

  get navbarSurface(): NonNullable<AppLayoutVariants['navbarSurface']> {
    return this.args.navbarSurface ?? 'plain';
  }

  get frameGradient(): boolean {
    return this.args.frameGradient ?? false;
  }

  get cardSurface(): 'solid' | 'translucent' {
    // A gradient pairs with a card it shows through; a flat frame keeps it solid.
    return (
      this.args.cardSurface ?? (this.frameGradient ? 'translucent' : 'solid')
    );
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
      cardSurface: this.cardSurface,
      // The shared styles draw the navbar, so they carry its surface.
      // `Sidebar` builds its own styles.
      color: this.color,
      navbarSurface: this.navbarSurface,
      breakpoint: this.breakpoint,
      scrollMode: this.scrollMode,
      sidebarSide: this.sidebarSide
    });
  }

  /**
   * The root's classes. Kept out of `styles`, which the context shares with
   * the parts: `sidebarColumn` reads the registered `Sidebar`, whose own
   * state comes from that context, so putting it there would be a cycle.
   */
  get rootClass(): string {
    const { appLayout } = useStyles();

    return appLayout({
      variant: this.variant,
      navbarPlacement: this.navbarPlacement,
      color: this.color,
      frameGradient: this.frameGradient,
      breakpoint: this.breakpoint,
      scrollMode: this.scrollMode,
      sidebarSide: this.sidebarSide,
      sidebarColumn: this.sidebarColumn,
      sidebarSize: this.registeredSidebar?.size,
      bottomNavRow: this.bottomNavShown ? 'shown' : 'none'
    }).base({ class: this.args.classes?.base });
  }

  /**
   * What the root publishes as `--app-sidebar-width` (see the `base` slot in
   * the theme): the width of the sidebar column, or none when there is no
   * column: no Sidebar registered, the sidebar is a drawer below the
   * breakpoint, or it is collapsed off-canvas. A published token only: it
   * settles after the first render (`none` until a Sidebar registers), and
   * the sidebar's own width does not read it.
   */
  get sidebarColumn(): 'shown' | 'collapsed' | 'none' {
    const sidebar = this.registeredSidebar;
    if (!sidebar || this.belowBreakpoint) {
      return 'none';
    }
    if (sidebar.collapsed) {
      return sidebar.collapsible === 'offcanvas' ? 'none' : 'collapsed';
    }
    return 'shown';
  }

  @cached
  get context(): AppLayoutContext {
    // eslint-disable-next-line @typescript-eslint/no-this-alias
    const layout = this;
    return {
      state: this.state,
      mainId: this.mainId,
      sidebarId: this.sidebarId,
      menuToggleId: this.menuToggleId,
      drawerId: this.drawerId,
      asideId: this.asideId,
      asideDrawerId: this.asideDrawerId,
      styles: this.styles,
      config: {
        variant: this.variant,
        navbarPlacement: this.navbarPlacement,
        breakpoint: this.breakpoint,
        scrollMode: this.scrollMode,
        sidebarSide: this.sidebarSide,
        color: this.color,
        sidebarSurface: this.sidebarSurface,
        navbarSurface: this.navbarSurface
      },
      classes: this.args.classes,
      get belowBreakpoint() {
        return layout.belowBreakpoint;
      },
      get belowAsideBreakpoint() {
        return layout.belowAsideBreakpoint;
      },
      get sidebarCollapsed() {
        return layout.effectiveSidebarCollapsed;
      },
      get mobileNav() {
        return layout.mobileNav;
      },
      get bottomNavMode() {
        return layout.bottomNavMode;
      },
      get bottomNavShown() {
        return layout.bottomNavShown;
      },
      get hasSidebar() {
        return layout.registeredSidebar !== undefined;
      },
      get canToggleSidebar() {
        return layout.registeredSidebar !== undefined && !layout.bottomNavMode;
      },
      get hasAside() {
        return layout.registeredAside !== undefined;
      },
      isRtl: this.isRtl,
      registerSidebar: this.registerSidebar,
      registerBottomNav: this.registerBottomNav,
      registerAside: this.registerAside
    };
  }

  focusMain = (event: Event): void => {
    const main = document.getElementById(this.mainId);
    if (main) {
      event.preventDefault();
      main.focus();
    }
  };

  // Browsers activate a link on Enter with a click, but a synthetic key
  // event does not; handling Enter directly makes both paths the same.
  focusMainOnEnter = (event: KeyboardEvent): void => {
    if (event.key === 'Enter') {
      this.focusMain(event);
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
      data-mobile-nav={{this.mobileNav}}
      data-sidebar-collapsed={{boolString this.effectiveSidebarCollapsed}}
      data-mobile-sidebar-open={{boolString this.state.mobileSidebarOpen}}
      data-aside-open={{boolString this.state.asideOpen}}
      class={{this.rootClass}}
      {{this.captureRoot}}
      {{this.closeDrawerInBottomMode
        this.bottomNavMode
        this.state.mobileSidebarOpen
      }}
      ...attributes
    >
      {{#if this.showSkipLink}}
        <a
          href="#{{this.mainId}}"
          data-part="skip-link"
          class={{this.styles.skipLink class=@classes.skipLink}}
          {{on "click" this.focusMain}}
          {{on "keydown" this.focusMainOnEnter}}
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
          Aside=(component Aside layout=this.context)
          AsideToggle=(component AsideToggle layout=this.context)
          BottomNav=(component BottomNav layout=this.context)
          Main=(component Main layout=this.context)
          MenuToggle=(component MenuToggle layout=this.context)
          Navbar=(component Navbar layout=this.context)
          PageHeader=(component PageHeader layout=this.context)
          Sidebar=(component Sidebar layout=this.context)
          SidebarToggle=(component SidebarToggle layout=this.context)
        )
      }}
    </div>
  </template>
}

function boolString(value: boolean): 'true' | 'false' {
  return value ? 'true' : 'false';
}

/** Tracks whether the viewport is below one breakpoint. */
class BreakpointWatcher {
  @tracked below: boolean;
  #stop: () => void;

  constructor(breakpoint: Breakpoint, onChange: (below: boolean) => void) {
    this.below = isBelowBreakpoint(breakpoint);
    this.#stop = watchBreakpoint(breakpoint, (below) => {
      onChange(below);
      this.below = below;
    });
  }

  stop(): void {
    this.#stop();
  }
}

const watchers = new WeakMap<object, BreakpointWatcher>();
const asideWatchers = new WeakMap<object, BreakpointWatcher>();

/**
 * Stops `owner`'s current watcher, if any, and starts one for `breakpoint`.
 * Once `owner` is being torn down it returns a watcher that is not listening
 * and not registered, so a late read cannot leak a listener.
 */
function replaceWatcher(
  registry: WeakMap<object, BreakpointWatcher>,
  owner: Component<AppLayoutSignature>,
  breakpoint: Breakpoint,
  onChange: (below: boolean) => void
): BreakpointWatcher {
  stopWatcher(registry, owner);
  const watcher = new BreakpointWatcher(breakpoint, onChange);
  if (owner.isDestroying) {
    watcher.stop();
    return watcher;
  }
  registry.set(owner, watcher);
  return watcher;
}

function stopWatcher(
  registry: WeakMap<object, BreakpointWatcher>,
  owner: object
): void {
  registry.get(owner)?.stop();
  registry.delete(owner);
}

export { AppLayout, type AppLayoutSignature, type AppLayoutArgs };
export default AppLayout;
