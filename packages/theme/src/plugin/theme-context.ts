const THEMED = ':is(.light, .dark, .theme-inverse)';

// Four themed ancestors: past the depth the enumeration below resolves.
const DEPTH_GUARD = `${THEMED} ${THEMED} ${THEMED} ${THEMED} *`;

// The ancestor chains under which the nearest themed ancestor resolves dark.
// Kept in step with the `dark` custom variant in `index.css` -- see the
// comment there for how the enumeration works and why it stops at 3.
const DARK_CHAINS = [
  `:is(.dark *):not(${THEMED} ${THEMED} *)`,
  `:is(${THEMED} .dark *, .light .theme-inverse *):not(${THEMED} ${THEMED} ${THEMED} *)`,
  `${THEMED} ${THEMED} .dark *`,
  `${THEMED} .light .theme-inverse *`,
  '.dark .theme-inverse .theme-inverse *'
].join(', ');

/**
 * Rewrite a `.dark <selector>` component rule so it resolves from the
 * nearest themed ancestor, like the `dark:` variant, instead of matching any
 * `.dark` ancestor (which leaks into a nested `.light`).
 *
 * Specificity matches the `.dark <selector>` it replaces: the leading
 * `:is(...)` counts the one class `.dark` did, and the theme conditions sit
 * in `:where()`. The leading `:is(...)` is always satisfied when the
 * conditions are, since each of them requires a themed ancestor.
 *
 * Accepts a comma-separated selector list and rewrites each entry.
 */
function inDarkContext(selector: string): string {
  return selector
    .split(',')
    .map(
      (s) =>
        `${THEMED} ${s.trim()}:where(:not(${DEPTH_GUARD})):where(${DARK_CHAINS})`
    )
    .join(', ');
}

export { inDarkContext };
