import type { ContentValue } from '@glint/template';
import type {
  TableVariants,
  TableSlots,
  SlotsToClasses
} from '@frontile/theme';

export interface ColumnDefinition<T = unknown> {
  /** The property key to extract data from items, or a unique identifier for the column */
  key: string;
  /** Display label for the column header */
  label: string;
  /** Optional function to transform or compute column values from the data item */
  accessorFn?: (item: T) => ContentValue;
  /** Whether this column should be frozen (sticky) during horizontal scrolling */
  isFrozen?: boolean;
  /** Position where the frozen column should stick. @default 'left' */
  frozenPosition?: 'left' | 'right';
}

export type { TableVariants, TableSlots, SlotsToClasses };

