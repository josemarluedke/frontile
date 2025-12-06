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
      'text-foreground',
      'z-0',
      'bg-neutral-subtle',
      'ring-1 ring-default ring-offset-1 ring-offset-background'
    ],
    img: 'size-full',
    name: [
      'w-full',
      'font-normal',
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
      xs: { base: 'size-5 text-xs' },
      sm: { base: 'size-6 text-sm' },
      md: { base: 'size-8 text-base' },
      lg: { base: 'size-10 text-lg' },
      xl: { base: 'size-12 text-xl' }
    }
  },
  defaultVariants: {
    size: 'md',
    shape: 'circle'
  }
});

export type AvatarVariants = VariantProps<typeof avatar>;
export type AvatarSlots = keyof ReturnType<typeof avatar>;
export { avatar };
