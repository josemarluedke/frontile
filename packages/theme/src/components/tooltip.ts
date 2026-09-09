import { tv, type VariantProps } from '../tw';

const tooltip = tv({
  slots: {
    // Width is intrinsic so a short label hugs its text, with a cap so a long
    // one wraps instead of running off the viewport. `origin-*` is keyed off
    // the resolved placement the content carries as `data-placement`, so the
    // enter transition grows out of the anchor rather than out of nowhere.
    base: [
      'relative w-max max-w-xs rounded-lg shadow-md overflow-visible',
      'data-[placement^=top]:origin-bottom',
      'data-[placement^=bottom]:origin-top',
      'data-[placement^=left]:origin-right',
      'data-[placement^=right]:origin-left'
    ],
    arrow: ''
  },
  variants: {
    size: {
      sm: { base: 'px-2 py-1 text-label-sm' },
      md: { base: 'px-2.5 py-1.5 text-label-sm' },
      lg: { base: 'px-3 py-2 text-label-md' }
    },
    // `bg-inherit` on the arrow (see `overlayArrow`) means each intent only
    // has to state the background once, on `base`. The border is stated on
    // both `base` and `arrow` for every intent so the two agree at the join:
    // `default` carries a visible `border-neutral-soft` on each (the arrow's
    // own shadow-less edge needs a level with more contrast than the body's
    // `shadow-md` gets away with), and every coloured intent clears both to
    // `border-transparent`. The body needs this explicitly, not just the
    // arrow: `Content`'s classNames (`popover.gts`) run this `base` class
    // through the *`popover`* tv, whose own base carries
    // `border border-neutral-subtle` (`popover.ts`) -- twMerge only drops
    // that when a later class from the same border-color group replaces it,
    // so a coloured intent with no border class of its own left that
    // neutral border showing on the body while the arrow (fixed here to
    // `border-transparent`) went invisible, a visible seam at the join.
    intent: {
      default: {
        base: 'bg-surface-input text-on-surface-input border border-neutral-soft',
        arrow: 'border-neutral-soft'
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
    intent: 'default'
  }
});

export type TooltipVariants = VariantProps<typeof tooltip>;
export type TooltipSlots = keyof ReturnType<typeof tooltip>;

export { tooltip };
