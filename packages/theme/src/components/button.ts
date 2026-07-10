import { tv } from '../tw';
import { focusVisibleRing } from './shared.ts';

const baseButton = tv({
  base: [
    // strong text role (Open Sans bold); size variants set text-strong-* which
    // carries the label size, weight, tracking, and line-height per the Facet spec
    'inline-flex items-center justify-center',
    '[&_svg]:size-[1em]',
    'font-header',
    'border',
    'border-transparent',
    'disabled:cursor-not-allowed',
    'disabled:bg-surface-overlay-soft',
    'disabled:text-neutral',
    'disabled:border-neutral-soft',
    ...focusVisibleRing
  ],
  variants: {
    appearance: {
      outlined: ''
    },
    intent: {
      default: '',
      primary: 'focus-visible:ring-primary-soft',
      accent: 'focus-visible:ring-accent-soft',
      success: 'focus-visible:ring-success-soft',
      warning: 'focus-visible:ring-warning-soft',
      danger: 'focus-visible:ring-danger-soft'
    },
    size: {
      xs: 'text-strong-sm px-4 py-1 gap-1 rounded-full',
      sm: 'text-strong-md px-5 py-1.5 gap-1 rounded-full',
      md: 'text-strong-lg px-6 py-2 gap-1.5 rounded-full',
      lg: 'text-strong-xl px-8 py-2.5 gap-1.5 rounded-full',
      xl: 'text-strong-2xl px-10 py-3 gap-2 rounded-full',
      '2xl': 'text-strong-3xl px-12 py-3.5 gap-2.5 rounded-full'
    },
    isInGroup: {
      true: [
        'rounded-none first:rounded-s-full last:rounded-e-full',
        '[&:not(:first-child):not(:last-child)]:rounded-none',
        'not-last-of-type:-me-px'
      ]
    }
  },
  compoundVariants: [
    // APPEARANCE: outlined
    {
      appearance: 'outlined',
      intent: 'default',
      class:
        'text-neutral-bolder border-neutral-bolder hover:bg-neutral-subtle hover:border-neutral-bolder hover:text-neutral-bolder active:bg-neutral-muted active:border-neutral-strong active:text-neutral-strong'
    },
    {
      appearance: 'outlined',
      intent: 'primary',
      class:
        'text-primary-strong border-primary hover:bg-primary-subtle hover:border-primary-soft hover:text-primary-bolder active:bg-primary-muted active:border-primary-firm active:text-primary-bolder'
    },
    {
      appearance: 'outlined',
      intent: 'accent',
      class:
        'text-accent-strong border-accent hover:bg-accent-subtle hover:border-accent-soft hover:text-accent-bolder active:bg-accent-muted active:border-accent-firm active:text-accent-bolder'
    },
    {
      appearance: 'outlined',
      intent: 'success',
      class:
        'text-success-strong border-success hover:bg-success-subtle hover:border-success-soft hover:text-success-bolder active:bg-success-muted active:border-success-firm active:text-success-bolder'
    },
    {
      appearance: 'outlined',
      intent: 'warning',
      class:
        'text-warning-strong border-warning hover:bg-warning-subtle hover:border-warning-soft hover:text-warning-bolder active:bg-warning-muted active:border-warning-firm active:text-warning-bolder'
    },
    {
      appearance: 'outlined',
      intent: 'danger',
      class:
        'text-danger-strong border-danger hover:bg-danger-subtle hover:border-danger-soft hover:text-danger-bolder active:bg-danger-muted active:border-danger-firm active:text-danger-bolder'
    }
  ],
  defaultVariants: {
    size: 'md',
    intent: 'default'
  }
});

