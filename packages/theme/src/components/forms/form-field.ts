import { tv } from 'tailwind-variants';

const label = tv({
  base: 'inline-block font-semibold leading-tight pb-1',
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

const hint = tv({
  base: 'text-gray-400 text-xs pb-1 last:pb-0',
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

const feedback = tv({
  base: 'text-xs pt-1',
  variants: {
    isError: {
      true: 'text-red-600'
    },
    size: {
      sm: 'text-xs',
      md: '',
      lg: 'text-sm'
    }
  },
  defaultVariants: {
    size: 'sm'
  }
});

const input = tv({
  base: [
    'appearance-none',
    'flex-1',
    'w-full',
    'bg-white',
    'text-gray-900',
    'placeholder-gray-400',
    'text-base',
    'border',
    'border-gray-400',
    'rounded',
    'leading-tight',
    'focus:ring',
    'focus:outline-none',
    'focus:border-blue-400',
    'disabled:border-gray-200 disabled:text-gray-500',
    'aria-invalid:border-red-600',
    'aria-invalid:focus:ring-red-400'
  ],
  variants: {
    size: {
      sm: 'p-2',
      md: 'p-3',
      lg: 'p-4'
    }
  },
  defaultVariants: {
    size: 'md'
  }
});

const textarea = tv({
  extend: input,
  base: 'min-h-24'
});

const checkboxRadioBase = tv({
  base: [
    'appearance-none',
    'inline-block',
    'align-middle',
    'select-none',
    'shrink-0',
    'h-[1em] w-[1em]',
    'text-base',
    'text-blue-500',
    'border border-gray-400',
    'bg-white',
    'checked:bg-origin-border checked:border-transparent checked:bg-current checked:bg-center checked:bg-no-repeat checked:disabled:bg-gray-300'
  ],
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

const checkbox = tv({
  extend: checkboxRadioBase,
  base: ['checked-bg-checkbox', 'rounded-sm'],
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

const radio = tv({
  extend: checkboxRadioBase,
  base: ['checked-bg-radio', 'rounded-full'],
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

export { label, hint, feedback, input, textarea, checkbox, radio };
