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
        dot: 'bg-primary-medium',
        closeButton: [
          'bg-primary-muted',
          'text-on-primary-medium',
          'hover:bg-primary-firm',
          'focus-visible:ring-primary-soft'
        ]
      },
      accent: {
        dot: 'bg-accent-medium',
        closeButton: [
          'bg-accent-muted',
          'text-on-accent-medium',
          'hover:bg-accent-firm',
          'focus-visible:ring-accent-soft'
        ]
      },
      success: {
        dot: 'bg-success-medium',
        closeButton: [
          'bg-success-muted',
          'text-on-success-medium',
          'hover:bg-success-firm',
          'focus-visible:ring-success-soft'
        ]
      },
      warning: {
        dot: 'bg-warning-medium',
        closeButton: [
          'bg-warning-muted',
          'text-on-warning-medium',
          'hover:bg-warning-firm',
          'focus-visible:ring-warning-soft'
        ]
      },
      danger: {
        dot: 'bg-danger-medium',
        closeButton: [
          'bg-danger-muted',
          'text-on-danger-medium',
          'hover:bg-danger-firm',
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
        base: 'bg-neutral-boldest text-on-neutral-boldest'
      }
    },
    {
      appearance: 'default',
      intent: 'primary',
      class: {
        base: 'bg-primary-medium text-on-primary-medium'
      }
    },
    {
      appearance: 'default',
      intent: 'accent',
      class: {
        base: 'bg-accent-medium text-on-accent-medium'
      }
    },
    {
      appearance: 'default',
      intent: 'success',
      class: {
        base: 'bg-success-medium text-on-success-medium'
      }
    },
    {
      appearance: 'default',
      intent: 'warning',
      class: {
        base: 'bg-warning-medium text-on-warning-medium'
      }
    },
    {
      appearance: 'default',
      intent: 'danger',
      class: {
        base: 'bg-danger-medium text-on-danger-medium'
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
        base: 'text-primary-strong bg-primary-subtle'
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
        base: 'text-primary-strong border border-primary-medium'
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
