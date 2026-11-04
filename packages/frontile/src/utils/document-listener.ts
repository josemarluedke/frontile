/**
 * The global `document`, or `undefined` where there is none (FastBoot, SSR,
 * prerender).
 */
export function globalDocument(): Document | undefined {
  return typeof document === 'undefined' ? undefined : document;
}

/**
 * Adds `listener` to `target` and returns the function that removes it.
 * With no target (no `document` on the server) nothing is registered and
 * the returned function does nothing, so callers need no guard of their own.
 */
export function listen<K extends keyof DocumentEventMap>(
  target: Document | undefined,
  type: K,
  listener: (event: DocumentEventMap[K]) => void
): () => void {
  if (!target) {
    return () => {};
  }
  target.addEventListener(type, listener);
  return () => target.removeEventListener(type, listener);
}
