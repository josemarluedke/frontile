import Component from '@glimmer/component';
import { cached, tracked } from '@glimmer/tracking';
import { hash } from '@ember/helper';
import { on } from '@ember/modifier';
import { guidFor } from '@ember/object/internals';
import { schedule } from '@ember/runloop';
import { modifier } from 'ember-modifier';
import { useStyles, type SlotsToClasses } from '@frontile/theme';
import {
  isBelowBreakpoint,
  watchBreakpoint,
  type Breakpoint
} from '../../utils/breakpoint';
import { globalDocument, listen } from '../../utils/document-listener';
import { AppLayoutState } from './app-layout-state';
import {
  ControlledAppLayoutState,
  type AppLayoutContext,
  type RegisteredSidebar
} from './context';
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
   * The viewport width (`sm` 40rem, `md` 48rem, `lg` 64rem) below which the
   * sidebar becomes a drawer opened by `MenuToggle`. Growing past it closes
   * an open drawer. Without `window.matchMedia` the layout stays desktop.
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
   * The keyboard shortcut that toggles the sidebar, or `false` for none. It
   * collapses or expands the sidebar on desktop and opens or closes the
   * drawer below `@breakpoint`. `mod` is Cmd on Apple platforms and Ctrl
   * elsewhere; `ctrl`, `meta`, `alt` and `shift` can be combined with a key,
   * joined by `+`. It only fires when focus is inside this layout (or on
   * the page body), so two layouts on a page do not both toggle.
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
    // `listen` is a no-op without a global `document` (FastBoot/SSR), so
    // constructing the layout on the server does not throw.
    this.#stopShortcut = listen(
      globalDocument(),
      'keydown',
      this.handleShortcut
    );
  }

  #stopShortcut: () => void;

  willDestroy(): void {
    super.willDestroy();
    this.#stopShortcut();
    stopWatcher(this);
  }

  #root?: HTMLElement;

  captureRoot = modifier((element: HTMLElement) => {
    this.#root = element;
    return () => {
      this.#root = undefined;
    };
  });

  /**
   * Rebuilt only when `@breakpoint` changes; the previous watcher stops.
   */
  @cached
  get breakpointWatcher(): BreakpointWatcher {
    return replaceWatcher(this, this.breakpoint, this.closeDrawerWhenWide);
  }

  closeDrawerWhenWide = (below: boolean): void => {
    if (!below && this.state.mobileSidebarOpen) {
      this.state.mobileSidebarOpen = false;
    }
  };

  get belowBreakpoint(): boolean {
    return this.breakpointWatcher.below;
  }

  // The Sidebar registers after render: the toggles that read it may already
  // have rendered in this pass, and writing it synchronously would trip
  // Glimmer's backtracking assertion.
  @tracked registeredSidebar?: RegisteredSidebar;

  registerSidebar = (sidebar: RegisteredSidebar): (() => void) => {
    schedule('afterRender', () => {
      if (!this.isDestroying) {
        this.registeredSidebar = sidebar;
      }
    });
    return () => {
      schedule('afterRender', () => {
        if (!this.isDestroying && this.registeredSidebar === sidebar) {
          this.registeredSidebar = undefined;
        }
      });
    };
  };

  get effectiveSidebarCollapsed(): boolean {
    return this.registeredSidebar
      ? this.registeredSidebar.collapsed
      : this.state.sidebarCollapsed;
  }

  isRtl = (): boolean => {
    const element = this.#root ?? globalDocument()?.documentElement;
    return element ? getComputedStyle(element).direction === 'rtl' : false;
  };

  get shortcut(): string | false {
    return this.args.toggleShortcut ?? 'mod+b';
  }

  /** Focus inside this layout, its drawer, or on the page body. */
  ownsTarget(target: EventTarget | null): boolean {
    if (target === document.body) {
      return true;
    }
    if (!(target instanceof Node)) {
      return false;
    }
    if (this.#root?.contains(target)) {
      return true;
    }
    return document.getElementById(this.drawerId)?.contains(target) ?? false;
  }

  handleShortcut = (event: KeyboardEvent): void => {
    const shortcut = this.shortcut;
    if (
      shortcut === false ||
      event.defaultPrevented ||
      !matchesShortcut(event, shortcut) ||
      !this.ownsTarget(event.target)
    ) {
      return;
    }
    event.preventDefault();
    if (this.belowBreakpoint) {
      this.state.mobileSidebarOpen = !this.state.mobileSidebarOpen;
    } else {
      this.state.toggleSidebar();
    }
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
      sidebarSide: this.sidebarSide,
      collapsed: this.state.sidebarCollapsed
    });
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
      styles: this.styles,
      config: {
        variant: this.variant,
        navbarPlacement: this.navbarPlacement,
        breakpoint: this.breakpoint,
        scrollMode: this.scrollMode,
        sidebarSide: this.sidebarSide
      },
      classes: this.args.classes,
      get belowBreakpoint() {
        return layout.belowBreakpoint;
      },
      get sidebarCollapsed() {
        return layout.effectiveSidebarCollapsed;
      },
      isRtl: this.isRtl,
      registerSidebar: this.registerSidebar
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
      data-sidebar-collapsed={{boolString this.state.sidebarCollapsed}}
      data-mobile-sidebar-open={{boolString this.state.mobileSidebarOpen}}
      data-aside-open={{boolString this.state.asideOpen}}
      class={{this.styles.base class=@classes.base}}
      {{this.captureRoot}}
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

/** Stops `owner`'s current watcher, if any, and starts one for `breakpoint`. */
function replaceWatcher(
  owner: object,
  breakpoint: Breakpoint,
  onChange: (below: boolean) => void
): BreakpointWatcher {
  stopWatcher(owner);
  const watcher = new BreakpointWatcher(breakpoint, onChange);
  watchers.set(owner, watcher);
  return watcher;
}

function stopWatcher(owner: object): void {
  watchers.get(owner)?.stop();
  watchers.delete(owner);
}

function isApplePlatform(): boolean {
  const nav = navigator as Navigator & {
    userAgentData?: { platform?: string };
  };
  const platform = nav.userAgentData?.platform || nav.platform || '';
  return /mac|iphone|ipad|ipod/i.test(platform);
}

/**
 * Whether `event` is exactly `shortcut`, e.g. `mod+b` or `ctrl+shift+k`:
 * the named modifiers held, no others, and the key (case-insensitive).
 */
function matchesShortcut(event: KeyboardEvent, shortcut: string): boolean {
  const parts = shortcut.toLowerCase().split('+');
  const key = parts.pop();
  if (!key || event.key?.toLowerCase() !== key) {
    return false;
  }
  const apple = isApplePlatform();
  const wanted = { ctrl: false, meta: false, alt: false, shift: false };
  for (const part of parts) {
    if (part === 'mod') {
      wanted[apple ? 'meta' : 'ctrl'] = true;
    } else if (part in wanted) {
      wanted[part as keyof typeof wanted] = true;
    } else {
      return false;
    }
  }
  return (
    event.ctrlKey === wanted.ctrl &&
    event.metaKey === wanted.meta &&
    event.altKey === wanted.alt &&
    event.shiftKey === wanted.shift
  );
}

export { AppLayout, type AppLayoutSignature, type AppLayoutArgs };
export default AppLayout;
