import { tv } from '../tw';
import { focusVisibleRing } from './shared';
import type { VariantProps } from '../tw';

const tabs = tv({
  slots: {
    base: 'flex',

    // The positioning context the indicator is measured against, and the
    // element that carries `group/tabs` in the template.
    list: ['relative isolate flex', 'select-none'],

    // Geometry comes from the custom properties `selectionIndicator`
    // publishes. `var()` names are literal: Tailwind generates nothing from
    // an interpolated class string.
    indicator: [
      'pointer-events-none absolute left-0 top-0 z-0',
      // Held until the first real measurement lands, so the indicator never
      // flies in from the container origin on first paint.
      'opacity-0',
      'group-data-[fr-si-ready]/tabs:opacity-100',
      // Tailwind v4 compiles `translate-x-*` to the standalone `translate`
      // property, not to `transform`, so `translate` is what has to be
      // transitioned. `transform` is listed for overrides that use it.
      'group-data-[fr-si-ready]/tabs:transition-[transform,translate,width,height]',
      'group-data-[fr-si-ready]/tabs:duration-200',
      'group-data-[fr-si-ready]/tabs:ease-out',
      'motion-reduce:transition-none'
    ],

    tab: [
      ...focusVisibleRing,
      'relative z-10',
      'inline-flex items-center justify-center gap-2',
      'cursor-pointer whitespace-nowrap',
      'transition-colors duration-200',
      'motion-reduce:transition-none',
      // Resting, hover and selected are three distinct levels so hover has
      // somewhere to go that is not the selected ink.
      'text-neutral-firm',
      // Scoped to unselected: an unscoped `hover:` ties on specificity with
      // the selected ink, leaving the winner to Tailwind's variant order.
      // "Not disabled" is `not-data-[disabled=true]`, not `data-[disabled=false]`:
      // an attribute-value selector cannot match an element that never declares
      // the attribute, and a consumer bringing their own element should not have
      // to know the theme wants a `data-disabled="false"` written onto it.
      'data-[selected=false]:not-data-[disabled=true]:hover:text-neutral-strong',
      'data-[disabled=true]:cursor-not-allowed data-[disabled=true]:opacity-disabled'
    ],

    panel: [...focusVisibleRing, 'outline-none']
  },

  variants: {
    variant: {
      solid: {
        list: 'bg-surface-overlay-soft dark:bg-surface-table rounded-pill p-1',
        indicator: [
          'w-[var(--fr-si-width)] h-[var(--fr-si-height)]',
          'translate-x-[var(--fr-si-x)] translate-y-[var(--fr-si-y)]',
          'rounded-pill shadow-elevation-1'
        ],
        tab: 'rounded-pill'
      },
      // Painting is finished in compoundVariants: the bar is pinned to a
      // different edge per orientation and reads a different pair of custom
      // properties, so there is nothing orientation-agnostic to say here.
      underline: {
        tab: 'rounded-md'
      }
    },

    // Fill and selected ink travel together: the label sits on the fill, so a
    // new intent needs both or its selected label is unreadable on its own
    // background. `underline` overrides the ink in one compound below, since a
    // bare bar puts no fill behind the label.
    intent: {
      default: {
        indicator: 'bg-surface-card dark:bg-neutral-soft',
        tab: 'data-[selected=true]:text-neutral-bolder'
      },
      primary: {
        indicator: 'bg-primary',
        tab: 'data-[selected=true]:text-on-primary'
      },
      secondary: {
        indicator: 'bg-secondary',
        tab: 'data-[selected=true]:text-on-secondary'
      },
      tertiary: {
        indicator: 'bg-tertiary',
        tab: 'data-[selected=true]:text-on-tertiary'
      },
      success: {
        indicator: 'bg-success',
        tab: 'data-[selected=true]:text-on-success'
      },
      warning: {
        indicator: 'bg-warning',
        tab: 'data-[selected=true]:text-on-warning'
      },
      danger: {
        indicator: 'bg-danger',
        tab: 'data-[selected=true]:text-on-danger'
      }
    },

    size: {
      sm: { tab: 'px-3 py-1 text-label-sm', panel: 'py-2' },
      md: { tab: 'px-4 py-1.5 text-label-md', panel: 'py-3' },
      lg: { tab: 'px-5 py-2 text-label-lg', panel: 'py-4' }
    },

    orientation: {
      horizontal: { base: 'flex-col', list: 'flex-row' },
      vertical: { base: 'flex-row gap-4', list: 'flex-col' }
    },

    // `base` needs the width too, not just `list`: the list's `w-full`
    // resolves against `base`, and a `base` with no width of its own collapses
    // to its content inside an `align-items: flex-start` parent -- leaving the
    // whole argument inert in exactly the layouts that reach for it.
    isFullWidth: { true: { base: 'w-full', list: 'w-full', tab: 'flex-1' } },

    isDisabled: {
      true: { list: 'opacity-disabled', tab: 'pointer-events-none' }
    }
  },

  compoundVariants: [
    // -- underline: no fill behind the label, so the intent colour lives on the
    // bar alone and the label stays high-contrast neutral at every intent --
    // matching the reference designs. The hover chip shares this matcher, so it
    // rides along rather than repeating the condition in a second entry.
    {
      variant: 'underline',
      class: {
        tab: 'data-[selected=true]:text-neutral-bolder data-[selected=false]:not-data-[disabled=true]:hover:bg-surface-overlay-soft'
      }
    },
    // A pill radius on a tall narrow column reads as an oval blob, so the
    // vertical axis squares off -- on the track and on what sits inside it, or
    // the indicator would bulge out of the track. The inner radius is the
    // outer one less the track's `p-1`. Only `solid` has a track to round.
    {
      variant: 'solid',
      orientation: 'vertical',
      class: {
        list: 'rounded-2xl',
        indicator: 'rounded-xl',
        tab: 'rounded-xl'
      }
    },
    // `default` intent's fill is a surface in solid; a bare bar needs ink.
    {
      variant: 'underline',
      intent: 'default',
      class: { indicator: 'bg-neutral-bolder' }
    },
    {
      variant: 'underline',
      orientation: 'horizontal',
      class: {
        list: 'gap-1 border-b border-neutral-mild dark:border-neutral-soft',
        indicator: [
          'top-auto bottom-0 h-0.5 rounded-full',
          'w-[var(--fr-si-width)]',
          'translate-x-[var(--fr-si-x)]'
        ]
      }
    },
    {
      variant: 'underline',
      orientation: 'vertical',
      class: {
        list: 'gap-1 border-l border-neutral-mild dark:border-neutral-soft',
        indicator: [
          'left-0 w-0.5 rounded-full',
          'h-[var(--fr-si-height)]',
          'translate-y-[var(--fr-si-y)]'
        ]
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

export { tabs };
export type TabsSlots = keyof ReturnType<typeof tabs>;
export type TabsVariants = VariantProps<typeof tabs>;
