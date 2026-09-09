/**
 * Test override. `undefined` means "ask the browser", which is what production
 * always does; a boolean forces the answer so a test can exercise both paths
 * without touching the real media query.
 */
let override: boolean | undefined;

function setPrefersReducedMotion(value: boolean | undefined): void {
  override = value;
}

function prefersReducedMotion(): boolean {
  if (override !== undefined) {
    return override;
  }

  if (typeof window === 'undefined' || !window.matchMedia) {
    return false;
  }

  return window.matchMedia('(prefers-reduced-motion: reduce)').matches;
}

export { prefersReducedMotion, setPrefersReducedMotion };
