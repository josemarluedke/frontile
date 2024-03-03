import { tv } from '../tw';

const baseButton = tv({
  base: [
    'leading-tight',
    'inline-block',
    'font-semibold',
    'border',
    'border-transparent',
    'rounded',
    'disabled:cursor-not-allowed',
    'disabled:opacity-40',
    'focus-visable:ring'
  ],
  variants: {
    appearance: {
      outlined: ''
    },
    isInGroup: {
      true: [
        'rounded-none first:rounded-l last:rounded-r',
        '[&:not(:first-child):not(:last-child)]:rounded-none',
        '[&:not(:last-of-type)]:-me-[1px]'
      ]
    },
    intent: {
      default: '',
      primary: '',
      success: '',
      warning: '',
      danger: ''
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
        'text-default-700 hover:text-background border-default-700 hover:bg-default-700'
    },
    {
      appearance: 'outlined',
      intent: 'primary',
      class:
        'text-primary hover:text-primary-foreground border-primary hover:bg-primary'
    },
    {
      appearance: 'outlined',
      intent: 'success',
      class:
        'text-success hover:text-success-foreground border-success hover:bg-success'
    },
    {
      appearance: 'outlined',
      intent: 'warning',
      class:
        'text-warning hover:text-warning-foreground border-warning hover:bg-warning'
    },
    {
      appearance: 'outlined',
      intent: 'danger',
      class:
        'text-danger hover:text-danger-foreground border-danger hover:bg-danger'
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
      class: 'bg-default-800 text-default-100 hover:bg-default-800/80'
    },
    {
      appearance: 'default',
      intent: 'primary',
      class: 'bg-primary-500 text-primary-foreground hover:bg-primary-500/80'
    },
    {
      appearance: 'default',
      intent: 'success',
      class: 'bg-success-500 text-success-foreground hover:bg-success-500/80'
    },
    {
      appearance: 'default',
      intent: 'warning',
      class: 'bg-warning-500 text-black hover:bg-warning-500/80'
    },
    {
      appearance: 'default',
      intent: 'danger',
      class: 'bg-danger text-danger-foreground hover:bg-danger/80'
    },

    // APPEARANCE: minimal
    {
      appearance: 'minimal',
      intent: 'default',
      class: 'text-default-700 hover:text-default-foreground hover:bg-default'
    },
    {
      appearance: 'minimal',
      intent: 'primary',
      class: 'text-primary hover:text-primary-foreground hover:bg-primary'
    },
    {
      appearance: 'minimal',
      intent: 'success',
      class: 'text-success hover:text-success-foreground hover:bg-success'
    },
    {
      appearance: 'minimal',
      intent: 'warning',
      class: 'text-warning hover:text-warning-foreground hover:bg-warning'
    },
    {
      appearance: 'minimal',
      intent: 'danger',
      class: 'text-danger hover:text-danger-foreground hover:bg-danger'
    },

    // APPEARANCE: custom
    {
      appearance: 'custom',
      intent: 'default',
      class: 'text-default-700'
    },
    {
      appearance: 'custom',
      intent: 'primary',
      class: 'text-primary'
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
        'bg-default-800 text-default-50 hover:bg-default-800/80 dark:bg-default dark:text-default-950 dark:hover:bg-default/40'
    },
    {
      appearance: 'outlined',
      intent: 'primary',
      isSelected: true,
      class: 'bg-primary text-primary-foreground hover:bg-primary/80'
    },
    {
      appearance: 'outlined',
      intent: 'success',
      isSelected: true,
      class: 'bg-success text-success-foreground hover:bg-success/80'
    },
    {
      appearance: 'outlined',
      intent: 'warning',
      isSelected: true,
      class: 'bg-warning text-warning-foreground hover:bg-warning/80'
    },
    {
      appearance: 'outlined',
      intent: 'danger',
      isSelected: true,
      class: 'bg-danger text-danger-foreground hover:bg-danger/80'
    }
  ]
});

const buttonGroup = tv({
  base: ['inline-flex items-center justify-center h-auto']
});

export { button, toggleButton, buttonGroup };
