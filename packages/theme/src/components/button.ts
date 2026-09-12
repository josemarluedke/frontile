import { tv } from '../tw';
import { focusVisibleRing } from './shared.ts';

const baseButton = tv({
  base: [
    'inline-flex items-center justify-center',
    '[&_svg]:size-[1em]',
    'font-header',
    'border',
    'border-transparent',
    'disabled:cursor-not-allowed',
    'disabled:opacity-disabled',
    ...focusVisibleRing
  ],
  variants: {
    variant: {
      outline: ''
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
        'rounded-none first-of-type:rounded-s-full last-of-type:rounded-e-full',
        '[&:not(:first-of-type):not(:last-of-type)]:rounded-none',
        'not-last-of-type:-me-px'
      ]
    }
  },
  compoundVariants: [
    {
      variant: 'outline',
      intent: 'default',
      class:
        'text-neutral-bolder border-neutral-bolder hover:bg-neutral-subtle hover:text-neutral-firm/80 hover:border-neutral-strong active:bg-neutral-muted active:text-neutral-firm active:border-neutral-firm'
    },
    {
      variant: 'outline',
      intent: 'primary',
      class:
        'text-primary border-primary hover:text-primary-mild hover:border-primary-mild active:text-primary-firm active:border-primary-firm'
    },
    {
      variant: 'outline',
      intent: 'secondary',
      class:
        'text-secondary-strong border-secondary-strong hover:text-secondary-firm hover:border-secondary-firm active:text-secondary-bolder active:border-secondary-bolder'
    },
    {
      variant: 'outline',
      intent: 'tertiary',
      class:
        'text-tertiary-strong border-tertiary-strong hover:text-tertiary-firm hover:border-tertiary-firm active:text-tertiary-bolder active:border-tertiary-bolder'
    },
    {
      variant: 'outline',
      intent: 'success',
      class:
        'text-success-strong border-success-strong hover:text-success-firm hover:border-success-firm active:text-success-bolder active:border-success-bolder'
    },
    {
      variant: 'outline',
      intent: 'warning',
      class:
        'text-warning-strong border-warning-strong hover:text-warning-firm hover:border-warning-firm active:text-warning-bolder active:border-warning-bolder'
    },
    {
      variant: 'outline',
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
    variant: {
      solid: 'shadow-elevation-2',
      soft: '',
      subtle: '',
      outline: '',
      ghost: '',
      plain: '',
      custom: ''
    },
    isLoading: {
      true: 'disabled:cursor-progress'
    }
  },
  compoundVariants: [
    // VARIANT: solid (Facet "filled") — fill + border + on-color
    {
      variant: 'solid',
      intent: 'default',
      class:
        'bg-neutral-bolder border-neutral-bolder text-on-neutral-bolder hover:bg-neutral-strong hover:border-neutral-strong hover:text-on-neutral-strong active:bg-neutral-firm active:border-neutral-firm active:text-on-neutral-firm'
    },
    {
      variant: 'solid',
      intent: 'primary',
      class:
        'bg-primary border-primary text-on-primary hover:bg-primary-mild hover:border-primary-mild hover:text-on-primary-mild active:bg-primary-firm active:border-primary-firm active:text-on-primary-firm'
    },
    {
      variant: 'solid',
      intent: 'secondary',
      class:
        'bg-secondary border-secondary text-on-secondary hover:bg-secondary-mild hover:border-secondary-mild hover:text-on-secondary-mild active:bg-secondary-firm active:border-secondary-firm active:text-on-secondary-firm'
    },
    {
      variant: 'solid',
      intent: 'tertiary',
      class:
        'bg-tertiary border-tertiary text-on-tertiary hover:bg-tertiary-mild hover:border-tertiary-mild hover:text-on-tertiary-mild active:bg-tertiary-firm active:border-tertiary-firm active:text-on-tertiary-firm'
    },
    {
      variant: 'solid',
      intent: 'success',
      class:
        'bg-success border-success text-on-success hover:bg-success-mild hover:border-success-mild hover:text-on-success-mild active:bg-success-firm active:border-success-firm active:text-on-success-firm'
    },
    {
      variant: 'solid',
      intent: 'warning',
      class:
        'bg-warning border-warning text-on-warning hover:bg-warning-mild hover:border-warning-mild hover:text-on-warning-mild active:bg-warning-firm active:border-warning-firm active:text-on-warning-firm'
    },
    {
      variant: 'solid',
      intent: 'danger',
      class:
        'bg-danger border-danger text-on-danger hover:bg-danger-mild hover:border-danger-mild hover:text-on-danger-mild active:bg-danger-firm active:border-danger-firm active:text-on-danger-firm'
    },
    // VARIANT: subtle — tint fill, plus the border Facet gives it
    {
      variant: 'subtle',
      intent: 'default',
      class:
        'bg-neutral-soft border-neutral-bolder text-neutral-bolder hover:bg-neutral-subtle hover:border-neutral-strong hover:text-neutral-strong active:bg-neutral-muted active:border-neutral-firm active:text-neutral-firm'
    },
    {
      variant: 'subtle',
      intent: 'primary',
      class:
        'bg-primary-soft border-primary text-primary hover:bg-primary-subtle hover:border-primary-mild hover:text-primary-mild active:bg-primary-muted active:border-primary-firm active:text-primary-firm'
    },
    {
      variant: 'subtle',
      intent: 'secondary',
      class:
        'bg-secondary-soft border-secondary-strong text-secondary-strong hover:bg-secondary-subtle hover:border-secondary-firm hover:text-secondary-firm active:bg-secondary-muted active:border-secondary-bolder active:text-secondary-bolder'
    },
    {
      variant: 'subtle',
      intent: 'tertiary',
      class:
        'bg-tertiary-soft border-tertiary-strong text-tertiary-strong hover:bg-tertiary-subtle hover:border-tertiary-firm hover:text-tertiary-firm active:bg-tertiary-muted active:border-tertiary-bolder active:text-tertiary-bolder'
    },
    {
      variant: 'subtle',
      intent: 'success',
      class:
        'bg-success-soft border-success-strong text-success-strong hover:bg-success-subtle hover:border-success-firm hover:text-success-firm active:bg-success-muted active:border-success-bolder active:text-success-bolder'
    },
    {
      variant: 'subtle',
      intent: 'warning',
      class:
        'bg-warning-soft border-warning-strong text-warning-strong hover:bg-warning-subtle hover:border-warning-firm hover:text-warning-firm active:bg-warning-muted active:border-warning-bolder active:text-warning-bolder'
    },
    {
      variant: 'subtle',
      intent: 'danger',
      class:
        'bg-danger-soft border-danger text-danger hover:bg-danger-subtle hover:border-danger-mild hover:text-danger-mild active:bg-danger-muted active:border-danger-firm active:text-danger-firm'
    },
    // VARIANT: plain (Facet "ghost") — ink only, no fill
    {
      variant: 'plain',
      intent: 'default',
      class:
        'text-neutral-bolder hover:text-neutral-firm/80 active:text-neutral-firm'
    },
    {
      variant: 'plain',
      intent: 'primary',
      class: 'text-primary hover:text-primary-mild active:text-primary-firm'
    },
    {
      variant: 'plain',
      intent: 'secondary',
      class:
        'text-secondary-strong hover:text-secondary-firm active:text-secondary-bolder'
    },
    {
      variant: 'plain',
      intent: 'tertiary',
      class:
        'text-tertiary-strong hover:text-tertiary-firm active:text-tertiary-bolder'
    },
    {
      variant: 'plain',
      intent: 'success',
      class:
        'text-success-strong hover:text-success-firm active:text-success-bolder'
    },
    {
      variant: 'plain',
      intent: 'warning',
      class:
        'text-warning-strong hover:text-warning-firm active:text-warning-bolder'
    },
    {
      variant: 'plain',
      intent: 'danger',
      class: 'text-danger hover:text-danger-mild active:text-danger-firm'
    },
    // VARIANT: ghost — plain's ink, plus a hover tint. New in 0.18; `plain`
    // (formerly `minimal`) stays the no-fill option.
    {
      variant: 'ghost',
      intent: 'default',
      class:
        'text-neutral-bolder hover:bg-neutral-subtle hover:text-neutral-firm/80 active:bg-neutral-muted active:text-neutral-firm'
    },
    {
      variant: 'ghost',
      intent: 'primary',
      class:
        'text-primary hover:bg-primary-soft hover:text-primary-mild active:bg-primary-muted active:text-primary-firm'
    },
    {
      variant: 'ghost',
      intent: 'secondary',
      class:
        'text-secondary-strong hover:bg-secondary-soft hover:text-secondary-firm active:bg-secondary-muted active:text-secondary-bolder'
    },
    {
      variant: 'ghost',
      intent: 'tertiary',
      class:
        'text-tertiary-strong hover:bg-tertiary-soft hover:text-tertiary-firm active:bg-tertiary-muted active:text-tertiary-bolder'
    },
    {
      variant: 'ghost',
      intent: 'success',
      class:
        'text-success-strong hover:bg-success-soft hover:text-success-firm active:bg-success-muted active:text-success-bolder'
    },
    {
      variant: 'ghost',
      intent: 'warning',
      class:
        'text-warning-strong hover:bg-warning-soft hover:text-warning-firm active:bg-warning-muted active:text-warning-bolder'
    },
    {
      variant: 'ghost',
      intent: 'danger',
      class:
        'text-danger hover:bg-danger-soft hover:text-danger-mild active:bg-danger-muted active:text-danger-firm'
    },
    // VARIANT: soft — tint fill that deepens through the ramp
    {
      variant: 'soft',
      intent: 'default',
      class:
        'bg-neutral-soft text-on-neutral-soft hover:bg-neutral-muted hover:text-on-neutral-muted active:bg-neutral-mild active:text-on-neutral-mild'
    },
    {
      variant: 'soft',
      intent: 'primary',
      class:
        'bg-primary-soft text-on-primary-soft hover:bg-primary-muted hover:text-on-primary-muted active:bg-primary-mild active:text-on-primary-mild'
    },
    {
      variant: 'soft',
      intent: 'secondary',
      class:
        'bg-secondary-soft text-on-secondary-soft hover:bg-secondary-muted hover:text-on-secondary-muted active:bg-secondary-mild active:text-on-secondary-mild'
    },
    {
      variant: 'soft',
      intent: 'tertiary',
      class:
        'bg-tertiary-soft text-on-tertiary-soft hover:bg-tertiary-muted hover:text-on-tertiary-muted active:bg-tertiary-mild active:text-on-tertiary-mild'
    },
    {
      variant: 'soft',
      intent: 'success',
      class:
        'bg-success-soft text-on-success-soft hover:bg-success-muted hover:text-on-success-muted active:bg-success-mild active:text-on-success-mild'
    },
    {
      variant: 'soft',
      intent: 'warning',
      class:
        'bg-warning-soft text-on-warning-soft hover:bg-warning-muted hover:text-on-warning-muted active:bg-warning-mild active:text-on-warning-mild'
    },
    {
      variant: 'soft',
      intent: 'danger',
      class:
        'bg-danger-soft text-on-danger-soft hover:bg-danger-muted hover:text-on-danger-muted active:bg-danger-mild active:text-on-danger-mild'
    },

    // VARIANT: custom
    {
      variant: 'custom',
      intent: 'default',
      class: 'text-neutral-strong'
    },
    {
      variant: 'custom',
      intent: 'primary',
      class: 'text-primary-strong'
    },
    {
      variant: 'custom',
      intent: 'secondary',
      class: 'text-secondary-strong'
    },
    {
      variant: 'custom',
      intent: 'tertiary',
      class: 'text-tertiary-strong'
    },
    {
      variant: 'custom',
      intent: 'success',
      class: 'text-success-strong'
    },
    {
      variant: 'custom',
      intent: 'warning',
      class: 'text-warning-strong'
    },
    {
      variant: 'custom',
      intent: 'danger',
      class: 'text-danger-strong'
    }
  ],
  defaultVariants: {
    size: 'md',
    intent: 'primary',
    variant: 'solid'
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
  // Selected is a *filled* state, so every color has to be restated here —
  // fill, border and ink, for the resting, hover and active steps. The
  // unselected `outline` rules in `baseButton` set their own
  // `hover:text-*`/`active:*` colors, and anything we leave out keeps leaking
  // through: an unselected ink color over a selected fill is what produced the
  // unreadable label on hover. The ramp matches the filled button
  // (`variant: 'solid'`) — one step deeper on hover, another on active —
  // and pairs each fill with its generated `on-*` contrast ink.
  compoundVariants: [
    {
      variant: 'outline',
      intent: 'default',
      isSelected: true,
      class:
        'bg-neutral-bolder border-neutral-bolder text-on-neutral-bolder hover:bg-neutral-strong hover:border-neutral-strong hover:text-on-neutral-strong active:bg-neutral-firm active:border-neutral-firm active:text-on-neutral-firm'
    },
    {
      variant: 'outline',
      intent: 'primary',
      isSelected: true,
      class:
        'bg-primary border-primary text-on-primary hover:bg-primary-mild hover:border-primary-mild hover:text-on-primary-mild active:bg-primary-firm active:border-primary-firm active:text-on-primary-firm'
    },
    {
      variant: 'outline',
      intent: 'secondary',
      isSelected: true,
      class:
        'bg-secondary border-secondary text-on-secondary hover:bg-secondary-mild hover:border-secondary-mild hover:text-on-secondary-mild active:bg-secondary-firm active:border-secondary-firm active:text-on-secondary-firm'
    },
    {
      variant: 'outline',
      intent: 'tertiary',
      isSelected: true,
      class:
        'bg-tertiary border-tertiary text-on-tertiary hover:bg-tertiary-mild hover:border-tertiary-mild hover:text-on-tertiary-mild active:bg-tertiary-firm active:border-tertiary-firm active:text-on-tertiary-firm'
    },
    {
      variant: 'outline',
      intent: 'success',
      isSelected: true,
      class:
        'bg-success border-success text-on-success hover:bg-success-mild hover:border-success-mild hover:text-on-success-mild active:bg-success-firm active:border-success-firm active:text-on-success-firm'
    },
    {
      variant: 'outline',
      intent: 'warning',
      isSelected: true,
      class:
        'bg-warning border-warning text-on-warning hover:bg-warning-mild hover:border-warning-mild hover:text-on-warning-mild active:bg-warning-firm active:border-warning-firm active:text-on-warning-firm'
    },
    {
      variant: 'outline',
      intent: 'danger',
      isSelected: true,
      class:
        'bg-danger border-danger text-on-danger hover:bg-danger-mild hover:border-danger-mild hover:text-on-danger-mild active:bg-danger-firm active:border-danger-firm active:text-on-danger-firm'
    }
  ]
});

const buttonGroup = tv({
  base: ['inline-flex items-stretch justify-center h-auto']
});

// The in-button spinner has to inherit the button's ink. `spinner`'s own base
// is `text-neutral-muted` / `fill-neutral-strong`, which is invisible on a
// filled primary button. `size-[1em]` makes it track the button's font size
// across all six sizes, matching the base button's `[&_svg]:size-[1em]`.
const buttonSpinner = tv({
  base: 'size-[1em] text-current/25 fill-current'
});

export { button, toggleButton, buttonGroup, buttonSpinner };
