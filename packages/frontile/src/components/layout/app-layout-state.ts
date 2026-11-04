import { tracked } from '@glimmer/tracking';

export interface AppLayoutStateInitial {
  sidebarCollapsed?: boolean;
  mobileSidebarOpen?: boolean;
  asideOpen?: boolean;
}

/**
 * Shared state for an app shell: desktop sidebar collapse, the mobile
 * sidebar drawer, and the secondary aside.
 *
 * The methods are arrow functions so they can be handed to templates
 * directly, e.g. `{{on "click" state.toggleAside}}`.
 */
export class AppLayoutState {
  /** Whether the desktop sidebar is collapsed to its narrow rail. */
  @tracked sidebarCollapsed = false;
  /** Whether the mobile sidebar drawer is open. */
  @tracked mobileSidebarOpen = false;
  /** Whether the aside panel is open. */
  @tracked asideOpen = false;

  constructor(initial: AppLayoutStateInitial = {}) {
    this.sidebarCollapsed = initial.sidebarCollapsed ?? false;
    this.mobileSidebarOpen = initial.mobileSidebarOpen ?? false;
    this.asideOpen = initial.asideOpen ?? false;
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

export default AppLayoutState;
