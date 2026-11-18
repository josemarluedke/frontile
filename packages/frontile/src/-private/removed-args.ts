import { assert } from '@ember/debug';

/**
 * Fail in development when a consumer still passes an argument that was
 * removed in 0.19.0.
 *
 * An explicitly `undefined` value does not fail: a parent that forwards
 * `@x={{@x}}` passes the name even when the caller never wrote it.
 *
 * `assert` is stripped from production builds, so this costs nearly nothing
 * there: the call, the message string and an `in` check remain unless the
 * consumer's build strips `assert`.
 * Call it once per instance (e.g. from the constructor), not from a getter
 * that re-runs.
 */
export function assertRemovedArg(
  component: string,
  args: object,
  from: string,
  to: string
): void {
  assert(
    `${component}: @${from} was removed in 0.19.0. Use @${to}.`,
    !(from in args) || (args as Record<string, unknown>)[from] === undefined
  );
}
