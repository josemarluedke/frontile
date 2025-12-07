/**
 * WCAG Contrast Calculation Utilities
 *
 * Provides functions to determine optimal contrasting colors (black or white)
 * for text on colored backgrounds using WCAG 2.1 standards.
 */

import Color from 'color';
import * as absolute from './palette-absolute';

/**
 * Get optimal contrasting color (black or white) for text on a given background
 *
 * Uses the Color package's built-in WCAG contrast calculation to determine
 * which color (black or white) provides better contrast on the given background.
 *
 * @param backgroundColor - Background color to calculate contrast for
 * @returns Contrasting color (black or white)
 */
export function getContrastingColor(backgroundColor: string): string {
  try {
    const bgColor = Color(backgroundColor);
    const black = Color(absolute.black);
    const white = Color(absolute.white);

    // Calculate contrast ratios using Color package's built-in WCAG method
    const contrastWithBlack = bgColor.contrast(black);
    const contrastWithWhite = bgColor.contrast(white);

    // Return the color with better contrast
    return contrastWithBlack > contrastWithWhite ? absolute.black : absolute.white;
  } catch (error) {
    // If color parsing fails, default to white (safe fallback)
    console.warn(`Failed to calculate contrast for color: ${backgroundColor}`, error);
    return absolute.white;
  }
}
