import { tv } from 'tailwind-variants';

const label = tv({
  slots: {
    base: 'text-foreground inline-block font-semibold leading-tight pb-1',
    asterisk: 'text-danger'
  },
  variants: {
    size: {
      sm: {
        base: 'text-xs'
      },
      md: {},
      lg: {
        base: 'text-lg'
      }
    }
  },
  defaultVariants: {
    size: 'md'
  }
});

const formDescription = tv({
  base: 'text-default-400 text-xs pb-1 last:pb-0',
  variants: {
    size: {
      sm: 'text-xs',
      md: '',
      lg: 'text-lg'
    }
  },
  defaultVariants: {
    size: 'md'
  }
});

const formFeedback = tv({
  base: 'text-xs pt-1',
  variants: {
    intent: {
      primary: 'text-primary',
      success: 'text-success',
      danger: 'text-danger',
      warning: 'text-warning'
    },
    size: {
      sm: 'text-xs',
      md: '',
      lg: 'text-lg'
    }
  },
  defaultVariants: {
    size: 'sm'
  }
});

const input = tv({
  slots: {
    base: '',
    input: [
      'appearance-none',
      'flex-1',
      'w-full',
      'bg-white dark:bg-default-100',
      'text-default-900',
      'placeholder-default-400',
      'text-base text-foreground',
      'border',
      'border-default-400',
      'rounded',
      'leading-tight',
      'focus:ring',
      'focus:outline-none',
      'focus:border-primary-400',
      'selection:bg-content3',
      'disabled:border-default-200 disabled:text-default-500',
      'aria-invalid:border-danger-400',
      'aria-invalid:focus:ring-danger-400'
    ]
  },
  variants: {
    size: {
      sm: { input: 'p-2' },
      md: { input: 'p-3' },
      lg: { input: 'p-4' }
    }
  },
  defaultVariants: {
    size: 'md'
  }
});

const textarea = tv({
  extend: input,
  slots: { input: 'min-h-24' }
});

const checkboxRadioBase = tv({
  slots: {
    base: ['max-w-fit flex items-center justify-start'],

    input: [
      'appearance-none',
      'inline-block',
      'align-middle',
      'select-none',
      'shrink-0',
      'h-[1em] w-[1em]',
      'text-base',
      'text-primary',
      'border border-default-400',
      'bg-white dark:bg-default-100',
      'checked:bg-origin-border checked:border-transparent dark:checked:bg-current checked:bg-current checked:bg-center checked:bg-no-repeat checked:disabled:bg-default-300'
    ],
    labelContainer: ['flex flex-col ml-2'],
    label: 'font-normal pb-0'
  },
  variants: {
    size: {
      sm: { input: '' },
      md: { input: '' },
      lg: { input: '' }
    }
  },
  defaultVariants: {
    size: 'md'
  }
});

const checkboxRadioGroupBase = tv({
  slots: {
    base: '',
    optionsContainer: [
      'flex flex-col flex-wrap gap-4 data-[orientation=horizontal]:flex-row'
    ],
    label: 'pb-2'
  }
});

const checkbox = tv({
  extend: checkboxRadioBase,
  slots: {
    input: ['checked-bg-checkbox', 'rounded-sm']
  },
  variants: {
    size: {
      sm: { input: '' },
      md: { input: '' },
      lg: { input: '' }
    }
  },
  defaultVariants: {
    size: 'md'
  }
});

const radio = tv({
  extend: checkboxRadioBase,
  slots: {
    input: ['checked-bg-radio', 'rounded-full']
  },
  variants: {
    size: {
      sm: { input: '' },
      md: { input: '' },
      lg: { input: '' }
    }
  },
  defaultVariants: {
    size: 'md'
  }
});

const radioGroup = tv({
  extend: checkboxRadioGroupBase
});

const checkboxGroup = tv({
  extend: checkboxRadioGroupBase
});

const select = tv({
  slots: {
    base: [],
    trigger: [
      input().input(),
      'flex items-center justify-between',
      'disabled:cursor-not-allowed'
    ],
    placeholder: 'text-default-400',
    listbox: 'scroll-py-6 max-h-64',
    icon: 'w-5 h-5'
  },
  variants: {
    size: {
      sm: { trigger: 'p-2' },
      md: { trigger: 'p-3' },
      lg: { trigger: 'p-4' }
    }
  },
  defaultVariants: {
    size: 'md'
  }
});

const nativeSelect = tv({
  extend: input,
  slots: {
    input: ['appearance-auto']
  }
});

export {
  label,
  formDescription,
  formFeedback,
  input,
  textarea,
  checkbox,
  radio,
  select,
  nativeSelect,
  checkboxGroup,
  radioGroup
};
