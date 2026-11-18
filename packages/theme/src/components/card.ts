import { tv } from '../tw';
import { focusVisibleRing } from './shared';

/**
 * Card is a surface and nothing else: it owns the fill, border, radius,
 * padding and the states a surface can be in. What goes inside is the call
 * site's business, and so is selection behaviour — `isSelected` only changes
 * how the surface looks.
 *
 * The border is `border-2` in every variant and state, so moving between
 * states never shifts the contents. `flat` and `soft` keep the same border
 * width but make it transparent.
 *
 * Everything that depends on more than one variant lives in
 * `compoundVariants`. tv() applies those after the plain variants and
 * resolves conflicts with tailwind-merge, so a state's border or fill wins
 * over the variant's resting one without relying on declaration order.
 */
const card = tv({
  base: [
    'border-2 rounded-[20px]',
    'transition-[color,background-color,border-color,box-shadow] duration-200',
    'motion-reduce:transition-none'
  ],
  variants: {
    variant: {
      outline: 'bg-surface-card',
      flat: 'bg-surface-card border-transparent',
      // `overlay-soft`, not `-subtle`: in dark mode `surface-card` and
      // `surface-overlay-subtle` are the same colour (white @ 7%), which would
      // make `soft` identical to `flat`. The same pairing rules out
      // `overlay-subtle` for any hover or pressed fill below.
      soft: 'bg-surface-overlay-soft border-transparent'
    },
    // Colour only steers the hover and selected border. The resting border
    // is neutral for both, as in the design.
    color: {
      neutral: '',
      primary: ''
    },
    density: {
      compact: 'p-3',
      comfortable: 'p-5',
      spacious: 'p-8'
    },
    // Only `outline` is ever raised; `flat` and `soft` have no shadow in
    // either setting.
    elevation: {
      raised: '',
      none: ''
    },
    isSelected: {
      true: '',
      false: ''
    },
    isInteractive: {
      true: '',
      false: ''
    },
    isDisabled: {
      true: 'opacity-disabled cursor-not-allowed',
      false: ''
    }
  },
  compoundVariants: [
    // RESTING SURFACE
    {
      variant: 'outline',
      isSelected: false,
      class: 'border-neutral-muted'
    },
    {
      variant: 'outline',
      elevation: 'raised',
      class: 'shadow-elevation-2'
    },

    // SELECTED. The fill is unchanged; only the border takes the colour.
    {
      isSelected: true,
      color: 'primary',
      class: 'border-primary'
    },
    {
      isSelected: true,
      color: 'neutral',
      class: 'border-neutral-bolder'
    },

    // INTERACTIVE. Disabled wins: no hover, pressed, focus ring or pointer.
    {
      isInteractive: true,
      isDisabled: false,
      class: ['cursor-pointer', ...focusVisibleRing]
    },

    // PRESSED sits one overlay level above each variant's hover, so it is a
    // distinct step in light and dark. Outline has no hover fill, so it goes
    // straight to `overlay-soft` off the card fill.
    {
      variant: 'outline',
      isInteractive: true,
      isDisabled: false,
      class: 'active:bg-surface-overlay-soft'
    },
    {
      variant: 'flat',
      isInteractive: true,
      isDisabled: false,
      class: 'active:bg-surface-overlay-mild'
    },
    {
      variant: 'soft',
      isInteractive: true,
      isDisabled: false,
      class: 'active:bg-surface-overlay-firm'
    },

    // HOVER, unselected. Hover is scoped to the unselected state so it never
    // ties on specificity with the selected border.
    {
      variant: 'outline',
      isInteractive: true,
      isDisabled: false,
      isSelected: false,
      color: 'primary',
      class: 'hover:border-primary-muted'
    },
    {
      variant: 'outline',
      isInteractive: true,
      isDisabled: false,
      isSelected: false,
      color: 'neutral',
      class: 'hover:border-neutral-soft'
    },
    {
      variant: 'flat',
      isInteractive: true,
      isDisabled: false,
      isSelected: false,
      class: 'hover:bg-surface-overlay-soft'
    },
    {
      variant: 'soft',
      isInteractive: true,
      isDisabled: false,
      isSelected: false,
      class: 'hover:bg-surface-overlay-mild'
    },

    // HOVER LIFT. Raised outline cards step up an elevation level, selected
    // or not.
    {
      variant: 'outline',
      elevation: 'raised',
      isInteractive: true,
      isDisabled: false,
      class: 'hover:shadow-elevation-3'
    }
  ],
  defaultVariants: {
    variant: 'outline',
    color: 'neutral',
    density: 'comfortable',
    elevation: 'raised',
    isSelected: false,
    isInteractive: false,
    isDisabled: false
  }
});

export { card };
