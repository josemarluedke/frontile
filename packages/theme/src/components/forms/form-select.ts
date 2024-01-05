import { tv } from 'tailwind-variants';

const formSelect = tv({
  slots: {
    base: 'flex flex-wrap	flex-row',
    label: 'flex-[1_100%]',
    select: '',
    hint: 'flex-[1_100%]',
    feedback: 'flex-[1_100%]'
  },
  variants: {
    size: {
      sm: '',
      md: '',
      lg: ''
    }
  },
  defaultVariants: {
    size: 'md'
  }
});

export { formSelect };
