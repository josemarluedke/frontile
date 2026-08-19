import { tv } from '../tw';

const chip = tv({
  slots: {
    base: [
      'disabled:cursor-not-allowed',
      'disabled:opacity-disabled',
      'whitespace-nowrap',
      'inline-flex items-center justify-between box-border'
    ],
    // label text role (size set per size variant)
    content: ['flex-1 text-inherit font-label'],
    dot: ['w-2', 'h-2', 'ml-1', 'rounded-full'],
    closeButton: ['p-0.5']
  },
  variants: {
    isDisabled: {
      true: 'opacity-disabled'
    },
    appearance: {
      default: '',
      outlined: '',
      faded: ''
    },
    intent: {
      default: {
        dot: 'bg-neutral-strong',
        closeButton: ['bg-neutral-muted', 'text-on-neutral', 'hover:bg-neutral']
      },
      primary: {
        dot: 'bg-primary',
        closeButton: [
          'bg-primary-muted',
          'text-on-primary',
          'hover:bg-primary-firm',
          'focus-visible:ring-primary-soft'
        ]
      },
      secondary: {
        dot: 'bg-secondary',
        closeButton: [
          'bg-secondary-muted',
          'text-on-secondary',
          'hover:bg-secondary-firm',
          'focus-visible:ring-secondary-soft'
        ]
      },
      tertiary: {
        dot: 'bg-tertiary',
        closeButton: [
          'bg-tertiary-muted',
          'text-on-tertiary',
          'hover:bg-tertiary-firm',
          'focus-visible:ring-tertiary-soft'
        ]
      },
      success: {
        dot: 'bg-success',
        closeButton: [
          'bg-success-muted',
          'text-on-success',
          'hover:bg-success-firm',
          'focus-visible:ring-success-soft'
        ]
      },
      warning: {
        dot: 'bg-warning',
        closeButton: [
          'bg-warning-muted',
          'text-on-warning',
          'hover:bg-warning-firm',
          'focus-visible:ring-warning-soft'
        ]
      },
      danger: {
        dot: 'bg-danger',
        closeButton: [
          'bg-danger-muted',
          'text-on-danger',
          'hover:bg-danger-firm',
          'focus-visible:ring-danger-soft'
        ]
      }
    },
    size: {
      sm: {
        base: 'text-label-2xs px-1 h-6',
        content: 'px-1',
        closeButton: 'text-label-2xs'
      },
      md: {
        base: 'text-label-xs px-1 h-7',
        content: 'px-2',
        closeButton: 'text-label-xs'
      },
      lg: {
        base: 'text-label-md px-2 h-8',
        content: 'px-2',
        closeButton: 'text-label-md'
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
        base: 'bg-neutral-bolder text-on-neutral-bolder'
      }
    },
    {
      appearance: 'default',
      intent: 'primary',
      class: {
        base: 'bg-primary text-on-primary'
      }
    },
    {
      appearance: 'default',
      intent: 'secondary',
      class: {
        base: 'bg-secondary text-on-secondary'
      }
    },
    {
      appearance: 'default',
      intent: 'tertiary',
      class: {
        base: 'bg-tertiary text-on-tertiary'
      }
    },
    {
      appearance: 'default',
      intent: 'success',
      class: {
        base: 'bg-success text-on-success'
      }
    },
    {
      appearance: 'default',
      intent: 'warning',
      class: {
        base: 'bg-warning text-on-warning'
      }
    },
    {
      appearance: 'default',
      intent: 'danger',
      class: {
        base: 'bg-danger text-on-danger'
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
      intent: 'secondary',
      class: {
        base: 'text-secondary-strong bg-secondary-subtle'
      }
    },
    {
      appearance: 'faded',
      intent: 'tertiary',
      class: {
        base: 'text-tertiary-strong bg-tertiary-subtle'
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
        base: 'text-neutral-strong border border-neutral'
      }
    },
    {
      appearance: 'outlined',
      intent: 'primary',
      class: {
        base: 'text-primary-strong border border-primary'
      }
    },
    {
      appearance: 'outlined',
      intent: 'secondary',
      class: {
        base: 'text-secondary-strong border border-secondary'
      }
    },
    {
      appearance: 'outlined',
      intent: 'tertiary',
      class: {
        base: 'text-tertiary-strong border border-tertiary'
      }
    },
    {
      appearance: 'outlined',
      intent: 'success',
      class: {
        base: 'text-success-strong border border-success'
      }
    },
    {
      appearance: 'outlined',
      intent: 'warning',
      class: {
        base: 'text-warning-strong border border-warning'
      }
    },
    {
      appearance: 'outlined',
      intent: 'danger',
      class: {
        base: 'text-danger-strong border border-danger'
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
