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
      'motion-reduce:transition-[opacity] motion-reduce:duration-150'
    ],
    // The inner element. Holds the actual row layout (icon, content,
    // actions, close button) and is never height-constrained, so its
    // `offsetHeight` is always the card's true natural height — that's
    // the value the measure modifier reads and reports to the stack.
    inner: 'flex gap-3 p-4 font-body text-body-2xs',
    icon: 'shrink-0 size-5',
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
        icon: 'mt-[calc((var(--text-label-xs)*var(--line-height-tight)-1.25rem)/2)]'
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

    // tonal: opaque tinted surface. `subtle` is opaque in both themes; `soft`
    // is translucent and must never be used on a floating toast.
    {
      variant: 'tonal',
      intent: 'default',
      class: {
        base: 'bg-neutral-subtle border-neutral-muted',
        icon: 'text-neutral-firm',
        title: 'text-neutral-firm'
      }
    },
    {
      variant: 'tonal',
      intent: 'info',
      class: {
        base: 'bg-primary-subtle border-primary-muted',
        icon: 'text-primary',
        title: 'text-primary'
      }
    },
    {
      // `success-firm` (green-600) on `success-subtle` (green-50) is only
      // ~2.2:1 in light mode — the light `success` scale runs bright at
      // every level below `strong`. `success-bolder` clears AA in both
      // themes (light: green-900 on green-50; dark: green-100 on
      // green-950). See packages/frontile/docs/notifications-usage.md's contrast note.
      variant: 'tonal',
      intent: 'success',
      class: {
        base: 'bg-success-subtle border-success-muted',
        icon: 'text-success-bolder',
        title: 'text-success-bolder'
      }
    },
    {
      // `warning` is the one intent whose dark `subtle` token (orange-600)
      // is a mid-tone rather than the near-black `-900`/`-950` tint every
      // other intent uses for its dark `subtle` — see semantic.ts. No text
      // color reaches 4.5:1 against it (even white is only ~5.5:1, and the
      // accent orange tones top out around 4:1), so the background itself
      // is special-cased here to the same `-900` depth the other intents
      // get for free, rather than changing the shared `warning` token and
      // affecting every other consumer of `bg-warning-subtle`. `bolder`
      // text (vs. the light theme's usual `firm`) is also needed in light
      // mode: `warning-firm` (orange-400) on `warning-subtle` (orange-50)
      // is only ~2.7:1. See packages/frontile/docs/notifications-usage.md's contrast note.
      variant: 'tonal',
      intent: 'warning',
      class: {
        base: 'bg-warning-subtle dark:bg-[#600102] border-warning-muted',
        icon: 'text-warning-bolder',
        title: 'text-warning-bolder'
      }
    },
    {
      variant: 'tonal',
      intent: 'danger',
      class: {
        base: 'bg-danger-subtle border-danger-muted',
        icon: 'text-danger-firm',
        title: 'text-danger-firm'
      }
    },

    // solid: filled surface, contrast text.
    {
      variant: 'solid',
      intent: 'default',
      class: {
        base: 'bg-neutral text-on-neutral',
        icon: 'text-on-neutral',
        title: 'text-on-neutral',
        description: 'text-on-neutral/80'
      }
    },
    {
      variant: 'solid',
      intent: 'info',
      class: {
        base: 'bg-primary text-on-primary',
        icon: 'text-on-primary',
        title: 'text-on-primary',
        description: 'text-on-primary/80'
      }
    },
    {
      variant: 'solid',
      intent: 'success',
      class: {
        base: 'bg-success text-on-success',
        icon: 'text-on-success',
        title: 'text-on-success',
        description: 'text-on-success/80'
      }
    },
    {
      variant: 'solid',
      intent: 'warning',
      class: {
        base: 'bg-warning text-on-warning',
        icon: 'text-on-warning',
        title: 'text-on-warning',
        description: 'text-on-warning/80'
      }
    },
    {
      variant: 'solid',
      intent: 'danger',
      class: {
        base: 'bg-danger text-on-danger',
        icon: 'text-on-danger',
        title: 'text-on-danger',
        description: 'text-on-danger/80'
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
