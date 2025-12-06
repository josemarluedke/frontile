import { tv, type VariantProps } from '../tw';
const spinner = tv({
  base: 'text-neutral-subtle animate-spin dark:text-neutral-soft',
  variants: {
    size: {
      xs: 'w-4 h-4',
      sm: 'w-6 h-6,',
      md: 'w-8 h-8,',
      lg: 'w-10 h-10',
      xl: 'w-12 h-12'
    },
    intent: {
      default: 'fill-neutral-strong dark:fill-neutral-subtle',
      primary: 'fill-primary',
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
