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
    isFrozen: {
      true: {}
    },
    frozenPosition: {
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
    hasFrozenHeader: {
      true: {}
    },
    isInFrozenRow: {
      true: {}
    }
  },
  compoundVariants: [
    // Frozen header - highest priority for intersections with columns
    {
      isFrozen: true,
      frozenPosition: 'top',
      class: {
        thead: ['sticky', 'top-0', 'z-2', 'bg-background']
      }
    },
    // Frozen footer
    {
      isFrozen: true,
      frozenPosition: 'bottom',
      class: {
        tfoot: ['sticky', 'bottom-0', 'z-2', 'bg-background']
      }
    },
    // Frozen columns - medium priority, header cells get higher z-index
    {
      isFrozen: true,
      frozenPosition: 'left',
      class: {
        th: ['sticky', 'left-0', 'z-3', 'bg-background'], // Higher for header intersection
        td: ['sticky', 'left-0', 'z-1', 'bg-background']
      }
    },
    {
      isFrozen: true,
      frozenPosition: 'right',
      class: {
        th: ['sticky', 'right-0', 'z-3', 'bg-background'], // Higher for header intersection
        td: ['sticky', 'right-0', 'z-1', 'bg-background']
      }
    },
    // Frozen rows - base layer
    {
      isFrozen: true,
      frozenPosition: 'top',
      class: {
        tr: ['sticky', 'top-0', 'z-1', 'bg-background']
      }
    },
    {
      isFrozen: true,
      frozenPosition: 'bottom',
      class: {
        tr: ['sticky', 'bottom-0', 'z-1', 'bg-background']
      }
    },
    // Frozen rows with frozen header - position after header
    {
      isFrozen: true,
      frozenPosition: 'top',
      hasFrozenHeader: true,
      class: {
        tr: [
          'sticky',
          'z-2',
          'bg-background',
          '[&.sticky]:[top:var(--table-header-height,48px)]'
        ]
      }
    },
    // Intersection cells: frozen column + frozen row - highest z-index
    {
      isFrozen: true,
      frozenPosition: 'left',
      isInFrozenRow: true,
      class: {
        td: ['sticky', 'left-0', 'z-2', 'bg-background']
      }
    },
    {
      isFrozen: true,
      frozenPosition: 'right',
      isInFrozenRow: true,
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
