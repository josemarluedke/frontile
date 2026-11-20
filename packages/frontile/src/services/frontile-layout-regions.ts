import Service from '@ember/service';
import { tracked } from '@glimmer/tracking';
import { schedule } from '@ember/runloop';
import { warn } from '@ember/debug';

/** A mounted target: the element sources render into, and how. */
interface RegionTarget {
  readonly element: Element;
  /** Whether every source renders (`true`) or only the newest. */
  readonly multiple: boolean;
}

/** One named region: where it renders (the target) and who fills it. */
export class LayoutRegionState {
  /**
   * Mounted targets in registration order. The newest is the one sources
   * render into; when it goes away, the previous one takes over again.
   * Reassigned, never mutated.
   */
  @tracked targets: readonly RegionTarget[] = [];
  /** Sources in registration (render) order. Reassigned, never mutated. */
  @tracked sources: readonly object[] = [];
  get hasContent(): boolean {
    return this.sources.length > 0;
  }

  /** The target sources render into: the newest mounted one. */
  get target(): RegionTarget | undefined {
    return this.targets[this.targets.length - 1];
  }

  /** Where `source` should render, or `null` when it is not shown. */
  targetFor(source: object): Element | null {
    const target = this.target;
    if (!target) {
      return null;
    }
    const shown = target.multiple
      ? this.sources.includes(source)
      : this.sources[this.sources.length - 1] === source;
    return shown ? target.element : null;
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

  /** Where `source` renders in the named region, or `null` (tracked). */
  targetFor(name: string, source: object): Element | null {
    return this.region(name).targetFor(source);
  }

  /**
   * Adds an element sources render into. The newest target wins; removing
   * it hands the sources back to the previous one. Returns the undo
   * function, which removes only this registration.
   */
  registerTarget(
    name: string,
    element: Element,
    options: { multiple?: boolean } = {}
  ): () => void {
    const region = this.region(name);
    const target: RegionTarget = {
      element,
      multiple: options.multiple ?? false
    };
    this.#write(() => {
      // A target that has left the document (the aside moving between its
      // column and its drawer) is being replaced, not duplicated.
      warn(
        `frontile: two targets render the layout region "${name}" at once; sources follow the newest. Region names are global to the app.`,
        !region.targets.some(
          (other) => other.element !== element && other.element.isConnected
        ),
        { id: 'frontile.layout-region.duplicate-target' }
      );
      region.targets = [...region.targets, target];
    });
    return () =>
      this.#write(() => {
        region.targets = region.targets.filter((t) => t !== target);
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
