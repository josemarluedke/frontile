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
    // Facet: disabled keeps the intent colors and simply drops opacity
    // (--opacity-disabled: 50% light / 40% dark) rather than swapping in a
    // grey palette.
    'disabled:opacity-disabled',
    ...focusVisibleRing
  ],
  variants: {
    appearance: {
      outlined: ''
    },
    intent: {
      default: '',
      primary: 'focus-visible:ring-primary-soft',
      secondary: 'focus-visible:ring-secondary-soft',
      tertiary: 'focus-visible:ring-tertiary-soft',
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
        // :first-of-type/:last-of-type (not :first-child/:last-child): a
        // grouped Dropdown's trigger can have a trailing portal-marker
        // <script> element as a sibling inside the group, which would make
        // the last button no longer :last-child. -of-type only counts
        // siblings of the same tag (button), so it isn't thrown off by it.
        'rounded-none first-of-type:rounded-s-full last-of-type:rounded-e-full',
        '[&:not(:first-of-type):not(:last-of-type)]:rounded-none',
        'not-last-of-type:-me-px'
      ]
    }
  },
  compoundVariants: [
    {
      appearance: 'outlined',
      intent: 'default',
      class:
        'text-neutral-bolder border-neutral-bolder hover:bg-neutral-subtle hover:text-neutral-mild hover:border-neutral-strong active:bg-neutral-muted active:text-neutral-firm active:border-neutral-firm'
    },
    {
      appearance: 'outlined',
      intent: 'primary',
      class:
        'text-primary border-primary hover:text-primary-mild hover:border-primary-mild active:text-primary-firm active:border-primary-firm'
    },
    {
      appearance: 'outlined',
      intent: 'secondary',
      class:
        'text-secondary-strong border-secondary-strong hover:text-secondary-firm hover:border-secondary-firm active:text-secondary-bolder active:border-secondary-bolder'
    },
    {
      appearance: 'outlined',
      intent: 'tertiary',
      class:
        'text-tertiary-strong border-tertiary-strong hover:text-tertiary-firm hover:border-tertiary-firm active:text-tertiary-bolder active:border-tertiary-bolder'
    },
    {
      appearance: 'outlined',
      intent: 'success',
      class:
        'text-success-strong border-success-strong hover:text-success-firm hover:border-success-firm active:text-success-bolder active:border-success-bolder'
    },
    {
      appearance: 'outlined',
      intent: 'warning',
      class:
        'text-warning-strong border-warning-strong hover:text-warning-firm hover:border-warning-firm active:text-warning-bolder active:border-warning-bolder'
    },
    {
      appearance: 'outlined',
      intent: 'danger',
      class:
        'text-danger border-danger hover:text-danger-mild hover:border-danger-mild active:text-danger-firm active:border-danger-firm'
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
    // APPEARANCE: default (Facet "filled") — fill + border + on-color
    {
      appearance: 'default',
      intent: 'default',
      class:
        'bg-neutral-bolder border-neutral-bolder text-on-neutral-bolder hover:bg-neutral-strong hover:border-neutral-strong hover:text-on-neutral-strong active:bg-neutral-firm active:border-neutral-firm active:text-on-neutral-firm'
    },
    {
      appearance: 'default',
      intent: 'primary',
      class:
        'bg-primary border-primary text-on-primary hover:bg-primary-mild hover:border-primary-mild hover:text-on-primary-mild active:bg-primary-firm active:border-primary-firm active:text-on-primary-firm'
    },
    {
      appearance: 'default',
      intent: 'secondary',
      class:
        'bg-secondary border-secondary text-on-secondary hover:bg-secondary-mild hover:border-secondary-mild hover:text-on-secondary-mild active:bg-secondary-firm active:border-secondary-firm active:text-on-secondary-firm'
    },
    {
      appearance: 'default',
      intent: 'tertiary',
      class:
        'bg-tertiary border-tertiary text-on-tertiary hover:bg-tertiary-mild hover:border-tertiary-mild hover:text-on-tertiary-mild active:bg-tertiary-firm active:border-tertiary-firm active:text-on-tertiary-firm'
    },
    {
      appearance: 'default',
      intent: 'success',
      class:
        'bg-success border-success text-on-success hover:bg-success-mild hover:border-success-mild hover:text-on-success-mild active:bg-success-firm active:border-success-firm active:text-on-success-firm'
    },
    {
      appearance: 'default',
      intent: 'warning',
      class:
        'bg-warning border-warning text-on-warning hover:bg-warning-mild hover:border-warning-mild hover:text-on-warning-mild active:bg-warning-firm active:border-warning-firm active:text-on-warning-firm'
    },
    {
      appearance: 'default',
      intent: 'danger',
      class:
        'bg-danger border-danger text-on-danger hover:bg-danger-mild hover:border-danger-mild hover:text-on-danger-mild active:bg-danger-firm active:border-danger-firm active:text-on-danger-firm'
    },
    // APPEARANCE: soft — tint fill, plus the border Facet gives it
    {
      appearance: 'soft',
      intent: 'default',
      class:
        'bg-neutral-soft border-neutral-bolder text-neutral-bolder hover:bg-neutral-subtle hover:border-neutral-strong hover:text-neutral-strong active:bg-neutral-muted active:border-neutral-firm active:text-neutral-firm'
    },
    {
      appearance: 'soft',
      intent: 'primary',
      class:
        'bg-primary-soft border-primary text-primary hover:bg-primary-subtle hover:border-primary-mild hover:text-primary-mild active:bg-primary-muted active:border-primary-firm active:text-primary-firm'
    },
    {
      appearance: 'soft',
      intent: 'secondary',
      class:
        'bg-secondary-soft border-secondary-strong text-secondary-strong hover:bg-secondary-subtle hover:border-secondary-firm hover:text-secondary-firm active:bg-secondary-muted active:border-secondary-bolder active:text-secondary-bolder'
    },
    {
      appearance: 'soft',
      intent: 'tertiary',
      class:
        'bg-tertiary-soft border-tertiary-strong text-tertiary-strong hover:bg-tertiary-subtle hover:border-tertiary-firm hover:text-tertiary-firm active:bg-tertiary-muted active:border-tertiary-bolder active:text-tertiary-bolder'
    },
    {
      appearance: 'soft',
      intent: 'success',
      class:
        'bg-success-soft border-success-strong text-success-strong hover:bg-success-subtle hover:border-success-firm hover:text-success-firm active:bg-success-muted active:border-success-bolder active:text-success-bolder'
    },
    {
      appearance: 'soft',
      intent: 'warning',
      class:
        'bg-warning-soft border-warning-strong text-warning-strong hover:bg-warning-subtle hover:border-warning-firm hover:text-warning-firm active:bg-warning-muted active:border-warning-bolder active:text-warning-bolder'
    },
    {
      appearance: 'soft',
      intent: 'danger',
      class:
        'bg-danger-soft border-danger text-danger hover:bg-danger-subtle hover:border-danger-mild hover:text-danger-mild active:bg-danger-muted active:border-danger-firm active:text-danger-firm'
    },
    // APPEARANCE: minimal (Facet "ghost") — ink only, no fill
    {
      appearance: 'minimal',
      intent: 'default',
      class:
        'text-neutral-bolder hover:text-neutral-strong active:text-neutral-firm'
    },
    {
      appearance: 'minimal',
      intent: 'primary',
      class: 'text-primary hover:text-primary-mild active:text-primary-firm'
    },
    {
      appearance: 'minimal',
      intent: 'secondary',
      class:
        'text-secondary-strong hover:text-secondary-firm active:text-secondary-bolder'
    },
    {
      appearance: 'minimal',
      intent: 'tertiary',
      class:
        'text-tertiary-strong hover:text-tertiary-firm active:text-tertiary-bolder'
    },
    {
      appearance: 'minimal',
      intent: 'success',
      class:
        'text-success-strong hover:text-success-firm active:text-success-bolder'
    },
    {
      appearance: 'minimal',
      intent: 'warning',
      class:
        'text-warning-strong hover:text-warning-firm active:text-warning-bolder'
    },
    {
      appearance: 'minimal',
      intent: 'danger',
      class: 'text-danger hover:text-danger-mild active:text-danger-firm'
    },
    // APPEARANCE: tonal — tint fill that deepens through the ramp
    {
      appearance: 'tonal',
      intent: 'default',
      class:
        'bg-neutral-soft text-on-neutral-soft hover:bg-neutral-muted hover:text-on-neutral-muted active:bg-neutral-mild active:text-on-neutral-mild'
    },
    {
      appearance: 'tonal',
      intent: 'primary',
      class:
        'bg-primary-soft text-on-primary-soft hover:bg-primary-muted hover:text-on-primary-muted active:bg-primary-mild active:text-on-primary-mild'
    },
    {
      appearance: 'tonal',
      intent: 'secondary',
      class:
        'bg-secondary-soft text-on-secondary-soft hover:bg-secondary-muted hover:text-on-secondary-muted active:bg-secondary-mild active:text-on-secondary-mild'
    },
    {
      appearance: 'tonal',
      intent: 'tertiary',
      class:
        'bg-tertiary-soft text-on-tertiary-soft hover:bg-tertiary-muted hover:text-on-tertiary-muted active:bg-tertiary-mild active:text-on-tertiary-mild'
    },
    {
      appearance: 'tonal',
      intent: 'success',
      class:
        'bg-success-soft text-on-success-soft hover:bg-success-muted hover:text-on-success-muted active:bg-success-mild active:text-on-success-mild'
    },
    {
      appearance: 'tonal',
      intent: 'warning',
      class:
        'bg-warning-soft text-on-warning-soft hover:bg-warning-muted hover:text-on-warning-muted active:bg-warning-mild active:text-on-warning-mild'
    },
    {
      appearance: 'tonal',
      intent: 'danger',
      class:
        'bg-danger-soft text-on-danger-soft hover:bg-danger-muted hover:text-on-danger-muted active:bg-danger-mild active:text-on-danger-mild'
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
      intent: 'secondary',
      class: 'text-secondary-strong'
    },
    {
      appearance: 'custom',
      intent: 'tertiary',
      class: 'text-tertiary-strong'
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
      intent: 'secondary',
      isSelected: true,
      class: 'bg-secondary text-on-secondary hover:bg-secondary-soft'
    },
    {
      appearance: 'outlined',
      intent: 'tertiary',
      isSelected: true,
      class: 'bg-tertiary text-on-tertiary hover:bg-tertiary-soft'
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
  base: ['inline-flex items-stretch justify-center h-auto']
});

export { button, toggleButton, buttonGroup };
