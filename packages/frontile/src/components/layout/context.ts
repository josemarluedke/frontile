import { useStyles, type SlotsToClasses } from '@frontile/theme';
import type { AppLayoutSlots } from '@frontile/theme';
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
  /** The mobile drawer's id, so the shortcut can tell it belongs here. */
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
  /** Whether the layout's root is laid out right to left. */
  isRtl(): boolean;
  /**
   * Called by `Sidebar` so the layout can report its effective collapse.
   * Returns the matching unregister function.
   */
  registerSidebar(sidebar: RegisteredSidebar): () => void;
}

export interface RegisteredSidebar {
  readonly collapsed: boolean;
}

export interface AppLayoutConfig {
  variant: 'inset' | 'attached';
  navbarPlacement: 'frame' | 'content';
  breakpoint: 'sm' | 'md' | 'lg';
  scrollMode: 'content' | 'page';
  sidebarSide: 'start' | 'end';
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
