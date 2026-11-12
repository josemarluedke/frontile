/**
 * Whether a `keydown` carries a key at all.
 *
 * The DOM types promise `KeyboardEvent.key` is always a string, but Chrome
 * also dispatches `keydown` as a plain `Event`, with no `key` or `code`, when
 * a browser autofill suggestion is picked. A handler that reads `event.key`
 * as a string (`toUpperCase()`, `length`) throws on it, so it checks this
 * first. A `keydown` without a key names nothing to act on.
 */
export function hasKey(event: KeyboardEvent): boolean {
  return typeof event.key === 'string';
}
