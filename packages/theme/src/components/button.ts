import { tv } from '../tw';
import { focusVisibleRing } from './shared.ts';

const baseButton = tv({
  base: [
    'leading-tight',
    'inline-block',
    'font-semibold',
    'border',
    'border-transparent',
    'rounded-sm',
    'disabled:cursor-not-allowed',
    'disabled:opacity-40',
    ...focusVisibleRing
  ],
  variants: {
    appearance: {
      outlined: ''
    },
    isInGroup: {
      true: [
        'rounded-none first:rounded-l last:rounded-r',
        '[&:not(:first-child):not(:last-child)]:rounded-none',
        'not-last-of-type:-me-px'
      ]
    },
    intent: {
      default: '',
      primary: 'focus-visible:ring-brand-soft',
      success: 'focus-visible:ring-success-soft',
      warning: 'focus-visible:ring-warning',
      danger: 'focus-visible:ring-danger'
    },
    size: {
      xs: 'text-sm px-2 py-1',
      sm: 'text-sm px-3 py-2',
      md: 'text-base px-4 py-2',
      lg: 'text-base px-5 py-4',
      xl: 'text-xl px-6 py-5'
    }
  },
  compoundVariants: [
    // APPEARANCE: outlined
    {
      appearance: 'outlined',
      intent: 'default',
      class:
        'text-neutral-medium hover:text-background border-neutral-medium hover:bg-neutral-medium'
    },
    {
      appearance: 'outlined',
      intent: 'primary',
      class: 'text-brand hover:text-on-brand border-brand-medium hover:bg-brand'
    },
    {
      appearance: 'outlined',
      intent: 'success',
      class:
        'text-success hover:text-on-success border-success hover:bg-success'
    },
    {
      appearance: 'outlined',
      intent: 'warning',
      class:
        'text-warning hover:text-on-warning border-warning hover:bg-warning'
    },
    {
      appearance: 'outlined',
      intent: 'danger',
      class: 'text-danger hover:text-on-danger border-danger hover:bg-danger'
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
      default: '',
      outlined: '',
      minimal: '',
      custom: ''
    }
  },
  compoundVariants: [
    // APPEARANCE: default
    {
      appearance: 'default',
      intent: 'default',
      class:
        'bg-neutral-strong text-on-neutral-strong hover:bg-neutral-strong/80'
    },
    {
      appearance: 'default',
      intent: 'primary',
      class: 'bg-brand text-on-brand hover:bg-brand-strong'
    },
    {
      appearance: 'default',
      intent: 'success',
      class: 'bg-success-soft text-on-success-soft hover:bg-success-soft/80'
    },
    {
      appearance: 'default',
      intent: 'warning',
      class: 'bg-warning-soft text-black hover:bg-warning-soft/80'
    },
    {
      appearance: 'default',
      intent: 'danger',
      class: 'bg-danger text-on-danger hover:bg-danger/80'
    },

    // APPEARANCE: minimal
    {
      appearance: 'minimal',
      intent: 'default',
      class: 'text-neutral-medium hover:text-on-neutral hover:bg-neutral'
    },
    {
      appearance: 'minimal',
      intent: 'primary',
      class: 'text-brand hover:text-on-brand hover:bg-brand'
    },
    {
      appearance: 'minimal',
      intent: 'success',
      class: 'text-success hover:text-on-success hover:bg-success'
    },
    {
      appearance: 'minimal',
      intent: 'warning',
      class: 'text-warning hover:text-on-warning hover:bg-warning'
    },
    {
      appearance: 'minimal',
      intent: 'danger',
      class: 'text-danger hover:text-on-danger hover:bg-danger'
    },

    // APPEARANCE: custom
    {
      appearance: 'custom',
      intent: 'default',
      class: 'text-neutral-medium'
    },
    {
      appearance: 'custom',
      intent: 'primary',
      class: 'text-brand'
    },
    {
      appearance: 'custom',
      intent: 'success',
      class: 'text-success'
    },
    {
      appearance: 'custom',
      intent: 'warning',
      class: 'text-warning'
    },
    {
      appearance: 'custom',
      intent: 'danger',
      class: 'text-danger'
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
        'bg-neutral-strong text-on-neutral-strong hover:bg-neutral-strong/80 dark:bg-neutral dark:text-neutral-strong dark:hover:bg-neutral/40'
    },
    {
      appearance: 'outlined',
      intent: 'primary',
      isSelected: true,
      class: 'bg-brand text-on-brand hover:bg-brand/80'
    },
    {
      appearance: 'outlined',
      intent: 'success',
      isSelected: true,
      class: 'bg-success text-on-success hover:bg-success/80'
    },
    {
      appearance: 'outlined',
      intent: 'warning',
      isSelected: true,
      class: 'bg-warning text-on-warning hover:bg-warning/80'
    },
    {
      appearance: 'outlined',
      intent: 'danger',
      isSelected: true,
      class: 'bg-danger text-on-danger hover:bg-danger/80'
    }
  ]
});

const buttonGroup = tv({
  base: ['inline-flex items-center justify-center h-auto']
});

export { button, toggleButton, buttonGroup };
