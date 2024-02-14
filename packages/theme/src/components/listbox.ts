import { tv } from 'tailwind-variants';

const listbox = tv({
  base: 'w-full flex flex-col gap-0.5 outline-none p-1'
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
      'rounded',
      'subpixel-antialiased',
      'outline-none',
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
    selectedIcon: ['text-inherit', 'w-4', 'h-4', 'flex-shrink-0'],
    shortcut: [
      'px-1',
      'py-0.5',
      'rounded',
      'font-sans',
      'text-foreground-500',
      'text-xs',
      'border',
      'border-default-300',
      'group-data-is-active:border-current'
    ]
  },
  variants: {
    appearence: {
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
    appearence: 'default',
    intent: 'default'
  },
  compoundVariants: [
    // appearence: default
    {
      appearence: 'default',
      intent: 'default',
      class: {
        base: [
          'data-is-active:bg-default',
          'data-is-active:text-default-foreground'
        ]
      }
    },
    {
      appearence: 'default',
      intent: 'primary',
      class: {
        base: [
          'data-is-active:bg-primary-500',
          'data-is-active:text-primary-foreground'
        ]
      }
    },
    {
      appearence: 'default',
      intent: 'success',
      class: {
        base: [
          'data-is-active:bg-success-500',
          'data-is-active:text-success-foreground'
        ]
      }
    },
    {
      appearence: 'default',
      intent: 'warning',
      class: {
        base: [
          'data-is-active:bg-warning-500',
          'data-is-active:text-warning-foreground'
        ]
      }
    },
    {
      appearence: 'default',
      intent: 'danger',
      class: {
        base: [
          'data-is-active:bg-danger-500',
          'data-is-active:text-danger-foreground'
        ]
      }
    },
    {
      appearence: 'default',
      intent: 'primary',
      isActive: true,
      class: {
        shortcut: ['text-primary-foreground']
      }
    },
    {
      appearence: 'default',
      intent: 'success',
      isActive: true,
      class: {
        shortcut: ['text-success-foreground']
      }
    },
    {
      appearence: 'default',
      intent: 'warning',
      isActive: true,
      class: {
        shortcut: ['text-warning-foreground']
      }
    },
    {
      appearence: 'default',
      intent: 'danger',
      isActive: true,
      class: {
        shortcut: ['text-danger-foreground']
      }
    },

    // appearence: outlined
    {
      appearence: 'outlined',
      intent: 'default',
      class: {
        base: [
          'data-is-active:border-default-700',
          'data-is-active:text-default-700'
        ]
      }
    },
    {
      appearence: 'outlined',
      intent: 'primary',
      class: {
        base: ['data-is-active:border-primary', 'data-is-active:text-primary']
      }
    },
    {
      appearence: 'outlined',
      intent: 'success',
      class: {
        base: ['data-is-active:border-success', 'data-is-active:text-success']
      }
    },
    {
      appearence: 'outlined',
      intent: 'warning',
      class: {
        base: ['data-is-active:border-warning', 'data-is-active:text-warning']
      }
    },
    {
      appearence: 'outlined',
      intent: 'danger',
      class: {
        base: ['data-is-active:border-danger', 'data-is-active:text-danger']
      }
    },

    // appearence: faded
    {
      appearence: 'faded',
      intent: 'default',
      class: {
        base: [
          'data-is-active:bg-default-400/20',
          'data-is-active:border-default-700',
          'data-is-active:text-default-700'
        ]
      }
    },
    {
      appearence: 'faded',
      intent: 'primary',
      class: {
        base: [
          'data-is-active:bg-primary-300/20',
          'data-is-active:border-primary',
          'data-is-active:text-primary'
        ]
      }
    },
    {
      appearence: 'faded',
      intent: 'success',
      class: {
        base: [
          'data-is-active:bg-success-300/20',
          'data-is-active:border-success',
          'data-is-active:text-success'
        ]
      }
    },
    {
      appearence: 'faded',
      intent: 'warning',
      class: {
        base: [
          'data-is-active:bg-warning-300/20',
          'data-is-active:border-warning',
          'data-is-active:text-warning'
        ]
      }
    },
    {
      appearence: 'faded',
      intent: 'danger',
      class: {
        base: [
          'data-is-active:bg-danger-300/20',
          'data-is-active:border-danger',
          'data-is-active:text-danger'
        ]
      }
    }
  ]
});

export { listbox, listboxItem };
