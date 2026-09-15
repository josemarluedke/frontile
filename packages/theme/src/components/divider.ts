import { tv } from '../tw';
const divider = tv({
  // `divider` is the purpose-built token for rules, and unlike the solid
  // `neutral-*` fills it is translucent — 15% ink over whatever sits behind it
  // (near-black in light, white in dark). That is what makes one divider work on
  // a page, a card and a tinted panel alike: it darkens or lightens its own
  // background rather than trying to match a fixed surface colour. `bg-neutral-subtle`
  // was the wrong choice here — it resolves to near-white in light and near-black
  // in dark, so it vanished on exactly the surfaces a divider is drawn on.
  base: 'shrink-0 bg-divider border-none',
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
    // `h-1` (4px) is the artwork's native height, and the rule is deliberately
    // subtle at that size. The mask is sized `100% 100%`, so the wobble
    // amplitude scales with the element's height -- a taller divider reads as
    // more obviously hand-drawn, but overstates a line the design intends to be
    // quiet. Raise this only with design's agreement.
    //
    // The height lives here rather than in the variant so it beats `h-px`
    // deterministically: tv() applies compound variants after variants, so
    // this does not depend on tailwind-merge resolving the conflict by
    // declaration order.
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
