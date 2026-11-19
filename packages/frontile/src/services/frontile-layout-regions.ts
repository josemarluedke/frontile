import Service from '@ember/service';
import { tracked } from '@glimmer/tracking';
import { schedule } from '@ember/runloop';
import { warn } from '@ember/debug';

/** One named region: where it renders (the target) and who fills it. */
export class LayoutRegionState {
  /** The element sources render into, once a target has mounted. */
  @tracked target: Element | null = null;
  /** Whether every source renders (`true`) or only the newest. */
  @tracked multiple = false;
  /** Sources in registration (render) order. Reassigned, never mutated. */
  @tracked sources: readonly object[] = [];
  /**
   * Whether a `Region` or an `Aside` has ever claimed this name. Not
   * tracked: it is only read after render, to warn about a typo.
   */
  declared = false;

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

/**
 * Connects `InLayoutRegion` sources, rendered anywhere in the app, to the
 * layout's named regions. Internal to Frontile: use `layout.Region`,
 * `layout.Aside @region` and `InLayoutRegion` instead.
 *
 * Every write is deferred to `afterRender`. Sources register while the
 * render is running, and the layout, which renders before `{{outlet}}`, has
 * usually already read the same tracked state in that render. Writing it
 * synchronously trips Glimmer's backtracking assertion. The deferred write
 * re-renders in the same runloop, so no paint happens in between.
 */
export default class FrontileLayoutRegionsService extends Service {
  #regions = new Map<string, LayoutRegionState>();
  #emptyListeners = new Map<string, Set<() => void>>();
  #warnedUndeclared = new Set<string>();

  #write(fn: () => void): void {
    schedule('afterRender', () => {
      if (!this.isDestroying && !this.isDestroyed) {
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

  /**
   * Marks the name as one a target renders, even while that target has no
   * element (a closed aside). Synchronous, and safe during render.
   */
  declare(name: string): void {
    this.region(name).declared = true;
  }

  /** Sets the element sources render into. Returns the undo function. */
  registerTarget(
    name: string,
    element: Element,
    options: { multiple?: boolean } = {}
  ): () => void {
    const region = this.region(name);
    this.#write(() => {
      // A target that has left the document (the aside moving between its
      // column and its drawer) is being replaced, not duplicated.
      const current = region.target;
      warn(
        `frontile: two targets render the layout region "${name}" at once; sources follow the newest. Region names are global to the app.`,
        !current || current === element || !current.isConnected,
        { id: 'frontile.layout-region.duplicate-target' }
      );
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

  /**
   * Adds a source to the named region. Returns the undo function. The
   * removal is deferred too, so a swap in one render goes 1 → 2 → 1 and the
   * region is never seen empty.
   */
  addSource(name: string, source: object): () => void {
    const region = this.region(name);
    this.#write(() => {
      // Targets declare their name while rendering, so by now every target
      // of this render has. An undeclared name is a typo or a missing
      // `layout.Region`.
      if (!region.declared && !this.#warnedUndeclared.has(name)) {
        this.#warnedUndeclared.add(name);
        warn(
          `frontile: <InLayoutRegion @name="${name}"> rendered, but no layout.Region or layout.Aside @region with the name "${name}" has rendered yet, so its content is not shown. Check the name, or ignore this if that region renders later.`,
          false,
          { id: 'frontile.layout-region.undeclared' }
        );
      }
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
    const set = listeners;
    set.add(listener);
    return () => set.delete(listener);
  }
}

declare module '@ember/service' {
  interface Registry {
    'frontile-layout-regions': FrontileLayoutRegionsService;
  }
}
