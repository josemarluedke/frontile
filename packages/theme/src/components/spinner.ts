import { tv, type VariantProps } from '../tw';
const spinner = tv({
  base: 'text-default-200 animate-spin dark:text-default-500',
  variants: {
    size: {
      xs: 'w-4 h-4',
      sm: 'w-6 h-6,',
      md: 'w-8 h-8,',
      lg: 'w-10 h-10',
      xl: 'w-12 h-12'
    },
    intent: {
      default: 'fill-default-800 dark:fill-default-200',
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
