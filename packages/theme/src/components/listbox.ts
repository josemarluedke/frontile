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
      'text-foreground-500',
      'group-hover:text-current'
    ],
    selectedIcon: ['text-inherit', 'w-4', 'h-4', 'shrink-0'],
    shortcut: [
      'px-1',
      'py-0.5',
      'rounded-sm',
      'font-sans',
      'text-foreground-500',
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
          'data-is-active:bg-neutral',
          'data-is-active:text-neutral-contrast-1'
        ]
      }
    },
    {
      appearance: 'default',
      intent: 'primary',
      class: {
        base: [
          'data-is-active:bg-brand-soft',
          'data-is-active:text-brand-contrast-1'
        ]
      }
    },
    {
      appearance: 'default',
      intent: 'success',
      class: {
        base: [
          'data-is-active:bg-success-soft',
          'data-is-active:text-success-contrast-1'
        ]
      }
    },
    {
      appearance: 'default',
      intent: 'warning',
      class: {
        base: [
          'data-is-active:bg-warning-soft',
          'data-is-active:text-warning-contrast-1'
        ]
      }
    },
    {
      appearance: 'default',
      intent: 'danger',
      class: {
        base: [
          'data-is-active:bg-danger-soft',
          'data-is-active:text-danger-contrast-1'
        ]
      }
    },
    {
      appearance: 'default',
      intent: 'primary',
      isActive: true,
      class: {
        shortcut: ['text-brand-contrast-1']
      }
    },
    {
      appearance: 'default',
      intent: 'success',
      isActive: true,
      class: {
        shortcut: ['text-success-contrast-1']
      }
    },
    {
      appearance: 'default',
      intent: 'warning',
      isActive: true,
      class: {
        shortcut: ['text-warning-contrast-1']
      }
    },
    {
      appearance: 'default',
      intent: 'danger',
      isActive: true,
      class: {
        shortcut: ['text-danger-contrast-1']
      }
    },

    // appearance: outlined
    {
      appearance: 'outlined',
      intent: 'default',
      class: {
        base: [
          'data-is-active:border-neutral-medium',
          'data-is-active:text-neutral-medium'
        ]
      }
    },
    {
      appearance: 'outlined',
      intent: 'primary',
      class: {
        base: ['data-is-active:border-brand-medium', 'data-is-active:text-brand']
      }
    },
    {
      appearance: 'outlined',
      intent: 'success',
      class: {
        base: ['data-is-active:border-success', 'data-is-active:text-success']
      }
    },
    {
      appearance: 'outlined',
      intent: 'warning',
      class: {
        base: ['data-is-active:border-warning', 'data-is-active:text-warning']
      }
    },
    {
      appearance: 'outlined',
      intent: 'danger',
      class: {
        base: ['data-is-active:border-danger', 'data-is-active:text-danger']
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
          'data-is-active:text-neutral-medium'
        ]
      }
    },
    {
      appearance: 'faded',
      intent: 'primary',
      class: {
        base: [
          'data-is-active:bg-brand-soft/20',
          'data-is-active:border-brand-medium',
          'data-is-active:text-brand'
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
          'data-is-active:text-success'
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
          'data-is-active:text-warning'
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
          'data-is-active:text-danger'
        ]
      }
    }
  ]
});

export { listbox, listboxItem };
