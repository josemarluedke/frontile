import { tv, type VariantProps } from '../tw';

const table = tv({
  slots: {
    base: ['w-full', 'caption-bottom', 'text-sm'],
    wrapper: ['relative', 'isolate', 'overflow-auto'],
    table: ['w-full', 'table-auto'],
    thead: ['relative'],
    tbody: [
      'divide-y',
      'divide-default-100',
      '[&>tr]:data-[selectable=true]:hover:bg-default-50',
      '[&>tr]:data-[selectable=true]:focus-visible:outline-primary'
    ],
    tfoot: ['relative'],
    tr: ['data-[selected=true]:bg-default-50'],
    separator: [
      'absolute',
      'z-2',
      'left-0',
      'w-full',
      'h-px',
      'bg-default-200'
    ],
    th: [
      'h-12',
      'px-4',
      'text-left',
      'align-middle',
      'font-medium',
      'text-foreground-600',
      '[&:has([role=checkbox])]:pr-0'
    ],
    td: [
      'p-4',
      'align-middle',
      'text-foreground',
      '[&:has([role=checkbox])]:pr-0'
    ],
    empty: ['text-foreground-400', 'align-middle', 'text-center', 'py-12']
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
          '[&_tr:nth-child(odd)]:bg-default-100/50 dark:[&_tr:nth-child(odd)]:bg-default-200/10'
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
        thead: ['sticky', 'top-0', 'z-2', 'bg-background']
      }
    },
    // Sticky footer
    {
      isSticky: true,
      stickyPosition: 'bottom',
      class: {
        tfoot: ['sticky', 'bottom-0', 'z-2', 'bg-background']
      }
    },
    // Sticky columns - medium priority, header cells get higher z-index
    {
      isSticky: true,
      stickyPosition: 'left',
      class: {
        th: ['sticky', 'left-0', 'z-3', 'bg-background'], // Higher for header intersection
        td: ['sticky', 'left-0', 'z-1', 'bg-background']
      }
    },
    {
      isSticky: true,
      stickyPosition: 'right',
      class: {
        th: ['sticky', 'right-0', 'z-3', 'bg-background'], // Higher for header intersection
        td: ['sticky', 'right-0', 'z-1', 'bg-background']
      }
    },
    // Sticky rows - base layer
    {
      isSticky: true,
      stickyPosition: 'top',
      class: {
        tr: ['sticky', 'top-0', 'z-1', 'bg-background']
      }
    },
    {
      isSticky: true,
      stickyPosition: 'bottom',
      class: {
        tr: ['sticky', 'bottom-0', 'z-1', 'bg-background']
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
          'bg-background',
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
        td: ['sticky', 'left-0', 'z-2', 'bg-background']
      }
    },
    {
      isSticky: true,
      stickyPosition: 'right',
      isInStickyRow: true,
      class: {
        td: ['sticky', 'right-0', 'z-2', 'bg-background']
      }
    },
    // Loading states with color variants
    {
      isLoading: true,
      loadingColor: 'default',
      class: {
        thead: `after:bg-default`
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
    }
  ],
  defaultVariants: {
    size: 'md',
    layout: 'auto',
    loadingColor: 'default'
  }
});

export type TableVariants = VariantProps<typeof table>;
export type TableSlots = keyof ReturnType<typeof table>;

export { table };
