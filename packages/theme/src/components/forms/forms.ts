import { tv, type VariantProps } from '../../tw';
import { focusVisibleRing, focusVisibleWithinRing } from '../shared';

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
      'rounded-sm',
      'leading-tight',
      'focus:ring-3',
      'focus:ring-focus',
      'focus:outline-hidden',
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
      'checked:bg-origin-border checked:border-transparent dark:checked:bg-current checked:bg-current checked:bg-center checked:bg-no-repeat checked:disabled:bg-default-300',
      ...focusVisibleRing
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
    input: ['checked-bg-checkbox', 'rounded-xs']
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
    input: '[button]:cursor-default',
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

const switchInput = tv({
  slots: {
    base: 'group relative max-w-fit inline-flex items-center justify-start',
    labelContainer: 'flex flex-col ml-2',
    label: 'font-normal pb-0',
    wrapper: [
      'px-1',
      'relative',
      'inline-flex',
      'items-center',
      'justify-start',
      'shrink-0',
      'overflow-hidden',
      'bg-default-300',
      'rounded-full',
      'cursor-pointer touch-none tap-highlight-transparent select-none',
      'transition-background',
      ...focusVisibleWithinRing
    ],
    hiddenInput: [
      'font-inherit',
      'text-[100%]',
      'leading-[1.15]',
      'm-0',
      'p-0',
      'overflow-visible',
      'box-border',
      'absolute',
      'top-0',
      'w-full',
      'h-full',
      'opacity-[0.0001]',
      'z-1',
      'cursor-pointer',
      'disabled:cursor-default'
    ],
    thumb: [
      'z-10',
      'flex',
      'items-center',
      'justify-center',
      'bg-white',
      'shadow-small',
      'rounded-full',
      'origin-right',
      'transition-all',
      'pointer-events-none',
      'text-black'
    ],
    startContent: [
      'z-0 absolute start-1.5 text-current',
      'opacity-0',
      'scale-50',
      'transition-transform-opacity',
      'group-data-[selected=true]:scale-100',
      'group-data-[selected=true]:opacity-100'
    ],
    endContent: [
      'z-0 absolute end-1.5 text-default-600',
      'opacity-100',
      'transition-transform-opacity',
      'group-data-[selected=true]:translate-x-3',
      'group-data-[selected=true]:opacity-0'
    ]
  },
  variants: {
    isDisabled: {
      true: {
        wrapper: 'opacity-disabled pointer-events-none'
      }
    },
    size: {
      sm: {
        wrapper: 'w-6 h-3 px-[2px]',
        thumb: ['w-2 h-2 text-xs', 'group-data-[selected=true]:ms-3'],
        endContent: 'text-xs',
        startContent: 'text-xs',
        label: 'text-small'
      },
      md: {
        wrapper: 'w-11 h-6',
        thumb: ['w-4 h-4 text-sm', 'group-data-[selected=true]:ms-5'],
        endContent: 'text-sm',
        startContent: 'text-sm',
        label: 'text-md'
      },
      lg: {
        wrapper: 'w-12 h-7',
        thumb: ['w-5 h-5 text-medium', 'group-data-[selected=true]:ms-5'],
        endContent: 'text-md',
        startContent: 'text-md',
        label: 'text-lg'
      }
    },
    intent: {
      default: {
        wrapper: [
          'group-data-[selected=true]:bg-default-400',
          'group-data-[selected=true]:text-default-foreground'
        ]
      },
      primary: {
        wrapper: [
          'group-data-[selected=true]:bg-primary',
          'group-data-[selected=true]:text-primary-foreground'
        ]
      },
      success: {
        wrapper: [
          'group-data-[selected=true]:bg-success',
          'group-data-[selected=true]:text-success-foreground'
        ]
      },
      warning: {
        wrapper: [
          'group-data-[selected=true]:bg-warning',
          'group-data-[selected=true]:text-warning-foreground'
        ]
      },
      danger: {
        wrapper: [
          'group-data-[selected=true]:bg-danger',
          'data-[selected=true]:text-danger-foreground'
        ]
      }
    }
  },
  defaultVariants: {
    size: 'md',
    intent: 'primary',
    isDisabled: false
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
export type SwitchVariants = VariantProps<typeof switchInput>;
export type SwitchSlots = keyof ReturnType<typeof switchInput>;

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
  radioGroup,
  switchInput
};
