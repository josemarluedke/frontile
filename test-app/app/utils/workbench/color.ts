/**
 * Color math for workbench swatches.
 *
 * Computed colors come back in whatever syntax the token was authored in
 * (`oklch(…)`, `color(srgb …)`, `rgb(… / a)`), so `parseColor` lets the
 * browser do the conversion: it paints the color onto a 1×1 canvas and reads
 * the pixel back as 8-bit sRGB.
 */

/** 0–255 channels; `a` is 0–1. */
export type RGBA = { r: number; g: number; b: number; a: number };

let context: CanvasRenderingContext2D | null = null;

function canvasContext(): CanvasRenderingContext2D {
  if (!context) {
    const canvas = document.createElement('canvas');
    canvas.width = 1;
    canvas.height = 1;
    context = canvas.getContext('2d', { willReadFrequently: true });
    if (!context) {
      throw new Error('workbench/color: 2D canvas is unavailable');
    }
  }
  return context;
}

/** Normalizes any CSS color the browser understands to 8-bit sRGB. */
export function parseColor(css: string): RGBA {
  const ctx = canvasContext();
  ctx.clearRect(0, 0, 1, 1);
  // Reset to a sentinel first: an unparseable value leaves `fillStyle`
  // unchanged instead of throwing.
  ctx.fillStyle = '#000';
  ctx.fillStyle = css;
  ctx.fillRect(0, 0, 1, 1);
  const [r = 0, g = 0, b = 0, a = 0] = ctx.getImageData(0, 0, 1, 1).data;
  return { r, g, b, a: Math.round((a / 255) * 1000) / 1000 };
}

/** Source-over compositing of `fg` onto `bg`; the result is opaque. */
export function compositeOver(fg: RGBA, bg: RGBA): RGBA {
  const blend = (f: number, b: number): number =>
    Math.round(f * fg.a + b * (1 - fg.a));
  return {
    r: blend(fg.r, bg.r),
    g: blend(fg.g, bg.g),
    b: blend(fg.b, bg.b),
    a: 1
  };
}

function luminance({ r, g, b }: RGBA): number {
  const linear = (channel: number): number => {
    const c = channel / 255;
    return c <= 0.04045 ? c / 12.92 : ((c + 0.055) / 1.055) ** 2.4;
  };
  return 0.2126 * linear(r) + 0.7152 * linear(g) + 0.0722 * linear(b);
}

/** WCAG 2.x contrast ratio between two opaque colors (1–21). */
export function contrastRatio(a: RGBA, b: RGBA): number {
  const la = luminance(a);
  const lb = luminance(b);
  const [hi, lo] = la > lb ? [la, lb] : [lb, la];
  return (hi + 0.05) / (lo + 0.05);
}

/** `#rrggbb`, with an `aa` suffix when `a < 1`. */
export function toHex(c: RGBA): string {
  const hex = (n: number): string =>
    Math.max(0, Math.min(255, Math.round(n)))
      .toString(16)
      .padStart(2, '0');
  const rgb = `#${hex(c.r)}${hex(c.g)}${hex(c.b)}`;
  return c.a < 1 ? `${rgb}${hex(c.a * 255)}` : rgb;
}