const button = tv({
  extend: baseButton,
  base: [''],
  variants: {
    appearance: {
      default: 'shadow-elevation-2',
      soft: '',
      outlined: '',
      minimal: '',
      tonal: 'shadow-elevation-2',
      custom: ''
    }
  },
  compoundVariants: [
    // APPEARANCE: default (filled)
    // Text color is fixed to the rest on-color for all states — only the
    // background walks the interaction trio. Switching the on-color per
    // state causes the label to flip white/black mid-interaction whenever
    // a state's background crosses the contrast threshold (e.g. primary's
    // hover step is lighter than its rest step in light mode).
    {
      appearance: 'default',
      intent: 'default',
      class:
        'bg-neutral-bolder text-on-neutral-bolder hover:bg-neutral-bolder active:bg-neutral-strong'
    },
    {
      appearance: 'default',
      intent: 'primary',
      class:
        'bg-primary text-on-primary hover:bg-primary-soft active:bg-primary-firm'
    },
    {
      appearance: 'default',
      intent: 'accent',
      class:
        'bg-accent text-on-accent hover:bg-accent-soft active:bg-accent-firm'
    },
    {
      appearance: 'default',
      intent: 'success',
      class:
        'bg-success text-on-success hover:bg-success-soft active:bg-success-firm'
    },
    {
      appearance: 'default',
      intent: 'warning',
      class:
        'bg-warning text-on-warning hover:bg-warning-soft active:bg-warning-firm'
    },
    {
      appearance: 'default',
      intent: 'danger',
      class:
        'bg-danger text-on-danger hover:bg-danger-soft active:bg-danger-firm'
    },

    // APPEARANCE: soft (tint fill + colored stroke)
    {
      appearance: 'soft',
      intent: 'default',
      class:
        'bg-neutral-subtle border-neutral-bolder text-neutral-bolder hover:bg-neutral-muted hover:border-neutral-bolder hover:text-neutral-bolder active:bg-neutral-soft active:border-neutral-strong active:text-neutral-strong'
    },
    {
      appearance: 'soft',
      intent: 'primary',
      class:
        'bg-primary-subtle border-primary text-primary-strong hover:bg-primary-muted hover:border-primary-soft hover:text-primary-bolder active:bg-primary-soft active:border-primary-firm active:text-primary-bolder'
    },
    {
      appearance: 'soft',
      intent: 'accent',
      class:
        'bg-accent-subtle border-accent text-accent-strong hover:bg-accent-muted hover:border-accent-soft hover:text-accent-bolder active:bg-accent-soft active:border-accent-firm active:text-accent-bolder'
    },
    {
      appearance: 'soft',
      intent: 'success',
      class:
        'bg-success-subtle border-success text-success-strong hover:bg-success-muted hover:border-success-soft hover:text-success-bolder active:bg-success-soft active:border-success-firm active:text-success-bolder'
    },
    {
      appearance: 'soft',
      intent: 'warning',
      class:
        'bg-warning-subtle border-warning text-warning-strong hover:bg-warning-muted hover:border-warning-soft hover:text-warning-bolder active:bg-warning-soft active:border-warning-firm active:text-warning-bolder'
    },
    {
      appearance: 'soft',
      intent: 'danger',
      class:
        'bg-danger-subtle border-danger text-danger-strong hover:bg-danger-muted hover:border-danger-soft hover:text-danger-bolder active:bg-danger-soft active:border-danger-firm active:text-danger-bolder'
    },

    // APPEARANCE: minimal (ghost)
    {
      appearance: 'minimal',
      intent: 'default',
      class:
        'text-neutral-bolder hover:bg-neutral-subtle hover:text-neutral-bolder active:bg-neutral-muted active:text-neutral-strong'
    },
    {
      appearance: 'minimal',
      intent: 'primary',
      class:
        'text-primary-strong hover:bg-primary-subtle hover:text-primary-bolder active:bg-primary-muted active:text-primary-bolder'
    },
    {
      appearance: 'minimal',
      intent: 'accent',
      class:
        'text-accent-strong hover:bg-accent-subtle hover:text-accent-bolder active:bg-accent-muted active:text-accent-bolder'
    },
    {
      appearance: 'minimal',
      intent: 'success',
      class:
        'text-success-strong hover:bg-success-subtle hover:text-success-bolder active:bg-success-muted active:text-success-bolder'
    },
    {
      appearance: 'minimal',
      intent: 'warning',
      class:
        'text-warning-strong hover:bg-warning-subtle hover:text-warning-bolder active:bg-warning-muted active:text-warning-bolder'
    },
    {
      appearance: 'minimal',
      intent: 'danger',
      class:
        'text-danger-strong hover:bg-danger-subtle hover:text-danger-bolder active:bg-danger-muted active:text-danger-bolder'
    },

    // APPEARANCE: tonal — text stays fixed (on-tonal); only the tint
    // background walks tonal → tint-hover → tint-pressed.
    {
      appearance: 'tonal',
      intent: 'default',
      class:
        'bg-neutral-subtle text-neutral-bolder hover:bg-neutral-muted active:bg-neutral-soft'
    },
    {
      appearance: 'tonal',
      intent: 'primary',
      class:
        'bg-primary-subtle text-primary-strong hover:bg-primary-muted active:bg-primary-soft'
    },
    {
      appearance: 'tonal',
      intent: 'accent',
      class:
        'bg-accent-subtle text-accent-strong hover:bg-accent-muted active:bg-accent-soft'
    },
    {
      appearance: 'tonal',
      intent: 'success',
      class:
        'bg-success-subtle text-success-strong hover:bg-success-muted active:bg-success-soft'
    },
    {
      appearance: 'tonal',
      intent: 'warning',
      class:
        'bg-warning-subtle text-warning-strong hover:bg-warning-muted active:bg-warning-soft'
    },
    {
      appearance: 'tonal',
      intent: 'danger',
      class:
        'bg-danger-subtle text-danger-strong hover:bg-danger-muted active:bg-danger-soft'
    },

    // APPEARANCE: custom
    {
      appearance: 'custom',
      intent: 'default',
      class: 'text-neutral-strong'
    },
    {
      appearance: 'custom',
      intent: 'primary',
      class: 'text-primary-strong'
    },
    {
      appearance: 'custom',
      intent: 'accent',
      class: 'text-accent-strong'
    },
    {
      appearance: 'custom',
      intent: 'success',
      class: 'text-success-strong'
    },
    {
      appearance: 'custom',
      intent: 'warning',
      class: 'text-warning-strong'
    },
    {
      appearance: 'custom',
      intent: 'danger',
      class: 'text-danger-strong'
    }
  ],
  defaultVariants: {
    size: 'md',
    intent: 'primary'
  }
});

