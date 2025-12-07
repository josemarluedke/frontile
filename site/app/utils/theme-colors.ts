/**
 * Color levels in order for iteration
 */
export const colorLevels = ['subtle', 'soft', 'medium', 'strong'] as const;

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
  'success',
  'danger',
  'warning',
  'inverse',
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
    soft: 'Soft color for moderate emphasis and secondary elements',
    medium: 'Medium color for standard emphasis and interactive elements',
    strong: 'Strong color for maximum emphasis and primary elements',
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
    success: 'Success',
    danger: 'Danger',
    warning: 'Warning',
    inverse: 'Inverse',
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
    success:
      'Colors for positive states, confirmations, and successful actions',
    danger: 'Colors for errors, warnings, and destructive actions',
    warning: 'Colors for cautions and important notices',
    inverse: 'High-contrast colors for overlays and backdrops',
  };
  return descriptions[category];
}
