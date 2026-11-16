import { settled } from '@ember/test-helpers';

/**
 * Dispatches a `keydown` with no `key`, like the one Chrome sends when a
 * browser autofill suggestion is picked. That one is a plain `Event`, not a
 * `KeyboardEvent`, so `key` and `code` are `undefined` even though the DOM
 * types promise strings.
 *
 * A listener that throws on it throws past `dispatchEvent`: the browser
 * reports it as an uncaught error, which fails the test.
 */
export async function keylessKeydown(
  target: Element | Document
): Promise<void> {
  target.dispatchEvent(
    new Event('keydown', { bubbles: true, cancelable: true })
  );
  await settled();
}
