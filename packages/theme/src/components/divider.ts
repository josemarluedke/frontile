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
    // `h-1` (4px) is the artwork's native height, and lives here rather than in
    // the variant so it beats `h-px` deterministically: tv() applies compound
    // variants after variants, so this does not depend on tailwind-merge
    // resolving the conflict by declaration order.
    {
      orientation: 'horizontal',
      variant: 'sketch',
      class: 'h-1 divider-sketch'
    }
  ],
  defaultVariants: {
    orientation: 'horizontal',
    variant: 'solid'
  }
});

export { divider };
