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
      'rounded-lg',
      'subpixel-antialiased',
      'outline-hidden',
      'cursor-pointer',
      'tap-highlight-transparent'
    ],
    descriptionWrapper: 'w-full flex flex-col items-start justify-center',
    label: 'flex-1 font-body text-body-2xs truncate',
    description: [
      'w-full',
      'font-body text-body-2xs',
      'text-neutral-firm',
      'group-hover:text-current'
    ],
    selectedIcon: ['text-inherit', 'w-4', 'h-4', 'shrink-0'],
    // The chevron on a row that opens a submenu. Sized like `selectedIcon`
    // -- both are trailing affordances on the same row -- but dimmer at rest,
    // since it marks a direction rather than a state. `text-inherit` on the
    // active row lets it pick up the row's own colour.
    submenuIndicator: [
      'text-neutral-firm',
      'group-data-is-active:text-inherit',
      'w-4',
      'h-4',
      'shrink-0'
    ]
  },
  variants: {
    variant: {
      solid: {
        base: ''
      },
      outline: {
        base: 'border border-transparent bg-transparent'
      },
      subtle: {
        base: ['border border-transparent']
      }
    },
    intent: {
      default: {},
      primary: {},
      secondary: {},
      tertiary: {},
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
    variant: 'solid',
    intent: 'default'
  },
  compoundVariants: [
    // variant: solid
    {
      variant: 'solid',
      intent: 'default',
      class: {
        base: [
          'data-is-active:bg-neutral-subtle',
          'data-is-active:text-neutral-strong'
        ]
      }
    },
    {
      variant: 'solid',
      intent: 'primary',
      class: {
        base: [
          'data-is-active:bg-primary-soft',
          'data-is-active:text-on-primary-soft'
        ]
      }
    },
    {
      variant: 'solid',
      intent: 'secondary',
      class: {
        base: [
          'data-is-active:bg-secondary-soft',
          'data-is-active:text-on-secondary-soft'
        ]
      }
    },
    {
      variant: 'solid',
      intent: 'tertiary',
      class: {
        base: [
          'data-is-active:bg-tertiary-soft',
          'data-is-active:text-on-tertiary-soft'
        ]
      }
    },
    {
      variant: 'solid',
      intent: 'success',
      class: {
        base: [
          'data-is-active:bg-success-soft',
          'data-is-active:text-on-success-soft'
        ]
      }
    },
    {
      variant: 'solid',
      intent: 'warning',
      class: {
        base: [
          'data-is-active:bg-warning-soft',
          'data-is-active:text-on-warning-soft'
        ]
      }
    },
    {
      variant: 'solid',
      intent: 'danger',
      class: {
        base: [
          'data-is-active:bg-danger-soft',
          'data-is-active:text-on-danger-soft'
        ]
      }
    },

    // variant: outline
    {
      variant: 'outline',
      intent: 'default',
      class: {
        base: [
          'data-is-active:border-neutral',
          'data-is-active:text-neutral-strong'
        ]
      }
    },
    {
      variant: 'outline',
      intent: 'primary',
      class: {
        base: [
          'data-is-active:border-primary',
          'data-is-active:text-primary-strong'
        ]
      }
    },
    {
      variant: 'outline',
      intent: 'secondary',
      class: {
        base: [
          'data-is-active:border-secondary',
          'data-is-active:text-secondary-strong'
        ]
      }
    },
    {
      variant: 'outline',
      intent: 'tertiary',
      class: {
        base: [
          'data-is-active:border-tertiary',
          'data-is-active:text-tertiary-strong'
        ]
      }
    },
    {
      variant: 'outline',
      intent: 'success',
      class: {
        base: [
          'data-is-active:border-success',
          'data-is-active:text-success-strong'
        ]
      }
    },
    {
      variant: 'outline',
      intent: 'warning',
      class: {
        base: [
          'data-is-active:border-warning',
          'data-is-active:text-warning-strong'
        ]
      }
    },
    {
      variant: 'outline',
      intent: 'danger',
      class: {
        base: [
          'data-is-active:border-danger',
          'data-is-active:text-danger-strong'
        ]
      }
    },

    // variant: subtle
    {
      variant: 'subtle',
      intent: 'default',
      class: {
        base: [
          'data-is-active:bg-neutral-soft/20',
          'data-is-active:border-neutral',
          'data-is-active:text-neutral-strong'
        ]
      }
    },
    {
      variant: 'subtle',
      intent: 'primary',
      class: {
        base: [
          'data-is-active:bg-primary-soft/20',
          'data-is-active:border-primary',
          'data-is-active:text-primary-strong'
        ]
      }
    },
    {
      variant: 'subtle',
      intent: 'secondary',
      class: {
        base: [
          'data-is-active:bg-secondary-soft/20',
          'data-is-active:border-secondary',
          'data-is-active:text-secondary-strong'
        ]
      }
    },
    {
      variant: 'subtle',
      intent: 'tertiary',
      class: {
        base: [
          'data-is-active:bg-tertiary-soft/20',
          'data-is-active:border-tertiary',
          'data-is-active:text-tertiary-strong'
        ]
      }
    },
    {
      variant: 'subtle',
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
      variant: 'subtle',
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
      variant: 'subtle',
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

const listboxGroup = tv({
  slots: {
    base: 'block',
    // Spacing for the separator a group renders after itself, so the value
    // lives here rather than being repeated at each call site.
    divider: 'my-1',
    // `block`: the heading is a <span>, and an inline box's vertical padding
    // is painted without taking up space -- so without this the rows sit
    // directly under the heading text whatever padding it is given.
    title: [
      'block',
      'px-2',
      'py-1.5',
      'font-body text-body-2xs font-medium',
      'text-neutral',
      'select-none'
    ],
    list: 'flex flex-col gap-0.5'
  }
});

export { listbox, listboxItem, listboxGroup };
