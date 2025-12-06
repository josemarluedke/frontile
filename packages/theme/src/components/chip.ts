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
        dot: 'bg-neutral-strong dark:bg-neutral-medium',
        closeButton: [
          'bg-neutral-soft',
          'text-neutral-contrast-1 dark:text-background',
          'dark:bg-neutral-medium',
          'hover:bg-neutral-soft/60 dark:hover:bg-neutral-medium/60'
        ]
      },
      primary: {
        dot: 'bg-brand',
        closeButton: [
          'bg-brand-medium',
          'text-background',
          'hover:bg-brand-medium/60',
          'focus-visible:ring-brand-medium'
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
        base: 'bg-neutral-strong text-neutral-contrast-1 dark:bg-neutral dark:text-inverse-strong'
      }
    },
    {
      appearance: 'default',
      intent: 'primary',
      class: {
        base: 'bg-brand text-brand-contrast-1'
      }
    },
    {
      appearance: 'default',
      intent: 'success',
      class: {
        base: 'bg-success text-success-contrast-1'
      }
    },
    {
      appearance: 'default',
      intent: 'warning',
      class: {
        base: 'bg-warning text-warning-contrast-1'
      }
    },
    {
      appearance: 'default',
      intent: 'danger',
      class: {
        base: 'bg-danger text-danger-contrast-1'
      }
    },

    // APPEARANCE: faded
    {
      appearance: 'faded',
      intent: 'default',
      class: {
        base: 'text-neutral-medium border border-neutral-medium bg-neutral-soft/20'
      }
    },
    {
      appearance: 'faded',
      intent: 'primary',
      class: {
        base: 'text-brand border border-brand-medium bg-brand-soft/20'
      }
    },
    {
      appearance: 'faded',
      intent: 'success',
      class: {
        base: 'text-success border border-success bg-success-soft/20'
      }
    },
    {
      appearance: 'faded',
      intent: 'warning',
      class: {
        base: 'text-warning border border-warning bg-warning-soft/20'
      }
    },
    {
      appearance: 'faded',
      intent: 'danger',
      class: {
        base: 'text-danger border border-danger bg-danger-soft/20'
      }
    },

    // APPEARANCE: outlined
    {
      appearance: 'outlined',
      intent: 'default',
      class: {
        base: 'text-neutral-medium border border-neutral-medium'
      }
    },
    {
      appearance: 'outlined',
      intent: 'primary',
      class: {
        base: 'text-brand border border-brand-medium'
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
