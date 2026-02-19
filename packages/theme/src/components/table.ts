import { tv, type VariantProps } from '../tw';

const table = tv({
  slots: {
    base: ['w-full', 'caption-bottom', 'text-sm'],
    wrapper: ['relative', 'isolate', 'overflow-auto', 'rounded-default', 'bg-surface-card'],
    table: ['w-full', 'table-auto'],
    thead: ['relative', 'bg-surface-overlay-subtle'],
    tbody: [
      'divide-y',
      'divide-surface-overlay-subtle',
      '[&>tr]:data-[selectable=true]:data-[selected=false]:hover:bg-neutral-subtle',
      '[&>tr]:data-[selectable=true]:transition-colors'
    ],
    tfoot: ['relative'],
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
      'bg-surface-overlay-medium'
    ],
    th: [
      'h-12',
      'px-4',
      'text-left',
      'align-middle',
      'font-semibold',
      'text-neutral-boldest',
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
      'font-semibold',
      'text-neutral-boldest',
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
      'p-4',
      'align-middle',
      'text-neutral-strong',
      '[&:has([role=checkbox])]:pr-0'
    ],
    empty: ['text-neutral-soft', 'align-middle', 'text-center', 'py-12']
  },
  variants: {
    size: {
      sm: {
        th: 'h-10 px-3 py-2 text-xs',
        td: 'px-3 py-2 text-xs'
      },
      md: {
        th: 'h-12 px-4 text-sm',
        td: 'p-4 text-sm'
      },
      lg: {
        th: 'h-14 px-6 text-base',
        td: 'p-6 text-base'
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
        tbody:
          '[&_tr:nth-child(odd)]:bg-surface-overlay-subtle'
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
        thead: ['sticky', 'top-0', 'z-2', 'bg-surface-card']
      }
    },
    // Sticky footer
    {
      isSticky: true,
      stickyPosition: 'bottom',
      class: {
        tfoot: ['sticky', 'bottom-0', 'z-2', 'bg-surface-card']
      }
    },
    // Sticky columns - medium priority, header cells get higher z-index
    {
      isSticky: true,
      stickyPosition: 'left',
      class: {
        th: [
          'sticky',
          'left-0',
          'z-3',
          'bg-surface-card',
          '[background-image:linear-gradient(var(--color-surface-overlay-subtle),var(--color-surface-overlay-subtle))]'
        ],
        td: ['sticky', 'left-0', 'z-1', 'bg-surface-card']
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
          'bg-surface-card',
          '[background-image:linear-gradient(var(--color-surface-overlay-subtle),var(--color-surface-overlay-subtle))]'
        ],
        td: ['sticky', 'right-0', 'z-1', 'bg-surface-card']
      }
    },
    // Sticky rows - base layer
    {
      isSticky: true,
      stickyPosition: 'top',
      class: {
        tr: ['sticky', 'top-0', 'z-1', 'bg-surface-card']
      }
    },
    {
      isSticky: true,
      stickyPosition: 'bottom',
      class: {
        tr: ['sticky', 'bottom-0', 'z-1', 'bg-surface-card']
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
          'bg-surface-card',
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
        td: ['sticky', 'left-0', 'z-2', 'bg-surface-card']
      }
    },
    {
      isSticky: true,
      stickyPosition: 'right',
      isInStickyRow: true,
      class: {
        td: ['sticky', 'right-0', 'z-2', 'bg-surface-card']
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
        thead: `after:bg-brand`
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
        tbody: '[&>tr]:data-[selected=true]:bg-neutral-subtle/50',
        tr: ['data-[selectable=true]:focus-visible:ring-default']
      }
    },
    {
      selectionColor: 'primary',
      class: {
        tbody: '[&>tr]:data-[selected=true]:bg-brand-subtle',
        tr: ['data-[selectable=true]:focus-visible:ring-brand-soft']
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
