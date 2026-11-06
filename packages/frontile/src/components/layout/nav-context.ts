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
