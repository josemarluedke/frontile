import { tv } from '../tw';
import { focusVisibleRing } from './shared';
import type { VariantProps } from '../tw';

const calendar = tv({
  slots: {
    base: [
      'inline-flex flex-col gap-3 p-3',
      // The two knobs that let a consumer resize cells and reshape them
      // without any new API. `--calendar-cell-radius` is how a `<:day>` block
      // with custom content escapes the circle.
      '[--calendar-cell-size:2.5rem]',
      '[--calendar-cell-radius:9999px]'
    ],

    // Header, year panel and month grids share one column sized to the grids
    // themselves. Without this the header stretches to the width of the
    // widest sibling -- a `<:footer>` of preset buttons, say -- and the prev
    // and next arrows drift away from the days they page.
    body: 'flex flex-col gap-3 w-fit',

    header: 'flex items-center justify-between gap-2',

    // `label-sm` is 1rem, which reads as heavy as a heading next to 14px day
    // numbers; `label-xs` is the 14px the caption wants.
    title: 'text-label-xs text-neutral-bolder',

    nav: 'flex items-center gap-1',

    navButton: [
      ...focusVisibleRing,
      'inline-flex items-center justify-center',
      'size-8 rounded-full',
      // The chevron inside is sized here rather than on the icon, so the
      // button stays the hit area and the glyph stays optically balanced
      // against the caption.
      '[&_svg]:size-4',
      'text-neutral-firm cursor-pointer',
      'transition-colors duration-200 motion-reduce:transition-none',
      'not-data-[disabled=true]:hover:bg-surface-overlay-soft',
      'not-data-[disabled=true]:hover:text-neutral-bolder',
      'data-[disabled=true]:cursor-not-allowed data-[disabled=true]:opacity-disabled'
    ],

    monthsWrapper: 'flex gap-4',
    monthGrid: 'border-collapse',
    weekdaysRow: '',

    // `caption-2xs` does not exist in the type scale -- the smallest caption
    // is `caption-sm` -- so the old value generated nothing and these labels
    // inherited 16px, rendering *larger* than the day numbers beneath them.
    // The row is also shorter than a day row: it is a label, not a cell.
    weekday: [
      'text-caption-sm text-neutral font-normal',
      'h-8 w-[var(--calendar-cell-size)]',
      'text-center align-middle'
    ],

    week: '',

    // The positioning context for `cellBand`. No padding: the band has to
    // reach the cell edges for adjacent bands to touch.
    cell: ['relative p-0 text-center', 'size-[var(--calendar-cell-size)]'],

    // The continuous range ribbon, behind the day. Absolutely positioned and
    // filling the whole cell, which is what removes the gap between days.
    cellBand: 'absolute inset-0 z-0 pointer-events-none',

    day: [
      ...focusVisibleRing,
      'relative z-1',
      'inline-flex items-center justify-center',
      'size-[calc(var(--calendar-cell-size)-0.25rem)]',
      'rounded-[var(--calendar-cell-radius)]',
      'text-body-sm text-neutral-strong',
      'cursor-pointer select-none',
      'transition-colors duration-200 motion-reduce:transition-none',
      'not-data-[disabled=true]:hover:bg-surface-overlay-soft',
      'data-[outside=true]:text-neutral-mild',
      'data-[disabled=true]:cursor-not-allowed data-[disabled=true]:text-neutral-mild',
      'data-[unavailable=true]:line-through data-[unavailable=true]:cursor-not-allowed',
      'data-[unavailable=true]:hover:bg-transparent'
    ],

    // Wraps default *and* `<:day>` content, so a block that renders more than
    // a numeral -- a price, an event count -- stacks and centres without
    // having to rebuild this layout itself.
    dayContent:
      'flex flex-col items-center justify-center leading-none overflow-hidden',

    // Sits below the grids, outside the column that sizes to them, so wide
    // content here wraps instead of stretching the header.
    footer: 'flex flex-wrap items-center gap-2 pt-1',

    // The today marker: a dot under the numeral rather than a ring, which
    // would compete with the selected fill.
    indicator: 'absolute bottom-1 size-1 rounded-full bg-current opacity-70',

    // The year panel stands in for the day grid rather than sitting above it,
    // so it is sized to the grid it replaces: seven cells wide, six tall. The
    // year list is long by design (a century back, for dates of birth), which
    // is exactly why it has to scroll inside that box instead of growing the
    // component to the height of its longest possible list.
    yearGrid: [
      'grid grid-cols-3 gap-1',
      'w-[calc(var(--calendar-cell-size)*7)]',
      'max-h-[calc(var(--calendar-cell-size)*6)] overflow-y-auto',
      'overscroll-contain'
    ],
    yearCell: [
      ...focusVisibleRing,
      'rounded-full px-3 py-2 text-body-sm cursor-pointer',
      'hover:bg-surface-overlay-soft',
      'data-[selected=true]:bg-surface-overlay-soft data-[selected=true]:font-medium'
    ]
  },

  variants: {
    intent: {
      default: {
        day: 'data-[selected=true]:bg-neutral-strong data-[selected=true]:text-on-neutral-strong',
        cellBand: 'data-[in-range=true]:bg-neutral-soft'
      },
      primary: {
        day: 'data-[selected=true]:bg-primary data-[selected=true]:text-on-primary',
        cellBand: 'data-[in-range=true]:bg-primary-soft'
      },
      secondary: {
        day: 'data-[selected=true]:bg-secondary data-[selected=true]:text-on-secondary',
        cellBand: 'data-[in-range=true]:bg-secondary-soft'
      },
      tertiary: {
        day: 'data-[selected=true]:bg-tertiary data-[selected=true]:text-on-tertiary',
        cellBand: 'data-[in-range=true]:bg-tertiary-soft'
      },
      success: {
        day: 'data-[selected=true]:bg-success data-[selected=true]:text-on-success',
        cellBand: 'data-[in-range=true]:bg-success-soft'
      },
      warning: {
        day: 'data-[selected=true]:bg-warning data-[selected=true]:text-on-warning',
        cellBand: 'data-[in-range=true]:bg-warning-soft'
      },
      danger: {
        day: 'data-[selected=true]:bg-danger data-[selected=true]:text-on-danger',
        cellBand: 'data-[in-range=true]:bg-danger-soft'
      }
    },

    size: {
      sm: {
        base: 'p-2 [--calendar-cell-size:2.25rem]',
        title: 'text-label-2xs',
        navButton: 'size-7 [&_svg]:size-3.5'
      },
      md: { base: '[--calendar-cell-size:2.5rem]' },
      lg: {
        base: 'p-4 [--calendar-cell-size:3rem]',
        title: 'text-label-sm',
        navButton: 'size-9 [&_svg]:size-5'
      }
    },

    isDisabled: {
      true: { base: 'opacity-disabled pointer-events-none' }
    }
  },

  defaultVariants: {
    intent: 'primary',
    size: 'md'
  }
});

export { calendar };
export type CalendarSlots = keyof ReturnType<typeof calendar>;
export type CalendarVariants = VariantProps<typeof calendar>;
