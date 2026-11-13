import { tv } from '../tw';

const popover = tv({
  // `max-w` keeps a popover that is wider than a phone -- `lg`/`xl`, or
  // `trigger` on a full-width trigger -- an inset card with a gutter on each
  // side, instead of running edge to edge. Narrower sizes are unaffected.
  base: 'bg-surface-input rounded-xl border border-neutral-subtle max-w-[calc(100vw-2rem)]',
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
