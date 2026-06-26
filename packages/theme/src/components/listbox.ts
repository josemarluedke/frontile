import { tv } from '../tw';

const listbox = tv({
  base: 'w-full flex flex-col gap-0.5 outline-hidden p-1'
});

const listboxItem = tv({
  slots: {
    base: [
      'flex',
      'group',
      'gap-2',
      'items-center',
      'justify-between',
      'relative',
      'px-2',
      'py-1.5',
      'w-full',
      'h-full',
      'box-border',
      'rounded-sm',
      'subpixel-antialiased',
      'outline-hidden',
      'cursor-pointer',
      'tap-highlight-transparent'
    ],
    descriptionWrapper: 'w-full flex flex-col items-start justify-center',
    label: 'flex-1 text-sm font-normal truncate',
    description: [
      'w-full',
      'text-xs',
      'text-neutral-firm',
      'group-hover:text-current'
    ],
    selectedIcon: ['text-inherit', 'w-4', 'h-4', 'shrink-0'],
    shortcut: [
      'px-1',
      'py-0.5',
      'rounded-sm',
      'font-sans',
      'text-neutral-medium',
      'text-xs',
      'border',
      'border-neutral-soft',
      'group-data-is-active:border-current'
    ]
  },
  variants: {
    appearance: {
      default: {
        base: ''
      },
      outlined: {
        base: 'border border-transparent bg-transparent'
      },
      faded: {
        base: ['border border-transparent']
      }
    },
    intent: {
      default: {},
      primary: {},
      secondary: {},
      accent: {},
      success: {},
      warning: {},
      danger: {}
    },
    isActive: { true: { base: [] } },

    withDivider: {
      true: {
        base: ['mb-1.5']
      }
    },

    isDisabled: {
      true: {
        base: 'opacity-disabled pointer-events-none'
      }
    },
    isSelected: {
      true: {
        base: ''
      }
    }
  },
  defaultVariants: {
    appearance: 'default',
    intent: 'default'
  },
  compoundVariants: [
    // appearance: default
    {
      appearance: 'default',
      intent: 'default',
      class: {
        base: [
          'data-is-active:bg-neutral-subtle',
          'data-is-active:text-neutral-strong'
        ]
      }
    },
    {
      appearance: 'default',
      intent: 'primary',
      class: {
        base: [
          'data-is-active:bg-primary-soft',
          'data-is-active:text-on-primary-soft'
        ]
      }
    },
    {
      appearance: 'default',
      intent: 'accent',
      class: {
        base: [
          'data-is-active:bg-accent-soft',
          'data-is-active:text-on-accent-soft'
        ]
      }
    },
    {
      appearance: 'default',
      intent: 'success',
      class: {
        base: [
          'data-is-active:bg-success-soft',
          'data-is-active:text-on-success-soft'
        ]
      }
    },
    {
      appearance: 'default',
      intent: 'warning',
      class: {
        base: [
          'data-is-active:bg-warning-soft',
          'data-is-active:text-on-warning-soft'
        ]
      }
    },
    {
      appearance: 'default',
      intent: 'danger',
      class: {
        base: [
          'data-is-active:bg-danger-soft',
          'data-is-active:text-on-danger-soft'
        ]
      }
    },
    {
      appearance: 'default',
      intent: 'default',
      isActive: true,
      class: {
        shortcut: ['text-on-neutral', 'border-on-neutral/20']
      }
    },
    {
      appearance: 'default',
      intent: 'primary',
      isActive: true,
      class: {
        shortcut: ['text-on-primary-soft', 'border-on-primary-soft/20']
      }
    },
    {
      appearance: 'default',
      intent: 'accent',
      isActive: true,
      class: {
        shortcut: ['text-on-accent-soft', 'border-on-accent-soft/20']
      }
    },
    {
      appearance: 'default',
      intent: 'success',
      isActive: true,
      class: {
        shortcut: ['text-on-success-soft', 'border-on-success-soft/20']
      }
    },
    {
      appearance: 'default',
      intent: 'warning',
      isActive: true,
      class: {
        shortcut: ['text-on-warning-soft', 'border-on-warning-soft/20']
      }
    },
    {
      appearance: 'default',
      intent: 'danger',
      isActive: true,
      class: {
        shortcut: ['text-on-danger-soft', 'border-on-danger-soft/20']
      }
    },

    // appearance: outlined
    {
      appearance: 'outlined',
      intent: 'default',
      class: {
        base: [
          'data-is-active:border-neutral-medium',
          'data-is-active:text-neutral-strong'
        ]
      }
    },
    {
      appearance: 'outlined',
      intent: 'primary',
      class: {
        base: [
          'data-is-active:border-primary-medium',
          'data-is-active:text-primary-strong'
        ]
      }
    },
    {
      appearance: 'outlined',
      intent: 'accent',
      class: {
        base: [
          'data-is-active:border-accent-medium',
          'data-is-active:text-accent-strong'
        ]
      }
    },
    {
      appearance: 'outlined',
      intent: 'success',
      class: {
        base: [
          'data-is-active:border-success',
          'data-is-active:text-success-strong'
        ]
      }
    },
    {
      appearance: 'outlined',
      intent: 'warning',
      class: {
        base: [
          'data-is-active:border-warning',
          'data-is-active:text-warning-strong'
        ]
      }
    },
    {
      appearance: 'outlined',
      intent: 'danger',
      class: {
        base: [
          'data-is-active:border-danger',
          'data-is-active:text-danger-strong'
        ]
      }
    },

    // appearance: faded
    {
      appearance: 'faded',
      intent: 'default',
      class: {
        base: [
          'data-is-active:bg-neutral-soft/20',
          'data-is-active:border-neutral-medium',
          'data-is-active:text-neutral-strong'
        ]
      }
    },
    {
      appearance: 'faded',
      intent: 'primary',
      class: {
        base: [
          'data-is-active:bg-primary-soft/20',
          'data-is-active:border-primary-medium',
          'data-is-active:text-primary-strong'
        ]
      }
    },
    {
      appearance: 'faded',
      intent: 'accent',
      class: {
        base: [
          'data-is-active:bg-accent-soft/20',
          'data-is-active:border-accent-medium',
          'data-is-active:text-accent-strong'
        ]
      }
    },
    {
      appearance: 'faded',
      intent: 'success',
      class: {
        base: [
          'data-is-active:bg-success-soft/20',
          'data-is-active:border-success',
          'data-is-active:text-success-strong'
        ]
      }
    },
    {
      appearance: 'faded',
      intent: 'warning',
      class: {
        base: [
          'data-is-active:bg-warning-soft/20',
          'data-is-active:border-warning',
          'data-is-active:text-warning-strong'
        ]
      }
    },
    {
      appearance: 'faded',
      intent: 'danger',
      class: {
        base: [
          'data-is-active:bg-danger-soft/20',
          'data-is-active:border-danger',
          'data-is-active:text-danger-strong'
        ]
      }
    }
  ]
});

export { listbox, listboxItem };
