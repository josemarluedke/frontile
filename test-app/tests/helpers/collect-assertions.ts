import { getDebugFunction, setDebugFunction } from '@ember/debug';

/**
 * Run `callback` with Ember's `assert` recording failed assertions instead of
 * throwing them, and return their messages.
 *
 * Use this to test a component's development assertion. Letting the assertion
 * throw during `render` -- even with `setupOnerror` catching it -- leaves
 * Ember's renderer re-running the failed root on every later run loop, for
 * the rest of the run ("Attempted to rerender, but the Ember application has
 * had an unrecoverable error"). With the assertion recorded, the render
 * completes normally and nothing is left behind.
 *
 * ```ts
 * const failed = await collectAssertions(() =>
 *   render(<template><Autocomplete @displayLimit={{1.5}} /></template>)
 * );
 * assert.true(failed.some((m) => m.includes('@displayLimit must be')));
 * ```
 */
export async function collectAssertions(
  callback: () => unknown
): Promise<string[]> {
  const original = getDebugFunction('assert');
  const failed: string[] = [];
  // Deliberately returns instead of throwing, which `assert`'s
  // `asserts condition` / `never` signature cannot express.
  const record = ((message: string, test?: unknown) => {
    if (!test) {
      failed.push(message);
    }
  }) as unknown as typeof original;
  setDebugFunction('assert', record);
  try {
    await callback();
  } finally {
    setDebugFunction('assert', original);
  }
  return failed;
}
