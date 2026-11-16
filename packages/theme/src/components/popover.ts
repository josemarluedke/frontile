import { tv } from '../tw';

const popover = tv({
  // The `--popover-available-*` properties are set by `Popover` once it has
  // positioned the content: the room left in the viewport minus a gutter. They
  // keep a wide popover -- `lg`/`xl`, or `trigger` on a full-width trigger -- an
  // inset card on a phone, and make a tall one scroll instead of running off
  // the screen. Before they are set, or outside `Popover`, the width falls back
  // to the viewport minus a gutter and the height is uncapped.
  base: 'bg-surface-input rounded-xl border border-neutral-subtle max-w-[var(--popover-available-width,calc(100vw-2rem))] max-h-[var(--popover-available-height,none)]',
  variants: {
    size: {
      sm: 'w-40',
      md: 'w-64',
      lg: 'w-96',
      xl: 'w-136',
      trigger: 'w-(--trigger-width)',
      // Sizes to the content instead of a fixed width. For panels whose
      // natural width is the point -- a calendar grid is as wide as seven day
      // cells, and wider still with two months side by side -- a fixed width
      // either clips the content or leaves it swimming.
      auto: 'w-auto'
    }
  },
  defaultVariants: {
    size: 'md'
  }
});

export { popover };
