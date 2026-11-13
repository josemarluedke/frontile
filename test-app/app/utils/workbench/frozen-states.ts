/**
 * Whether the test app can render interaction states without interaction.
 *
 * `app/tw.css` extends Tailwind's `hover`, `active`, `focus` and
 * `focus-within` variants so these attributes force the matching styles:
 *
 * - `data-force-hover` renders `hover:` utilities
 * - `data-force-active` renders `active:` utilities
 * - `data-focus-visible-added` renders `focus:`, `focus-within:` (on an
 *   ancestor) and the theme's `focus-visible:` utilities
 *
 * Workbench pages read this to choose between the frozen state matrix and the
 * fallback. `tests/integration/workbench/frozen-states-test.gts` covers it.
 */
export const FROZEN_STATES_SUPPORTED = true;
