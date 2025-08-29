import { tv, type VariantProps } from '../tw';

const table = tv({
  slots: {
    base: ['w-full', 'caption-bottom', 'text-sm'],
    wrapper: [
      'relative',
      'isolate',
      'overflow-auto',
      'border',
      'border-default-200',
      'rounded-lg'
    ],
    table: ['w-full', 'table-auto', 'border-collapse'],
    thead: ['border-b', 'border-default-200'],
    tbody: ['[&_tr:last-child]:border-0'],
    tfoot: ['border-t', 'border-default-200'],
    tr: [
      'border-b',
      'border-default-100',
      'transition-colors',
      'data-[state=selected]:bg-default-100'
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
    emptyCell: ['text-center', 'py-8', 'text-foreground-500']
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
    }
  ],
  defaultVariants: {
    size: 'md',
    layout: 'auto'
  }
});

export type TableVariants = VariantProps<typeof table>;
export type TableSlots = keyof ReturnType<typeof table>;

export { table };
