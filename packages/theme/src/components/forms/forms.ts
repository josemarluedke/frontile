import { tv, type VariantProps } from '../../tw';
import { focusVisibleRing, focusVisibleWithinRing } from '../shared';

const label = tv({
  slots: {
    // label text role (Open Sans semibold, tight leading)
    base: 'text-neutral-bolder inline-block font-label text-label-sm pb-2',
    asterisk: 'text-danger'
  },
  variants: {
    size: {
      sm: {
        base: 'text-label-2xs'
      },
      md: {},
      lg: {
        base: 'text-label-md'
      }
    }
  },
  defaultVariants: {
    size: 'md'
  }
});

const formDescription = tv({
  // help/description text — body role
  base: 'text-neutral font-body text-body-micro pb-1 last:pb-0',
  variants: {
    size: {
      sm: 'text-body-micro',
      md: '',
      lg: 'text-body-sm'
    }
  },
  defaultVariants: {
    size: 'md'
  }
});

const formFeedback = tv({
  // validation/feedback text — body role
  base: 'font-body text-body-micro pt-1',
  variants: {
    intent: {
      primary: 'text-primary',
      secondary: 'text-secondary',
      tertiary: 'text-tertiary',
      success: 'text-success',
      danger: 'text-danger',
      warning: 'text-warning'
    },
    size: {
      sm: 'text-body-micro',
      md: '',
      lg: 'text-body-sm'
    }
  },
  defaultVariants: {
    size: 'sm'
  }
});

