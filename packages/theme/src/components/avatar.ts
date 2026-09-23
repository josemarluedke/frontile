import { tv, type VariantProps } from '../tw';
const avatar = tv({
  slots: {
    base: [
      'flex',
      'relative',
      'justify-center',
      'items-center',
      'box-border',
      'overflow-hidden',
      'align-middle',
      'text-neutral-strong',
      'z-0',
      'bg-neutral-subtle'
    ],
    img: 'size-full',
    name: [
      'w-full',
      'font-label',
      'text-center',
      'text-inherit',
      'absolute',
      'top-1/2',
      'left-1/2',
      '-translate-x-1/2',
      '-translate-y-1/2',
      'select-none'
    ]
  },
  variants: {
    shape: {
      square: 'rounded-[20%]',
      circle: 'rounded-full'
    },
    size: {
      xs: { base: 'size-5 text-label-2xs' },
      sm: { base: 'size-6 text-label-xs' },
      md: { base: 'size-8 text-label-sm' },
      lg: { base: 'size-10 text-label-md' },
      xl: { base: 'size-12 text-label-lg' }
    },
    /**
     * How the image fills the avatar. `cover` crops to fill, which suits
     * photos. `contain` shows the whole image inset from the edge, which suits
     * logos and wordmarks that must not be cropped.
     */
    fit: {
      cover: { img: 'object-cover' },
      contain: { img: 'object-contain' }
    },
    /**
     * Draws a ring with an offset around the avatar, to separate it from a
     * busy background or from its neighbours in a stack.
     */
    isBordered: {
      true: {
        base: 'ring-1 ring-default ring-offset-1 ring-offset-background'
      }
    }
  },
  compoundVariants: [
    // The inset keeps a contained image off the round edge. It lives on the
    // img, so padding shrinks the box `object-contain` fits into.
    { fit: 'contain', size: 'xs', class: { img: 'p-px' } },
    { fit: 'contain', size: 'sm', class: { img: 'p-0.5' } },
    { fit: 'contain', size: 'md', class: { img: 'p-0.5' } },
    { fit: 'contain', size: 'lg', class: { img: 'p-1' } },
    { fit: 'contain', size: 'xl', class: { img: 'p-1' } }
  ],
  defaultVariants: {
    size: 'md',
    shape: 'circle',
    fit: 'cover',
    isBordered: false
  }
});

export type AvatarVariants = VariantProps<typeof avatar>;
export type AvatarSlots = keyof ReturnType<typeof avatar>;
export { avatar };
