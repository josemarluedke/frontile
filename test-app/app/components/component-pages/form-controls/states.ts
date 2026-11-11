import {
  FORM_STATES,
  type WorkbenchState
} from 'test-app/components/workbench/state-matrix';

/**
 * The one row each form-control matrix shows. The row value binds straight to
 * the control's size; the Sizes section covers the others.
 */
export const STATE_ROWS = ['md'] as const;

/** Every form column, for controls that take `readonly`. */
export const ALL_FORM_STATES = FORM_STATES;

/** For controls with no read-only mode (checkbox, radio, switch, selects). */
export const FORM_STATES_NO_READONLY: readonly WorkbenchState[] =
  FORM_STATES.filter((state) => state !== 'readonly');

/**
 * For InputOTP. Its focus ring comes from component state set by a real
 * `focus` event (`isFocused` → the active cell), not from a CSS `:focus`
 * selector, so no attribute can force it: the focus columns are left out
 * rather than shown unfocused.
 */
export const FORM_STATES_NO_FOCUS: readonly WorkbenchState[] =
  FORM_STATES.filter((state) => state !== 'focus' && state !== 'invalid-focus');

export const SELECT_ITEMS = ['Apple', 'Banana', 'Cherry'];

/**
 * For Switch. Its track rings through the theme's `focusVisibleWithinRing`,
 * which mixes `has-focus-visible:` (width, offset: matches the force
 * attribute) with `has-[:focus-visible]:` (the `ring-focus` colour: matches
 * only real `:focus-visible`). Forced, the ring is drawn in the wrong colour,
 * so the focus columns are left out rather than shown misleadingly.
 */
export const FORM_STATES_NO_READONLY_NO_FOCUS: readonly WorkbenchState[] =
  FORM_STATES_NO_FOCUS.filter((state) => state !== 'readonly');
