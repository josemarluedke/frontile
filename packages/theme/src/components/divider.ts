import { tv } from 'tailwind-variants';
const divider = tv({
  base: 'shrink-0 bg-default-200 border-none',
  variants: {
    orientation: {
      horizontal: 'w-full h-[1px]',
      vertical: 'h-full w-[1px]'
    }
  },
  defaultVariants: {
    orientation: 'horizontal'
  }
});

export { divider };
