import { tv, type VariantProps } from '../tw';

const tooltip = tv({
  slots: {
    // Width is intrinsic so a short label hugs its text, with a cap so a long
    // one wraps instead of running off the viewport. `origin-*` is keyed off
    // the resolved placement the content carries as `data-placement`, so the
    // enter transition grows out of the anchor rather than out of nowhere.
    base: [
      'relative w-max max-w-xs rounded-lg shadow-md',
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
    // has to state the background once, on `base`.
    intent: {
      default: { base: 'bg-surface-input text-on-surface-input border border-neutral-subtle' },
      primary: { base: 'bg-primary text-on-primary' },
      secondary: { base: 'bg-secondary text-on-secondary' },
      tertiary: { base: 'bg-tertiary text-on-tertiary' },
      success: { base: 'bg-success text-on-success' },
      warning: { base: 'bg-warning text-on-warning' },
      danger: { base: 'bg-danger text-on-danger' }
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
