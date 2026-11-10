/**
 * The layout breakpoints, matching Tailwind's `sm`, `md` and `lg` screens.
 */
export type Breakpoint = 'sm' | 'md' | 'lg';

const WIDTHS: Record<Breakpoint, string> = {
  sm: '40rem',
  md: '48rem',
  lg: '64rem'
};

/**
 * "Below the breakpoint" is the exact complement of Tailwind's
 * `md:` (`min-width: 48rem`): subtracting 0.02px leaves no width at which
 * both or neither match, without assuming a root font size.
 */
function query(breakpoint: Breakpoint): string {
  return `(max-width: calc(${WIDTHS[breakpoint]} - 0.02px))`;
}

function mediaQueryList(breakpoint: Breakpoint): MediaQueryList | undefined {
  if (
    typeof window === 'undefined' ||
    typeof window.matchMedia !== 'function'
  ) {
    return undefined;
  }
  return window.matchMedia(query(breakpoint));
}

/**
 * Whether the viewport is narrower than `breakpoint`. `false` where
 * `matchMedia` is unavailable, so callers fall back to the desktop layout.
 */
export function isBelowBreakpoint(breakpoint: Breakpoint): boolean {
  return mediaQueryList(breakpoint)?.matches ?? false;
}

/**
 * Calls `callback` with the new answer whenever the viewport crosses
 * `breakpoint`. Returns a function that stops watching. A no-op where
 * `matchMedia` is unavailable.
 */
export function watchBreakpoint(
  breakpoint: Breakpoint,
  callback: (below: boolean) => void
): () => void {
  const mql = mediaQueryList(breakpoint);
  if (!mql) {
    return () => {};
  }

  const listener = (event: MediaQueryListEvent): void =>
    callback(event.matches);

  if (typeof mql.addEventListener === 'function') {
    mql.addEventListener('change', listener);
    return () => mql.removeEventListener('change', listener);
  }

  // Safari < 14.
  mql.addListener(listener);
  return () => mql.removeListener(listener);
}
