import { tv } from '../tw';
import { focusVisibleRing } from './shared';

/**
 * Card is a surface and nothing else: it owns the fill, border, radius,
 * padding and the states a surface can be in. What goes inside is the call
 * site's business, and so is selection behaviour — `isSelected` only changes
 * how the surface looks.
 *
 * The border is `border` (1px) in every variant and state, so moving between
 * states never shifts the contents. `flat` and `soft` keep the same border
 * width but make it transparent. Hover and selected add weight without
 * changing that width: a second 1px layer, drawn inside the border in the same
 * colour with `inset-shadow-[0_0_0_1px_…]`, so the edge reads as 2px.
 *
 * That layer is an `inset-shadow`, not a `ring` or an `outline`. `ring-*`
 * shares its `--tw-ring-*` variables with the focus ring (`focusVisibleRing`),
 * so a focused selected card would get an inset focus ring; `outline` is the
 * focus indicator in forced-colors (`outline-hidden`). `inset-shadow` has its
 * own variable and stacks with `shadow-elevation-*` and the focus ring.
 *
 * `box-shadow` is not drawn in forced-colors, so a selected card widens its
 * border to 3px in that mode instead (`forced-colors:border-[3px]`). A layout
 * shift is acceptable there; losing the selected cue is not.
 *
 * Everything that depends on more than one variant lives in
 * `compoundVariants`. tv() applies those after the plain variants and
 * resolves conflicts with tailwind-merge, so a state's border or fill wins
 * over the variant's resting one without relying on declaration order.
 */
const card = tv({
  base: [
    // A positioning context for the selection indicator.
    'relative',
    'border rounded-[20px]',
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

    // SELECTED. The fill is unchanged; the border takes the colour and a
    // second 1px layer inside it makes the edge read as 2px. Forced-colors
    // draws no box-shadow, so it gets a real, thicker border instead.
    {
      isSelected: true,
      color: 'primary',
      class: [
        'border-primary',
        'inset-shadow-[0_0_0_1px_var(--color-primary)]',
        'forced-colors:border-[3px]'
      ]
    },
    {
      isSelected: true,
      color: 'neutral',
      class: [
        'border-neutral-bolder',
        'inset-shadow-[0_0_0_1px_var(--color-neutral-bolder)]',
        'forced-colors:border-[3px]'
      ]
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
    // ties on specificity with the selected border. The border colour is
    // joined by a 1px inset layer in the same colour, so it reads as 2px.
    {
      variant: 'outline',
      isInteractive: true,
      isDisabled: false,
      isSelected: false,
      color: 'primary',
      class: [
        'hover:border-primary-muted',
        'hover:inset-shadow-[0_0_0_1px_var(--color-primary-muted)]'
      ]
    },
    {
      variant: 'outline',
      isInteractive: true,
      isDisabled: false,
      isSelected: false,
      color: 'neutral',
      class: [
        'hover:border-neutral-soft',
        'hover:inset-shadow-[0_0_0_1px_var(--color-neutral-soft)]'
      ]
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

/**
 * The selection indicator: a small solid circle overhanging a card's top-right
 * corner, holding whatever icon the call site passes in the `indicator` block.
 * Card renders it only while selected, so it has no state of its own. The
 * overhang is why `card` is `relative` and has no `overflow-hidden`.
 *
 * `starting:` gives it a short fade and scale in when it mounts; reduced
 * motion drops the transition.
 */
const cardIndicator = tv({
  base: [
    // Offsets are measured from the padding box, inside the 1px border, so
    // 1.25 (5px) leaves the circle 4px past the card's outer edge.
    'pointer-events-none absolute -top-1.25 -right-1.25 z-10',
    'inline-flex size-5 items-center justify-center rounded-full',
    '[&>svg]:size-3',
    'transition-[opacity,scale] duration-200',
    'starting:opacity-0 starting:scale-75',
    'motion-reduce:transition-none'
  ],
  variants: {
    color: {
      neutral: 'bg-neutral-bolder text-on-neutral-bolder',
      primary: 'bg-primary text-on-primary'
    }
  },
  defaultVariants: {
    color: 'neutral'
  }
});

export { card, cardIndicator };
