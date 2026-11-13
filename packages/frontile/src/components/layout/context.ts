import { useStyles, type SlotsToClasses } from '@frontile/theme';
import type { AppLayoutSlots, AppLayoutVariants } from '@frontile/theme';
import type { AppLayoutState } from './app-layout-state';

export type AppLayoutStyles = ReturnType<
  ReturnType<typeof useStyles>['appLayout']
>;

/**
 * What `AppLayout` hands each part it yields. Internal: parts receive it as
 * a bound `@layout` argument and fall back to standalone styles without it.
 */
export interface AppLayoutContext {
  state: AppLayoutState;
  mainId: string;
  sidebarId: string;
  /** The `MenuToggle`'s id, so the drawer can return focus to it. */
  menuToggleId: string;
  /** The mobile drawer's id. */
  drawerId: string;
  styles: AppLayoutStyles;
  /** The variant props the layout's `styles` were built from. */
  config: AppLayoutConfig;
  classes?: SlotsToClasses<AppLayoutSlots>;
  /** Whether the viewport is below `config.breakpoint` (tracked). */
  readonly belowBreakpoint: boolean;
  /**
   * Whether the sidebar is collapsed as drawn: `state.sidebarCollapsed`,
   * except that a sidebar with `@collapsible="none"` never is (tracked).
   */
  readonly sidebarCollapsed: boolean;
  /** The aside's id, for `AsideToggle`'s `aria-controls`. */
  asideId: string;
  /** The aside drawer's id. */
  asideDrawerId: string;
  /**
   * Whether the viewport is below `lg`, where the aside is a drawer. Fixed at
   * `lg`, independent of `config.breakpoint` (tracked).
   */
  readonly belowAsideBreakpoint: boolean;
  /** Whether the layout's root is laid out right to left. */
  isRtl(): boolean;
  /**
   * Called by `Sidebar` so the layout can report its effective collapse.
   * Returns the matching unregister function.
   */
  registerSidebar(sidebar: RegisteredSidebar): () => void;
  /** Whether a `Sidebar` is registered (tracked). */
  readonly hasSidebar: boolean;
  /**
   * Whether `SidebarToggle` and `MenuToggle` render: there is a `Sidebar`,
   * and the bottom bar is not standing in for it (tracked).
   */
  readonly canToggleSidebar: boolean;
  /**
   * How navigation is shown below the breakpoint: the sidebar in a `drawer`,
   * or a `bottom` bar (`BottomNav`) with no sidebar (tracked).
   */
  readonly mobileNav: 'drawer' | 'bottom';
  /**
   * Whether the bottom bar replaces the sidebar right now: `mobileNav` is
   * `bottom` and the viewport is below the breakpoint. `Sidebar`,
   * `MenuToggle` and `SidebarToggle` render nothing then, and `BottomNav`
   * renders (tracked).
   */
  readonly bottomNavMode: boolean;
  /**
   * Whether a registered `BottomNav` is shown: `bottomNavMode` with a
   * `BottomNav` in the layout. Settles after the first render, like the
   * registered sidebar (tracked).
   */
  readonly bottomNavShown: boolean;
  /**
   * Called by `BottomNav` so the layout can give it a row and publish
   * `--app-bottomnav-height`. Returns the matching unregister function.
   */
  registerBottomNav(nav: object): () => void;
  /**
   * Whether an `Aside` is rendered in the layout. `AsideToggle` renders
   * nothing without one. Settles after the first render, like the registered
   * sidebar (tracked). PROTOTYPE: false while a route-driven `Aside`
   * (`@region`) is registered but empty.
   */
  readonly hasAside: boolean;
  /**
   * Called by `Aside` so the layout knows it has one. Returns the matching
   * unregister function.
   */
  registerAside(aside: RegisteredAside): () => void;
}

export interface RegisteredAside {
  /** PROTOTYPE. Whether the aside has content; omitted means it does. */
  readonly available?: boolean;
}

export interface RegisteredSidebar {
  readonly collapsed: boolean;
  readonly collapsible: 'icon' | 'offcanvas' | 'none';
  readonly size: 'default' | 'rail';
}

