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
      'data-[selected=false]:data-[disabled=false]:hover:text-neutral-strong',
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

    // Only the indicator's fill is shared across variants. The selected text
    // colour differs -- filled pill needs a contrast colour, a bare underline
    // does not -- so it is set in compoundVariants.
    intent: {
      default: { indicator: 'bg-surface-card dark:bg-neutral-soft' },
      primary: { indicator: 'bg-primary' },
      secondary: { indicator: 'bg-secondary' },
      tertiary: { indicator: 'bg-tertiary' },
      success: { indicator: 'bg-success' },
      warning: { indicator: 'bg-warning' },
      danger: { indicator: 'bg-danger' }
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

    isFullWidth: { true: { list: 'w-full', tab: 'flex-1' } },

    isDisabled: {
      true: { list: 'opacity-disabled', tab: 'pointer-events-none' }
    }
  },

  compoundVariants: [
    // -- solid: the pill is filled, so selected text needs a contrast colour.
    {
      variant: 'solid',
      intent: 'default',
      class: { tab: 'data-[selected=true]:text-neutral-bolder' }
    },
    {
      variant: 'solid',
      intent: 'primary',
      class: { tab: 'data-[selected=true]:text-on-primary' }
    },
    {
      variant: 'solid',
      intent: 'secondary',
      class: { tab: 'data-[selected=true]:text-on-secondary' }
    },
    {
      variant: 'solid',
      intent: 'tertiary',
      class: { tab: 'data-[selected=true]:text-on-tertiary' }
    },
    {
      variant: 'solid',
      intent: 'success',
      class: { tab: 'data-[selected=true]:text-on-success' }
    },
    {
      variant: 'solid',
      intent: 'warning',
      class: { tab: 'data-[selected=true]:text-on-warning' }
    },
    {
      variant: 'solid',
      intent: 'danger',
      class: { tab: 'data-[selected=true]:text-on-danger' }
    },

    // -- underline: only the bar carries the intent colour; the label stays
    // high-contrast neutral at every intent, matching the reference designs.
    {
      variant: 'underline',
      class: { tab: 'data-[selected=true]:text-neutral-bolder' }
    },
    // `default` intent's fill is a surface in solid; a bare bar needs ink.
    {
      variant: 'underline',
      intent: 'default',
      class: { indicator: 'bg-neutral-bolder' }
    },
    // A subtle chip behind an unselected tab on hover.
    {
      variant: 'underline',
      class: {
        tab: 'data-[selected=false]:data-[disabled=false]:hover:bg-surface-overlay-soft'
      }
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
