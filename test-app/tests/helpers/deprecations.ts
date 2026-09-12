import { registerDeprecationHandler } from '@ember/debug';

/**
 * Collect the ids of deprecations raised from this point on, in order.
 *
 * Call inside the test body, before rendering. Handlers registered this way
 * live for the lifetime of the app instance, which `setupRenderingTest` tears
 * down per test — so the array never leaks into a neighbouring test.
 */
export function trackDeprecations(): { ids: string[] } {
  const ids: string[] = [];

  registerDeprecationHandler((message, options, next) => {
    if (options?.id) {
      ids.push(options.id);
    }

    next(message, options);
  });

  return { ids };
}
