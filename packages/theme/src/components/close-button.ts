import { tv, type VariantProps } from '../tw';

const closeButton = tv({
  slots: {
    base: 'rounded-full transition transition-200 focus-visable:ring text-inherit',
    icon: 'size-[1em]'
  },

  variants: {
    size: {
      xs: { base: 'text-sm p-1' },
      sm: { base: 'text-base p-2' },
      md: { base: 'text-xl p-2' },
      lg: { base: 'text-2xl p-3' },
      xl: { base: 'text-4xl p-3' }
    },
    variant: {
      transparent: { base: ['bg-transparent', 'hover:bg-default-100'] },
      subtle: {
        base: [
          'bg-default-100',
          'text-default-foreground dark:text-default-background',
          'dark:bg-default-200',
          'hover:bg-default-200/60 dark:hover:bg-default-800/60'
        ]
      }
    }
  },
  defaultVariants: {
    size: 'md',
    variant: 'transparent'
  }
});

export type CloseButtonVariants = VariantProps<typeof closeButton>;
export { closeButton };
