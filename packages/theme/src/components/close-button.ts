import { tv, type VariantProps } from '../tw';
import { focusVisibleRing } from './shared';

const closeButton = tv({
  slots: {
    base: [
      'rounded-full transition transition-200 text-inherit',
      ...focusVisibleRing
    ],
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
      transparent: { base: ['bg-transparent', 'hover:bg-neutral-subtle'] },
      subtle: {
        base: [
          'bg-neutral-subtle',
          'text-neutral-contrast-1 dark:text-default-background',
          'dark:bg-inverse-subtle',
          'hover:bg-neutral-subtle/60 dark:hover:bg-neutral-strong/60'
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
