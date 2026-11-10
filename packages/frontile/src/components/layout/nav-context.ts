import { cached, tracked } from '@glimmer/tracking';
import { schedule } from '@ember/runloop';
import { isDestroyed, isDestroying } from '@ember/destroyable';

/**
 * What a `NavFolder` (or a `BottomNav.More`) reads from each of its items.
 * All are getters, so the container always sees an item's current state,
 * router-derived active included. A folder registered with a parent reports
 * the same three for its children.
 */
export interface NavItemHandle {
  readonly isActive: boolean;
  readonly isHidden: boolean;
  /** Whether a badge is shown: never for a hidden item. */
  readonly hasBadge: boolean;
}

/**
 * The part of a `NavFolder` its items talk to. An item registers itself when
 * it is created and calls the returned function when it is destroyed.
 * `BottomNav.More` implements it too, for the items and folders in its sheet.
 */
export interface NavFolderContext {
  registerItem(item: NavItemHandle): () => void;
}

/**
 * The items registered with a `NavFolder` or a `BottomNav.More`, and what
 * the container derives from them.
 *
 * Items register while they render, so the set is not tracked: reading it
 * during render and then changing it in the same render would trip
 * Glimmer's backtracking assertion. `version` is bumped after render
 * instead, once per batch, which re-runs everything that reads it.
 */
export class NavItemRegistry {
  #owner: object;
  #items = new Set<NavItemHandle>();
  #bumpScheduled = false;
  @tracked version = 0;

  /** `owner` is the container; nothing is bumped once it is destroyed. */
  constructor(owner: object) {
    this.#owner = owner;
  }

  #bump(): void {
    if (this.#bumpScheduled) {
      return;
    }
    this.#bumpScheduled = true;
    schedule('afterRender', () => {
      this.#bumpScheduled = false;
      if (!isDestroying(this.#owner) && !isDestroyed(this.#owner)) {
        this.version++;
      }
    });
  }

  registerItem = (item: NavItemHandle): (() => void) => {
    this.#items.add(item);
    this.#bump();
    return () => {
      this.#items.delete(item);
      this.#bump();
    };
  };

  /** What the container's items register with. */
  readonly context: NavFolderContext = { registerItem: this.registerItem };

  get items(): NavItemHandle[] {
    // Consumed so the getters below re-run when items come or go. Each
    // handle's own state is a live read.
    void this.version;
    return [...this.#items];
  }

  @cached
  get visibleItems(): NavItemHandle[] {
    return this.items.filter((item) => !item.isHidden);
  }

  /** A hidden item never makes the container active. */
  @cached
  get hasActive(): boolean {
    return this.visibleItems.some((item) => item.isActive);
  }

  /** A hidden item never badges the container. */
  @cached
  get hasBadge(): boolean {
    return this.visibleItems.some((item) => item.hasBadge);
  }
}
