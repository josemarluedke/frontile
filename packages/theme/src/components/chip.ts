import { tv } from '../tw';

const chip = tv({
  slots: {
    base: [
      'whitespace-nowrap',
      'inline-flex items-center justify-between box-border'
    ],
    // label text role (size set per size variant)
    content: ['flex-1 text-inherit font-label'],
    dot: ['shrink-0', 'ml-1', 'rounded-full'],
    closeButton: [
      'shrink-0',
      'p-0.5',
      // The shared ring is drawn with a background-coloured offset, which
      // inside a chip reads as a hole punched in the chip.
      'focus-visible:ring-2 focus-visible:ring-offset-0',
      'disabled:cursor-not-allowed'
    ]
  },
  variants: {
    isDisabled: {
      true: 'opacity-disabled cursor-not-allowed'
    },
    variant: {
      solid: '',
      outline: '',
      soft: ''
    },
    // The close button is a filled circle in every variant. `-muted` is
    // light enough to sit on the page in `outline`/`soft` and to read as a
    // disc on a filled chip, and each level carries its own `on-` colour — the
    // pairing this used to get wrong, by putting `text-on-{intent}` (the
    // contrast colour for the DEFAULT level) on a `-muted` circle.
    intent: {
      default: {
        dot: 'bg-neutral-strong',
        closeButton: 'bg-neutral-muted text-on-neutral-muted'
      },
      primary: {
        dot: 'bg-primary',
        closeButton: 'bg-primary-muted text-on-primary-muted'
      },
      secondary: {
        dot: 'bg-secondary',
        closeButton: 'bg-secondary-muted text-on-secondary-muted'
      },
      tertiary: {
        dot: 'bg-tertiary',
        closeButton: 'bg-tertiary-muted text-on-tertiary-muted'
      },
      success: {
        dot: 'bg-success',
        closeButton: 'bg-success-muted text-on-success-muted'
      },
      warning: {
        dot: 'bg-warning',
        closeButton: 'bg-warning-muted text-on-warning-muted'
      },
      danger: {
        dot: 'bg-danger',
        closeButton: 'bg-danger-muted text-on-danger-muted'
      }
    },
    size: {
      sm: {
        base: 'text-label-2xs px-1 h-6',
        content: 'px-1',
        dot: 'size-1.5',
        closeButton: 'text-label-2xs'
      },
      md: {
        base: 'text-label-xs px-1 h-7',
        content: 'px-2',
        dot: 'size-2',
        closeButton: 'text-label-xs'
      },
      lg: {
        base: 'text-label-md px-2 h-8',
        content: 'px-2',
        dot: 'size-2.5',
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
    // A filled chip's background *is* the intent colour, so an intent-coloured
    // dot disappears into it. Inherit the chip's text colour instead — the one
    // colour guaranteed to contrast the fill.
    {
      variant: 'solid',
      class: {
        dot: 'bg-current'
      }
    },

    // VARIANT: solid (filled)
    //
    // The chip's own fill is the intent's DEFAULT level, so the close button
    // cannot hover *towards* it the way the other two variants do — the
    // circle would vanish into the chip. It steps down to `-subtle` instead.
    {
      variant: 'solid',
      intent: 'default',
      class: {
        base: 'bg-neutral-bolder text-on-neutral-bolder',
        closeButton: 'hover:bg-neutral-subtle hover:text-on-neutral-subtle'
      }
    },
    {
      variant: 'solid',
      intent: 'primary',
      class: {
        base: 'bg-primary text-on-primary',
        closeButton: 'hover:bg-primary-subtle hover:text-on-primary-subtle'
      }
    },
    {
      variant: 'solid',
      intent: 'secondary',
      class: {
        base: 'bg-secondary text-on-secondary',
        closeButton: 'hover:bg-secondary-subtle hover:text-on-secondary-subtle'
      }
    },
    {
      variant: 'solid',
      intent: 'tertiary',
      class: {
        base: 'bg-tertiary text-on-tertiary',
        closeButton: 'hover:bg-tertiary-subtle hover:text-on-tertiary-subtle'
      }
    },
    {
      variant: 'solid',
      intent: 'success',
      class: {
        base: 'bg-success text-on-success',
        closeButton: 'hover:bg-success-subtle hover:text-on-success-subtle'
      }
    },
    {
      variant: 'solid',
      intent: 'warning',
      class: {
        base: 'bg-warning text-on-warning',
        closeButton: 'hover:bg-warning-subtle hover:text-on-warning-subtle'
      }
    },
    {
      variant: 'solid',
      intent: 'danger',
      class: {
        base: 'bg-danger text-on-danger',
        closeButton: 'hover:bg-danger-subtle hover:text-on-danger-subtle'
      }
    },

    // VARIANT: soft (tonal)
    {
      variant: 'soft',
      intent: 'default',
      class: {
        base: 'text-neutral-strong bg-neutral-subtle',
        closeButton: 'hover:bg-neutral hover:text-on-neutral'
      }
    },
    {
      variant: 'soft',
      intent: 'primary',
      class: {
        base: 'text-primary-strong bg-primary-subtle',
        closeButton: 'hover:bg-primary hover:text-on-primary'
      }
    },
    {
      variant: 'soft',
      intent: 'secondary',
      class: {
        base: 'text-secondary-strong bg-secondary-subtle',
        closeButton: 'hover:bg-secondary hover:text-on-secondary'
      }
    },
    {
      variant: 'soft',
      intent: 'tertiary',
      class: {
        base: 'text-tertiary-strong bg-tertiary-subtle',
        closeButton: 'hover:bg-tertiary hover:text-on-tertiary'
      }
    },
    {
      variant: 'soft',
      intent: 'success',
      class: {
        base: 'text-success-strong bg-success-subtle',
        closeButton: 'hover:bg-success hover:text-on-success'
      }
    },
    {
      variant: 'soft',
      intent: 'warning',
      class: {
        base: 'text-warning-strong bg-warning-subtle',
        closeButton: 'hover:bg-warning hover:text-on-warning'
      }
    },
    {
      variant: 'soft',
      intent: 'danger',
      class: {
        base: 'text-danger-strong bg-danger-subtle',
        closeButton: 'hover:bg-danger hover:text-on-danger'
      }
    },

    // VARIANT: outline
    {
      variant: 'outline',
      intent: 'default',
      class: {
        base: 'text-neutral-strong border border-neutral',
        closeButton: 'hover:bg-neutral hover:text-on-neutral'
      }
    },
    {
      variant: 'outline',
      intent: 'primary',
      class: {
        base: 'text-primary-strong border border-primary',
        closeButton: 'hover:bg-primary hover:text-on-primary'
      }
    },
    {
      variant: 'outline',
      intent: 'secondary',
      class: {
        base: 'text-secondary-strong border border-secondary',
        closeButton: 'hover:bg-secondary hover:text-on-secondary'
      }
    },
    {
      variant: 'outline',
      intent: 'tertiary',
      class: {
        base: 'text-tertiary-strong border border-tertiary',
        closeButton: 'hover:bg-tertiary hover:text-on-tertiary'
      }
    },
    {
      variant: 'outline',
      intent: 'success',
      class: {
        base: 'text-success-strong border border-success',
        closeButton: 'hover:bg-success hover:text-on-success'
      }
    },
    {
      variant: 'outline',
      intent: 'warning',
      class: {
        base: 'text-warning-strong border border-warning',
        closeButton: 'hover:bg-warning hover:text-on-warning'
      }
    },
    {
      variant: 'outline',
      intent: 'danger',
      class: {
        base: 'text-danger-strong border border-danger',
        closeButton: 'hover:bg-danger hover:text-on-danger'
      }
    }
  ],
  defaultVariants: {
    size: 'md',
    intent: 'default',
    variant: 'solid',
    radius: 'full'
  }
});

export { chip };
