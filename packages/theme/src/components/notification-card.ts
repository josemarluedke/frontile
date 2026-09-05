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
      info: {},
      success: {},
      warning: {},
      danger: {}
    },
    variant: {
      default: {
        base: 'bg-surface-modal border-surface-overlay-mild',
        description: 'text-neutral'
      },
      tonal: {
        description: 'text-neutral'
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
    {
      variant: 'default',
      intent: 'info',
      class: { icon: 'text-primary', title: 'text-primary' }
    },
    {
      variant: 'default',
      intent: 'success',
      class: { icon: 'text-success-firm', title: 'text-success-firm' }
    },
    {
      variant: 'default',
      intent: 'warning',
      class: { icon: 'text-warning-firm', title: 'text-warning-firm' }
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
      intent: 'info',
      class: {
        base: 'bg-primary-subtle border-primary-muted',
        icon: 'text-primary',
        title: 'text-primary'
      }
    },
    {
      variant: 'tonal',
      intent: 'success',
      class: {
        base: 'bg-success-subtle border-success-muted',
        icon: 'text-success-firm',
        title: 'text-success-firm'
      }
    },
    {
      variant: 'tonal',
      intent: 'warning',
      class: {
        base: 'bg-warning-subtle border-warning-muted',
        icon: 'text-warning-firm',
        title: 'text-warning-firm'
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
    intent: 'info',
    variant: 'default',
    hasDescription: false
  }
});

export { notificationCard };
