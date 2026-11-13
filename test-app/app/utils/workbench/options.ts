/**
 * Option lists the workbench pages iterate over, typed against each
 * component's own signature. `satisfies` makes Glint fail when a value is
 * renamed or removed from the API; a new value still has to be added here by
 * hand. Deprecated names (`@intent`, `@appearance` values, CloseButton's
 * `transparent`/`subtle`) are left out on purpose.
 */
import type {
  AlertSignature,
  ButtonGroupSignature,
  ButtonSignature,
  CheckboxGroupSignature,
  CheckboxSignature,
  ChipSignature,
  CloseButtonSignature,
  FormDescriptionSignature,
  FormFeedbackSignature,
  InputOtpSignature,
  InputSignature,
  LabelSignature,
  NativeSelectSignature,
  ProgressBarSignature,
  RadioGroupSignature,
  RadioSignature,
  SegmentedControlSignature,
  SelectSignature,
  SwitchSignature,
  TextareaSignature,
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

// Form controls ------------------------------------------------------------

/** Every form control takes the same three sizes. */
const FORM_SIZES = ['sm', 'md', 'lg'] as const;

export const INPUT_SIZES = FORM_SIZES satisfies ArgValues<
  InputSignature['Args']['size']
>;

export const TEXTAREA_SIZES = FORM_SIZES satisfies ArgValues<
  TextareaSignature['Args']['size']
>;

/** Select sizes its field with `@inputSize`; `@size` is the popover's. */
export const SELECT_SIZES = FORM_SIZES satisfies ArgValues<
  SelectSignature<unknown>['Args']['inputSize']
>;

export const NATIVE_SELECT_SIZES = FORM_SIZES satisfies ArgValues<
  NativeSelectSignature<unknown>['Args']['size']
>;

export const CHECKBOX_SIZES = FORM_SIZES satisfies ArgValues<
  CheckboxSignature['Args']['size']
>;

export const CHECKBOX_GROUP_SIZES = FORM_SIZES satisfies ArgValues<
  CheckboxGroupSignature['Args']['size']
>;

export const RADIO_SIZES = FORM_SIZES satisfies ArgValues<
  RadioSignature<string>['Args']['size']
>;

export const RADIO_GROUP_SIZES = FORM_SIZES satisfies ArgValues<
  RadioGroupSignature<string>['Args']['size']
>;

export const SWITCH_SIZES = FORM_SIZES satisfies ArgValues<
  SwitchSignature['Args']['size']
>;

export const INPUT_OTP_SIZES = FORM_SIZES satisfies ArgValues<
  InputOtpSignature['Args']['size']
>;

export const LABEL_SIZES = FORM_SIZES satisfies ArgValues<
  LabelSignature['Args']['size']
>;

export const FORM_DESCRIPTION_SIZES = FORM_SIZES satisfies ArgValues<
  FormDescriptionSignature['Args']['size']
>;

export const FORM_FEEDBACK_SIZES = FORM_SIZES satisfies ArgValues<
  FormFeedbackSignature['Args']['size']
>;

export const FORM_FEEDBACK_STATUSES = [
  'danger',
  'warning',
  'success',
  'primary',
  'secondary',
  'tertiary'
] as const satisfies ArgValues<FormFeedbackSignature['Args']['status']>;

// Alert ------------------------------------------------------------------

/** Alert takes `@status`, not `@color`: the value also picks the ARIA role. */
export const ALERT_STATUSES = [
  'neutral',
  'primary',
  'success',
  'warning',
  'danger'
] as const satisfies ArgValues<AlertSignature['Args']['status']>;

export const ALERT_VARIANTS = [
  'surface',
  'soft',
  'solid'
] as const satisfies ArgValues<AlertSignature['Args']['variant']>;

export const ALERT_LAYOUTS = ['inline', 'banner'] as const satisfies ArgValues<
  AlertSignature['Args']['layout']
>;

// ProgressBar ------------------------------------------------------------

export const PROGRESS_BAR_SIZES = [
  'xs',
  'sm',
  'md',
  'lg'
] as const satisfies ArgValues<ProgressBarSignature['Args']['size']>;

export const PROGRESS_BAR_COLORS = [
  'neutral',
  'primary',
  'secondary',
  'tertiary',
  'success',
  'warning',
  'danger'
] as const satisfies ArgValues<ProgressBarSignature['Args']['color']>;

export const PROGRESS_BAR_RADII = [
  'none',
  'sm',
  'lg',
  'full'
] as const satisfies ArgValues<ProgressBarSignature['Args']['radius']>;

/** The three positions that matter: empty, partway, full. */
export const PROGRESS_BAR_VALUES = [0, 50, 100] as const;
