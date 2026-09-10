/**
 * One slot in the rendered page row: either a page number, or the gap marker
 * standing in for a run of pages that did not fit.
 */
export type PaginationItem =
  { type: 'page'; value: number } | { type: 'ellipsis' };

export interface PaginationRangeOptions {
  /** The current page, 1-based. Assumed already clamped by the caller. */
  page: number;
  /** How many pages exist in total. */
  totalPages: number;
  /** How many pages to show either side of the current one. */
  siblingCount: number;
}

/**
 * How many pages are pinned at each end. Fixed rather than configurable: every
 * reference design (and every screenshot this component was drawn from) pins
 * exactly one, and the argument would only ever be set to 1.
 */
const BOUNDARY_COUNT = 1;

function span(start: number, end: number): number[] {
  if (end < start) {
    return [];
  }

  return Array.from({ length: end - start + 1 }, (_, i) => start + i);
}

/**
 * Computes the visible page row, MUI's algorithm with a fixed boundary of 1.
 *
 * The property worth preserving here is a **constant slot count**: the sibling
 * window is clamped away from both ends rather than simply centred on `page`,
 * so a control at page 1 is exactly as wide as one at page 12 and the buttons
 * never shift under the pointer as you page through. A naive
 * "current ± siblings, plus the boundaries" set is one line shorter and
 * reflows on almost every click.
 *
 * The other subtlety is the `else` branch on each side: when the gap left by
 * the window is exactly one page wide, that page is rendered instead of an
 * ellipsis. An ellipsis hiding a single page is strictly worse than the page —
 * same width, one fewer destination.
 */
export function paginationRange({
  page,
  totalPages,
  siblingCount
}: PaginationRangeOptions): PaginationItem[] {
  if (totalPages < 1) {
    return [];
  }

  const startPages = span(1, Math.min(BOUNDARY_COUNT, totalPages));
  const endPages = span(
    Math.max(totalPages - BOUNDARY_COUNT + 1, BOUNDARY_COUNT + 1),
    totalPages
  );

  const siblingsStart = Math.max(
    Math.min(
      page - siblingCount,
      totalPages - BOUNDARY_COUNT - siblingCount * 2 - 1
    ),
    BOUNDARY_COUNT + 2
  );

  const siblingsEnd = Math.min(
    Math.max(page + siblingCount, BOUNDARY_COUNT + siblingCount * 2 + 2),
    endPages.length > 0 ? (endPages[0] as number) - 2 : totalPages - 1
  );

  const values: (number | 'ellipsis')[] = [
    ...startPages,

    ...(siblingsStart > BOUNDARY_COUNT + 2
      ? (['ellipsis'] as const)
      : BOUNDARY_COUNT + 1 < totalPages - BOUNDARY_COUNT
        ? [BOUNDARY_COUNT + 1]
        : []),

    ...span(siblingsStart, siblingsEnd),

    ...(siblingsEnd < totalPages - BOUNDARY_COUNT - 1
      ? (['ellipsis'] as const)
      : totalPages - BOUNDARY_COUNT > BOUNDARY_COUNT
        ? [totalPages - BOUNDARY_COUNT]
        : []),

    ...endPages
  ];

  return values.map((value) =>
    value === 'ellipsis' ? { type: 'ellipsis' } : { type: 'page', value }
  );
}
