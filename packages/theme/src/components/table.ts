import { tv, type VariantProps } from '../tw';

const table = tv({
  slots: {
    base: ['w-full', 'caption-bottom', 'text-sm'],
    wrapper: [
      'relative',
      'overflow-auto',
      'border',
      'border-default-200',
      'rounded-lg'
    ],
    table: ['w-full', 'table-auto', 'border-collapse'],
    thead: ['border-b', 'border-default-200'],
    tbody: ['[&_tr:last-child]:border-0'],
    tr: [
      'border-b',
      'border-default-100',
      'transition-colors',
      'hover:bg-default-50/50',
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
    emptyCell: [
      'text-center',
      'py-8',
      'text-foreground-500'
    ]
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
    }
  },
  defaultVariants: {
    size: 'md',
    layout: 'auto'
  }
});

export type TableVariants = VariantProps<typeof table>;
export type TableSlots = keyof ReturnType<typeof table>;

export { table };

