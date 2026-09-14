import { tv } from '../tw';
import { statusRowCloseButton } from './shared';

const notificationCard = tv({
  slots: {
    // The outer element. It carries the box treatment (surface color,
    // border, rounded corners, shadow) and everything the stack's geometry
    // animates (`transform`, `opacity`, and — while collapsed — a clamped
    // `height` so a taller card behind the front one can't poke out past
    // it). `overflow-hidden` here is what makes that clamp actually crop
    // the content instead of just failing to contain it.
    //
    // Deliberately NOT a flex container and NOT where padding/gap live:
    // the `ResizeObserver` in notification-card.gts measures `inner`, not
    // `base`, specifically so the reported height is always the content's
    // true natural height, never the clamped one `base` might be wearing
    // at the time. Move layout classes here and that guarantee breaks.
    base: [
      'pointer-events-auto w-full',
      'rounded-2xl border shadow-lg',
      'overflow-hidden',
      'transition-[transform,opacity,height] ease-[cubic-bezier(0.21,1.02,0.73,1)]',
      // The three `transition-duration` values line up positionally with
      // `transition-[transform,opacity,height]` above: transform and height
      // are the stack's own expand/collapse choreography, fixed at 400ms to
      // match the container's own height transition (see
      // notifications-container.gts) and the design spec's "transform
      // 400ms"; the middle value is the one `@transitionDuration` actually
      // governs (the enter/exit fade), supplied via the
      // `--frontile-toast-fade` custom property the card sets inline (see
      // notification-card.gts's `style` getter). Both the property order
      // and the duration ownership live here in one place so they can never
      // drift apart across the component boundary.
      '[transition-duration:400ms,_var(--frontile-toast-fade,_200ms),_400ms]',
      'motion-reduce:transition-[opacity] motion-reduce:duration-150',
      // Dropping the transition above only makes the transform apply
      // instantly instead of animating it — the transform itself (the
      // stack's slide/scale choreography) still comes from notification-card.gts's
      // `style` getter as an *inline* `transform:` declaration, so it would
      // still be present, just un-animated. An inline style normally wins
      // over any stylesheet rule regardless of that rule's specificity, but
      // `!important` is the one thing that overrides it — Tailwind v4 marks
      // a utility `!important` with a trailing `!`, which is exactly what's
      // needed here. This neutralizes every transform (enter/exit slide,
      // and the stack's hover-expand translate/scale) under
      // `prefers-reduced-motion`, matching the spec's "drops all
      // transforms", entirely in CSS with no JS branching required.
      'motion-reduce:transform-none!'
    ],
    // The inner element. Holds the actual row layout (icon, content,
    // actions, close button) and is never height-constrained, so its
    // `offsetHeight` is always the card's true natural height — that's
    // the value the measure modifier reads and reports to the stack.
    inner: 'flex gap-3 p-4 font-body text-body-2xs',
    icon: 'shrink-0 size-5',
    // The loading spinner's own slot, distinct from `icon`. It must NOT
    // reuse `icon` — `icon`'s intent-coloured `text-*` class (the compound
    // variants below) would win the Tailwind-merge over the Spinner's own
    // dim `text-neutral-muted` track, making the arc and track nearly
    // identical and the spin unreadable. `size-5` matches `icon` exactly so
    // a promise settling (spinner -> icon) never resizes the card. The arc
    // colour comes from `@intent` passed to <Spinner>, not from this slot;
    // this slot only ever supplies sizing/position and, where needed
    // (solid variant below), an explicit track/arc override.
    spinner: 'shrink-0 size-5',
    content: 'grow min-w-0 flex flex-col gap-1',
    title: 'font-label text-label-xs',
    description: 'text-body-2xs',
    customActions: 'flex flex-nowrap shrink-0 items-center gap-2 self-center',
    customActionButton: '',
    closeButton: statusRowCloseButton
  },

  variants: {
    intent: {
      default: {},
      info: {},
      success: {},
      warning: {},
      danger: {}
    },
    variant: {
      // `text-neutral` (the DEFAULT level) is only ~3:1 against a light
      // surface — below the 4.5:1 WCAG AA floor these labels need at this
      // size. `text-neutral-firm` clears it comfortably against every
      // surface this description can sit on, light or dark, tonal or not.
      // See packages/frontile/docs/notifications-usage.md's contrast note for the measured ratios.
      surface: {
        base: 'bg-surface-modal border-surface-overlay-mild',
        description: 'text-neutral-firm'
      },
      // The outer surface/border is intent-independent — every `soft`
      // compound variant below borrows the same neutral surface `surface`
      // uses (see the comment above the `soft` compound variants), so it
      // lives here once instead of repeating in each of them.
      soft: {
        base: 'bg-surface-modal border-surface-overlay-mild',
        description: 'text-neutral-firm'
      },
      solid: {
        base: 'border-transparent'
      }
    },
    // With a description, the icon centres on the *title's* line box rather
    // than the whole (now two-line) card — hence the negative offset.
    hasDescription: {
      true: {
        inner: 'items-start',
        icon: 'mt-[calc((var(--text-label-xs)*var(--line-height-tight)-1.25rem)/2)]',
        spinner:
          'mt-[calc((var(--text-label-xs)*var(--line-height-tight)-1.25rem)/2)]'
      },
      false: {
        inner: 'items-center'
      }
    },
    // Cards are pinned to the placement edge so the stack grows away from
    // it, once the container has supplied stack geometry (`@geometry` on
    // <NotificationCard>). `none` is the default — a card rendered without
    // geometry (e.g. a standalone demo) keeps its normal document flow.
    // The dynamic parts of the stack's positioning (transform, opacity,
    // height, z-index, transform-origin) still come from the card's own
    // inline `style` getter, since they change per-frame with the stack's
    // geometry — only the static edge-pinning lives here.
    stackPlacement: {
      top: { base: 'absolute inset-x-0 top-0' },
      bottom: { base: 'absolute inset-x-0 bottom-0' },
      none: {}
    }
  },

  compoundVariants: [
    // surface: neutral surface, colour carried by the icon and title.
    // `default` intent has no accent — icon and title stay neutral, same
    // `firm` level the other intents use for their accent text.
    {
      variant: 'surface',
      intent: 'default',
      class: { icon: 'text-neutral-firm', title: 'text-neutral-firm' }
    },
    {
      variant: 'surface',
      intent: 'info',
      class: { icon: 'text-primary', title: 'text-primary' }
    },
    {
      // `success-firm` is only ~2.3:1 on the white card surface in light
      // mode; `bolder` clears AA in both themes. See packages/frontile/docs/notifications-usage.md's
      // contrast note.
      variant: 'surface',
      intent: 'success',
      class: { icon: 'text-success-bolder', title: 'text-success-bolder' }
    },
    {
      // `warning-firm` is only ~3:1 on the white card surface in light
      // mode; `bolder` clears AA in both themes. See packages/frontile/docs/notifications-usage.md's
      // contrast note.
      variant: 'surface',
      intent: 'warning',
      class: { icon: 'text-warning-bolder', title: 'text-warning-bolder' }
    },
    {
      variant: 'surface',
      intent: 'danger',
      class: { icon: 'text-danger-firm', title: 'text-danger-firm' }
    },

    // soft: an opaque outer surface (so the floating card never lets page
    // content show through) with the translucent `{intent}-soft` tint and its
    // `on-*` contrast ink applied to the *inner* element, which composites
    // over that opaque surface. The outer picks up the `surface` variant's
    // neutral surface/border instead of a colour-matched one, so it borrows
    // that treatment rather than inventing a new one.
    {
      variant: 'soft',
      intent: 'default',
      class: {
        inner: 'bg-neutral-soft',
        icon: 'text-on-neutral-soft',
        title: 'text-on-neutral-soft'
      }
    },
    {
      variant: 'soft',
      intent: 'info',
      class: {
        inner: 'bg-primary-soft',
        icon: 'text-on-primary-soft',
        title: 'text-on-primary-soft'
      }
    },
    {
      variant: 'soft',
      intent: 'success',
      class: {
        inner: 'bg-success-soft',
        icon: 'text-on-success-soft',
        title: 'text-on-success-soft'
      }
    },
    {
      variant: 'soft',
      intent: 'warning',
      class: {
        inner: 'bg-warning-soft',
        icon: 'text-on-warning-soft',
        title: 'text-on-warning-soft'
      }
    },
    {
      variant: 'soft',
      intent: 'danger',
      class: {
        inner: 'bg-danger-soft',
        icon: 'text-on-danger-soft',
        title: 'text-on-danger-soft'
      }
    },

    // solid: filled surface, contrast text. `description` uses the
    // full-strength `on-{intent}` ink rather than a translucent cut — see
    // packages/frontile/docs/notifications-usage.md's contrast note for why
    // (a translucent cut used to fail WCAG AA here).
    //
    // The spinner override matters because `@intent` on <Spinner> drives its
    // arc via `fill-{intent}`, the exact same color as this variant's own
    // `bg-{intent}` surface — left alone the arc would be camouflaged
    // against its own card, so `solid` forces both halves of the spinner to
    // the contrast ink instead.
    {
      variant: 'solid',
      intent: 'default',
      class: {
        base: 'bg-neutral text-on-neutral',
        icon: 'text-on-neutral',
        title: 'text-on-neutral',
        description: 'text-on-neutral',
        spinner: 'fill-on-neutral text-on-neutral/30'
      }
    },
    {
      variant: 'solid',
      intent: 'info',
      class: {
        base: 'bg-primary text-on-primary',
        icon: 'text-on-primary',
        title: 'text-on-primary',
        description: 'text-on-primary',
        spinner: 'fill-on-primary text-on-primary/30'
      }
    },
    {
      variant: 'solid',
      intent: 'success',
      class: {
        base: 'bg-success text-on-success',
        icon: 'text-on-success',
        title: 'text-on-success',
        description: 'text-on-success',
        spinner: 'fill-on-success text-on-success/30'
      }
    },
    {
      variant: 'solid',
      intent: 'warning',
      class: {
        base: 'bg-warning text-on-warning',
        icon: 'text-on-warning',
        title: 'text-on-warning',
        description: 'text-on-warning',
        spinner: 'fill-on-warning text-on-warning/30'
      }
    },
    {
      variant: 'solid',
      intent: 'danger',
      class: {
        base: 'bg-danger text-on-danger',
        icon: 'text-on-danger',
        title: 'text-on-danger',
        description: 'text-on-danger',
        spinner: 'fill-on-danger text-on-danger/30'
      }
    }
  ],

  defaultVariants: {
    intent: 'default',
    variant: 'surface',
    hasDescription: false,
    stackPlacement: 'none'
  }
});

export { notificationCard };
