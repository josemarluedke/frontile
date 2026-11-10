import { tv } from '../tw';

const chip = tv({
  slots: {
    base: [
      'whitespace-nowrap',
      'inline-flex items-center justify-between box-border rounded-full'
    ],
    // The clickable part: a link, a button or (with neither) a plain span. It
    // holds the dot and the content; the close button is its sibling, never a
    // descendant, so the two stay separate controls with separate tab stops.
    body: ['inline-flex items-center flex-1 min-w-0 rounded-full outline-none'],
    // label text role (size set per size variant)
    content: ['flex-1 text-inherit font-label'],
    dot: ['shrink-0', 'ml-1', 'rounded-full'],
    closeButton: [
      'shrink-0',
      'p-0.5',
      // The shared ring is drawn with a background-coloured offset, which
      // inside a chip reads as a hole punched in the chip.
      'focus-visible:ring-2 focus-visible:ring-offset-0',
      'cursor-pointer disabled:cursor-not-allowed'
    ]
  },
  variants: {
    isDisabled: {
      true: {
        base: 'opacity-disabled cursor-not-allowed',
        body: 'cursor-not-allowed'
      }
    },
    // The body is a link or a button that can be activated. The component
    // passes `false` while disabled, so a disabled chip has neither the
    // pointer nor the hover/active fills below. The ring sits on the body,
    // without the shared ring's offset for the same reason as the close
    // button's.
    isPressable: {
      true: {
        body: [
          'cursor-pointer',
          'focus-visible:ring-2 focus-visible:ring-focus focus-visible:ring-offset-0'
        ]
      },
      false: ''
    },
    // Holds the pressed (active-step) fill. See the selected compounds below.
    isSelected: {
      true: '',
      false: ''
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
    color: {
      neutral: {
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
      // For dense UI — table cells, list rows, multi-select fields. It keeps
      // `sm`'s text size and loses height and padding instead: 12px is about
      // as small as a label stays readable. The close button drops to
      // `label-micro` so its circle (icon plus `p-0.5`) still fits the 20px
      // chip.
      xs: {
        base: 'text-label-2xs px-0.5 h-5',
        content: 'px-1 leading-4',
        dot: 'size-1.5',
        closeButton: 'text-label-micro'
      },
      sm: {
        base: 'text-label-2xs px-1 h-6',
        content: 'px-1 leading-4',
        dot: 'size-1.5',
        closeButton: 'text-label-2xs'
      },
      md: {
        base: 'text-label-xs px-1 h-7',
        content: 'px-2 leading-5',
        dot: 'size-2',
        closeButton: 'text-label-xs'
      },
      lg: {
        base: 'text-label-md px-2 h-8',
        content: 'px-2 leading-6',
        dot: 'size-2.5',
        closeButton: 'text-label-md'
      }
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
      color: 'neutral',
      class: {
        base: 'bg-neutral-bolder text-on-neutral-bolder',
        closeButton: 'hover:bg-neutral-subtle hover:text-on-neutral-subtle'
      }
    },
    {
      variant: 'solid',
      color: 'primary',
      class: {
        base: 'bg-primary text-on-primary',
        closeButton: 'hover:bg-primary-subtle hover:text-on-primary-subtle'
      }
    },
    {
      variant: 'solid',
      color: 'secondary',
      class: {
        base: 'bg-secondary text-on-secondary',
        closeButton: 'hover:bg-secondary-subtle hover:text-on-secondary-subtle'
      }
    },
    {
      variant: 'solid',
      color: 'tertiary',
      class: {
        base: 'bg-tertiary text-on-tertiary',
        closeButton: 'hover:bg-tertiary-subtle hover:text-on-tertiary-subtle'
      }
    },
    {
      variant: 'solid',
      color: 'success',
      class: {
        base: 'bg-success text-on-success',
        closeButton: 'hover:bg-success-subtle hover:text-on-success-subtle'
      }
    },
    {
      variant: 'solid',
      color: 'warning',
      class: {
        base: 'bg-warning text-on-warning',
        closeButton: 'hover:bg-warning-subtle hover:text-on-warning-subtle'
      }
    },
    {
      variant: 'solid',
      color: 'danger',
      class: {
        base: 'bg-danger text-on-danger',
        closeButton: 'hover:bg-danger-subtle hover:text-on-danger-subtle'
      }
    },

    // VARIANT: soft (tonal)
    {
      variant: 'soft',
      color: 'neutral',
      class: {
        base: 'text-neutral-strong bg-neutral-subtle',
        closeButton: 'hover:bg-neutral hover:text-on-neutral'
      }
    },
    {
      variant: 'soft',
      color: 'primary',
      class: {
        base: 'text-primary-strong bg-primary-subtle',
        closeButton: 'hover:bg-primary hover:text-on-primary'
      }
    },
    {
      variant: 'soft',
      color: 'secondary',
      class: {
        base: 'text-secondary-strong bg-secondary-subtle',
        closeButton: 'hover:bg-secondary hover:text-on-secondary'
      }
    },
    {
      variant: 'soft',
      color: 'tertiary',
      class: {
        base: 'text-tertiary-strong bg-tertiary-subtle',
        closeButton: 'hover:bg-tertiary hover:text-on-tertiary'
      }
    },
    {
      variant: 'soft',
      color: 'success',
      class: {
        base: 'text-success-strong bg-success-subtle',
        closeButton: 'hover:bg-success hover:text-on-success'
      }
    },
    {
      variant: 'soft',
      color: 'warning',
      class: {
        base: 'text-warning-strong bg-warning-subtle',
        closeButton: 'hover:bg-warning hover:text-on-warning'
      }
    },
    {
      variant: 'soft',
      color: 'danger',
      class: {
        base: 'text-danger-strong bg-danger-subtle',
        closeButton: 'hover:bg-danger hover:text-on-danger'
      }
    },

    // VARIANT: outline
    {
      variant: 'outline',
      color: 'neutral',
      class: {
        base: 'text-neutral-strong border border-neutral',
        closeButton: 'hover:bg-neutral hover:text-on-neutral'
      }
    },
    {
      variant: 'outline',
      color: 'primary',
      class: {
        base: 'text-primary-strong border border-primary',
        closeButton: 'hover:bg-primary hover:text-on-primary'
      }
    },
    {
      variant: 'outline',
      color: 'secondary',
      class: {
        base: 'text-secondary-strong border border-secondary',
        closeButton: 'hover:bg-secondary hover:text-on-secondary'
      }
    },
    {
      variant: 'outline',
      color: 'tertiary',
      class: {
        base: 'text-tertiary-strong border border-tertiary',
        closeButton: 'hover:bg-tertiary hover:text-on-tertiary'
      }
    },
    {
      variant: 'outline',
      color: 'success',
      class: {
        base: 'text-success-strong border border-success',
        closeButton: 'hover:bg-success hover:text-on-success'
      }
    },
    {
      variant: 'outline',
      color: 'warning',
      class: {
        base: 'text-warning-strong border border-warning',
        closeButton: 'hover:bg-warning hover:text-on-warning'
      }
    },
    {
      variant: 'outline',
      color: 'danger',
      class: {
        base: 'text-danger-strong border border-danger',
        closeButton: 'hover:bg-danger hover:text-on-danger'
      }
    },

    // BODY STATES (hover / active / selected)
    //
    // The fills go on the base, so the whole pill changes, but are keyed to
    // the body's own `:hover`/`:active` through `has-[>[data-part=body]:…]`:
    // pointing at the close button (a sibling of the body) does not light the
    // chip up, and the close button keeps its own circle hover. Putting the
    // fill on the body instead would tint only part of the pill, since the
    // base's padding and the close button sit outside it.
    //
    // Steps follow the spec's States table and Button's ladder: soft
    // `-subtle` -> `-muted` -> `-soft`; outline transparent -> `-subtle` ->
    // `-muted`; solid DEFAULT -> `-mild` -> `-firm` (neutral, which rests on
    // `-bolder`, steps down to `-strong` then `-firm`, as Button's does).
    // A selected chip holds the active fill and does not respond to hover.
    {
      variant: 'solid',
      color: 'neutral',
      isPressable: true,
      isSelected: false,
      class: {
        base: 'has-[>[data-part=body]:hover]:bg-neutral-strong has-[>[data-part=body]:hover]:text-on-neutral-strong has-[>[data-part=body]:active]:bg-neutral-firm has-[>[data-part=body]:active]:text-on-neutral-firm'
      }
    },
    {
      variant: 'solid',
      color: 'primary',
      isPressable: true,
      isSelected: false,
      class: {
        base: 'has-[>[data-part=body]:hover]:bg-primary-mild has-[>[data-part=body]:hover]:text-on-primary-mild has-[>[data-part=body]:active]:bg-primary-firm has-[>[data-part=body]:active]:text-on-primary-firm'
      }
    },
    {
      variant: 'solid',
      color: 'secondary',
      isPressable: true,
      isSelected: false,
      class: {
        base: 'has-[>[data-part=body]:hover]:bg-secondary-mild has-[>[data-part=body]:hover]:text-on-secondary-mild has-[>[data-part=body]:active]:bg-secondary-firm has-[>[data-part=body]:active]:text-on-secondary-firm'
      }
    },
    {
      variant: 'solid',
      color: 'tertiary',
      isPressable: true,
      isSelected: false,
      class: {
        base: 'has-[>[data-part=body]:hover]:bg-tertiary-mild has-[>[data-part=body]:hover]:text-on-tertiary-mild has-[>[data-part=body]:active]:bg-tertiary-firm has-[>[data-part=body]:active]:text-on-tertiary-firm'
      }
    },
    {
      variant: 'solid',
      color: 'success',
      isPressable: true,
      isSelected: false,
      class: {
        base: 'has-[>[data-part=body]:hover]:bg-success-mild has-[>[data-part=body]:hover]:text-on-success-mild has-[>[data-part=body]:active]:bg-success-firm has-[>[data-part=body]:active]:text-on-success-firm'
      }
    },
    {
      variant: 'solid',
      color: 'warning',
      isPressable: true,
      isSelected: false,
      class: {
        base: 'has-[>[data-part=body]:hover]:bg-warning-mild has-[>[data-part=body]:hover]:text-on-warning-mild has-[>[data-part=body]:active]:bg-warning-firm has-[>[data-part=body]:active]:text-on-warning-firm'
      }
    },
    {
      variant: 'solid',
      color: 'danger',
      isPressable: true,
      isSelected: false,
      class: {
        base: 'has-[>[data-part=body]:hover]:bg-danger-mild has-[>[data-part=body]:hover]:text-on-danger-mild has-[>[data-part=body]:active]:bg-danger-firm has-[>[data-part=body]:active]:text-on-danger-firm'
      }
    },
    {
      variant: 'soft',
      color: 'neutral',
      isPressable: true,
      isSelected: false,
      class: {
        base: 'has-[>[data-part=body]:hover]:bg-neutral-muted has-[>[data-part=body]:active]:bg-neutral-soft'
      }
    },
    {
      variant: 'soft',
      color: 'primary',
      isPressable: true,
      isSelected: false,
      class: {
        base: 'has-[>[data-part=body]:hover]:bg-primary-muted has-[>[data-part=body]:active]:bg-primary-soft'
      }
    },
    {
      variant: 'soft',
      color: 'secondary',
      isPressable: true,
      isSelected: false,
      class: {
        base: 'has-[>[data-part=body]:hover]:bg-secondary-muted has-[>[data-part=body]:active]:bg-secondary-soft'
      }
    },
    {
      variant: 'soft',
      color: 'tertiary',
      isPressable: true,
      isSelected: false,
      class: {
        base: 'has-[>[data-part=body]:hover]:bg-tertiary-muted has-[>[data-part=body]:active]:bg-tertiary-soft'
      }
    },
    {
      variant: 'soft',
      color: 'success',
      isPressable: true,
      isSelected: false,
      class: {
        base: 'has-[>[data-part=body]:hover]:bg-success-muted has-[>[data-part=body]:active]:bg-success-soft'
      }
    },
    {
      variant: 'soft',
      color: 'warning',
      isPressable: true,
      isSelected: false,
      class: {
        base: 'has-[>[data-part=body]:hover]:bg-warning-muted has-[>[data-part=body]:active]:bg-warning-soft'
      }
    },
    {
      variant: 'soft',
      color: 'danger',
      isPressable: true,
      isSelected: false,
      class: {
        base: 'has-[>[data-part=body]:hover]:bg-danger-muted has-[>[data-part=body]:active]:bg-danger-soft'
      }
    },
    {
      variant: 'outline',
      color: 'neutral',
      isPressable: true,
      isSelected: false,
      class: {
        base: 'has-[>[data-part=body]:hover]:bg-neutral-subtle has-[>[data-part=body]:active]:bg-neutral-muted'
      }
    },
    {
      variant: 'outline',
      color: 'primary',
      isPressable: true,
      isSelected: false,
      class: {
        base: 'has-[>[data-part=body]:hover]:bg-primary-subtle has-[>[data-part=body]:active]:bg-primary-muted'
      }
    },
    {
      variant: 'outline',
      color: 'secondary',
      isPressable: true,
      isSelected: false,
      class: {
        base: 'has-[>[data-part=body]:hover]:bg-secondary-subtle has-[>[data-part=body]:active]:bg-secondary-muted'
      }
    },
    {
      variant: 'outline',
      color: 'tertiary',
      isPressable: true,
      isSelected: false,
      class: {
        base: 'has-[>[data-part=body]:hover]:bg-tertiary-subtle has-[>[data-part=body]:active]:bg-tertiary-muted'
      }
    },
    {
      variant: 'outline',
      color: 'success',
      isPressable: true,
      isSelected: false,
      class: {
        base: 'has-[>[data-part=body]:hover]:bg-success-subtle has-[>[data-part=body]:active]:bg-success-muted'
      }
    },
    {
      variant: 'outline',
      color: 'warning',
      isPressable: true,
      isSelected: false,
      class: {
        base: 'has-[>[data-part=body]:hover]:bg-warning-subtle has-[>[data-part=body]:active]:bg-warning-muted'
      }
    },
    {
      variant: 'outline',
      color: 'danger',
      isPressable: true,
      isSelected: false,
      class: {
        base: 'has-[>[data-part=body]:hover]:bg-danger-subtle has-[>[data-part=body]:active]:bg-danger-muted'
      }
    },

    // Selected: holds the active-step fill.
    {
      variant: 'solid',
      color: 'neutral',
      isSelected: true,
      class: { base: 'bg-neutral-firm text-on-neutral-firm' }
    },
    {
      variant: 'solid',
      color: 'primary',
      isSelected: true,
      class: { base: 'bg-primary-firm text-on-primary-firm' }
    },
    {
      variant: 'solid',
      color: 'secondary',
      isSelected: true,
      class: { base: 'bg-secondary-firm text-on-secondary-firm' }
    },
    {
      variant: 'solid',
      color: 'tertiary',
      isSelected: true,
      class: { base: 'bg-tertiary-firm text-on-tertiary-firm' }
    },
    {
      variant: 'solid',
      color: 'success',
      isSelected: true,
      class: { base: 'bg-success-firm text-on-success-firm' }
    },
    {
      variant: 'solid',
      color: 'warning',
      isSelected: true,
      class: { base: 'bg-warning-firm text-on-warning-firm' }
    },
    {
      variant: 'solid',
      color: 'danger',
      isSelected: true,
      class: { base: 'bg-danger-firm text-on-danger-firm' }
    },
    {
      variant: 'soft',
      color: 'neutral',
      isSelected: true,
      class: { base: 'bg-neutral-soft' }
    },
    {
      variant: 'soft',
      color: 'primary',
      isSelected: true,
      class: { base: 'bg-primary-soft' }
    },
    {
      variant: 'soft',
      color: 'secondary',
      isSelected: true,
      class: { base: 'bg-secondary-soft' }
    },
    {
      variant: 'soft',
      color: 'tertiary',
      isSelected: true,
      class: { base: 'bg-tertiary-soft' }
    },
    {
      variant: 'soft',
      color: 'success',
      isSelected: true,
      class: { base: 'bg-success-soft' }
    },
    {
      variant: 'soft',
      color: 'warning',
      isSelected: true,
      class: { base: 'bg-warning-soft' }
    },
    {
      variant: 'soft',
      color: 'danger',
      isSelected: true,
      class: { base: 'bg-danger-soft' }
    },
    {
      variant: 'outline',
      color: 'neutral',
      isSelected: true,
      class: { base: 'bg-neutral-muted' }
    },
    {
      variant: 'outline',
      color: 'primary',
      isSelected: true,
      class: { base: 'bg-primary-muted' }
    },
    {
      variant: 'outline',
      color: 'secondary',
      isSelected: true,
      class: { base: 'bg-secondary-muted' }
    },
    {
      variant: 'outline',
      color: 'tertiary',
      isSelected: true,
      class: { base: 'bg-tertiary-muted' }
    },
    {
      variant: 'outline',
      color: 'success',
      isSelected: true,
      class: { base: 'bg-success-muted' }
    },
    {
      variant: 'outline',
      color: 'warning',
      isSelected: true,
      class: { base: 'bg-warning-muted' }
    },
    {
      variant: 'outline',
      color: 'danger',
      isSelected: true,
      class: { base: 'bg-danger-muted' }
    }
  ],
  defaultVariants: {
    size: 'md',
    color: 'neutral',
    variant: 'solid',
    isPressable: false,
    isSelected: false
  }
});

export { chip };
