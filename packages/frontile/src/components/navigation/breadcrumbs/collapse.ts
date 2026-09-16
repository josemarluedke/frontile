/**
 * One entry in `Breadcrumbs`' `@items` array.
 *
 * The index signature is deliberate: it lets a consumer carry extra data (an
 * icon name, the record the crumb came from) through to the `item` block,
 * which is yielded the original object alongside the computed context.
 */
export interface BreadcrumbsItemData {
  label?: string;
  route?: string;
  model?: unknown;
  models?: unknown[];
  query?: Record<string, unknown>;
  href?: string;
  isCurrent?: boolean;
  isDisabled?: boolean;
  [key: string]: unknown;
}

/**
 * One rendered slot: either a crumb, or the gap marker standing in for the run
 * of crumbs that did not fit. `index` is the crumb's position in the original
 * array, not in the rendered list -- the `item` block needs the former.
 */
export type BreadcrumbsSlot<
  T extends BreadcrumbsItemData = BreadcrumbsItemData
> =
  | { type: 'item'; item: T; index: number }
  | { type: 'ellipsis'; hiddenItems: T[] };

export interface CollapseOptions {
  /** Omitted, nothing collapses. */
  maxItems?: number;
  /** @defaultValue 1 */
  itemsBeforeCollapse?: number;
  /** @defaultValue 1 */
  itemsAfterCollapse?: number;
}

/**
 * Splits a trail into the crumbs that render and the ones an ellipsis stands
 * in for.
 *
 * Unlike `paginationRange`, this needs no special case for a gap of exactly
 * one: clamping `maxItems` up to `before + after + 1` means `items.length >
 * max` implies `items.length >= before + after + 2`, so a rendered ellipsis
 * always hides at least two crumbs. Clamping rather than throwing because a
 * `@maxItems` smaller than the crumbs that are always kept is a caller
 * mistake that has an obvious correct reading.
 */
export function collapseBreadcrumbs<T extends BreadcrumbsItemData>(
  items: T[],
  options: CollapseOptions = {}
): BreadcrumbsSlot<T>[] {
  const asSlot = (item: T, index: number): BreadcrumbsSlot<T> => ({
    type: 'item',
    item,
    index
  });

  if (options.maxItems === undefined) {
    return items.map(asSlot);
  }

  const before = Math.max(0, Math.trunc(options.itemsBeforeCollapse ?? 1));
  const after = Math.max(0, Math.trunc(options.itemsAfterCollapse ?? 1));
  const max = Math.max(Math.trunc(options.maxItems), before + after + 1);

  if (items.length <= max) {
    return items.map(asSlot);
  }

  const tailStart = items.length - after;

  return [
    ...items.slice(0, before).map(asSlot),
    { type: 'ellipsis', hiddenItems: items.slice(before, tailStart) },
    ...items
      .slice(tailStart)
      .map((item, offset) => asSlot(item, tailStart + offset))
  ];
}
