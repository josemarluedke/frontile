import { tv } from '../tw';
import { focusVisibleRing, focusVisibleWithinRing } from './shared';
import type { VariantProps } from '../tw';

const segmentedControl = tv({
  slots: {
    // The positioning context the indicator is measured against. `isolate`
    // keeps the indicator's stacking behind the items without leaking a
    // z-index into the surrounding page.
    base: ['relative isolate inline-flex', 'rounded-pill', 'p-1'],

    // Geometry comes from the custom properties `selectionIndicator` publishes;
    // this slot only decides what it looks like. `var()` names are literal:
    // Tailwind generates nothing from an interpolated class string.
    indicator: [
      'pointer-events-none absolute left-0 top-0 z-0',
      'w-[var(--fr-si-width)] h-[var(--fr-si-height)]',
      'translate-x-[var(--fr-si-x)] translate-y-[var(--fr-si-y)]',
      'rounded-pill',
      // Held until the first real measurement lands, so the indicator never
      // flies in from the container origin on first paint.
      'opacity-0',
      'group-data-[fr-si-ready]/segmented:opacity-100',
      // Tailwind v4 compiles `translate-x-*` to the standalone `translate`
      // property, not to `transform`, so `translate` is what has to be
      // transitioned. `transform` is listed for overrides that use it.
      'group-data-[fr-si-ready]/segmented:transition-[transform,translate,width,height]',
      'group-data-[fr-si-ready]/segmented:duration-200',
      'group-data-[fr-si-ready]/segmented:ease-out',
      'motion-reduce:transition-none'
    ],

    // Both focus rings, not one per rendering mode: in button mode the item is
    // the focusable element and `has-[:focus-visible]` has no descendant to
    // match, while in form mode the label is not focusable and `focus-visible:`
    // never matches it. Only one set can ever apply, so a third rendering mode
    // needs no third branch.
    item: [
      ...focusVisibleRing,
      ...focusVisibleWithinRing,
      'relative z-10',
      'inline-flex items-center justify-center gap-2',
      'cursor-pointer select-none whitespace-nowrap',
      'rounded-pill',
      'transition-colors duration-200',
      'motion-reduce:transition-none',
      // Both rendering modes publish `data-disabled`, so one selector covers
      // them. Keying off native `disabled:` would miss form mode, where the
      // item is a `<label>` and only the hidden input is disabled.
      'data-[disabled=true]:cursor-not-allowed data-[disabled=true]:opacity-disabled',
      // Resting, hover and selected are three distinct levels so hover has
      // somewhere to go that is not the selected ink. `neutral-firm` clears
      // WCAG AA against the track in both modes.
      'text-neutral-firm',
      // Scoped to unselected: an unscoped `hover:` ties on specificity with the
      // variants' `data-[selected=true]:` ink, leaving the winner to Tailwind's
      // emitted variant order.
      'data-[selected=false]:data-[disabled=false]:hover:text-neutral-strong'
    ]
  },

  variants: {
    variant: {
      solid: {
        // `surface-overlay-soft` is translucent in dark mode, as is the
        // indicator's `surface-card`; two stacked veils composite
        // unpredictably, so dark mode uses an opaque role instead.
        base: 'bg-surface-overlay-soft dark:bg-surface-table',
        indicator: 'shadow-elevation-1'
      },
      ghost: {
        base: 'bg-transparent',
        indicator: ''
      }
    },

    // Keyed off `data-selected`, which the item publishes in both rendering
    // modes -- the two express selection on different elements, so a rule per
    // mode is one mode away from being forgotten. Written literally: Tailwind
    // generates nothing from a composed class string.
    intent: {
      default: {
        // Opaque white in light mode. In dark, `surface-card` is translucent,
        // so an opaque neutral is used instead -- see the track above.
        indicator: 'bg-surface-card dark:bg-neutral-soft',
        item: 'data-[selected=true]:text-neutral-bolder'
      },
      primary: {
        indicator: 'bg-primary',
        item: 'data-[selected=true]:text-on-primary'
      },
      secondary: {
        indicator: 'bg-secondary',
        item: 'data-[selected=true]:text-on-secondary'
      },
      tertiary: {
        indicator: 'bg-tertiary',
        item: 'data-[selected=true]:text-on-tertiary'
      },
      success: {
        indicator: 'bg-success',
        item: 'data-[selected=true]:text-on-success'
      },
      warning: {
        indicator: 'bg-warning',
        item: 'data-[selected=true]:text-on-warning'
      },
      danger: {
        indicator: 'bg-danger',
        item: 'data-[selected=true]:text-on-danger'
      }
    },

    size: {
      sm: { item: 'px-3 py-1 text-label-sm' },
      md: { item: 'px-4 py-1.5 text-label-md' },
      lg: { item: 'px-5 py-2 text-label-lg' }
    },

    orientation: {
      horizontal: { base: 'flex-row' },
      // A pill radius on a tall narrow column reads as an oval blob, so the
      // vertical axis squares off -- on the track and on what sits inside it,
      // or the indicator would bulge out of the track. The inner radius is the
      // outer one less the track's `p-1`.
      vertical: {
        base: 'flex-col rounded-2xl',
        indicator: 'rounded-xl',
        item: 'rounded-xl'
      }
    },

    isFullWidth: {
      true: { base: 'flex w-full', item: 'flex-1' }
    },

    isDisabled: {
      true: { base: 'opacity-disabled', item: 'pointer-events-none' }
    },

    hasSeparators: {
      true: {
        item: [
          // A hairline before every item except the first. The level differs
          // per mode: neither the neutral scale nor the track is symmetric
          // across them, so one level cannot read on both.
          'before:absolute before:content-[""]',
          'before:bg-neutral-mild dark:before:bg-neutral-soft',
          'before:transition-opacity before:duration-200',
          'motion-reduce:before:transition-none',
          // The indicator's `<span>` is the container's true first child, so
          // `first:` would never match an item; `first-of-type:` does.
          'first-of-type:before:content-none',
          // Hidden on the selected item and the one after it, so the indicator
          // never crosses a visible line. Sibling selectors know the order, so
          // nothing tracks indices.
          'before:opacity-100',
          'data-[selected=true]:before:opacity-0',
          '[&[data-selected=true]+*]:before:opacity-0'
        ]
      }
    }
  },

  compoundVariants: [
    // Vertical items get their width from the flex stretch, so the padding
    // budget moves to the cross axis. One literal class per size.
    { orientation: 'vertical', size: 'sm', class: { item: 'py-1.5' } },
    { orientation: 'vertical', size: 'md', class: { item: 'py-2' } },
    { orientation: 'vertical', size: 'lg', class: { item: 'py-2.5' } },
    {
      hasSeparators: true,
      orientation: 'horizontal',
      class: {
        item: 'before:left-0 before:top-1/2 before:-translate-y-1/2 before:w-px before:h-4'
      }
    },
    {
      hasSeparators: true,
      orientation: 'vertical',
      class: {
        item: 'before:top-0 before:left-1/2 before:-translate-x-1/2 before:h-px before:w-4'
      }
    }
  ],

  defaultVariants: {
    variant: 'solid',
    intent: 'default',
    size: 'md',
    orientation: 'horizontal'
  }
});

export { segmentedControl };
export type SegmentedControlSlots = keyof ReturnType<typeof segmentedControl>;
export type SegmentedControlVariants = VariantProps<typeof segmentedControl>;
