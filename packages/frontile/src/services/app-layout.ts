import Service from '@ember/service';
import { tracked } from '@glimmer/tracking';
import { schedule } from '@ember/runloop';
import type { AppLayoutState } from '../components/layout/app-layout-state';
import type { BreadcrumbsItemData } from '../components/navigation/breadcrumbs/collapse';

/**
 * PROTOTYPE. What the mounted `AppLayout` hands the service, so code rendered
 * inside `{{outlet}}` (which cannot see the layout's yielded context) can
 * reach its state.
 */
export interface RegisteredLayout {
  readonly state: AppLayoutState;
}

/** One named region: where it renders (the target) and who fills it. */
export class LayoutRegionState {
  /** The element sources render into, once a target has mounted. */
  @tracked target: Element | null = null;
  /** Whether every source renders (`true`) or only the newest. */
  @tracked multiple = false;
  /** Sources in registration (render) order. Reassigned, never mutated. */
  @tracked sources: readonly object[] = [];

  get hasContent(): boolean {
    return this.sources.length > 0;
  }

  /** Where `source` should render, or `null` when it is not shown. */
  targetFor(source: object): Element | null {
    if (!this.target) {
      return null;
    }
    const shown = this.multiple
      ? this.sources.includes(source)
      : this.sources[this.sources.length - 1] === source;
    return shown ? this.target : null;
  }
}

/** One `{{breadcrumb}}` invocation. Its item is updated in place. */
export class BreadcrumbToken {
  @tracked item: BreadcrumbsItemData = {};
}

/**
 * PROTOTYPE. Connects route templates to the single mounted `AppLayout`:
 * named regions (filled with `LayoutRegion` / `LayoutAside`) and a
 * breadcrumb trail (filled with `{{breadcrumb}}`).
 *
 * Every write is deferred to `afterRender`. Sources register while the
 * render is running, and the layout -- which renders before `{{outlet}}` --
 * has usually already read the same tracked state in that render; writing
 * it synchronously trips Glimmer's backtracking assertion (see the
 * `syncWritesForTesting` test).
 */
export default class AppLayoutService extends Service {
  /** The mounted `AppLayout`, once it has registered (tracked). */
  @tracked layout?: RegisteredLayout;

  @tracked breadcrumbTokens: readonly BreadcrumbToken[] = [];

  /**
   * Test-only: write synchronously instead of after render, to demonstrate
   * the backtracking assertion. Never set in an app.
   *
   * @internal
   */
  syncWritesForTesting = false;

  #regions = new Map<string, LayoutRegionState>();
  #emptyListeners = new Map<string, Set<() => void>>();

  #write(fn: () => void, allowSync = true): void {
    if (allowSync && this.syncWritesForTesting) {
      fn();
      return;
    }
    schedule('afterRender', () => {
      if (!this.isDestroying) {
        fn();
      }
    });
  }

  /** The named region, created on first use (by a source or a target). */
  region(name: string): LayoutRegionState {
    let region = this.#regions.get(name);
    if (!region) {
      region = new LayoutRegionState();
      this.#regions.set(name, region);
    }
    return region;
  }

  /** Whether any source fills the named region (tracked). */
  hasContent(name: string): boolean {
    return this.region(name).hasContent;
  }

  registerLayout(layout: RegisteredLayout): () => void {
    this.#write(() => {
      if (this.layout && this.layout !== layout) {
        console.warn(
          'frontile: a second AppLayout registered with the app-layout service; regions follow the newest.'
        );
      }
      this.layout = layout;
    }, false);
    return () =>
      this.#write(() => {
        if (this.layout === layout) {
          this.layout = undefined;
        }
      });
  }

  registerTarget(
    name: string,
    element: Element,
    options: { multiple?: boolean } = {}
  ): () => void {
    const region = this.region(name);
    this.#write(() => {
      region.multiple = options.multiple ?? false;
      region.target = element;
    });
    return () =>
      this.#write(() => {
        if (region.target === element) {
          region.target = null;
        }
      });
  }

  addSource(name: string, source: object): () => void {
    const region = this.region(name);
    this.#write(() => {
      region.sources = [...region.sources, source];
    });
    return () =>
      this.#write(() => {
        const before = region.sources.length;
        region.sources = region.sources.filter((s) => s !== source);
        if (before > 0 && region.sources.length === 0) {
          this.#emptyListeners.get(name)?.forEach((listener) => listener());
        }
      });
  }

  /**
   * Calls `listener` whenever the named region loses its last source. Runs
   * after render, so it may change tracked state.
   */
  onEmpty(name: string, listener: () => void): () => void {
    let listeners = this.#emptyListeners.get(name);
    if (!listeners) {
      listeners = new Set();
      this.#emptyListeners.set(name, listeners);
    }
    listeners.add(listener);
    return () => listeners.delete(listener);
  }

  /** The trail, outermost first (tracked). */
  get breadcrumbs(): BreadcrumbsItemData[] {
    return this.breadcrumbTokens.map((token) => token.item);
  }

  addBreadcrumb(token: BreadcrumbToken): () => void {
    this.#write(() => {
      this.breadcrumbTokens = [...this.breadcrumbTokens, token];
    });
    return () =>
      this.#write(() => {
        this.breadcrumbTokens = this.breadcrumbTokens.filter(
          (t) => t !== token
        );
      });
  }

  updateBreadcrumb(token: BreadcrumbToken, item: BreadcrumbsItemData): void {
    this.#write(() => {
      token.item = item;
    });
  }
}

declare module '@ember/service' {
  interface Registry {
    'app-layout': AppLayoutService;
  }
}
