import type {
  TableVariants,
  TableSlots,
  SlotsToClasses,
  ClassValue
} from '@frontile/theme';

// Re-export universal-ember/table types for convenience
export type { Column, Row, Table } from '@universal-ember/table';
import type { Row, Column } from '@universal-ember/table';
import type { ContentValue } from '@glint/template';
import type { ComponentLike } from '@glint/template';

// Re-export sorting types from universal-ember/table
export {
  SortDirection,
  type Sort,
  type SortItem
} from '@universal-ember/table/plugins/data-sorting';

export interface CellContext<T> {
  column: Column<T>;
  row: Row<T>;
}

export interface CellSignature<T> {
  Args: {
    column: Column<T>;
    row: Row<T>;
  };
}

// Frontile sticky options
export interface FrontileStickyOptions {
  isSticky?: boolean;
  stickyPosition?: 'left' | 'right';
}

// Frontile plugin option type for embedding in universal-ember pluginOptions
export type FrontilePluginOption = [string, () => FrontileStickyOptions];

// Our own independent ColumnConfig interface
export interface ColumnConfig<T = unknown> {
  /** The key to extract data from items */
  key: string;
  /** Display name for the column header */
  name: string;
  /** Optional function to transform/compute column values */
  value?: (ctx: CellContext<T>) => ContentValue;
  /** Custom component to render for this column's cells */
  Cell?: ComponentLike<CellSignature<T>>;
  /** Whether this column should be sticky during horizontal scrolling */
  isSticky?: boolean;
  /** Position where the sticky column should stick. @default 'left' */
  stickyPosition?: 'left' | 'right';
  /** Whether this column should be visible. @default true */
  isVisible?: boolean;
  /** Whether this column is sortable. @default false */
  isSortable?: boolean;
  /** Use this key instead of the column key for sorting. Useful when the display key differs from the data key */
  sortProperty?: string;
}

// Type utility to extract column keys from ColumnConfig array as literal string union
export type ColumnKeys<T extends unknown[]> = T[number] extends {
  key: infer K;
}
  ? K extends string
    ? K
    : never
  : never;

export type { TableVariants, TableSlots, SlotsToClasses, ClassValue };
