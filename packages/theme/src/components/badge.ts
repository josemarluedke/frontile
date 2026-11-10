import { tv } from '../tw';

const badge = tv({
  slots: {
    base: 'inline-flex items-center whitespace-nowrap font-label leading-none',
    // emphasized value, e.g. a price
    value: 'font-bold tabular-nums leading-none',
    // unit following the value, e.g. "/mo"
    unit: 'opacity-80 leading-none',
    icon: 'inline-flex shrink-0 items-center justify-center [&>svg]:size-full'
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
    // Value and unit share the label's font size so their baselines line up;
    // the value is set apart by weight only. Heights match Chip (20, 24, 28,
    // 32px). Radius steps with size and is never a pill: that shape belongs
    // to Chip.
    size: {
      xs: {
        base: 'text-label-2xs h-5 px-1.5 gap-1 rounded-sm',
        icon: 'size-3'
      },
      sm: {
        base: 'text-label-2xs h-6 px-2 gap-1 rounded-sm',
        icon: 'size-3'
      },
      md: {
        base: 'text-label-xs h-7 px-2.5 gap-1.5 rounded-md',
        icon: 'size-3.5'
      },
      lg: {
        base: 'text-label-md h-8 px-3 gap-1.5 rounded-md',
        icon: 'size-4'
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
