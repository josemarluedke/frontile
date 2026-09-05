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
      // `translate` is the property that actually moves the indicator:
      // Tailwind v4 compiles `translate-x-*`/`translate-y-*` to the
      // standalone CSS `translate` property, NOT to `transform`. Omitting it
      // here made the pill snap to its new position in a single frame while
      // only `width` eased -- the slide, the component's headline behaviour,
      // never happened. `transform` stays in the list only as cheap
      // belt-and-braces: the docs steer overrides AWAY from `transform`
      // (it composes with `translate` rather than replacing it, so the
      // offset lands twice -- see the "transform / translate trap" section
      // of selection-indicator.md), but naming an unused property in a
      // transition list costs nothing, and an override that reaches for it
      // anyway then eases instead of snapping.
      'group-data-[fr-si-ready]/segmented:transition-[transform,translate,width,height]',
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
      // Both rendering modes publish `data-disabled`, so one selector covers
      // them. Keying off native `disabled:` would miss form mode, where the
      // item is a `<label>` and only the hidden input is disabled.
      'data-[disabled=true]:cursor-not-allowed data-[disabled=true]:opacity-disabled'
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

    // Selected-state text colour keys off `data-selected`, which the item
    // publishes in both rendering modes. That matters beyond brevity: the two
    // modes express "selected" on different elements -- button mode's item
    // carries `aria-checked`, while form mode's `<label>` only contains a
    // checked `sr-only` input -- and pairing a rule per mode is how this
    // component previously shipped a bug where the colour silently never
    // applied in form mode. One attribute, one rule, no mode to forget.
    // `data-[selected=true]` is a specificity step above the resting
    // `text-neutral-strong`, so it wins regardless of source order. Written
    // out literally: Tailwind generates nothing from a composed class string.
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
        // `data-[selected=true]:text-neutral-bolder` below (gray['100'] in
        // dark mode) comfortably legible against it (~6.8:1 contrast).
        indicator: 'bg-surface-card dark:bg-neutral-soft',
        item: 'text-neutral-strong hover:text-neutral-bolder data-[selected=true]:text-neutral-bolder'
      },
      primary: {
        indicator: 'bg-primary',
        item: 'text-neutral-strong hover:text-neutral-bolder data-[selected=true]:text-on-primary'
      },
      secondary: {
        indicator: 'bg-secondary',
        item: 'text-neutral-strong hover:text-neutral-bolder data-[selected=true]:text-on-secondary'
      },
      tertiary: {
        indicator: 'bg-tertiary',
        item: 'text-neutral-strong hover:text-neutral-bolder data-[selected=true]:text-on-tertiary'
      },
      success: {
        indicator: 'bg-success',
        item: 'text-neutral-strong hover:text-neutral-bolder data-[selected=true]:text-on-success'
      },
      warning: {
        indicator: 'bg-warning',
        item: 'text-neutral-strong hover:text-neutral-bolder data-[selected=true]:text-on-warning'
      },
      danger: {
        indicator: 'bg-danger',
        item: 'text-neutral-strong hover:text-neutral-bolder data-[selected=true]:text-on-danger'
      }
    },

    size: {
      sm: { item: 'px-3 py-1 text-label-sm' },
      md: { item: 'px-4 py-1.5 text-label-md' },
      lg: { item: 'px-5 py-2 text-label-lg' }
    },

    orientation: {
      horizontal: { base: 'flex-row' },
      // A pill radius on a tall narrow column is an oval blob rather than a
      // stack, so the vertical axis swaps to a rounded rectangle -- on the
      // track AND on the things that sit inside it, or the indicator's own
      // 9999px would still bulge out of the squared-off track. Radii come from
      // the registered `rounded` scale (`--radius-2xl` 16px outside,
      // `--radius-xl` 12px inside, which is the outer radius less the track's
      // `p-1`), never an invented value; tailwind-merge's `rounded` group lets
      // them override the slot's own `rounded-pill`.
      //
      // The radius swap plus the per-size `py-*` compound variants below are
      // the whole of this axis's styling. Items share a width without anything
      // stated here: `align-items` is left at its flex default, so they stretch
      // to the column and the indicator keeps one width as the selection moves.
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
          // A hairline before every item except the first.
          //
          // The level differs per mode because neither the neutral scale nor
          // the track is symmetric across them. `neutral-muted` alone reads at
          // 1.06:1 against the light track (`surface-overlay-soft` over the
          // page, ~#f2f2f2) -- mathematically invisible -- while reading fine
          // on the dark one. `mild` in light and `soft` in dark land at
          // 1.49:1 and 2.08:1: present without competing with the labels.
          'before:absolute before:content-[""]',
          'before:bg-neutral-mild dark:before:bg-neutral-soft',
          'before:transition-opacity before:duration-200',
          'motion-reduce:before:transition-none',
          // The indicator's own `<span>` is the container's true first
          // child, so `first:` (which matches `:first-child`) would never
          // match any item -- `first-of-type:` matches the first item among
          // its own tag (`button`/`label`) instead, regardless of what
          // precedes it.
          'first-of-type:before:content-none',
          // Hidden on the selected item and on the one immediately after it,
          // so the indicator never slides across a visible line. Sibling
          // selectors already know the order, so nothing has to track indices.
          'before:opacity-100',
          'data-[selected=true]:before:opacity-0',
          '[&[data-selected=true]+*]:before:opacity-0'
        ]
      }
    }
  },

  compoundVariants: [
    // Stacked rows read as cramped at the horizontal paddings, where the
    // px/py ratio is tuned for items sitting shoulder to shoulder. On the
    // vertical axis the width comes from the flex stretch instead, so the
    // padding budget moves to the cross axis. Written as one literal class per
    // size; tailwind-merge drops the `py-*` set by the `size` variant.
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
