import type { containerPlacement } from './types';

/**
 * How much each card behind the front of the stack shrinks, as a fraction.
 */
const SCALE_STEP = 0.05;

interface NotificationStackInput {
  /**
   * Measured card heights in px, ordered front-first (index 0 is the newest
   * notification). A card that has not been measured yet contributes 0.
   */
  heights: number[];

  isExpanded: boolean;

  /**
   * Peek offset between collapsed cards, and the gap between expanded cards.
   */
  gap: number;

  /**
   * How many cards stay visible while collapsed.
   */
  visibleToasts: number;

  placement: containerPlacement;
}

interface CardGeometry {
  transform: string;
  zIndex: number;
  opacity: number;

  /**
   * Fixed height in px while collapsed, so a taller card behind the front one
   * cannot stick out past it. `null` means the card sizes to its content.
   */
  height: number | null;

  transformOrigin: 'top center' | 'bottom center';

  /**
   * `'none'` when the card is fully transparent (collapsed beyond
   * `visibleToasts`), so it cannot swallow clicks meant for the page beneath
   * it; `'auto'` otherwise.
   */
  pointerEvents: 'auto' | 'none';
}

/**
 * Pure geometry for the notification stack: given measured card heights and
 * the current expansion state, it produces the transform for each card and
 * the height the container should animate to.
 *
 * Deliberately free of Ember and DOM dependencies so the layout maths can be
 * tested on its own.
 */
class NotificationStack {
  readonly heights: number[];
  readonly isExpanded: boolean;
  readonly gap: number;
  readonly visibleToasts: number;
  readonly placement: containerPlacement;

  constructor(input: NotificationStackInput) {
    this.heights = input.heights;
    this.isExpanded = input.isExpanded;
    this.gap = input.gap;
    this.visibleToasts = input.visibleToasts;
    this.placement = input.placement;
  }

  get isTopPlacement(): boolean {
    return this.placement.startsWith('top');
  }

  /**
   * Cards are pinned to the placement edge, so a top placement stacks
   * downwards and a bottom placement stacks upwards.
   */
  get directionSign(): number {
    return this.isTopPlacement ? 1 : -1;
  }

  get transformOrigin(): CardGeometry['transformOrigin'] {
    return this.isTopPlacement ? 'top center' : 'bottom center';
  }

  get count(): number {
    return this.heights.length;
  }

  get frontHeight(): number {
    return this.heights[0] ?? 0;
  }

  geometryFor(index: number): CardGeometry {
    const zIndex = this.count - index;

    if (this.isExpanded) {
      return {
        transform: `translateY(${this.directionSign * this.offsetBefore(index)}px) scale(1)`,
        zIndex,
        opacity: 1,
        height: null,
        transformOrigin: this.transformOrigin,
        pointerEvents: 'auto'
      };
    }

    const offset = index * this.gap;
    const scale = Math.max(0, 1 - index * SCALE_STEP);
    const isVisible = index < this.visibleToasts;

    return {
      transform: `translateY(${this.directionSign * offset}px) scale(${scale})`,
      zIndex,
      opacity: isVisible ? 1 : 0,
      // The front card must size to its own content (`null`). Clamping it to
      // `frontHeight` would be self-referential — `frontHeight` *is* the
      // front card's own measurement — and would permanently lock in
      // whatever height was measured first, before content (e.g. a long
      // description) finished laying out. Only cards behind the front one
      // need clamping, so a taller card further back can't poke out past it.
      height: index === 0 ? null : this.frontHeight,
      transformOrigin: this.transformOrigin,
      // A card past `visibleToasts` is fully transparent while collapsed;
      // without this it would still sit in the fixed-position stack and
      // swallow clicks meant for the page beneath it.
      pointerEvents: isVisible ? 'auto' : 'none'
    };
  }

  get containerHeight(): number {
    if (this.count === 0) {
      return 0;
    }

    if (this.isExpanded) {
      return this.offsetBefore(this.count) - this.gap;
    }

    const visible = Math.min(this.count, this.visibleToasts);
    return this.frontHeight + (visible - 1) * this.gap;
  }

  /**
   * Distance from the placement edge to the leading edge of `index`, i.e. the
   * summed heights and gaps of every card in front of it.
   */
  private offsetBefore(index: number): number {
    let offset = 0;

    for (let i = 0; i < index; i++) {
      offset += (this.heights[i] ?? 0) + this.gap;
    }

    return offset;
  }
}

export { NotificationStack };
export type { NotificationStackInput, CardGeometry };
