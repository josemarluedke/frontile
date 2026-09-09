import { tv } from '../tw';
import { statusRowCloseButton } from './shared';

/**
 * `default` and `tonal` wear the same outer box. `tonal` carries its colour
 * on the inner element instead (see its compound variants), so the two must
 * stay identical out here — sharing the object keeps that structural rather
 * than a thing a future edit has to remember.
 *
 * `text-neutral` (the DEFAULT level) is only ~3:1 against a light surface —
 * below the 4.5:1 WCAG AA floor a description needs at this size.
 * `text-neutral-firm` clears it against every surface this text can sit on,
 * light or dark.
 */
const neutralSurface = {
  base: 'bg-surface-modal border-surface-overlay-mild',
  description: 'text-neutral-firm'
};

const alert = tv({
  slots: {
    // The outer element: box treatment only (surface, border, radius).
    // No shadow and a tighter radius than `notificationCard` — an Alert
    // sits in the page rather than floating over it, and no transition
    // machinery or `stackPlacement`, which exist on the card only to serve
    // the notification stack's geometry.
    //
    // `overflow-hidden` is not optional: this element owns the radius, but
    // the `tonal` variant paints its tint on `inner` (it needs an opaque
    // surface underneath — see that slot). `inner` has square corners, so
    // without clipping here its tint paints over all four rounded corners
    // and the alert reads as a rectangle.
    base: 'w-full rounded-lg border overflow-hidden',
    // The inner element carries the row layout. Alert has no
    // ResizeObserver, so unlike the card it does not need this split for
    // measurement — it needs it because the `tonal` variant's translucent
    // `{intent}-soft` tint has to composite over an opaque surface. All
    // three variants share the structure rather than branching the DOM.
    inner: 'flex gap-3 p-4 font-body text-body-2xs',
    // `inline-flex items-center justify-center` turns this slot into a
    // fixed 20px centering box, and `[&>*]:size-full` forces whatever
    // element lands inside it (default intent glyph, or arbitrary content
    // yielded through the `icon` block, e.g. `<Spinner @size='sm' />`) to
    // fill that box rather than render at its own intrinsic size. Without
    // this, a yielded `Spinner` (`sm` = 24px) would overflow and
    // misalign inside the 20px slot — see alert.md's "Icon" section.
    // The trailing `!` marks the utility `!important` (Tailwind v4 syntax):
    // `[&>*]:size-full` is equal specificity to whatever size utility the
    // yielded component carries on itself (e.g. Spinner's own `w-6 h-6`), so
    // without `!` which one wins is just Tailwind's emission order — it
    // happens to work today but could flip on a Tailwind version bump or
    // build change with no structural guarantee. `!` makes this clamp always
    // win instead of relying on that ordering. Same pattern as
    // `motion-reduce:transform-none!` in notification-card.ts.
    icon: 'shrink-0 size-5 inline-flex items-center justify-center [&>*]:size-full!',
    content: 'grow min-w-0 flex flex-col gap-1',
    title: 'font-label text-label-xs',
    description: 'text-body-2xs',
    actions: 'flex flex-nowrap shrink-0 items-center gap-2 self-center',
    closeButton: statusRowCloseButton
  },

  variants: {
    // Intent alone paints nothing; every colour comes from an intent ×
    // variant compound below.
    //
    // The other half of an intent lives in the component: `INTENT_CONFIG` in
    // alert.gts maps it to a glyph and an ARIA role. Adding an intent means
    // adding it in both places — this list plus its three compound variants
    // here, and a row there.
    intent: {
      default: {},
      info: {},
      success: {},
      warning: {},
      danger: {}
    },
    variant: {
      default: neutralSurface,
      // Intent-independent out here: every `tonal` compound below tints the
      // *inner* element instead, so the outer box is `default`'s.
      tonal: neutralSurface,
      solid: {
        base: 'border-transparent'
      }
    },
    // Shape and alignment, independent of the colour `variant` above.
    //
    // `banner` is a full-bleed announcement bar spanning its container: no
    // radius, no border, content centred. Width is not part of it — `base`
    // is already `w-full`, so an Alert fills its container either way.
    layout: {
      inline: {},
      banner: {
        // `relative` is the positioning context for the pinned close button
        // below. `rounded-none` and `border-0` beat the base slot's
        // `rounded-lg` and `border` through tailwind-merge.
        base: 'relative rounded-none border-0',
        inner: 'justify-center',
        // `grow-0` is what actually centres the row. `content`'s `grow` is
        // what pins the text left and pushes trailing items right, so
        // without dropping it `justify-center` has no free space to
        // distribute and silently does nothing.
        content: 'grow-0 text-center',
        // Out of the flex flow entirely, so the text stays centred on the
        // full banner whether or not the alert is dismissible — a
        // dismissible and a non-dismissible banner stacked together line up.
        // `mr-0` cancels the inline layout's `-mr-1`, which would otherwise
        // pull the pinned button past the edge.
        closeButton: 'absolute right-3 top-1/2 -translate-y-1/2 mr-0'
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
    // The `default` intent has no accent colour to lend the title emphasis,
    // so the title earns its prominence from weight of ink instead, sitting
    // a level above the icon.
    {
      variant: 'default',
      intent: 'default',
      class: { icon: 'text-neutral-firm', title: 'text-neutral-bolder' }
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
    },

    // A banner centres its text, so the inline layout's top-aligned icon and
    // its calculated negative offset (see the `hasDescription` variant) read
    // as misaligned. Centre the row instead, whether or not it wraps.
    {
      layout: 'banner',
      hasDescription: true,
      class: { inner: 'items-center', icon: 'mt-0' }
    }
  ],

  defaultVariants: {
    intent: 'default',
    variant: 'default',
    layout: 'inline',
    hasDescription: false
  }
});

export type AlertSlots = keyof ReturnType<typeof alert>;
export { alert };
