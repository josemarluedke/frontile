import { parse, wcagContrast } from 'culori';
import { black, white } from './palette-absolute';

function swapColorValues<T extends Record<string, unknown>>(
  colors: T
): Record<string, unknown> {
  const swappedColors: Record<string, unknown> = {};
  const keys = Object.keys(colors);
  const length = keys.length;

  for (let i = 0; i < length / 2; i++) {
    const key1 = keys[i] as string;
    const key2 = keys[length - 1 - i] as string;

    swappedColors[key1] = colors[key2];
    swappedColors[key2] = colors[key1];
  }
  if (length % 2 !== 0) {
    const middleKey = keys[Math.floor(length / 2)] as string;

    swappedColors[middleKey] = colors[middleKey];
  }

  return swappedColors;
}

// Pre-parse absolute colors once (these are known-valid hex colors)
const parsedBlack = parse(black);
const parsedWhite = parse(white);

/**
 * Get optimal contrasting color (black or white) for text on a given background.
 * Uses WCAG contrast ratios to determine which provides better readability.
 */
function getContrastingColor(backgroundColor: string): string {
  const bgColor = parse(backgroundColor);
  if (!bgColor || !parsedBlack || !parsedWhite) {
    console.warn(
      `Failed to parse color: ${backgroundColor}, defaulting to white`
    );
    return white;
  }

  const contrastWithBlack = wcagContrast(bgColor, parsedBlack);
  const contrastWithWhite = wcagContrast(bgColor, parsedWhite);

  return contrastWithBlack > contrastWithWhite ? black : white;
}

export { swapColorValues, getContrastingColor };
