import { tv } from '../tw';

const chip = tv({
  slots: {
    base: [
      'leading-tight',
      'disabled:cursor-not-allowed',
      'disabled:opacity-40',
      'whitespace-nowrap',
      'inline-flex items-center justify-between box-border'
    ],
    content: ['flex-1 text-inherit font-normal'],
    dot: ['w-2', 'h-2', 'ml-1', 'rounded-full'],
    closeButton: ['p-0.5']
  },
  variants: {
    isDisabled: {
      true: 'opacity-40'
    },
    appearance: {
      default: '',
      outlined: '',
      faded: ''
    },
    intent: {
      default: {
        dot: 'bg-neutral-strong',
        closeButton: [
          'bg-neutral-muted',
          'text-on-neutral-medium',
          'hover:bg-neutral-medium'
        ]
      },
      primary: {
        dot: 'bg-brand-soft',
        closeButton: [
          'bg-brand-muted',
          'text-on-brand-soft',
          'hover:bg-brand-medium',
          'focus-visible:ring-brand-soft'
        ]
      },
      accent: {
        dot: 'bg-accent-soft',
        closeButton: [
          'bg-accent-muted',
          'text-on-accent-soft',
          'hover:bg-accent-medium',
          'focus-visible:ring-accent-soft'
        ]
      },
      success: {
        dot: 'bg-success-soft',
        closeButton: [
          'bg-success-muted',
          'text-on-success-soft',
          'hover:bg-success-medium',
          'focus-visible:ring-success-soft'
        ]
      },
      warning: {
        dot: 'bg-warning-soft',
        closeButton: [
          'bg-warning-muted',
          'text-on-warning-soft',
          'hover:bg-warning-medium',
          'focus-visible:ring-warning-soft'
        ]
      },
      danger: {
        dot: 'bg-danger-soft',
        closeButton: [
          'bg-danger-muted',
          'text-on-danger-soft',
          'hover:bg-danger-medium',
          'focus-visible:ring-danger-soft'
        ]
      }
    },
    size: {
      sm: {
        base: 'text-xs px-1 h-6',
        content: 'px-1',
        closeButton: 'text-xs'
      },
      md: {
        base: 'text-sm px-1 h-7',
        content: 'px-2',
        closeButton: 'text-sm'
      },
      lg: {
        base: 'text-lg px-2 h-8',
        content: 'px-2',
        closeButton: 'text-lg'
      }
    },
    radius: {
      none: 'rounded-none',
      sm: 'rounded-sm',
      lg: 'rounded-lg',
      full: 'rounded-full'
    }
  },
  compoundVariants: [
    // APPEARANCE: default (filled)
    {
      appearance: 'default',
      intent: 'default',
      class: {
        base: 'bg-neutral-firm text-on-neutral-firm'
      }
    },
    {
      appearance: 'default',
      intent: 'primary',
      class: {
        base: 'bg-brand-soft text-on-brand-soft'
      }
    },
    {
      appearance: 'default',
      intent: 'accent',
      class: {
        base: 'bg-accent-soft text-on-accent-soft'
      }
    },
    {
      appearance: 'default',
      intent: 'success',
      class: {
        base: 'bg-success-soft text-on-success-soft'
      }
    },
    {
      appearance: 'default',
      intent: 'warning',
      class: {
        base: 'bg-warning-soft text-on-warning-soft'
      }
    },
    {
      appearance: 'default',
      intent: 'danger',
      class: {
        base: 'bg-danger-soft text-on-danger-soft'
      }
    },

    // APPEARANCE: faded (tonal)
    {
      appearance: 'faded',
      intent: 'default',
      class: {
        base: 'text-neutral-strong bg-neutral-subtle'
      }
    },
    {
      appearance: 'faded',
      intent: 'primary',
      class: {
        base: 'text-brand-strong bg-brand-subtle'
      }
    },
    {
      appearance: 'faded',
      intent: 'accent',
      class: {
        base: 'text-accent-strong bg-accent-subtle'
      }
    },
    {
      appearance: 'faded',
      intent: 'success',
      class: {
        base: 'text-success-strong bg-success-subtle'
      }
    },
    {
      appearance: 'faded',
      intent: 'warning',
      class: {
        base: 'text-warning-strong bg-warning-subtle'
      }
    },
    {
      appearance: 'faded',
      intent: 'danger',
      class: {
        base: 'text-danger-strong bg-danger-subtle'
      }
    },

    // APPEARANCE: outlined
    {
      appearance: 'outlined',
      intent: 'default',
      class: {
        base: 'text-neutral-strong border border-neutral-medium'
      }
    },
    {
      appearance: 'outlined',
      intent: 'primary',
      class: {
        base: 'text-brand-strong border border-brand-medium'
      }
    },
    {
      appearance: 'outlined',
      intent: 'accent',
      class: {
        base: 'text-accent-strong border border-accent-medium'
      }
    },
    {
      appearance: 'outlined',
      intent: 'success',
      class: {
        base: 'text-success-strong border border-success-medium'
      }
    },
    {
      appearance: 'outlined',
      intent: 'warning',
      class: {
        base: 'text-warning-strong border border-warning-medium'
      }
    },
    {
      appearance: 'outlined',
      intent: 'danger',
      class: {
        base: 'text-danger-strong border border-danger-medium'
      }
    }
  ],
  defaultVariants: {
    size: 'md',
    intent: 'default',
    appearance: 'default',
    radius: 'full'
  }
});

export { chip };
