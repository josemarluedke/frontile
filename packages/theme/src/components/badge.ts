import { tv } from '../tw';

const badge = tv({
  slots: {
    base: 'inline-flex items-center whitespace-nowrap font-label',
    // emphasized value, e.g. a price
    value: 'font-bold tabular-nums',
    // unit following the value, e.g. "/mo"
    unit: 'opacity-80',
    icon: 'size-3 shrink-0'
  },
  variants: {
    variant: {
      soft: '',
      outline: ''
    },
    color: {
      neutral: '',
      primary: '',
      secondary: '',
      tertiary: '',
      success: '',
      danger: ''
    },
    // Heights match Chip (20, 24, 28, 32px). Radius steps with size and is
    // never a pill: that shape belongs to Chip.
    size: {
      xs: {
        base: 'text-label-2xs h-5 px-1.5 gap-1 rounded-sm',
        value: 'text-label-xs'
      },
      sm: {
        base: 'text-label-2xs h-6 px-2 gap-1 rounded-sm',
        value: 'text-label-xs'
      },
      md: {
        base: 'text-label-xs h-7 px-2.5 gap-1.5 rounded-md',
        value: 'text-label-md'
      },
      lg: {
        base: 'text-label-md h-8 px-3 gap-1.5 rounded-md',
        value: 'text-label-lg'
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
    size: 'md',
    color: 'neutral',
    variant: 'soft'
  }
});

export { badge };
