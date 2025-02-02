import { tv, type VariantProps } from '../../tw';

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
    innerContainer: 'relative flex',
    startContent: 'absolute inset-y-0 left-0 flex items-center',
    endContent: 'absolute inset-y-0 right-0 flex items-center',
    input: [
      'appearance-none',
      'flex-1',
      'w-full',
      'bg-white dark:bg-default-100',
      'text-default-900',
      'placeholder-default-400',
      'text-base text-left text-foreground',
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
      sm: { input: 'p-2', startContent: 'pl-2', endContent: 'pr-2' },
      md: { input: 'p-3', startContent: 'pl-3', endContent: 'pr-3' },
      lg: { input: 'p-4', startContent: 'pl-4', endContent: 'pr-4' }
    },
    hasStartContent: {
      true: { input: 'ps-8' }
    },
    hasEndContent: {
      true: { input: 'pe-10' }
    },
    startContentPointerEvents: {
      auto: { startContent: 'pointer-events-auto' },
      none: { startContent: 'pointer-events-none' }
    },
    endContentPointerEvents: {
      auto: { endContent: 'pointer-events-auto' },
      none: { endContent: 'pointer-events-none' }
    }
  },
  defaultVariants: {
    size: 'md'
  }
});

const textarea = tv({
  extend: input,
  slots: { input: 'min-h-24' },
  variants: {
    size: {
      sm: {},
      md: {},
      lg: {}
    }
  }
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
  },
  variants: {
    size: {
      sm: '',
      md: '',
      lg: ''
    }
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
  extend: input,
  slots: {
    base: [],
    placeholder: 'text-default-400',
    listbox: 'scroll-py-6 max-h-64',
    icon: 'w-5 h-5',
    clearButton: 'pointer-events-auto',
    input: '[&:is(button)]:cursor-default',
    emptyContent: 'p-2'
  },
  variants: {
    size: {
      sm: {},
      md: {},
      lg: {}
    }
  },
  defaultVariants: {
    size: 'md'
  }
});

const nativeSelect = tv({
  extend: input,
  slots: {
    input: ['appearance-none'],
    icon: 'w-5 h-5'
  },
  variants: {
    size: {
      sm: {},
      md: {},
      lg: {}
    }
  }
});

export type LabelVariants = VariantProps<typeof label>;
export type LabelSlots = keyof ReturnType<typeof label>;
export type FormDescriptionVariants = VariantProps<typeof formDescription>;
export type FormDescriptionSlots = keyof ReturnType<typeof formDescription>;
export type FormFeedbackVariants = VariantProps<typeof formFeedback>;
export type FormFeedbackSlots = keyof ReturnType<typeof formFeedback>;
export type InputVariants = VariantProps<typeof input>;
export type InputSlots = keyof ReturnType<typeof input>;
export type TextareaVariants = VariantProps<typeof textarea>;
export type TextareaSlots = keyof ReturnType<typeof textarea>;
export type CheckboxVariants = VariantProps<typeof checkbox>;
export type CheckboxSlots = keyof ReturnType<typeof checkbox>;
export type RadioVariants = VariantProps<typeof radio>;
export type RadioSlots = keyof ReturnType<typeof radio>;
export type SelectVariants = VariantProps<typeof select>;
export type SelectSlots = keyof ReturnType<typeof select>;
export type NativeSelectVariants = VariantProps<typeof nativeSelect>;
export type NativeSelectSlots = keyof ReturnType<typeof nativeSelect>;
export type CheckboxGroupVariants = VariantProps<typeof checkboxGroup>;
export type CheckboxGroupSlots = keyof ReturnType<typeof checkboxGroup>;
export type RadioGroupVariants = VariantProps<typeof radioGroup>;
export type RadioGroupSlots = keyof ReturnType<typeof radioGroup>;

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
