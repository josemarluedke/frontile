/**
 * The attributes the drawer's own parts carry so the drag gesture can find
 * them, and the selectors it looks them up by.
 *
 * `dragToDismiss` is a generic modifier: it knows nothing about drawers and
 * takes opaque selector strings. That leaves the emitting element and the
 * consuming selector in different files with nothing tying them together, so
 * renaming an attribute breaks the gesture silently — no type error, and the
 * only symptom is a drag that no longer starts. Both sides read from here
 * instead, and `drawer-selectors-test` asserts the rendered markup still
 * matches, since a template cannot bind an attribute's *name*.
 *
 * @internal
 */

/** Marks the drawer's scrollable body. */
export const DRAWER_BODY_ATTRIBUTE = 'data-drawer-body';

/** Marks the drawer's grab handle. */
export const DRAWER_DRAG_HANDLE_ATTRIBUTE = 'data-drawer-drag-handle';

/** Passed to `dragToDismiss` as `scrollSelector`. */
export const DRAWER_BODY_SELECTOR = `[${DRAWER_BODY_ATTRIBUTE}]`;

/** Passed to `dragToDismiss` as `handleSelector`. */
export const DRAWER_DRAG_HANDLE_SELECTOR = `[${DRAWER_DRAG_HANDLE_ATTRIBUTE}]`;
