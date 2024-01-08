import { tv } from 'tailwind-variants';

const formInput = tv({
  slots: {
    base: 'flex flex-wrap	flex-row',
    label: 'flex-[1_100%]',
    input: '',
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

const formTextarea = tv({
  extend: formInput
});

export { formInput, formTextarea };