const toggleButton = tv({
  extend: baseButton,
  base: [''],
  variants: {
    isSelected: {
      true: ''
    }
  },
  compoundVariants: [
    {
      appearance: 'outlined',
      intent: 'default',
      isSelected: true,
      class: 'bg-neutral-bolder text-on-neutral-bolder hover:bg-neutral-bolder'
    },
    {
      appearance: 'outlined',
      intent: 'primary',
      isSelected: true,
      class: 'bg-primary text-on-primary hover:bg-primary-soft'
    },
    {
      appearance: 'outlined',
      intent: 'accent',
      isSelected: true,
      class: 'bg-accent text-on-accent hover:bg-accent-soft'
    },
    {
      appearance: 'outlined',
      intent: 'success',
      isSelected: true,
      class: 'bg-success text-on-success hover:bg-success-soft'
    },
    {
      appearance: 'outlined',
      intent: 'warning',
      isSelected: true,
      class: 'bg-warning text-on-warning hover:bg-warning-soft'
    },
    {
      appearance: 'outlined',
      intent: 'danger',
      isSelected: true,
      class: 'bg-danger text-on-danger hover:bg-danger-soft'
    }
  ]
});

const buttonGroup = tv({
  base: ['inline-flex items-center justify-center h-auto']
});

export { button, toggleButton, buttonGroup };
