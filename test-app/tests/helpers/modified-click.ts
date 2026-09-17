import { click } from '@ember/test-helpers';

/**
 * Clicks with a modifier held and reports whether anything called
 * `preventDefault` on the way.
 *
 * This is how you assert that a link still offers "open in a new tab". The
 * listener sits on `document` in the bubble phase, so it runs after any handler
 * the component -- or `LinkTo` -- attached to the element itself, and sees
 * their verdict rather than racing them.
 *
 * It then prevents the default itself, because the elements worth testing this
 * way have real hrefs and the suite should not be opening tabs.
 *
 * @returns whether a handler prevented the click's default action. `false` is
 * the passing case: the browser was left to do its job.
 */
export async function modifiedClickWasPrevented(
  element: Element
): Promise<boolean> {
  let prevented = false;

  const spy = (event: Event): void => {
    prevented = event.defaultPrevented;
    event.preventDefault();
  };

  document.addEventListener('click', spy);

  try {
    await click(element, { metaKey: true });
  } finally {
    document.removeEventListener('click', spy);
  }

  return prevented;
}
