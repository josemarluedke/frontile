import { buildWaiter } from '@ember/test-waiters';

type When = 'frame' | 'microtask';

/**
 * A single piece of deferred work that must not outlive a `settled()`.
 *
 * Scheduling something for a later turn and cleaning it up correctly is the
 * same four rules every time: only one pending at a time, hold a test-waiter
 * token so `settled()` waits for it, end that token on the fire path *and* the
 * cancel path, and cancel on teardown. Missing the second half of the third
 * rule hangs the whole test suite, which is why this is worth having once
 * rather than three times.
 */
class DeferredWork {
  #waiter: ReturnType<typeof buildWaiter>;
  #token?: unknown;
  #cancelScheduled?: () => void;

  /** @param label the test-waiter name, which must be unique per instance. */
  constructor(label: string) {
    this.#waiter = buildWaiter(label);
  }

  get isPending(): boolean {
    return this.#token !== undefined;
  }

  /** Queues `run`, unless something is already queued. */
  schedule(run: () => void, when: When = 'frame'): void {
    if (this.#token) {
      return;
    }

    const token = this.#waiter.beginAsync();
    this.#token = token;

    const fire = (): void => {
      // Cancelled, or superseded by a later schedule.
      if (this.#token !== token) {
        return;
      }
      this.#token = undefined;
      this.#cancelScheduled = undefined;
      this.#waiter.endAsync(token);
      run();
    };

    if (when === 'microtask') {
      queueMicrotask(fire);
      return;
    }

    const frame = requestAnimationFrame(fire);
    this.#cancelScheduled = (): void => cancelAnimationFrame(frame);
  }

  /** Drops any pending work and releases its waiter token. */
  cancel(): void {
    this.#cancelScheduled?.();
    this.#cancelScheduled = undefined;

    if (this.#token) {
      this.#waiter.endAsync(this.#token);
      this.#token = undefined;
    }
  }
}

function deferredWork(label: string): DeferredWork {
  return new DeferredWork(label);
}

export { deferredWork };
export type { DeferredWork };
