/**
 * What a `NavFolder` reads from each of its items. Both are getters, so the
 * folder always sees an item's current state, router-derived active included.
 */
export interface NavItemHandle {
  readonly isActive: boolean;
  readonly isHidden: boolean;
}

/**
 * The part of a `NavFolder` its items talk to. An item registers itself when
 * it is created and calls the returned function when it is destroyed.
 */
export interface NavFolderContext {
  registerItem(item: NavItemHandle): () => void;
}
