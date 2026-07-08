import { tv } from '../tw';
import { focusVisibleRing } from './shared.ts';

const baseButton = tv({
  base: [
    'leading-none',
    'inline-flex items-center justify-center',
    '[&_svg]:size-[1em]',
    'font-bold',
    'border',
    'border-transparent',
    'disabled:cursor-not-allowed',
    'disabled:bg-surface-overlay-soft',
    'disabled:text-neutral-medium',
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
      xs: 'text-sm leading-none px-4 py-1 gap-1 rounded-full',
      sm: 'text-base leading-none px-5 py-1.5 gap-1.5 rounded-full',
      md: 'text-lg leading-none px-6 py-2 gap-1.5 rounded-full',
      lg: 'text-2xl leading-none px-8 py-2.5 gap-2 rounded-full',
      xl: 'text-3xl leading-none px-10 py-3 gap-2.5 rounded-full',
      '2xl': 'text-4xl leading-none px-12 py-3.5 gap-3 rounded-full',
      '3xl': 'text-5xl leading-none px-12 py-4 gap-3 rounded-full'
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
        'text-neutral-strong border-neutral-medium hover:bg-neutral-subtle hover:border-neutral-firm active:bg-neutral-muted active:text-neutral-bolder'
    },
    {
      appearance: 'outlined',
      intent: 'primary',
      class:
        'text-primary-strong border-primary-medium hover:bg-primary-subtle hover:border-primary-firm active:bg-primary-muted active:text-primary-bolder'
    },
    {
      appearance: 'outlined',
      intent: 'accent',
      class:
        'text-accent-strong border-accent-medium hover:bg-accent-subtle hover:border-accent-firm active:bg-accent-muted active:text-accent-bolder'
    },
    {
      appearance: 'outlined',
      intent: 'success',
      class:
        'text-success-strong border-success-medium hover:bg-success-subtle hover:border-success-firm active:bg-success-muted active:text-success-bolder'
    },
    {
      appearance: 'outlined',
      intent: 'warning',
      class:
        'text-warning-strong border-warning-medium hover:bg-warning-subtle hover:border-warning-firm active:bg-warning-muted active:text-warning-bolder'
    },
    {
      appearance: 'outlined',
      intent: 'danger',
      class:
        'text-danger-strong border-danger-medium hover:bg-danger-subtle hover:border-danger-firm active:bg-danger-muted active:text-danger-bolder'
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
    {
      appearance: 'default',
      intent: 'default',
      class:
        'bg-neutral-boldest text-on-neutral-boldest hover:bg-neutral-bolder hover:text-on-neutral-bolder active:bg-neutral-strong active:text-on-neutral-strong'
    },
    {
      appearance: 'default',
      intent: 'primary',
      class:
        'bg-primary-soft text-on-primary-soft hover:bg-primary-medium hover:text-on-primary-medium active:bg-primary-firm active:text-on-primary-firm'
    },
    {
      appearance: 'default',
      intent: 'accent',
      class:
        'bg-accent-soft text-on-accent-soft hover:bg-accent-medium hover:text-on-accent-medium active:bg-accent-firm active:text-on-accent-firm'
    },
    {
      appearance: 'default',
      intent: 'success',
      class:
        'bg-success-soft text-on-success-soft hover:bg-success-medium hover:text-on-success-medium active:bg-success-firm active:text-on-success-firm'
    },
    {
      appearance: 'default',
      intent: 'warning',
      class:
        'bg-warning-soft text-on-warning-soft hover:bg-warning-medium hover:text-on-warning-medium active:bg-warning-firm active:text-on-warning-firm'
    },
    {
      appearance: 'default',
      intent: 'danger',
      class:
        'bg-danger-soft text-on-danger-soft hover:bg-danger-medium hover:text-on-danger-medium active:bg-danger-firm active:text-on-danger-firm'
    },

    // APPEARANCE: soft (tint fill + colored stroke)
    {
      appearance: 'soft',
      intent: 'default',
      class:
        'bg-neutral-subtle border-neutral-medium text-neutral-strong hover:bg-neutral-muted hover:border-neutral-firm active:bg-neutral-soft active:border-neutral-strong active:text-on-neutral-soft'
    },
    {
      appearance: 'soft',
      intent: 'primary',
      class:
        'bg-primary-subtle border-primary-medium text-primary-strong hover:bg-primary-muted hover:border-primary-firm active:bg-primary-soft active:border-primary-strong active:text-on-primary-soft'
    },
    {
      appearance: 'soft',
      intent: 'accent',
      class:
        'bg-accent-subtle border-accent-medium text-accent-strong hover:bg-accent-muted hover:border-accent-firm active:bg-accent-soft active:border-accent-strong active:text-on-accent-soft'
    },
    {
      appearance: 'soft',
      intent: 'success',
      class:
        'bg-success-subtle border-success-medium text-success-strong hover:bg-success-muted hover:border-success-firm active:bg-success-soft active:border-success-strong active:text-on-success-soft'
    },
    {
      appearance: 'soft',
      intent: 'warning',
      class:
        'bg-warning-subtle border-warning-medium text-warning-strong hover:bg-warning-muted hover:border-warning-firm active:bg-warning-soft active:border-warning-strong active:text-on-warning-soft'
    },
    {
      appearance: 'soft',
      intent: 'danger',
      class:
        'bg-danger-subtle border-danger-medium text-danger-strong hover:bg-danger-muted hover:border-danger-firm active:bg-danger-soft active:border-danger-strong active:text-on-danger-soft'
    },

    // APPEARANCE: minimal (ghost)
    {
      appearance: 'minimal',
      intent: 'default',
      class:
        'text-neutral-strong hover:bg-neutral-subtle active:bg-neutral-muted active:text-neutral-bolder'
    },
    {
      appearance: 'minimal',
      intent: 'primary',
      class:
        'text-primary-strong hover:bg-primary-subtle active:bg-primary-muted active:text-primary-bolder'
    },
    {
      appearance: 'minimal',
      intent: 'accent',
      class:
        'text-accent-strong hover:bg-accent-subtle active:bg-accent-muted active:text-accent-bolder'
    },
    {
      appearance: 'minimal',
      intent: 'success',
      class:
        'text-success-strong hover:bg-success-subtle active:bg-success-muted active:text-success-bolder'
    },
    {
      appearance: 'minimal',
      intent: 'warning',
      class:
        'text-warning-strong hover:bg-warning-subtle active:bg-warning-muted active:text-warning-bolder'
    },
    {
      appearance: 'minimal',
      intent: 'danger',
      class:
        'text-danger-strong hover:bg-danger-subtle active:bg-danger-muted active:text-danger-bolder'
    },

    // APPEARANCE: tonal
    {
      appearance: 'tonal',
      intent: 'default',
      class:
        'bg-neutral-subtle text-neutral-strong hover:bg-neutral-muted active:bg-neutral-soft active:text-on-neutral-soft'
    },
    {
      appearance: 'tonal',
      intent: 'primary',
      class:
        'bg-primary-subtle text-primary-strong hover:bg-primary-muted active:bg-primary-soft active:text-on-primary-soft'
    },
    {
      appearance: 'tonal',
      intent: 'accent',
      class:
        'bg-accent-subtle text-accent-strong hover:bg-accent-muted active:bg-accent-soft active:text-on-accent-soft'
    },
    {
      appearance: 'tonal',
      intent: 'success',
      class:
        'bg-success-subtle text-success-strong hover:bg-success-muted active:bg-success-soft active:text-on-success-soft'
    },
    {
      appearance: 'tonal',
      intent: 'warning',
      class:
        'bg-warning-subtle text-warning-strong hover:bg-warning-muted active:bg-warning-soft active:text-on-warning-soft'
    },
    {
      appearance: 'tonal',
      intent: 'danger',
      class:
        'bg-danger-subtle text-danger-strong hover:bg-danger-muted active:bg-danger-soft active:text-on-danger-soft'
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
      class:
        'bg-neutral-firm text-on-neutral-firm hover:bg-neutral-strong hover:text-on-neutral-strong'
    },
    {
      appearance: 'outlined',
      intent: 'primary',
      isSelected: true,
      class:
        'bg-primary-soft text-on-primary-soft hover:bg-primary-medium hover:text-on-primary-medium'
    },
    {
      appearance: 'outlined',
      intent: 'accent',
      isSelected: true,
      class:
        'bg-accent-soft text-on-accent-soft hover:bg-accent-medium hover:text-on-accent-medium'
    },
    {
      appearance: 'outlined',
      intent: 'success',
      isSelected: true,
      class:
        'bg-success-soft text-on-success-soft hover:bg-success-medium hover:text-on-success-medium'
    },
    {
      appearance: 'outlined',
      intent: 'warning',
      isSelected: true,
      class:
        'bg-warning-soft text-on-warning-soft hover:bg-warning-medium hover:text-on-warning-medium'
    },
    {
      appearance: 'outlined',
      intent: 'danger',
      isSelected: true,
      class:
        'bg-danger-soft text-on-danger-soft hover:bg-danger-medium hover:text-on-danger-medium'
    }
  ]
});

const buttonGroup = tv({
  base: ['inline-flex items-center justify-center h-auto']
});

export { button, toggleButton, buttonGroup };