export interface AppLayoutConfig {
  variant: 'inset' | 'attached';
  navbarPlacement: 'frame' | 'content';
  breakpoint: 'sm' | 'md' | 'lg';
  scrollMode: 'content' | 'page';
  sidebarSide: 'start' | 'end';
  color: NonNullable<AppLayoutVariants['color']>;
  sidebarSurface: NonNullable<AppLayoutVariants['sidebarSurface']>;
  navbarSurface: NonNullable<AppLayoutVariants['navbarSurface']>;
}

/**
 * The layout-wide variants a part passes when it builds its own styles from
 * the layout's config. `variant` is left to the part: a standalone part
 * picks its own default.
 */
export function layoutVariants(
  config: AppLayoutConfig | undefined
): Partial<
  Pick<
    AppLayoutConfig,
    'navbarPlacement' | 'breakpoint' | 'scrollMode' | 'sidebarSide'
  >
> {
  return {
    navbarPlacement: config?.navbarPlacement,
    breakpoint: config?.breakpoint,
    scrollMode: config?.scrollMode,
    sidebarSide: config?.sidebarSide
  };
}

/** Styles for a part rendered outside an `AppLayout`: no card chrome. */
export function standaloneStyles(): AppLayoutStyles {
  return useStyles().appLayout({ variant: 'attached' });
}

type StateKey = 'sidebarCollapsed' | 'mobileSidebarOpen' | 'asideOpen';

export interface ControlledStateArgs {
  sidebarCollapsed?: boolean;
  onSidebarCollapsedChange?: (value: boolean) => void;
  mobileSidebarOpen?: boolean;
  onMobileSidebarOpenChange?: (value: boolean) => void;
  asideOpen?: boolean;
  onAsideOpenChange?: (value: boolean) => void;
}

const CALLBACKS = {
  sidebarCollapsed: 'onSidebarCollapsedChange',
  mobileSidebarOpen: 'onMobileSidebarOpenChange',
  asideOpen: 'onAsideOpenChange'
} as const;

/**
 * An `AppLayoutState` whose fields can each be controlled by an argument.
 *
 * A field is controlled when its argument is *passed* (checked with `in`, as
 * `Tabs` does for `@value`); it then reads from the argument and a write only
 * calls the matching `on…Change` callback. An uncontrolled field reads and
 * writes the wrapped state, seeded from the `@default…` arguments, and calls
 * the callback too.
 */
export class ControlledAppLayoutState implements AppLayoutState {
  #own: AppLayoutState;
  #args: () => ControlledStateArgs;

  constructor(own: AppLayoutState, args: () => ControlledStateArgs) {
    this.#own = own;
    this.#args = args;
  }

  #read(key: StateKey): boolean {
    const args = this.#args();
    return key in args ? Boolean(args[key]) : this.#own[key];
  }

  #write(key: StateKey, value: boolean): void {
    if (this.#read(key) === value) {
      return;
    }
    this.#own[key] = value;
    this.#args()[CALLBACKS[key]]?.(value);
  }

  get sidebarCollapsed(): boolean {
    return this.#read('sidebarCollapsed');
  }

  set sidebarCollapsed(value: boolean) {
    this.#write('sidebarCollapsed', value);
  }

  get mobileSidebarOpen(): boolean {
    return this.#read('mobileSidebarOpen');
  }

  set mobileSidebarOpen(value: boolean) {
    this.#write('mobileSidebarOpen', value);
  }

  get asideOpen(): boolean {
    return this.#read('asideOpen');
  }

  set asideOpen(value: boolean) {
    this.#write('asideOpen', value);
  }

  toggleSidebar = (): void => {
    this.sidebarCollapsed = !this.sidebarCollapsed;
  };

  collapseSidebar = (): void => {
    this.sidebarCollapsed = true;
  };

  expandSidebar = (): void => {
    this.sidebarCollapsed = false;
  };

  openMobileSidebar = (): void => {
    this.mobileSidebarOpen = true;
  };

  closeMobileSidebar = (): void => {
    this.mobileSidebarOpen = false;
  };

  toggleAside = (): void => {
    this.asideOpen = !this.asideOpen;
  };

  closeAside = (): void => {
    this.asideOpen = false;
  };
}
