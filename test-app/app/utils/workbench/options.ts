/**
 * Option lists the workbench pages iterate over, typed against each
 * component's own signature. `satisfies` makes Glint fail when a value is
 * renamed or removed from the API; a new value still has to be added here by
 * hand. Deprecated names (`@intent`, `@appearance` values, CloseButton's
 * `transparent`/`subtle`) are left out on purpose.
 */
import type {
  ButtonGroupSignature,
  ButtonSignature,
  ChipSignature,
  CloseButtonSignature,
  SegmentedControlSignature,
  ToggleButtonSignature
} from 'frontile';

type ArgValues<T> = readonly NonNullable<T>[];

// Button ---------------------------------------------------------------

/** `custom` is left out: it renders no theme classes. */
export const BUTTON_VARIANTS = [
  'solid',
  'soft',
  'subtle',
  'outline',
  'ghost',
  'plain'
] as const satisfies ArgValues<ButtonSignature['Args']['variant']>;

export const BUTTON_COLORS = [
  'neutral',
  'primary',
  'secondary',
  'tertiary',
  'success',
  'warning',
  'danger'
] as const satisfies ArgValues<ButtonSignature['Args']['color']>;

export const BUTTON_SIZES = [
  'xs',
  'sm',
  'md',
  'lg',
  'xl',
  '2xl'
] as const satisfies ArgValues<ButtonSignature['Args']['size']>;

// ButtonGroup ------------------------------------------------------------

export const BUTTON_GROUP_VARIANTS = BUTTON_VARIANTS satisfies ArgValues<
  ButtonGroupSignature['Args']['variant']
>;

export const BUTTON_GROUP_SIZES = BUTTON_SIZES satisfies ArgValues<
  ButtonGroupSignature['Args']['size']
>;

// ToggleButton -----------------------------------------------------------

/** ToggleButton's theme styles only `outline`, so the page varies color. */
export const TOGGLE_BUTTON_COLORS = BUTTON_COLORS satisfies ArgValues<
  ToggleButtonSignature['Args']['color']
>;

export const TOGGLE_BUTTON_SIZES = BUTTON_SIZES satisfies ArgValues<
  ToggleButtonSignature['Args']['size']
>;

// Chip -------------------------------------------------------------------

export const CHIP_VARIANTS = [
  'solid',
  'outline',
  'soft'
] as const satisfies ArgValues<ChipSignature['Args']['variant']>;

export const CHIP_COLORS = [
  'neutral',
  'primary',
  'secondary',
  'tertiary',
  'success',
  'warning',
  'danger'
] as const satisfies ArgValues<ChipSignature['Args']['color']>;

export const CHIP_SIZES = ['xs', 'sm', 'md', 'lg'] as const satisfies ArgValues<
  ChipSignature['Args']['size']
>;

// CloseButton ------------------------------------------------------------

export const CLOSE_BUTTON_VARIANTS = [
  'ghost',
  'soft'
] as const satisfies ArgValues<CloseButtonSignature['Args']['variant']>;

export const CLOSE_BUTTON_SIZES = [
  'xs',
  'sm',
  'md',
  'lg',
  'xl'
] as const satisfies ArgValues<CloseButtonSignature['Args']['size']>;

// SegmentedControl -------------------------------------------------------

type SegmentedControlArgs = SegmentedControlSignature<unknown>['Args'];

export const SEGMENTED_CONTROL_VARIANTS = [
  'solid',
  'ghost'
] as const satisfies ArgValues<SegmentedControlArgs['variant']>;

export const SEGMENTED_CONTROL_COLORS = [
  'neutral',
  'primary',
  'secondary',
  'tertiary',
  'success',
  'warning',
  'danger'
] as const satisfies ArgValues<SegmentedControlArgs['color']>;

export const SEGMENTED_CONTROL_SIZES = [
  'sm',
  'md',
  'lg'
] as const satisfies ArgValues<SegmentedControlArgs['size']>;
