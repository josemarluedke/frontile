import { tv, type VariantProps } from '../tw';

const ROLES = [
  'neutral',
  'primary',
  'secondary',
  'tertiary',
  'success',
  'warning',
  'danger'
] as const;
type Role = (typeof ROLES)[number];

// Every class is written out in full so Tailwind can find it in source.
const SOLID: Record<Role, string> = {
  neutral: 'bg-neutral text-on-neutral',
  primary: 'bg-primary text-on-primary',
  secondary: 'bg-secondary text-on-secondary',
  tertiary: 'bg-tertiary text-on-tertiary',
  success: 'bg-success text-on-success',
  warning: 'bg-warning text-on-warning',
  danger: 'bg-danger text-on-danger'
};

const SOFT: Record<Role, string> = {
  neutral: 'bg-neutral-muted text-on-neutral-muted',
  primary: 'bg-primary-muted text-on-primary-muted',
  secondary: 'bg-secondary-muted text-on-secondary-muted',
  tertiary: 'bg-tertiary-muted text-on-tertiary-muted',
  success: 'bg-success-muted text-on-success-muted',
  warning: 'bg-warning-muted text-on-warning-muted',
  danger: 'bg-danger-muted text-on-danger-muted'
};

const SUBTLE: Record<Role, string> = {
  neutral: 'bg-neutral-subtle text-on-neutral-subtle',
  primary: 'bg-primary-subtle text-on-primary-subtle',
  secondary: 'bg-secondary-subtle text-on-secondary-subtle',
  tertiary: 'bg-tertiary-subtle text-on-tertiary-subtle',
  success: 'bg-success-subtle text-on-success-subtle',
  warning: 'bg-warning-subtle text-on-warning-subtle',
  danger: 'bg-danger-subtle text-on-danger-subtle'
};

// The ring is an inset border on a `box-border` circle, so the outer size and
// the icon position match the filled variants.
const OUTLINE: Record<Role, string> = {
  neutral: 'border border-neutral text-neutral-strong',
  primary: 'border border-primary text-primary-strong',
  secondary: 'border border-secondary text-secondary-strong',
  tertiary: 'border border-tertiary text-tertiary-strong',
  success: 'border border-success text-success-strong',
  warning: 'border border-warning text-warning-strong',
  danger: 'border border-danger text-danger-strong'
};

const PLAIN: Record<Role, string> = {
  neutral: 'text-neutral-strong',
  primary: 'text-primary-strong',
  secondary: 'text-secondary-strong',
  tertiary: 'text-tertiary-strong',
  success: 'text-success-strong',
  warning: 'text-warning-strong',
  danger: 'text-danger-strong'
};

const BY_VARIANT = {
  solid: SOLID,
  soft: SOFT,
  subtle: SUBTLE,
  outline: OUTLINE,
  plain: PLAIN
} as const;

// A circle that centers an icon. The circle diameters are Tailwind spacing
// steps. The icon is sized by the `svg` it contains, to the `size-icon-*` step
// of the same name, which is the label text size at that step: an Icon at a
// size matches the icon inside a Button, Badge or Chip at that size.
const icon = tv({
  base: 'box-border inline-flex shrink-0 items-center justify-center rounded-full align-middle',
  variants: {
    size: {
      '4xs': 'size-4 [&_svg]:size-icon-4xs',
      '3xs': 'size-5 [&_svg]:size-icon-3xs',
      '2xs': 'size-6 [&_svg]:size-icon-2xs',
      xs: 'size-8 [&_svg]:size-icon-xs',
      sm: 'size-10 [&_svg]:size-icon-sm',
      md: 'size-12 [&_svg]:size-icon-md',
      lg: 'size-16 [&_svg]:size-icon-lg',
      xl: 'size-18 [&_svg]:size-icon-xl',
      '2xl': 'size-20 [&_svg]:size-icon-2xl',
      '3xl': 'size-24 [&_svg]:size-icon-3xl'
    },
    color: {
      neutral: '',
      primary: '',
      secondary: '',
      tertiary: '',
      success: '',
      warning: '',
      danger: ''
    },
    variant: {
      solid: '',
      soft: '',
      subtle: '',
      outline: '',
      plain: ''
    },
    // Re-resolves every color token to the opposite scheme for this icon.
    inverse: {
      true: 'theme-inverse'
    }
  },
  compoundVariants: ROLES.flatMap((color) =>
    (Object.keys(BY_VARIANT) as (keyof typeof BY_VARIANT)[]).map((variant) => ({
      color,
      variant,
      class: BY_VARIANT[variant][color]
    }))
  ),
  // `color` has no default: a plain icon without one inherits the text color.
  defaultVariants: {
    size: 'md',
    variant: 'plain'
  }
});

export type IconVariants = VariantProps<typeof icon>;
export { icon };
