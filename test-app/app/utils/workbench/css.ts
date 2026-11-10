/** Computed-style readers for workbench specimens and swatches. */

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
