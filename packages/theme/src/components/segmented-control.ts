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
        //
        // In dark mode `surface-overlay-soft` resolves to a *translucent*
        // white wash (white @ 11%), same as the indicator's `surface-card`
        // (white @ 7%, see the `intent.default.indicator` comment below) --
        // two translucent veils stacked on an unknown page background give an
        // unpredictable, washed-out composite (the pill was in fact the
        // *less* opaque of the two, so it could read as no lighter than the
        // track). `dark:bg-surface-table` swaps in the opaque dark
        // container role (palette.gray['900']) for a solid, predictable
        // recessed track -- the same "opaque role instead of a translucent
        // surface-*" fix already used elsewhere in this codebase (see
        // packages/theme/src/components/table.ts's own `surface-table`
        // usage, and overlays.ts's `dark:bg-surface-lift-strong` override of
        // `surface-overlay-strong` for the same reason). Light mode is
        // untouched and already correct (black @ 5% over a white page reads
        // as a subtle grey track).
        base: 'bg-surface-overlay-soft dark:bg-surface-table',
        indicator: 'shadow-elevation-1'
      },
      ghost: {
        base: 'bg-transparent',
        indicator: ''
      }
    },

    intent: {
      default: {
        // Light mode: `bg-surface-card` is opaque white (`absolute.white`) --
        // a clean white pill on the (now opaque) grey track, exactly the
        // reference look. Left unchanged.
        //
        // Dark mode: `surface-card` is translucent (white @ 7%) -- stacked on
        // the track's own translucent wash this composited to only a few
        // points of luminance difference, an almost invisible selected
        // state. `packages/theme/src/plugin/resolve.ts`'s
        // `shouldGenerateOnColor()` already refuses to generate `on-*`
        // contrast colors for `surface-overlay-*`/`surface-lift-*` roles
        // because their contrast depends on whatever shows through --
        // stacking two such roles has the same problem. `dark:bg-neutral-soft`
        // swaps in the opaque neutral role (palette.gray['700']) instead: a
        // solid, clearly-lighter pill against the `surface-table`
        // (palette.gray['900']) track now used above, and it keeps
        // `aria-checked:text-neutral-bolder` below (palette.gray['100'] in
        // dark mode) comfortably legible against it (~6.8:1 contrast).
        indicator: 'bg-surface-card dark:bg-neutral-soft',
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
