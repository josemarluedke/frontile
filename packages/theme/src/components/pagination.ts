import { tv } from '../tw';
import { focusVisibleRing } from './shared';
import type { VariantProps } from 'tailwind-variants';

/**
 * Prev/next/first/last share every class, but `tv` has no way for one slot to
 * inherit another, so the list is written once here and spread into both. It
 * is not folded into a single `control` slot because `classes.prev` and
 * `classes.next` are part of the component's public override surface.
 */
const control = [
  ...focusVisibleRing,
  'inline-flex shrink-0 items-center justify-center gap-1',
  'rounded-pill',
  'cursor-pointer select-none whitespace-nowrap',
  'text-neutral-firm',
  'transition-colors duration-200',
  'motion-reduce:transition-none',
  'enabled:hover:bg-surface-overlay-soft enabled:hover:text-neutral-strong',
  'disabled:cursor-not-allowed disabled:opacity-disabled'
];

/**
 * The size-dependent half of the same story: `prev` and `next` are one
 * affordance at every size, so each size is written once here and spread into
 * both slots below. Written as whole literal class strings rather than
 * composed from parts -- Tailwind generates nothing from an interpolated
 * class, so the scanner has to see each one intact.
 */
const controlSize = {
  sm: 'h-7 px-2 text-label-xs [&_svg]:size-3.5',
  md: 'h-9 px-3 text-label-sm [&_svg]:size-4',
  lg: 'h-11 px-4 text-label-md [&_svg]:size-5'
} as const;

const pagination = tv({
  slots: {
    // The summary sits on the leading edge and the controls on the trailing
    // one, so the row justifies apart only when a summary is actually there;
    // with nothing to justify against, the controls centre instead. Keyed off
    // the summary element's own presence with `:has()` -- the same trick
    // `table.ts` uses -- so the layout follows the rendered structure rather
    // than a variant the component has to compute and thread through.
    base: [
      'flex w-full items-center gap-4',
      'justify-center',
      '[&:has([data-pagination-summary])]:justify-between'
    ],

    summary: 'text-neutral shrink-0',

    list: 'flex items-center',

    item: 'flex',

    // The resting chip is ghost, so a row of them reads as text with the
    // active one as the only ink. Hover is scoped to the inactive chips:
    // unscoped, it ties with the active fill on specificity and the winner is
    // left to Tailwind's variant ordering.
    page: [
      ...focusVisibleRing,
      'inline-flex shrink-0 items-center justify-center',
      'rounded-pill',
      'cursor-pointer select-none tabular-nums',
      'text-neutral-firm',
      'transition-colors duration-200',
      'motion-reduce:transition-none',
      'data-[active=false]:enabled:hover:bg-surface-overlay-soft',
      'data-[active=false]:enabled:hover:text-neutral-strong',
      'disabled:cursor-not-allowed disabled:opacity-disabled'
    ],

    prev: control,
    next: control,

    // Not a button, so no focus ring and no hover: it is a gap marker, and
    // giving it an affordance would promise a destination it does not have.
    ellipsis:
      'inline-flex shrink-0 items-center justify-center select-none text-neutral'
  },

  variants: {
    // `page` is sized square via `size-*` so a one-digit and a three-digit
    // chip are the same circle; `tabular-nums` above stops the digits jittering
    // as the number changes. The controls are pill-shaped rather than square
    // because they carry a word as well as a chevron.
    size: {
      sm: {
        summary: 'text-body-xs',
        list: 'gap-0.5',
        page: 'size-7 text-label-xs',
        prev: controlSize.sm,
        next: controlSize.sm,
        ellipsis: 'size-7 text-label-xs'
      },
      md: {
        summary: 'text-body-sm',
        list: 'gap-1',
        page: 'size-9 text-label-sm',
        prev: controlSize.md,
        next: controlSize.md,
        ellipsis: 'size-9 text-label-sm'
      },
      lg: {
        summary: 'text-body-md',
        list: 'gap-1.5',
        page: 'size-11 text-label-md',
        prev: controlSize.lg,
        next: controlSize.lg,
        ellipsis: 'size-11 text-label-md'
      }
    },

    // Fill and label travel together: the digit sits on the fill, so each
    // intent needs both or the active chip is unreadable.
    intent: {
      default: {
        page: 'data-[active=true]:bg-neutral-bolder data-[active=true]:text-on-neutral-bolder'
      },
      primary: {
        page: 'data-[active=true]:bg-primary data-[active=true]:text-on-primary'
      },
      secondary: {
        page: 'data-[active=true]:bg-secondary data-[active=true]:text-on-secondary'
      },
      tertiary: {
        page: 'data-[active=true]:bg-tertiary data-[active=true]:text-on-tertiary'
      },
      success: {
        page: 'data-[active=true]:bg-success data-[active=true]:text-on-success'
      },
      warning: {
        page: 'data-[active=true]:bg-warning data-[active=true]:text-on-warning'
      },
      danger: {
        page: 'data-[active=true]:bg-danger data-[active=true]:text-on-danger'
      }
    },

    // The buttons also carry a real `disabled` attribute, so this is purely
    // the group-level dimming; `pointer-events-none` covers a consumer's own
    // element supplied through the `item` block, which the component cannot
    // disable for them.
    isDisabled: {
      true: { base: 'opacity-disabled', list: 'pointer-events-none' }
    }
  },

  defaultVariants: {
    size: 'md',
    intent: 'default',
    isDisabled: false
  }
});

export type PaginationVariants = VariantProps<typeof pagination>;
export type PaginationSlots = keyof ReturnType<typeof pagination>;

export { pagination };
