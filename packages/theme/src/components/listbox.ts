import { tv } from 'tailwind-variants';

const listbox = tv({
  slots: {
    base: 'w-full relative flex flex-col gap-1 p-1',
    list: 'w-full flex flex-col gap-0.5 outline-none'
  }
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
      'group-hover:border-current'
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
          'data-[active=true]:bg-default',
          'data-[active=true]:text-default-foreground'
        ]
      }
    },
    {
      appearence: 'default',
      intent: 'primary',
      class: {
        base: [
          'data-[active=true]:bg-primary',
          'data-[active=true]:text-primary-foreground'
        ]
      }
    },
    {
      appearence: 'default',
      intent: 'success',
      class: {
        base: [
          'data-[active=true]:bg-success',
          'data-[active=true]:text-success-foreground'
        ]
      }
    },
    {
      appearence: 'default',
      intent: 'warning',
      class: {
        base: [
          'data-[active=true]:bg-warning',
          'data-[active=true]:text-warning-foreground'
        ]
      }
    },
    {
      appearence: 'default',
      intent: 'danger',
      class: {
        base: [
          'data-[active=true]:bg-danger',
          'data-[active=true]:text-danger-foreground'
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
          'data-[active=true]:border-default-700',
          'data-[active=true]:text-default-700'
        ]
      }
    },
    {
      appearence: 'outlined',
      intent: 'primary',
      class: {
        base: [
          'data-[active=true]:border-primary',
          'data-[active=true]:text-primary'
        ]
      }
    },
    {
      appearence: 'outlined',
      intent: 'success',
      class: {
        base: [
          'data-[active=true]:border-success',
          'data-[active=true]:text-success'
        ]
      }
    },
    {
      appearence: 'outlined',
      intent: 'warning',
      class: {
        base: [
          'data-[active=true]:border-warning',
          'data-[active=true]:text-warning'
        ]
      }
    },
    {
      appearence: 'outlined',
      intent: 'danger',
      class: {
        base: [
          'data-[active=true]:border-danger',
          'data-[active=true]:text-danger'
        ]
      }
    },

    // appearence: faded
    {
      appearence: 'faded',
      intent: 'default',
      class: {
        base: [
          'data-[active=true]:bg-default-700/20',
          'data-[active=true]:border-default-700',
          'data-[active=true]:text-default-700'
        ]
      }
    },
    {
      appearence: 'faded',
      intent: 'primary',
      class: {
        base: [
          'data-[active=true]:bg-primary/20',
          'data-[active=true]:border-primary-600',
          'data-[active=true]:text-primary-600'
        ]
      }
    },
    {
      appearence: 'faded',
      intent: 'success',
      class: {
        base: [
          'data-[active=true]:bg-success/20',
          'data-[active=true]:border-success-600',
          'data-[active=true]:text-success-600'
        ]
      }
    },
    {
      appearence: 'faded',
      intent: 'warning',
      class: {
        base: [
          'data-[active=true]:bg-warning/20',
          'data-[active=true]:border-warning-600',
          'data-[active=true]:text-warning-600'
        ]
      }
    },
    {
      appearence: 'faded',
      intent: 'danger',
      class: {
        base: [
          'data-[active=true]:bg-danger/20',
          'data-[active=true]:border-danger-600',
          'data-[active=true]:text-danger-600'
        ]
      }
    }
  ]
});

export { listbox, listboxItem };
