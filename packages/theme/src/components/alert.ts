import { tv } from '../tw';
import { focusVisibleRing } from './shared';

const alert = tv({
  slots: {
    // The outer element: box treatment only (surface, border, radius).
    // No shadow and a tighter radius than `notificationCard` — an Alert
    // sits in the page rather than floating over it. No transition
    // machinery, no `stackPlacement`, no `overflow-hidden`: those exist on
    // the card to serve the notification stack's geometry, which Alert has
    // no part in.
    base: 'w-full rounded-lg border',
    // The inner element carries the row layout. Alert has no
    // ResizeObserver, so unlike the card it does not need this split for
    // measurement — it needs it because the `tonal` variant's translucent
    // `{intent}-soft` tint has to composite over an opaque surface. All
    // three variants share the structure rather than branching the DOM.
    inner: 'flex gap-3 p-4 font-body text-body-2xs',
    icon: 'shrink-0 size-5',
    content: 'grow min-w-0 flex flex-col gap-1',
    title: 'font-label text-label-xs',
    description: 'text-body-2xs',
    actions: 'flex flex-nowrap shrink-0 items-center gap-2 self-center',
    closeButton: [
      'shrink-0 self-center -mr-1 inline-block p-1.5 rounded-full',
      'transition duration-200',
      'hover:bg-surface-overlay-soft',
      ...focusVisibleRing
    ]
  },

  variants: {
    // Intent alone paints nothing; every colour comes from an intent ×
    // variant compound below.
    intent: {
      default: {},
      info: {},
      success: {},
      warning: {},
      danger: {}
    },
    variant: {
      // `text-neutral` (the DEFAULT level) is only ~3:1 against a light
      // surface — below the 4.5:1 WCAG AA floor a description needs at
      // this size. `text-neutral-firm` clears it against every surface
      // this text can sit on, light or dark.
      default: {
        base: 'bg-surface-modal border-surface-overlay-mild',
        description: 'text-neutral-firm'
      },
      // The outer surface/border is intent-independent — every `tonal`
      // compound below tints the *inner* element instead — so it lives
      // here once rather than repeating five times.
      tonal: {
        base: 'bg-surface-modal border-surface-overlay-mild',
        description: 'text-neutral-firm'
      },
      solid: {
        base: 'border-transparent'
      }
    },
    // With a description the icon centres on the *title's* line box rather
    // than on the whole (now multi-line) row, hence the negative offset.
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
    // The `default` intent has no accent — icon and title stay neutral at
    // the same `firm` level the other intents use for their accent text.
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
      // `success-firm` is only ~2.3:1 on a light surface; `bolder` clears
      // AA in both themes. Same measurement the card's theme records.
      variant: 'default',
      intent: 'success',
      class: { icon: 'text-success-bolder', title: 'text-success-bolder' }
    },
    {
      // `warning-firm` is only ~3:1 on a light surface; `bolder` clears AA
      // in both themes.
      variant: 'default',
      intent: 'warning',
      class: { icon: 'text-warning-bolder', title: 'text-warning-bolder' }
    },
    {
      variant: 'default',
      intent: 'danger',
      class: { icon: 'text-danger-firm', title: 'text-danger-firm' }
    },

    // tonal: an opaque outer surface with the translucent `{intent}-soft`
    // tint and its `on-*` contrast ink applied to the inner element, which
    // composites over that opaque surface. Same recipe as Button's
    // `appearance: 'tonal'` and NotificationCard's.
    {
      variant: 'tonal',
      intent: 'default',
      class: {
        inner: 'bg-neutral-soft',
        icon: 'text-on-neutral-soft',
        title: 'text-on-neutral-soft'
      }
    },
    {
      variant: 'tonal',
      intent: 'info',
      class: {
        inner: 'bg-primary-soft',
        icon: 'text-on-primary-soft',
        title: 'text-on-primary-soft'
      }
    },
    {
      variant: 'tonal',
      intent: 'success',
      class: {
        inner: 'bg-success-soft',
        icon: 'text-on-success-soft',
        title: 'text-on-success-soft'
      }
    },
    {
      variant: 'tonal',
      intent: 'warning',
      class: {
        inner: 'bg-warning-soft',
        icon: 'text-on-warning-soft',
        title: 'text-on-warning-soft'
      }
    },
    {
      variant: 'tonal',
      intent: 'danger',
      class: {
        inner: 'bg-danger-soft',
        icon: 'text-on-danger-soft',
        title: 'text-on-danger-soft'
      }
    },

    // solid: filled surface, contrast ink. The description uses the
    // full-strength `on-{intent}` ink rather than a translucent cut — a
    // translucent cut failed WCAG AA in the equivalent card recipe.
    {
      variant: 'solid',
      intent: 'default',
      class: {
        base: 'bg-neutral text-on-neutral',
        icon: 'text-on-neutral',
        title: 'text-on-neutral',
        description: 'text-on-neutral'
      }
    },
    {
      variant: 'solid',
      intent: 'info',
      class: {
        base: 'bg-primary text-on-primary',
        icon: 'text-on-primary',
        title: 'text-on-primary',
        description: 'text-on-primary'
      }
    },
    {
      variant: 'solid',
      intent: 'success',
      class: {
        base: 'bg-success text-on-success',
        icon: 'text-on-success',
        title: 'text-on-success',
        description: 'text-on-success'
      }
    },
    {
      variant: 'solid',
      intent: 'warning',
      class: {
        base: 'bg-warning text-on-warning',
        icon: 'text-on-warning',
        title: 'text-on-warning',
        description: 'text-on-warning'
      }
    },
    {
      variant: 'solid',
      intent: 'danger',
      class: {
        base: 'bg-danger text-on-danger',
        icon: 'text-on-danger',
        title: 'text-on-danger',
        description: 'text-on-danger'
      }
    }
  ],

  defaultVariants: {
    intent: 'default',
    variant: 'default',
    hasDescription: false
  }
});

export type AlertSlots = keyof ReturnType<typeof alert>;
export { alert };
