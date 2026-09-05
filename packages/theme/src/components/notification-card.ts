import { tv } from '../tw';
import { focusVisibleRing } from './shared';

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
      'transition-[transform,opacity,height] duration-400 ease-[cubic-bezier(0.21,1.02,0.73,1)]',
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
    closeButton: [
      'shrink-0 self-center -mr-1 inline-block p-1.5 rounded-full',
      'transition duration-200',
      'hover:bg-surface-overlay-soft',
      ...focusVisibleRing
    ]
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
      default: {
        base: 'bg-surface-modal border-surface-overlay-mild',
        description: 'text-neutral-firm'
      },
      tonal: {
        description: 'text-neutral-firm'
      },
      solid: {
        base: 'border-transparent'
      }
    },
    // No description: the row reads as a single centred line — icon, title,
    // and close button all share the same vertical centre.
    // With a description: the card grows to two lines, so the icon aligns
    // with the *title's* line box instead of the whole card. The icon is
    // nudged down by half the difference between the title's line height and
    // the icon's own height, so their centres coincide.
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
    }
  },

  compoundVariants: [
    // default: neutral surface, colour carried by the icon and title.
    // `default` intent has no accent — icon and title stay neutral, same
    // `firm` level the other intents use for their accent text.
    {
      variant: 'default',
      intent: 'default',
      class: { icon: 'text-neutral-firm', title: 'text-neutral-firm' }
    },
    {
      variant: 'default',
      intent: 'info',
      class: { icon: 'text-primary', title: 'text-primary' }
    },
    {
      // `success-firm` is only ~2.3:1 on the white card surface in light
      // mode; `bolder` clears AA in both themes. See packages/frontile/docs/notifications-usage.md's
      // contrast note.
      variant: 'default',
      intent: 'success',
      class: { icon: 'text-success-bolder', title: 'text-success-bolder' }
    },
    {
      // `warning-firm` is only ~3:1 on the white card surface in light
      // mode; `bolder` clears AA in both themes. See packages/frontile/docs/notifications-usage.md's
      // contrast note.
      variant: 'default',
      intent: 'warning',
      class: { icon: 'text-warning-bolder', title: 'text-warning-bolder' }
    },
    {
      variant: 'default',
      intent: 'danger',
      class: { icon: 'text-danger-firm', title: 'text-danger-firm' }
    },

    // tonal: same recipe as Button's `appearance: 'tonal'` — an opaque
    // outer surface (so the floating card never lets page content show
    // through) with the translucent `{intent}-soft` tint and its `on-*`
    // contrast ink applied to the *inner* element, which composites over
    // that opaque surface. The outer picks up the `default` variant's
    // neutral surface/border instead of a colour-matched one: Button's
    // tonal has no border at all, but a card floating over arbitrary page
    // content benefits from the same edge definition `default` already
    // uses, so it borrows that treatment rather than inventing a new one.
    {
      variant: 'tonal',
      intent: 'default',
      class: {
        base: 'bg-surface-modal border-surface-overlay-mild',
        inner: 'bg-neutral-soft',
        icon: 'text-on-neutral-soft',
        title: 'text-on-neutral-soft'
      }
    },
    {
      variant: 'tonal',
      intent: 'info',
      class: {
        base: 'bg-surface-modal border-surface-overlay-mild',
        inner: 'bg-primary-soft',
        icon: 'text-on-primary-soft',
        title: 'text-on-primary-soft'
      }
    },
    {
      variant: 'tonal',
      intent: 'success',
      class: {
        base: 'bg-surface-modal border-surface-overlay-mild',
        inner: 'bg-success-soft',
        icon: 'text-on-success-soft',
        title: 'text-on-success-soft'
      }
    },
    {
      variant: 'tonal',
      intent: 'warning',
      class: {
        base: 'bg-surface-modal border-surface-overlay-mild',
        inner: 'bg-warning-soft',
        icon: 'text-on-warning-soft',
        title: 'text-on-warning-soft'
      }
    },
    {
      variant: 'tonal',
      intent: 'danger',
      class: {
        base: 'bg-surface-modal border-surface-overlay-mild',
        inner: 'bg-danger-soft',
        icon: 'text-on-danger-soft',
        title: 'text-on-danger-soft'
      }
    },

    // solid: filled surface, contrast text.
    //
    // `description` uses the full-strength `on-{intent}` ink, not a
    // translucent cut of it. An earlier version used `/80` here, but
    // compositing white/black at 80% over a saturated fill loses most of
    // the contrast — e.g. `danger`'s fill (`#e51701`) drops to ~3.37:1 in
    // light mode, below the 4.5:1 WCAG AA floor. Full opacity matches the
    // title/icon contrast (≥4.71:1 for every intent in both themes) with
    // no measurable loss of visual hierarchy, since the hierarchy here
    // already comes from font weight/size, not from a dimmed description.
    //
    // The spinner override here matters for a reason the other solid classes
    // don't have to worry about: `@intent` on <Spinner> (mapped from
    // `ACTION_INTENT`) drives the arc via `fill-{intent}` — e.g. `fill-primary`
    // — which is the *exact same color* as this variant's own `bg-{intent}`
    // surface. Left alone, the arc would be perfectly camouflaged against its
    // own card. So on `solid` we force both halves of the spinner to the
    // contrast ink instead: `fill-on-{intent}` for the arc (full strength,
    // same ink as the icon/title) and `text-on-{intent}/30` for the track (the
    // same ink at low opacity, so it reads as dim without needing a second
    // neutral color that might clash with a saturated fill).
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
    variant: 'default',
    hasDescription: false
  }
});

export { notificationCard };
