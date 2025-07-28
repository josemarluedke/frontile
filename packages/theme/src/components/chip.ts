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
        dot: 'bg-default-800 dark:bg-default-700',
        closeButton: [
          'bg-default-400',
          'text-default-foreground dark:text-default-background',
          'dark:bg-default-600',
          'hover:bg-default-400/60 dark:hover:bg-default-600/60'
        ]
      },
      primary: {
        dot: 'bg-primary',
        closeButton: [
          'bg-primary-700',
          'text-background',
          'hover:bg-primary-700/60',
          'focus-visible:ring-primary-700'
        ]
      },
      success: {
        dot: 'bg-success',
        closeButton: [
          'bg-success',
          'text-background',
          'hover:bg-success/60',
          'focus-visible:ring-success'
        ]
      },
      warning: {
        dot: 'bg-warning',
        closeButton: [
          'bg-warning',
          'text-background',
          'hover:bg-warning/60',
          'focus-visible:ring-warning'
        ]
      },
      danger: {
        dot: 'bg-danger',
        closeButton: [
          'bg-danger',
          'text-background',
          'hover:bg-danger/60',
          'focus-visible:ring-danger'
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
    // APPEARANCE: default
    {
      appearance: 'default',
      intent: 'default',
      class: {
        base: 'bg-default-800 text-default-50 dark:bg-default dark:text-default-950'
      }
    },
    {
      appearance: 'default',
      intent: 'primary',
      class: {
        base: 'bg-primary text-primary-foreground'
      }
    },
    {
      appearance: 'default',
      intent: 'success',
      class: {
        base: 'bg-success text-success-foreground'
      }
    },
    {
      appearance: 'default',
      intent: 'warning',
      class: {
        base: 'bg-warning text-warning-foreground'
      }
    },
    {
      appearance: 'default',
      intent: 'danger',
      class: {
        base: 'bg-danger text-danger-foreground'
      }
    },

    // APPEARANCE: faded
    {
      appearance: 'faded',
      intent: 'default',
      class: {
        base: 'text-default-700 border border-default-700 bg-default-400/20'
      }
    },
    {
      appearance: 'faded',
      intent: 'primary',
      class: {
        base: 'text-primary border border-primary bg-primary-300/20'
      }
    },
    {
      appearance: 'faded',
      intent: 'success',
      class: {
        base: 'text-success border border-success bg-success-300/20'
      }
    },
    {
      appearance: 'faded',
      intent: 'warning',
      class: {
        base: 'text-warning border border-warning bg-warning-300/20'
      }
    },
    {
      appearance: 'faded',
      intent: 'danger',
      class: {
        base: 'text-danger border border-danger bg-danger-300/20'
      }
    },

    // APPEARANCE: outlined
    {
      appearance: 'outlined',
      intent: 'default',
      class: {
        base: 'text-default-700 border border-default-700'
      }
    },
    {
      appearance: 'outlined',
      intent: 'primary',
      class: {
        base: 'text-primary border border-primary'
      }
    },
    {
      appearance: 'outlined',
      intent: 'success',
      class: {
        base: 'text-success border border-success'
      }
    },
    {
      appearance: 'outlined',
      intent: 'warning',
      class: {
        base: 'text-warning border border-warning'
      }
    },
    {
      appearance: 'outlined',
      intent: 'danger',
      class: {
        base: 'text-danger border border-danger'
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
