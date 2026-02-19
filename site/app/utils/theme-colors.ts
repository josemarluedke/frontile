/**
 * Color levels in order for iteration
 */
export const colorLevels = [
  'subtle',
  'muted',
  'soft',
  'medium',
  'firm',
  'strong',
  'bolder',
  'boldest',
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
  'brand',
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
export function getSurfaceOverlayClass(
  level: string,
  inverse: boolean = false
): string {
  const prefix = inverse ? 'bg-surface-overlay-inverse' : 'bg-surface-overlay';
  return `${prefix}-${level}`;
}

/**
 * Get human-readable description for color level
 */
export function getColorLevelDescription(level: ColorLevel): string {
  const descriptions: Record<ColorLevel, string> = {
    subtle: 'Subtle color for minimal emphasis and backgrounds',
    muted: 'Muted color for subdued elements and hover states',
    soft: 'Soft color for moderate emphasis and secondary elements',
    medium: 'Medium color for standard emphasis and interactive elements',
    firm: 'Firm color for increased emphasis and active states',
    strong: 'Strong color for maximum emphasis and primary elements',
    bolder: 'Bolder color for high contrast and important elements',
    boldest: 'Boldest color for maximum contrast and critical elements',
  };
  return descriptions[level];
}

/**
 * Get human-readable name for color category
 */
export function getCategoryDisplayName(category: ColorCategory): string {
  const names: Record<ColorCategory, string> = {
    neutral: 'Neutral',
    brand: 'Brand',
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
    brand: 'Primary brand colors for important actions and brand elements',
    accent: 'Secondary brand colors for highlights and special features',
    success:
      'Colors for positive states, confirmations, and successful actions',
    danger: 'Colors for errors, warnings, and destructive actions',
    warning: 'Colors for cautions and important notices',
  };
  return descriptions[category];
}
