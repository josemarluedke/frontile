import type { ContentValue } from '@glint/template';

export interface ColumnDefinition<T = unknown> {
  key: string;
  label: string;
  accessorFn?: (item: T) => ContentValue;
}

export interface TableSignature<T> {
  Args: {
    columns?: ColumnDefinition<T>[];
    items?: T[];
    class?: string;
  };
  Element: HTMLTableElement;
  Blocks: {
    default: [
      {
        Column: typeof import('./table-column').TableColumn;
        Header: typeof import('./table-header').TableHeader;
        Body: typeof import('./table-body').TableBody;
        Row: typeof import('./table-row').TableRow;
        Cell: typeof import('./table-cell').TableCell;
      }
    ];
  };
}

export interface TableHeaderSignature {
  Args: {
    columns?: ColumnDefinition<any>[];
    class?: string;
  };
  Element: HTMLTableSectionElement;
  Blocks: {
    default: [
      {
        Column: typeof import('./table-column').TableColumn;
      }
    ];
  };
}

export interface TableBodySignature<T> {
  Args: {
    columns?: ColumnDefinition<T>[];
    items?: T[];
    class?: string;
  };
  Element: HTMLTableSectionElement;
  Blocks: {
    default: [
      {
        Row: typeof import('./table-row').TableRow;
        Cell: typeof import('./table-cell').TableCell;
      }
    ];
    row: [
      {
        item: T;
        Row: typeof import('./table-row').TableRow;
        Cell: typeof import('./table-cell').TableCell;
      }
    ];
  };
}

export interface TableColumnSignature {
  Args: {
    column?: ColumnDefinition<any>;
    class?: string;
  };
  Element: HTMLTableCellElement;
  Blocks: {
    default: [];
  };
}

export interface TableRowSignature<T> {
  Args: {
    item?: T;
    columns?: ColumnDefinition<T>[];
    class?: string;
  };
  Element: HTMLTableRowElement;
  Blocks: {
    default: [
      {
        Cell: typeof import('./table-cell').TableCell;
      }
    ];
  };
}

export interface TableCellSignature {
  Args: {
    item?: unknown;
    column?: ColumnDefinition<any>;
    value?: ContentValue;
    class?: string;
  };
  Element: HTMLTableCellElement;
  Blocks: {
    default: [];
  };
}