import { tv, type VariantProps } from '../tw';
const spinner = tv({
  base: 'text-neutral-muted animate-spin',
  variants: {
    size: {
      xs: 'w-4 h-4',
      sm: 'w-6 h-6,',
      md: 'w-8 h-8,',
      lg: 'w-10 h-10',
      xl: 'w-12 h-12'
    },
    intent: {
      default: 'fill-neutral-strong',
      primary: 'fill-brand',
      success: 'fill-success',
      warning: 'fill-warning',
      danger: 'fill-danger'
    }
  },
  defaultVariants: {
    size: 'md',
    intent: 'default'
  }
});

export type SpinnerVariants = VariantProps<typeof spinner>;
export { spinner };
