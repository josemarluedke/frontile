import type {
  TableVariants,
  TableSlots,
  SlotsToClasses,
  ClassValue
} from '@frontile/theme';

// Re-export universal-ember/table types for convenience
export type { Column, Row, Table } from '@universal-ember/table';
import type { ColumnConfig as UniversalColumnConfig } from '@universal-ember/table';

// Frontile sticky options
export interface FrontileStickyOptions {
  isSticky?: boolean;
  stickyPosition?: 'left' | 'right';
}

// Frontile plugin option type for embedding in universal-ember pluginOptions
export type FrontilePluginOption = [string, () => FrontileStickyOptions];

// Extended ColumnConfig with Frontile-specific options
export interface ColumnConfig<T = unknown> extends UniversalColumnConfig<T> {
  /** Whether this column should be sticky during horizontal scrolling */
  isSticky?: boolean;
  /** Position where the sticky column should stick. @default 'left' */
  stickyPosition?: 'left' | 'right';
  /** Whether this column should be visible. @default true */
  isVisible?: boolean;
}

// Type utility to extract column keys from ColumnConfig array as literal string union
export type ColumnKeys<T extends any[]> = T[number] extends {
  key: infer K;
}
  ? K extends string
    ? K
    : never
  : never;

export type { TableVariants, TableSlots, SlotsToClasses, ClassValue };
