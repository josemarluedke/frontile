import { tv, type VariantProps } from '../tw';

const skeleton = tv({
  base: ['block', 'h-4', 'w-full', 'rounded-default', 'overflow-hidden'],
  variants: {
    animation: {
      shimmer: [
        'bg-linear-to-r',
        'from-surface-overlay-soft',
        'via-surface-overlay-strong',
        'to-surface-overlay-soft',
        'bg-[length:200%_100%]',
        'animate-shimmer'
      ],
      pulse: ['bg-surface-overlay-medium', 'animate-pulse'],
      none: ['bg-surface-overlay-medium']
    }
  },
  defaultVariants: {
    animation: 'shimmer'
  }
});

export type SkeletonVariants = VariantProps<typeof skeleton>;
export { skeleton };