// The visual shell of a form field: background, border, radius, and the
// invalid/disabled treatments. Shared by the `input` slot and by `select`'s
// `chipsField`, which becomes the shell when chips render beside the trigger.
const fieldShell = [
  'bg-surface-input',
  'border',
  'border-neutral-soft',
  'rounded-xl',
  'selection:bg-surface-overlay-soft'
];

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
      ...fieldShell,
      'text-neutral-strong',
      'placeholder-neutral',
      // body role family; single-line controls keep tight leading (not the body relaxed leading)
      'font-body text-base text-left',
      'leading-tight',
      'focus:ring-3',
      'focus:ring-focus',
      'focus:outline-hidden',
      'focus:border-primary-soft',
      'disabled:border-neutral-subtle disabled:text-neutral-soft',
      'aria-invalid:border-danger-soft',
      'aria-invalid:focus:ring-danger-soft'
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
    // When chips render beside the trigger, `chipsField` owns the field shell
    // and the trigger itself must be visually bare.
    hasChips: {
      true: {
        input: [
          'border-0',
          'bg-transparent',
          'p-0',
          'w-auto',
          'flex-1',
          'min-w-16',
          'focus:ring-0',
          'focus:border-transparent'
        ]
      }
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
      'text-base',
      'border-2 border-neutral',
      'bg-surface-input',
      'transition-colors',
      'checked:bg-origin-border checked:bg-center checked:bg-no-repeat',
      'checked:disabled:bg-neutral-soft checked:disabled:border-neutral-soft',
      ...focusVisibleRing
    ],
    labelContainer: ['flex flex-col ml-2'],
    label: 'font-body text-body-xs pb-0'
  },
  variants: {
    size: {
      sm: { input: 'h-4 w-4' },
      md: { input: 'h-5 w-5' },
      lg: { input: 'h-6 w-6' }
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
    input: [
      'checked-bg-checkbox',
      'indeterminate-bg-checkbox',
      'rounded-sm',
      'checked:bg-primary checked:border-primary',
      // Indeterminate state styles - show minus/dash icon
      'indeterminate:bg-primary',
      'indeterminate:border-primary',
      'indeterminate:bg-origin-border',
      'indeterminate:bg-center',
      'indeterminate:bg-no-repeat'
    ]
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

const radio = tv({
  extend: checkboxRadioBase,
  slots: {
    input: [
      'checked-bg-radio',
      'rounded-full',
      'checked:bg-primary checked:border-primary'
    ]
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
    placeholder: 'text-neutral',
    listbox: 'scroll-py-6 max-h-64',
    icon: 'w-5 h-5',
    clearButton: 'pointer-events-auto',
    input: '[button]:cursor-default',
    emptyContent: 'p-2',
    // The wrapper around the trigger. It is rendered in every mode; the
    // `hasChips` variant below decides whether it is the field shell or a
    // transparent passthrough. Authored here rather than as literal classes in
    // the component template because Tailwind does not scan
    // `packages/frontile/src`.
    chipsField: '',
    chipsContainer: 'flex flex-wrap items-center gap-1 min-w-0',
    chip: ''
  },
  variants: {
    size: {
      sm: {},
      md: {},
      lg: {}
    },
    // When chips render, `chipsField` becomes the field shell in place of the
    // trigger's own border (see the `hasChips` variant on `input`), and owns the
    // padding. Otherwise it is a transparent, full-width flex passthrough: the
    // shell stays on the trigger, but the wrapper is still a real box, so it can
    // be measured as the popover's width reference in both modes.
    //
    // `data-invalid` / `data-disabled` are set by the component because
    // `aria-invalid:` and `disabled:` only match the element carrying them.
    hasChips: {
      true: {
        chipsField: [
          ...fieldShell,
          'flex',
          'flex-wrap',
          'items-center',
          'gap-1',
          'w-full',
          'cursor-default',
          'focus-within:ring-3',
          'focus-within:ring-focus',
          'focus-within:border-primary-soft',
          'data-[invalid=true]:border-danger-soft',
          'data-[invalid=true]:focus-within:ring-danger-soft',
          'data-[disabled=true]:border-neutral-subtle',
          'data-[disabled=true]:text-neutral-soft'
        ]
      },
      false: { chipsField: 'flex w-full min-w-0' }
    }
  },
  compoundVariants: [
    // Padding belongs to whichever element is the field shell, so it is applied
    // to `chipsField` only in chips mode -- in passthrough mode the wrapper has
    // to add no geometry of its own.
    { hasChips: true, size: 'sm', class: { chipsField: 'p-1 gap-1' } },
    { hasChips: true, size: 'md', class: { chipsField: 'p-1.5 gap-1' } },
    { hasChips: true, size: 'lg', class: { chipsField: 'p-2 gap-1.5' } },
    // Chips have to clear the absolutely-positioned start/end content the same
    // way a bare `input` does, otherwise they run underneath the chevron and the
    // clear button.
    { hasChips: true, hasStartContent: true, class: { chipsField: 'ps-8' } },
    { hasChips: true, hasEndContent: true, class: { chipsField: 'pe-10' } },
    // ...and once `chipsField` reserves that room, the bare trigger inside it
    // must not reserve it a second time.
    { hasChips: true, hasStartContent: true, class: { input: 'ps-0' } },
    { hasChips: true, hasEndContent: true, class: { input: 'pe-0' } }
  ],
  defaultVariants: {
    size: 'md'
  }
});

// Note: extends `input` rather than `select` because tailwind-variants
// loses inherited slot types across two levels of `extend`.
const autocomplete = tv({
  extend: input,
  slots: {
    base: [],
    listbox: 'scroll-py-6 max-h-64',
    icon: 'w-5 h-5',
    clearButton: 'pointer-events-auto',
    input: 'cursor-text',
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
    label: 'font-body text-body-xs pb-0',
    wrapper: [
      'px-1',
      'relative',
      'inline-flex',
      'items-center',
      'justify-start',
      'shrink-0',
      'overflow-hidden',
      'bg-neutral-soft',
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
      'z-0 absolute end-1.5 text-neutral',
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
          'group-data-[selected=true]:bg-neutral-firm',
          'group-data-[selected=true]:text-on-neutral-firm'
        ]
      },
      primary: {
        wrapper: [
          'group-data-[selected=true]:bg-primary',
          'group-data-[selected=true]:text-on-primary'
        ]
      },
      secondary: {
        wrapper: [
          'group-data-[selected=true]:bg-secondary',
          'group-data-[selected=true]:text-on-secondary'
        ]
      },
      tertiary: {
        wrapper: [
          'group-data-[selected=true]:bg-tertiary',
          'group-data-[selected=true]:text-on-tertiary'
        ]
      },
      success: {
        wrapper: [
          'group-data-[selected=true]:bg-success',
          'group-data-[selected=true]:text-on-success'
        ]
      },
      warning: {
        wrapper: [
          'group-data-[selected=true]:bg-warning',
          'group-data-[selected=true]:text-on-warning'
        ]
      },
      danger: {
        wrapper: [
          'group-data-[selected=true]:bg-danger',
          'group-data-[selected=true]:text-on-danger'
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
export type AutocompleteVariants = VariantProps<typeof autocomplete>;
export type AutocompleteSlots = keyof ReturnType<typeof autocomplete>;
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
  autocomplete,
  nativeSelect,
  checkboxGroup,
  radioGroup,
  switchInput
};
