import { tv, type VariantProps } from '../tw';

const table = tv({
  slots: {
    base: ['w-full', 'caption-bottom', 'font-body text-body-2xs'],
    wrapper: [
      'relative',
      'isolate',
      'overflow-auto',
      'rounded-default',
      // `surface-table` rather than `surface-card`, which the table otherwise
      // looks exactly like: every sticky part of the table paints over the rows
      // and columns scrolling beneath it, and in dark `card` is a translucent
      // veil that would let them read through. The role carries the colour that
      // veil renders, with the alpha already resolved. Override
      // `--color-surface-table` to sit a table on a different background.
      'bg-surface-table'
    ],
    table: ['w-full', 'table-auto'],
    thead: ['relative', 'bg-surface-overlay-subtle'],
    tbody: [
      'divide-y',
      'divide-surface-overlay-subtle',
      // Rows carry the surface themselves rather than letting the wrapper show
      // through: a sticky row has to hide the rows sliding under it, and a
      // sticky cell picks its fill up from its row via `background-color:
      // inherit`. Row tints layer on top of this, and any tint that replaces it
      // has to be opaque too — see `striped` and the selection variants.
      '[&>tr]:bg-surface-table',
      // `muted`, not `subtle`: in dark `neutral-subtle` is gray-900, the same
      // value `surface-table` carries, so a `subtle` hover reads as no hover at
      // all. This stays a background *colour* so `transition-colors` animates it.
      '[&>tr]:data-[selectable=true]:data-[selected=false]:hover:bg-neutral-muted',
      '[&>tr]:data-[selectable=true]:transition-colors'
    ],
    // Footer rows take the surface for the same reason body rows do: a sticky
    // column in the footer scrolls past the cells to its side.
    tfoot: ['relative', '[&>tr]:bg-surface-table'],
    tr: [
      'data-[disabled=true]:opacity-50',
      'data-[disabled=true]:cursor-not-allowed',
      'data-[disabled=true]:hover:bg-transparent',
      'data-[selectable=true]:focus-visible:ring-2',
      'data-[selectable=true]:focus-visible:ring-inset',
      'data-[selectable=true]:focus-visible:ring-default',
      'data-[selectable=true]:focus-visible:z-10',
      'transition-colors',
      'duration-150',
      'outline-hidden'
    ],
    separator: [
      'absolute',
      'z-2',
      'left-0',
      'w-full',
      'h-px',
      'bg-surface-overlay-mild'
    ],
    th: [
      'h-12',
      'px-4',
      'text-left',
      'align-middle',
      'font-label',
      'text-neutral-bolder',
      '[&:has([role=checkbox])]:pr-0',
      'data-[sortable=true]:cursor-pointer'
    ],
    sortButton: [
      'group/sort',
      'inline-flex',
      'items-center',
      'gap-1',
      'w-full',
      'text-left',
      'font-label',
      'text-neutral-bolder',
      'outline-hidden',
      'focus-visible:z-10',
      'focus-visible:ring-3',
      'focus-visible:ring-focus',
      'focus-visible:ring-offset-2',
      'focus-visible:ring-offset-background'
    ],
    sortIcon: [
      'size-4',
      'flex-shrink-0',
      'text-neutral-soft',
      'transition-opacity',
      'data-[sorted=false]:opacity-0',
      'group-hover/sort:data-[sorted=false]:opacity-100',
      'data-[sorted=true]:opacity-100'
    ],
    columnVisibilityButton: ['flex'],
    columnVisibilityIcon: ['size-6'],
    td: [
      'align-middle',
      'text-neutral-strong',
      '[&:has([role=checkbox])]:pr-0'
    ],
    empty: ['text-neutral-soft', 'align-middle', 'text-center', 'py-12'],
    // Deliberately carries no width or height: these classes are merged onto
    // Skeleton *after* its own shape and size variants, so any dimension set
    // here would defeat a column's `skeleton: 'circle'` preset. The table
    // passes its `size` through to Skeleton instead.
    skeleton: ['max-w-[16ch]'],
    // Placeholder rows fade in one after another. The per-row `animation-delay`
    // is set inline by the component, since a delay that scales with the row
    // index cannot be a static utility class.
    skeletonRow: ['animate-skeleton-enter', 'motion-reduce:animate-none']
  },
  variants: {
    size: {
      sm: {
        th: 'h-10 px-3 py-2 text-label-2xs',
        td: 'px-3 py-2 text-body-2xs'
      },
      md: {
        th: 'h-12 px-4 text-label-xs',
        td: 'p-4 text-body-2xs'
      },
      lg: {
        th: 'h-14 px-6 text-label-sm',
        td: 'p-6 text-body-xs'
      }
    },
    isLoading: {
      true: {
        thead: [
          'after:absolute',
          'after:top-full',
          'after:left-0',
          'after:w-1/2',
          'after:animate-swing',
          'after:h-px',
          'after:z-10'
        ]
      }
    },
    // Declared empty on purpose: these variants exist only so `isLoading` can
    // pair with them in `compoundVariants` below, where the actual
    // `thead: after:bg-*` colour is applied. A colour set here would paint the
    // hairline even when the table is not loading.
    loadingColor: {
      default: {},
      primary: {},
      success: {},
      warning: {},
      danger: {}
    },
    selectionColor: {
      default: {},
      primary: {},
      success: {},
      warning: {},
      danger: {}
    },
    layout: {
      auto: {
        table: 'table-auto'
      },
      fixed: {
        table: 'table-fixed'
      }
    },
    striped: {
      true: {
        // A translucent tint, so it goes on as a background *image* layer over
        // the row's opaque fill instead of replacing it. Painting it as the
        // background colour would make every striped sticky row see-through.
        tbody:
          '[&_tr:nth-child(odd)]:[background-image:linear-gradient(var(--color-surface-overlay-subtle),var(--color-surface-overlay-subtle))]'
      }
    },
    isSticky: {
      true: {}
    },
    stickyPosition: {
      left: {},
      right: {},
      top: {},
      bottom: {}
    },
    isScrollable: {
      true: {
        wrapper: ['overflow-auto']
      }
    },
    hasStickyHeader: {
      true: {}
    },
    isInStickyRow: {
      true: {}
    }
  },
  compoundVariants: [
    // Sticky header - highest priority for intersections with columns
    {
      isSticky: true,
      stickyPosition: 'top',
      class: {
        // The opaque surface plus the header's own translucent tint as a layer
        // above it, which is what a non-sticky `thead` composites to over the
        // wrapper — so stuck and unstuck headers read as the same colour.
        thead: [
          'sticky',
          'top-0',
          'z-2',
          'bg-surface-table',
          '[background-image:linear-gradient(var(--color-surface-overlay-subtle),var(--color-surface-overlay-subtle))]'
        ]
      }
    },
    // Sticky footer
    {
      isSticky: true,
      stickyPosition: 'bottom',
      class: {
        tfoot: ['sticky', 'bottom-0', 'z-2', 'bg-surface-table']
      }
    },
    // Sticky columns - medium priority, header cells get higher z-index.
    // Body and footer cells inherit their row's paint — fill, and any tint
    // layered over it — so a pinned column tracks selection, hover and striping
    // instead of masking them with a surface of its own.
    {
      isSticky: true,
      stickyPosition: 'left',
      class: {
        th: [
          'sticky',
          'left-0',
          'z-3',
          'bg-surface-table',
          '[background-image:linear-gradient(var(--color-surface-overlay-subtle),var(--color-surface-overlay-subtle))]'
        ],
        td: [
          'sticky',
          'left-0',
          'z-1',
          'bg-inherit',
          '[background-image:inherit]'
        ]
      }
    },
    {
      isSticky: true,
      stickyPosition: 'right',
      class: {
        th: [
          'sticky',
          'right-0',
          'z-3',
          'bg-surface-table',
          '[background-image:linear-gradient(var(--color-surface-overlay-subtle),var(--color-surface-overlay-subtle))]'
        ],
        td: [
          'sticky',
          'right-0',
          'z-1',
          'bg-inherit',
          '[background-image:inherit]'
        ]
      }
    },
    // Sticky rows - base layer
    {
      isSticky: true,
      stickyPosition: 'top',
      class: {
        tr: ['sticky', 'top-0', 'z-1', 'bg-surface-table']
      }
    },
    {
      isSticky: true,
      stickyPosition: 'bottom',
      class: {
        tr: ['sticky', 'bottom-0', 'z-1', 'bg-surface-table']
      }
    },
    // Sticky rows with sticky header - position after header
    {
      isSticky: true,
      stickyPosition: 'top',
      hasStickyHeader: true,
      class: {
        tr: [
          'sticky',
          'z-2',
          'bg-surface-table',
          '[&.sticky]:[top:var(--table-header-height,48px)]'
        ]
      }
    },
    // Intersection cells: sticky column + sticky row - highest z-index
    {
      isSticky: true,
      stickyPosition: 'left',
      isInStickyRow: true,
      class: {
        td: [
          'sticky',
          'left-0',
          'z-2',
          'bg-inherit',
          '[background-image:inherit]'
        ]
      }
    },
    {
      isSticky: true,
      stickyPosition: 'right',
      isInStickyRow: true,
      class: {
        td: [
          'sticky',
          'right-0',
          'z-2',
          'bg-inherit',
          '[background-image:inherit]'
        ]
      }
    },
    // Loading states with color variants
    {
      isLoading: true,
      loadingColor: 'default',
      class: {
        thead: `after:bg-neutral`
      }
    },
    {
      isLoading: true,
      loadingColor: 'primary',
      class: {
        thead: `after:bg-primary`
      }
    },
    {
      isLoading: true,
      loadingColor: 'success',
      class: {
        thead: `after:bg-success`
      }
    },
    {
      isLoading: true,
      loadingColor: 'warning',
      class: {
        thead: `after:bg-warning`
      }
    },
    {
      isLoading: true,
      loadingColor: 'danger',
      class: {
        thead: `after:bg-danger`
      }
    },
    // Selection color variants
    {
      selectionColor: 'default',
      class: {
        // Half-opacity, so it layers over the row's fill rather than replacing
        // it — a selected sticky row still has to occlude what scrolls under.
        // The other selection colours are opaque and can stay plain fills.
        //
        // `soft` rather than `subtle`, which in dark is the same value as
        // `surface-table` and so tints nothing. At 50% this lands on the weight
        // the colour variants carry (1.4:1 against the surface, against
        // `primary-subtle`'s 1.38:1).
        tbody:
          '[&>tr]:data-[selected=true]:[background-image:linear-gradient(color-mix(in_oklab,var(--color-neutral-soft)_50%,transparent),color-mix(in_oklab,var(--color-neutral-soft)_50%,transparent))]',
        tr: ['data-[selectable=true]:focus-visible:ring-default']
      }
    },
    {
      selectionColor: 'primary',
      class: {
        tbody: '[&>tr]:data-[selected=true]:bg-primary-subtle',
        tr: ['data-[selectable=true]:focus-visible:ring-primary-soft']
      }
    },
    {
      selectionColor: 'success',
      class: {
        tbody: '[&>tr]:data-[selected=true]:bg-success-subtle',
        tr: ['data-[selectable=true]:focus-visible:ring-success']
      }
    },
    {
      selectionColor: 'warning',
      class: {
        tbody: '[&>tr]:data-[selected=true]:bg-warning-subtle',
        tr: ['data-[selectable=true]:focus-visible:ring-warning']
      }
    },
    {
      selectionColor: 'danger',
      class: {
        tbody: '[&>tr]:data-[selected=true]:bg-danger-subtle',
        tr: ['data-[selectable=true]:focus-visible:ring-danger']
      }
    }
  ],
  defaultVariants: {
    size: 'md',
    layout: 'auto',
    loadingColor: 'default',
    selectionColor: 'primary'
  }
});

export type TableVariants = VariantProps<typeof table>;
export type TableSlots = keyof ReturnType<typeof table>;

export { table };
