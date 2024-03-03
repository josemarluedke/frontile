import { tv } from '../tw';

const closeButton = tv({
  slots: {
    base: 'rounded-full hover:bg-default-100 transition transition-200 focus-visable:ring text-inherit',
    icon: 'size-[1em]'
  },

  variants: {
    size: {
      xs: 'text-sm p-1',
      sm: 'text-base p-2',
      md: 'text-xl p-2',
      lg: 'text-2xl p-3',
      xl: 'text-4xl p-3'
    }
  },
  defaultVariants: {
    size: 'md'
  }
});

export { closeButton };
