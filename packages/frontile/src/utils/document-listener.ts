/**
 * The global `document`, or `undefined` where there is none (FastBoot, SSR,
 * prerender).
 */
export function globalDocument(): Document | undefined {
  return typeof document === 'undefined' ? undefined : document;
}
