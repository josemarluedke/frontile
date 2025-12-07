/**
 * WCAG Contrast Calculation Utilities
 *
 * Provides functions to calculate color contrast ratios according to WCAG 2.1 standards
 * and determine optimal contrasting colors (black or white) for text on colored backgrounds.
 */

import Color from 'color';
import * as absolute from './palette-absolute';

/**
 * Calculate relative luminance according to WCAG 2.1 formula
 *
 * @see https://www.w3.org/TR/WCAG21/#dfn-relative-luminance
 * @param color - Color string in any format supported by the Color library
 * @returns Relative luminance value between 0 and 1
 */
export function getRelativeLuminance(color: string): number {
  const c = Color(color);
  const rgb = c.rgb().array();
  const [r = 0, g = 0, b = 0] = rgb.map((channel) => {
    const normalized = channel / 255;
    return normalized <= 0.03928
      ? normalized / 12.92
      : Math.pow((normalized + 0.055) / 1.055, 2.4);
  });

  return 0.2126 * r + 0.7152 * g + 0.0722 * b;
}

/**
 * Calculate contrast ratio between two colors according to WCAG 2.1
 *
 * @see https://www.w3.org/TR/WCAG21/#dfn-contrast-ratio
 * @param foreground - Foreground color (typically text)
 * @param background - Background color
 * @returns Contrast ratio between 1:1 and 21:1
 */
export function getContrastRatio(
  foreground: string,
  background: string
): number {
  const l1 = getRelativeLuminance(foreground);
  const l2 = getRelativeLuminance(background);
  const lighter = Math.max(l1, l2);
  const darker = Math.min(l1, l2);

  return (lighter + 0.05) / (darker + 0.05);
}

/**
 * Blend a semi-transparent color with a background color
 * Uses alpha compositing formula
 *
 * @param foreground - Semi-transparent color
 * @param background - Background color (assumed opaque)
 * @returns Blended opaque color
 */
function blendWithBackground(foreground: Color, background: Color): Color {
  const alpha = foreground.alpha();

  if (alpha >= 1) {
    return foreground;
  }

  const fg = foreground.rgb();
  const bg = background.rgb();

  return Color.rgb(
    fg.red() * alpha + bg.red() * (1 - alpha),
    fg.green() * alpha + bg.green() * (1 - alpha),
    fg.blue() * alpha + bg.blue() * (1 - alpha)
  );
}

/**
 * Get optimal contrasting color (black or white) for text on a given background
 *
 * @param backgroundColor - Background color to calculate contrast for
 * @param options - Configuration options
 * @param options.themeBackground - Theme background color for blending transparent colors (default: white)
 * @param options.darkColor - Dark color to use for contrast (default: absolute black)
 * @param options.lightColor - Light color to use for contrast (default: absolute white)
 * @param options.threshold - Minimum contrast ratio threshold (default: 4.5 for WCAG AA)
 * @returns Contrasting color (black or white)
 */
export function getContrastingColor(
  backgroundColor: string,
  options: {
    themeBackground?: string;
    darkColor?: string;
    lightColor?: string;
    threshold?: number;
  } = {}
): string {
  const {
    themeBackground = absolute.white,
    darkColor = absolute.black,
    lightColor = absolute.white,
    threshold = 4.5
  } = options;

  try {
    let bgColor = Color(backgroundColor);

    // If color has transparency, blend it with the theme background
    if (bgColor.alpha() < 1) {
      const themeBg = Color(themeBackground);
      bgColor = blendWithBackground(bgColor, themeBg);
    }

    // Calculate contrast ratios with both black and white
    const contrastWithBlack = getContrastRatio(darkColor, bgColor.hex());
    const contrastWithWhite = getContrastRatio(lightColor, bgColor.hex());

    // Choose the color with better contrast
    // If both meet the threshold, prefer black for accessibility (better for dyslexia)
    if (
      contrastWithBlack >= threshold &&
      contrastWithBlack >= contrastWithWhite
    ) {
      return darkColor;
    }

    return lightColor;
  } catch (error) {
    // If color parsing fails, default to white (safe fallback)
    console.warn(
      `Failed to calculate contrast for color: ${backgroundColor}`,
      error
    );
    return lightColor;
  }
}
