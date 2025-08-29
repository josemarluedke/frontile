import type { ContentValue } from '@glint/template';
import type {
  TableVariants,
  TableSlots,
  SlotsToClasses
} from '@frontile/theme';

export interface ColumnDefinition<T = unknown> {
  key: string;
  label: string;
  accessorFn?: (item: T) => ContentValue;
}

export type { TableVariants, TableSlots, SlotsToClasses };