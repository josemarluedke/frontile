import { tv, type VariantProps } from '../tw';

const tooltip = tv({
  slots: {
    // Width is intrinsic so a short label hugs its text, with a cap so a long
    // one wraps instead of running off the viewport. `origin-*` is keyed off
    // the resolved placement the content carries as `data-placement`, so the
    // enter transition grows out of the anchor rather than out of nowhere.
    //
    // Type is the `body` role, not `label`: a tooltip is a sentence read in
    // passing, so it wants regular weight and running-text leading. `label`
    // is semibold at a leading of 1, which renders a short tip heavy and
    // packs a wrapped one into touching lines. `antialiased` keeps light
    // text on the dark fill from blooming on macOS.
    base: [
      'relative w-max max-w-xs rounded-md shadow-md overflow-visible',
      'font-body antialiased',
      'data-[placement^=top]:origin-bottom',
      'data-[placement^=bottom]:origin-top',
      'data-[placement^=left]:origin-right',
      'data-[placement^=right]:origin-left'
    ],
    arrow: ''
  },
  variants: {
    size: {
      sm: { base: 'px-1.5 py-0.5 text-body-2xs' },
      md: { base: 'px-2 py-1 text-body-xs' },
      lg: { base: 'px-2.5 py-1.5 text-body-sm' }
    },
    // `bg-inherit` on the arrow (see `overlayArrow`) means each color only
    // has to state the background once, on `base`. The border is cleared to
    // `border-transparent` on both `base` and `arrow` for every color. The
    // body needs it explicitly: `Content`'s classNames (`popover.gts`) run
    // this `base` class through the *`popover`* tv, whose own base carries
    // `border border-neutral-subtle` (`popover.ts`), and twMerge only drops
    // that when a later class from the same border-color group replaces it.
    // Leaving it would show a hairline on the body that the arrow lacks, a
    // seam at the join.
    //
    // `neutral` is a raised warm gray in *both* schemes rather than a
    // scheme-following surface. `surface-input` is pure black in dark mode,
    // which sits *below* a warm-black page and leaves a border to do all the
    // separating. `neutral-strong` (light) and `neutral-muted` (dark) resolve
    // to the same step of the gray ramp, so the tooltip reads as a lifted
    // chip on either ground, and its edge comes from the fill, not a border.
    color: {
      neutral: {
        base: [
          'bg-neutral-strong text-on-neutral-strong border-transparent',
          'dark:bg-neutral-muted dark:text-on-neutral-muted'
        ],
        arrow: 'border-transparent'
      },
      primary: {
        base: 'bg-primary text-on-primary border-transparent',
        arrow: 'border-transparent'
      },
      secondary: {
        base: 'bg-secondary text-on-secondary border-transparent',
        arrow: 'border-transparent'
      },
      tertiary: {
        base: 'bg-tertiary text-on-tertiary border-transparent',
        arrow: 'border-transparent'
      },
      success: {
        base: 'bg-success text-on-success border-transparent',
        arrow: 'border-transparent'
      },
      warning: {
        base: 'bg-warning text-on-warning border-transparent',
        arrow: 'border-transparent'
      },
      danger: {
        base: 'bg-danger text-on-danger border-transparent',
        arrow: 'border-transparent'
      }
    }
  },
  defaultVariants: {
    size: 'md',
    color: 'neutral'
  }
});

export type TooltipVariants = VariantProps<typeof tooltip>;
export type TooltipSlots = keyof ReturnType<typeof tooltip>;

export { tooltip };
