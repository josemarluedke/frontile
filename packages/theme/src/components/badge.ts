import { tv } from '../tw';

const badge = tv({
  slots: {
    // Regular weight; the `text-strong-*` size tokens would set bold, so the
    // weight is pinned here and only `value` is heavier.
    base: 'inline-flex items-center whitespace-nowrap font-label font-normal leading-none',
    // emphasized value, e.g. a price
    value: 'font-bold tabular-nums leading-none',
    // unit following the value, e.g. "/mo"
    unit: 'opacity-80 leading-none',
    // status dot before the content; sized per size, coloured per color
    dot: 'shrink-0 rounded-full',
    icon: 'inline-flex shrink-0 items-center justify-center [&>svg]:size-full'
  },
  variants: {
    variant: {
      soft: '',
      outline: ''
    },
    color: {
      neutral: {
        dot: 'bg-neutral-strong'
      },
      primary: {
        dot: 'bg-primary'
      },
      secondary: {
        dot: 'bg-secondary'
      },
      tertiary: {
        dot: 'bg-tertiary'
      },
      success: {
        dot: 'bg-success'
      },
      danger: {
        dot: 'bg-danger'
      }
    },
    // Text follows Button's ramp: the same `@size` gives the same
    // `text-strong-*` token on Badge, Chip and Button. Value and unit share
    // the label's font size so their baselines line up; the value is set apart
    // by weight only. Heights and padding are Badge's own, chosen so the text
    // fits. Radius steps with size and is never a pill: that shape belongs
    // to Chip.
    size: {
      // Smaller than Button's smallest size: the next `text-strong-*` step
      // down (12.3px), 20px tall.
      '2xs': {
        base: 'text-strong-2xs h-5 px-1.5 gap-1 rounded-sm',
        dot: 'size-1.5',
        icon: 'size-3'
      },
      xs: {
        base: 'text-strong-xs h-6 px-2 gap-1 rounded-sm',
        dot: 'size-2',
        icon: 'size-3.5'
      },
      sm: {
        base: 'text-strong-sm h-7 px-2.5 gap-1.5 rounded-sm',
        dot: 'size-2',
        icon: 'size-4'
      },
      md: {
        base: 'text-strong-md h-8 px-3 gap-1.5 rounded-md',
        dot: 'size-2',
        icon: 'size-4'
      },
      lg: {
        base: 'text-strong-lg h-10 px-4 gap-2 rounded-md',
        dot: 'size-2.5',
        icon: 'size-5'
      },
      xl: {
        base: 'text-strong-xl h-11 px-5 gap-2 rounded-lg',
        dot: 'size-3',
        icon: 'size-6'
      },
      '2xl': {
        base: 'text-strong-2xl h-14 px-6 gap-2.5 rounded-lg',
        dot: 'size-3.5',
        icon: 'size-8'
      }
    }
  },
  compoundVariants: [
    // VARIANT: soft (tonal). One level above Chip's `soft` (`-subtle`).
    {
      variant: 'soft',
      color: 'neutral',
      class: {
        base: 'bg-neutral-muted text-on-neutral-muted'
      }
    },
    {
      variant: 'soft',
      color: 'primary',
      class: {
        base: 'bg-primary-muted text-on-primary-muted'
      }
    },
    {
      variant: 'soft',
      color: 'secondary',
      class: {
        base: 'bg-secondary-muted text-on-secondary-muted'
      }
    },
    {
      variant: 'soft',
      color: 'tertiary',
      class: {
        base: 'bg-tertiary-muted text-on-tertiary-muted'
      }
    },
    {
      variant: 'soft',
      color: 'success',
      class: {
        base: 'bg-success-muted text-on-success-muted'
      }
    },
    {
      variant: 'soft',
      color: 'danger',
      class: {
        base: 'bg-danger-muted text-on-danger-muted'
      }
    },

    // VARIANT: outline
    {
      variant: 'outline',
      color: 'neutral',
      class: {
        base: 'border border-current text-neutral-strong'
      }
    },
    {
      variant: 'outline',
      color: 'primary',
      class: {
        base: 'border border-current text-primary-strong'
      }
    },
    {
      variant: 'outline',
      color: 'secondary',
      class: {
        base: 'border border-current text-secondary-strong'
      }
    },
    {
      variant: 'outline',
      color: 'tertiary',
      class: {
        base: 'border border-current text-tertiary-strong'
      }
    },
    {
      variant: 'outline',
      color: 'success',
      class: {
        base: 'border border-current text-success-strong'
      }
    },
    {
      variant: 'outline',
      color: 'danger',
      class: {
        base: 'border border-current text-danger-strong'
      }
    }
  ],
  defaultVariants: {
    size: 'xs',
    color: 'neutral',
    variant: 'soft'
  }
});

export { badge };
