import { tv } from '../tw';
const divider = tv({
  base: 'shrink-0 bg-neutral-subtle border-none',
  variants: {
    orientation: {
      horizontal: 'w-full h-px',
      vertical: 'h-full w-px'
    },
    variant: {
      solid: '',
      // Intentionally empty. The sketch treatment is attached by the compound
      // variant below, so it can only ever apply to a horizontal divider —
      // see the comment there.
      sketch: ''
    }
  },
  compoundVariants: [
    // Horizontal only, deliberately. The artwork is a near-horizontal ribbon;
    // squashed into a 1px-wide column by `mask-size: 100% 100%` it renders as a
    // stub covering roughly the top 45% of the height, not a rule. Scoping it
    // here means `orientation="vertical" variant="sketch"` silently falls back
    // to an ordinary vertical line.
    //
    // `h-2` (8px) is chosen for legibility, not to match the source art. The
    // mask is sized `100% 100%`, so the artwork's wobble amplitude scales with
    // the element's height: at 4px the wave is only about a pixel and the line
    // reads as a straight hairline, losing the hand-drawn character entirely.
    //
    // The height lives here rather than in the variant so it beats `h-px`
    // deterministically: tv() applies compound variants after variants, so
    // this does not depend on tailwind-merge resolving the conflict by
    // declaration order.
    {
      orientation: 'horizontal',
      variant: 'sketch',
      class: 'h-2 divider-sketch'
    }
  ],
  defaultVariants: {
    orientation: 'horizontal',
    variant: 'solid'
  }
});

export { divider };
