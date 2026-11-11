type Listener = () => void;

const listeners = new Set<Listener>();
let observer: MutationObserver | null = null;

/**
 * Subscribe to class changes on `<html>` (the theme switcher toggles
 * `.light` / `.dark` there). All subscribers share one MutationObserver, which
 * exists only while at least one subscriber does. Returns an unsubscribe.
 */
export function subscribe(cb: Listener): () => void {
  // Wrap so subscribing the same function twice stays two subscriptions.
  const listener: Listener = () => cb();
  listeners.add(listener);

  if (!observer) {
    observer = new MutationObserver(() => {
      for (const l of Array.from(listeners)) {
        l();
      }
    });
    observer.observe(document.documentElement, {
      attributes: true,
      attributeFilter: ['class']
    });
  }

  return () => {
    listeners.delete(listener);
    if (listeners.size === 0 && observer) {
      observer.disconnect();
      observer = null;
    }
  };
}
