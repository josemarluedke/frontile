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
      transparent: {
        base: ['bg-transparent', 'hover:bg-surface-overlay-subtle']
      },
      subtle: {
        base: [
          'bg-neutral-subtle',
          'text-on-neutral-subtle',
          'hover:bg-surface-overlay-subtle'
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
