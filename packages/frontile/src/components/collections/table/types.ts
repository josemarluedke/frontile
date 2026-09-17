import type {
  TableVariants,
  TableSlots,
  SlotsToClasses,
  ClassValue,
  SkeletonVariants
} from '@frontile/theme';

export type { Column, Row, Table } from '@universal-ember/table';
import type { Row, Column } from '@universal-ember/table';
import type { ContentValue } from '@glint/template';
import type { ComponentLike } from '@glint/template';

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

export interface FrontileColumnOptions {
  isSticky?: boolean;
  stickyPosition?: 'left' | 'right';
  skeleton?: SkeletonVariants['shape'];
}

/**
 * @deprecated Renamed to `FrontileColumnOptions`, which now carries more than
 * sticky configuration. This alias will be removed in a future major.
 */
export type FrontileStickyOptions = FrontileColumnOptions;

export type FrontilePluginOption = [string, () => FrontileColumnOptions];

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
  /**
   * Shape of the placeholder rendered in this column by `@skeletonRows`.
   * Defaults to a text bar. Use `circle` for avatar columns, `square` for
   * thumbnails. For anything richer, render your own rows via `<:bodyTop>`.
   */
  skeleton?: SkeletonVariants['shape'];
}

export type ColumnKeys<T extends unknown[]> = T[number] extends {
  key: infer K;
}
  ? K extends string
    ? K
    : never
  : never;

export type SelectionMode = 'none' | 'single' | 'multiple';

export type { TableVariants, TableSlots, SlotsToClasses, ClassValue };
