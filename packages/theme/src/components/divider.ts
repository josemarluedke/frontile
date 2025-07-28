import { tv } from '../tw';
const divider = tv({
  base: 'shrink-0 bg-default-200 border-none',
  variants: {
    orientation: {
      horizontal: 'w-full h-px',
      vertical: 'h-full w-px'
    }
  },
  defaultVariants: {
    orientation: 'horizontal'
  }
});

export { divider };
