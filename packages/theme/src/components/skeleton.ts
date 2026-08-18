import { tv, type VariantProps } from '../tw';

// Border-radius lives ONLY in the `shape` variants, never in `base`. Frontile's
// `rounded-default` is a custom value that tailwind-merge does not recognise as
// part of the `rounded` group, so a base radius would survive alongside a
// shape's radius instead of being replaced by it.
const skeleton = tv({
  base: ['block', 'overflow-hidden'],
  variants: {
    shape: {
      text: 'w-full rounded-default',
      circle: 'aspect-square rounded-full',
      // Matches Avatar's squircle radius so the two line up side by side.
      square: 'aspect-square rounded-[20%]',
      rounded: 'w-full rounded-lg',
      rect: 'w-full rounded-none'
    },
    // Resolved per shape in compoundVariants: `circle`/`square` take both
    // dimensions from Avatar's size scale, the rest take a height.
    size: {
      xs: '',
      sm: '',
      md: '',
      lg: '',
      xl: ''
    },
    animation: {
      shimmer: [
        'bg-linear-to-r',
        'from-surface-overlay-soft',
        'via-surface-overlay-firm',
        'to-surface-overlay-soft',
        'bg-[length:200%_100%]',
        'animate-shimmer'
      ],
      pulse: ['bg-surface-overlay-mild', 'animate-pulse'],
      none: ['bg-surface-overlay-mild']
    }
  },
  compoundVariants: [
    // Square-ish shapes: one token sets width and height, reusing Avatar's
    // scale so `<Skeleton @shape="circle" @size="md" />` matches
    // `<Avatar @size="md" />` exactly.
    { shape: ['circle', 'square'], size: 'xs', class: 'size-5' },
    { shape: ['circle', 'square'], size: 'sm', class: 'size-6' },
    { shape: ['circle', 'square'], size: 'md', class: 'size-8' },
    { shape: ['circle', 'square'], size: 'lg', class: 'size-10' },
    { shape: ['circle', 'square'], size: 'xl', class: 'size-12' },

    // Full-width shapes: size sets a height. Every shape gets one so a
    // Skeleton is never zero-height — an invisible placeholder makes a
    // loading state look like an empty state. Override with `@class`.
    { shape: ['text', 'rounded', 'rect'], size: 'xs', class: 'h-2.5' },
    { shape: ['text', 'rounded', 'rect'], size: 'sm', class: 'h-3' },
    { shape: ['text', 'rounded', 'rect'], size: 'md', class: 'h-4' },
    { shape: ['text', 'rounded', 'rect'], size: 'lg', class: 'h-5' },
    { shape: ['text', 'rounded', 'rect'], size: 'xl', class: 'h-6' }
  ],
  defaultVariants: {
    shape: 'text',
    size: 'md',
    animation: 'shimmer'
  }
});

export type SkeletonVariants = VariantProps<typeof skeleton>;
export { skeleton };
