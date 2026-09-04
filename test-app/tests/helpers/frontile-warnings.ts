import { registerWarnHandler } from '@ember/debug';

interface WarnOptions {
  id?: string;
}

/**
 * `registerWarnHandler` is install-only — Ember offers no way to remove a
 * handler, and each call stacks a new one whose `next` is the previous one.
 * A handler installed per test therefore lives for the rest of the suite, and
 * one that swallows warnings without calling `next` keeps swallowing them long
 * after the test that wanted them has finished.
 *
 * So these helpers install exactly one handler pair, once, and open and close a
 * capture *window* around each callback instead. Outside a window both handlers
 * are pure pass-throughs, which is what keeps unrelated tests able to surface
 * a genuine Frontile warning.
 */

// Set only while `captureFrontileWarnings` is awaiting its callback.
let captured: string[] | null = null;
// Set only while `observeWarningsBelowCapture` is awaiting its callback.
let observed: string[] | null = null;
let installed = false;

function frontileId(options: unknown): string | undefined {
  const id = (options as WarnOptions | undefined)?.id;
  return id?.startsWith('frontile.') ? id : undefined;
}

function install(): void {
  if (installed) {
    return;
  }
  installed = true;

  // Installed first, so it sits *below* the capture handler in the chain and
  // only sees warnings the capture window let through.
  registerWarnHandler((message, options, next) => {
    const id = frontileId(options);

    if (observed && id) {
      observed.push(id);
      return;
    }

    next(message, options);
  });

  // Installed second, so it runs first and can swallow the expected warnings
  // of a test that opted in.
  registerWarnHandler((message, options, next) => {
    const id = frontileId(options);

    if (captured && id) {
      captured.push(id);
      return;
    }

    next(message, options);
  });
}

/**
 * Captures the ids of Frontile warnings raised while `callback` runs, instead of
 * letting them print. Tests that deliberately render a dialog with no
 * accessible name use this so the expected warning is asserted rather than
 * spamming every run's output.
 *
 * The capture window closes when `callback` settles, so warnings raised
 * afterwards travel down the handler chain as usual.
 */
export async function captureFrontileWarnings(
  callback: () => Promise<void>
): Promise<string[]> {
  install();

  const ids: string[] = [];
  captured = ids;

  try {
    await callback();
  } finally {
    captured = null;
  }

  return ids;
}

/**
 * Records the Frontile warnings that reach the handler *below* the capture
 * window. Only used to prove that a closed capture window really does let
 * warnings through — a capture handler left armed would starve this one.
 */
export async function observeWarningsBelowCapture(
  callback: () => Promise<void>
): Promise<string[]> {
  install();

  const ids: string[] = [];
  observed = ids;

  try {
    await callback();
  } finally {
    observed = null;
  }

  return ids;
}
