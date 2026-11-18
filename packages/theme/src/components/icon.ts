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

// Fill and ink per color and variant, from the design artifact's Icon spec.
// The artifact picks a different level per role (soft is `*-soft` for most and
// `*-muted` for neutral and warning), so these are tables, not a rule. Where
// Frontile's auto-generated `on-*` token differs from the artifact's ink (the
// artifact has `on-neutral` white on its mid-gray fill, Frontile black), the
// level that gives the artifact's ink is used instead, and the tests check the
// ink itself. Every class is written out in full so Tailwind can find it.
const SOLID: Record<Role, string> = {
  neutral: 'bg-on-neutral-subtle text-on-neutral-strong',
  primary: 'bg-primary text-on-primary',
  secondary: 'bg-secondary text-on-secondary',
  tertiary: 'bg-tertiary text-on-tertiary',
  success: 'bg-success text-on-success',
  warning: 'bg-warning text-on-warning',
  danger: 'bg-danger text-on-danger'
};

const SOFT: Record<Role, string> = {
  neutral: 'bg-neutral-muted text-on-neutral-muted',
  primary: 'bg-primary-soft text-on-primary-soft',
  secondary: 'bg-secondary-soft text-on-secondary-soft',
  tertiary: 'bg-tertiary-soft text-on-tertiary-soft',
  success: 'bg-success-soft text-on-success-soft',
  warning: 'bg-warning-muted text-on-warning-soft',
  danger: 'bg-danger-soft text-on-danger-soft'
};

const SUBTLE: Record<Role, string> = {
  neutral: 'bg-neutral-subtle text-neutral-strong',
  primary: 'bg-primary-soft text-primary',
  secondary: 'bg-secondary-soft text-secondary',
  tertiary: 'bg-tertiary-muted text-tertiary-strong',
  success: 'bg-success-muted text-success-strong',
  warning: 'bg-warning-subtle text-warning',
  danger: 'bg-danger-muted text-danger'
};

// The icon color for the variants with no fill behind it. The outline ring
// takes the same color.
const INK: Record<Role, string> = {
  neutral: 'text-on-neutral-subtle',
  primary: 'text-primary',
  secondary: 'text-secondary',
  tertiary: 'text-tertiary-strong',
  success: 'text-success-strong',
  warning: 'text-warning',
  danger: 'text-danger'
};

const BY_VARIANT = {
  solid: SOLID,
  soft: SOFT,
  subtle: SUBTLE,
  outline: INK,
  plain: INK
} as const;

// A circle that centers an icon, sized from the design artifact: the circle
// diameter, the icon inside it, and for `plain` a tighter box with no circle.
// The icon is the `svg` the block contains, so it needs no size class of its
// own. These are the artifact's pixel values, not the `size-icon-*` ramp, which
// follows the label text. Outline draws its ring as an inset shadow in the
// icon color, 0.5px at 4xs up to 2.5px at 3xl.
//
// One deliberate difference from the artifact: it has `xl` the same as `lg`
// (64px circle, 40px plain box), which looks like a Figma slip, so `xl` is 72px
// and 44px, between `lg` and `2xl`. Confirm with the designer.
const icon = tv({
  base: 'box-border inline-flex shrink-0 items-center justify-center rounded-full align-middle',
  variants: {
    size: {
      '4xs': 'size-4 [&_svg]:size-[8px]',
      '3xs': 'size-5 [&_svg]:size-[10px]',
      '2xs': 'size-6 [&_svg]:size-[12px]',
      xs: 'size-8 [&_svg]:size-[16px]',
      sm: 'size-10 [&_svg]:size-[20px]',
      md: 'size-12 [&_svg]:size-[28px]',
      lg: 'size-16 [&_svg]:size-[32px]',
      xl: 'size-18 [&_svg]:size-[40px]',
      '2xl': 'size-20 [&_svg]:size-[48px]',
      '3xl': 'size-24 [&_svg]:size-[56px]'
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
    // For an icon on a surface of the other scheme. See the compound variants.
    inverse: {
      true: ''
    }
  },
  compoundVariants: [
    ...ROLES.flatMap((color) =>
      (Object.keys(BY_VARIANT) as (keyof typeof BY_VARIANT)[]).map(
        (variant) => ({ color, variant, class: BY_VARIANT[variant][color] })
      )
    ),
    // Inverse. Neutral solid, outline and plain swap their tokens, as the
    // artifact does: the fill and the icon change places, and the ink takes
    // `on-neutral`. Everything else re-resolves its tokens to the opposite
    // scheme with `theme-inverse`.
    {
      inverse: true,
      color: 'neutral',
      variant: 'solid',
      class: 'bg-on-neutral-strong text-on-neutral-subtle'
    },
    {
      inverse: true,
      color: 'neutral',
      variant: ['outline', 'plain'],
      class: 'text-on-neutral-strong'
    },
    {
      inverse: true,
      color: 'neutral',
      variant: ['soft', 'subtle'],
      class: 'theme-inverse'
    },
    {
      inverse: true,
      color: [
        'primary',
        'secondary',
        'tertiary',
        'success',
        'warning',
        'danger'
      ],
      class: 'theme-inverse'
    },
    // Plain has no circle, so its box is tighter. The icon size is unchanged.
    { variant: 'plain', size: '4xs', class: 'size-3' },
    { variant: 'plain', size: '3xs', class: 'size-3.5' },
    { variant: 'plain', size: '2xs', class: 'size-4' },
    { variant: 'plain', size: 'xs', class: 'size-5' },
    { variant: 'plain', size: 'sm', class: 'size-6' },
    { variant: 'plain', size: 'md', class: 'size-8' },
    { variant: 'plain', size: 'lg', class: 'size-10' },
    { variant: 'plain', size: 'xl', class: 'size-11' },
    { variant: 'plain', size: '2xl', class: 'size-12' },
    { variant: 'plain', size: '3xl', class: 'size-14' },
    // The ring, in the icon color.
    {
      variant: 'outline',
      size: ['4xs', '3xs'],
      class: 'shadow-[inset_0_0_0_0.5px_currentColor]'
    },
    {
      variant: 'outline',
      size: ['2xs', 'xs'],
      class: 'shadow-[inset_0_0_0_1px_currentColor]'
    },
    {
      variant: 'outline',
      size: 'sm',
      class: 'shadow-[inset_0_0_0_1.5px_currentColor]'
    },
    {
      variant: 'outline',
      size: ['md', 'lg', 'xl', '2xl'],
      class: 'shadow-[inset_0_0_0_2px_currentColor]'
    },
    {
      variant: 'outline',
      size: '3xl',
      class: 'shadow-[inset_0_0_0_2.5px_currentColor]'
    }
  ],
  // `color` has no default: a plain icon without one inherits the text color.
  defaultVariants: {
    size: 'md',
    variant: 'plain'
  }
});

export type IconVariants = VariantProps<typeof icon>;
export { icon };
