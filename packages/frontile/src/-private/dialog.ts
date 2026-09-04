import { warn } from '@ember/debug';

/**
 * Warns when a dialog ends up with no accessible name at all — no registered
 * `Header`, and no `aria-label`/`aria-labelledby` of the consumer's own.
 * Assistive technology announces such a dialog as just "dialog", and nothing
 * else surfaces the mistake at runtime.
 *
 * Consumer-supplied names arrive through `...attributes`, which the component
 * cannot see in its args, so this inspects the rendered element for them. A
 * heading merely carrying `headerId` deliberately does *not* count: nothing
 * points `aria-labelledby` at it, so the dialog really is unnamed, and that is
 * the case most worth surfacing.
 *
 * `warn` is stripped from production builds, so this costs consumers nothing.
 */
export function warnIfDialogHasNoAccessibleName(
  element: Element,
  hasRegisteredHeader: boolean,
  component: 'modal' | 'drawer'
): void {
  const hasName =
    hasRegisteredHeader ||
    !!element.getAttribute('aria-label') ||
    !!element.getAttribute('aria-labelledby');

  const name = component === 'modal' ? 'Modal' : 'Drawer';
  const block = component === 'modal' ? 'm' : 'd';

  warn(
    `<${name}> has no accessible name: assistive technology will announce it ` +
      `as just "dialog". Render the yielded <${block}.Header>, or pass your ` +
      `own aria-label or aria-labelledby to <${name}>. Putting the yielded ` +
      `headerId on a heading of your own is not enough on its own — pass ` +
      `aria-labelledby={{${block}.headerId}} alongside it.`,
    hasName,
    { id: `frontile.${component}.missing-accessible-name` }
  );
}
