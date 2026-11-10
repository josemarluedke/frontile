import { find, focus } from '@ember/test-helpers';

/**
 * Focuses `target` the way a keyboard user would, so it matches
 * `:focus-visible`.
 *
 * Components that open on keyboard focus only (a tooltip's trigger) check
 * `element.matches(':focus-visible')`. A programmatic `focus()` does not
 * reliably match it: Chrome reports no `:focus` at all while the window
 * itself is unfocused, which a CI runner often is, and the heuristic also
 * follows whatever the previous test did with the pointer. Making the
 * element report `:focus-visible` keeps the test about the component.
 */
export async function keyboardFocus(target: string | Element): Promise<void> {
  const element =
    typeof target === 'string' ? (find(target) as Element) : target;
  const matches = element.matches.bind(element);
  element.matches = (selector: string) =>
    selector === ':focus-visible' || matches(selector);
  await focus(element);
}
