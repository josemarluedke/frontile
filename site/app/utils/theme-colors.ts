/**
 * Color levels in order for iteration
 */
export const colorLevels = [
  'subtle',
  'muted',
  'soft',
  'DEFAULT',
  'firm',
  'strong',
  'bolder',
] as const;

/**
 * Surface solid levels (0-11)
 */
export const surfaceSolidLevels = [
  0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11,
] as const;

/**
 * Surface overlay levels
 */
export const surfaceOverlayLevels = [
  'subtle',
  'soft',
  'medium',
  'strong',
] as const;

/**
 * Color categories
 */
export const colorCategories = [
  'neutral',
  'primary',
  'accent',
  'success',
  'danger',
  'warning',
] as const;

export type ColorCategory = (typeof colorCategories)[number];
export type ColorLevel = (typeof colorLevels)[number];

/**
 * Get Tailwind class name for surface overlay
 */
export function getSurfaceOverlayClass(level: string): string {
  return `bg-surface-overlay-${level}`;
}

/**
 * Get human-readable description for color level
 */
export function getColorLevelDescription(level: ColorLevel): string {
  const descriptions: Record<ColorLevel, string> = {
    // Surface band — fills for backgrounds and decorative borders
    subtle: 'Surface · faintest fill for hairline backgrounds and tonal rests',
    muted: 'Surface · light fill for hover on tonal surfaces',
    soft: 'Surface · soft fill, the hover step for solid fills',
    DEFAULT: 'Surface · resting fill, the bare bg-{category} token',
    firm: 'Surface · most emphatic fill for pressed and active backgrounds',
    // Ink band — legible foregrounds for text and outlined borders
    strong: 'Ink · default legible foreground for text and outlined borders',
    bolder: 'Ink · highest-emphasis foreground for headings and hover text',
  };
  return descriptions[level];
}

/**
 * Get human-readable name for color category
 */
export function getCategoryDisplayName(category: ColorCategory): string {
  const names: Record<ColorCategory, string> = {
    neutral: 'Neutral',
    primary: 'Primary',
    accent: 'Accent',
    success: 'Success',
    danger: 'Danger',
    warning: 'Warning',
  };
  return names[category];
}

/**
 * Get description for color category
 */
export function getCategoryDescription(category: ColorCategory): string {
  const descriptions: Record<ColorCategory, string> = {
    neutral: 'Default interface colors for text, backgrounds, and borders',
    primary: 'Primary brand colors for important actions and brand elements',
    accent: 'Secondary brand colors for highlights and special features',
    success:
      'Colors for positive states, confirmations, and successful actions',
    danger: 'Colors for errors, warnings, and destructive actions',
    warning: 'Colors for cautions and important notices',
  };
  return descriptions[category];
}
