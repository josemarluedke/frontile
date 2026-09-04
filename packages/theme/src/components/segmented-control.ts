import { tv } from '../tw';
import { focusVisibleRing, focusVisibleWithinRing } from './shared';
import type { VariantProps } from '../tw';

const segmentedControl = tv({
  slots: {
    // The positioning context the indicator is measured against. `isolate`
    // keeps the indicator's stacking behind the items without leaking a
    // z-index into the surrounding page.
    base: ['relative isolate inline-flex', 'rounded-pill', 'p-1'],

    // Geometry comes entirely from the custom properties SelectionIndicator
    // publishes; this slot decides only what that geometry looks like. An
    // underline variant would keep `--fr-si-x` / `--fr-si-width` and pin
    // itself to one edge instead -- no JS change.
    //
    // `var()` names are written literally: Tailwind generates nothing from an
    // interpolated class string.
    indicator: [
      'pointer-events-none absolute left-0 top-0 z-0',
      'w-[var(--fr-si-width)] h-[var(--fr-si-height)]',
      'translate-x-[var(--fr-si-x)] translate-y-[var(--fr-si-y)]',
      'rounded-pill',
      // Held still until the first real measurement has landed, so the
      // indicator never flies in from the container origin on first paint.
      'opacity-0',
      'group-data-[fr-si-ready]/segmented:opacity-100',
      'group-data-[fr-si-ready]/segmented:transition-[transform,width,height]',
      'group-data-[fr-si-ready]/segmented:duration-200',
      'group-data-[fr-si-ready]/segmented:ease-out',
      'motion-reduce:transition-none'
    ],

    // The focus ring is NOT set here: it differs by rendering mode and is
    // supplied by the `mode` variant below.
    item: [
      'relative z-10',
      'inline-flex items-center justify-center gap-2',
      'cursor-pointer select-none whitespace-nowrap',
      'rounded-pill',
      'transition-colors duration-200',
      'motion-reduce:transition-none',
      'disabled:cursor-not-allowed disabled:opacity-disabled',
      'aria-disabled:cursor-not-allowed aria-disabled:opacity-disabled',
      'has-[:disabled]:cursor-not-allowed has-[:disabled]:opacity-disabled'
    ]
  },

  variants: {
    // Which element the item renders as. In form mode the radio input is
    // `sr-only`, so focusing it would otherwise show no ring at all -- the
    // ring has to be drawn on the wrapping label instead.
    mode: {
      button: { item: focusVisibleRing },
      form: { item: focusVisibleWithinRing }
    },

    variant: {
      solid: {
        // `bg-surface-soft` does not exist in this design system's surface
        // scale (surface roles are `overlay-*`/`lift-*` plus named container
        // surfaces like `card`/`table`/`input`/`modal` -- see
        // packages/theme/src/colors/semantic.ts and packages/theme/src/colors/types.ts).
        // `bg-surface-overlay-soft` is the closest existing role and is the
        // one other components already use for a recessed track (see
        // packages/theme/src/components/progress-bar.ts).
        base: 'bg-surface-overlay-soft',
        indicator: 'shadow-elevation-1'
      },
      ghost: {
        base: 'bg-transparent',
        indicator: ''
      }
    },

    intent: {
      default: {
        indicator: 'bg-surface-card',
        item: 'text-neutral-strong hover:text-neutral-bolder aria-checked:text-neutral-bolder'
      },
      primary: {
        indicator: 'bg-primary',
        item: 'text-neutral-strong hover:text-neutral-bolder aria-checked:text-on-primary'
      },
      secondary: {
        indicator: 'bg-secondary',
        item: 'text-neutral-strong hover:text-neutral-bolder aria-checked:text-on-secondary'
      },
      tertiary: {
        indicator: 'bg-tertiary',
        item: 'text-neutral-strong hover:text-neutral-bolder aria-checked:text-on-tertiary'
      },
      success: {
        indicator: 'bg-success',
        item: 'text-neutral-strong hover:text-neutral-bolder aria-checked:text-on-success'
      },
      warning: {
        indicator: 'bg-warning',
        item: 'text-neutral-strong hover:text-neutral-bolder aria-checked:text-on-warning'
      },
      danger: {
        indicator: 'bg-danger',
        item: 'text-neutral-strong hover:text-neutral-bolder aria-checked:text-on-danger'
      }
    },

    size: {
      sm: { item: 'px-3 py-1 text-label-sm' },
      md: { item: 'px-4 py-1.5 text-label-md' },
      lg: { item: 'px-5 py-2 text-label-lg' }
    },

    orientation: {
      horizontal: { base: 'flex-row' },
      vertical: { base: 'flex-col' }
    },

    isFullWidth: {
      true: { base: 'flex w-full', item: 'flex-1' }
    },

    isDisabled: {
      true: { base: 'opacity-disabled', item: 'pointer-events-none' }
    }
  },

  defaultVariants: {
    mode: 'button',
    variant: 'solid',
    intent: 'default',
    size: 'md',
    orientation: 'horizontal'
  }
});

export { segmentedControl };
export type SegmentedControlSlots = keyof ReturnType<typeof segmentedControl>;
export type SegmentedControlVariants = VariantProps<typeof segmentedControl>;
