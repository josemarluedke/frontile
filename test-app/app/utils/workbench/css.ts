/** Computed-style readers for workbench specimens and swatches. */

import { compositeOver, parseColor, type RGBA } from './color';

const WHITE: RGBA = { r: 255, g: 255, b: 255, a: 1 };

/**
 * The opaque color showing through behind `el`'s contents: its own
 * background composited over each ancestor's, down to the first opaque one
 * (white if none is).
 */
export function backdropColor(el: Element): RGBA {
  const layers: RGBA[] = [];
  for (let node: Element | null = el; node; node = node.parentElement) {
    const layer = parseColor(getComputedStyle(node).backgroundColor);
    if (layer.a === 0) {
      continue;
    }
    layers.push(layer);
    if (layer.a === 1) {
      break;
    }
  }
  return layers.reduceRight<RGBA>(
    (below, layer) => compositeOver(layer, below),
    WHITE
  );
}

/** The trimmed computed value of a custom property (e.g. `--color-primary`). */
export function readVar(el: Element, name: string): string {
  return getComputedStyle(el).getPropertyValue(name).trim();
}

export interface TypeMeasure {
  fontSize: string;
  lineHeight: string;
  fontWeight: string;
  letterSpacing: string;
}

/** The computed type metrics of an element. */
export function measureType(el: Element): TypeMeasure {
  const style = getComputedStyle(el);
  return {
    fontSize: style.fontSize,
    lineHeight: style.lineHeight,
    fontWeight: style.fontWeight,
    letterSpacing: style.letterSpacing
  };
}
