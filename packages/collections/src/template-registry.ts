import type { Listbox, Dropdown, Table, TableHeader, TableBody, TableColumn, TableRow, TableCell } from './index';

export default interface Registry {
  Listbox: typeof Listbox;
  Dropdown: typeof Dropdown;
  Table: typeof Table;
  TableHeader: typeof TableHeader;
  TableBody: typeof TableBody;
  TableColumn: typeof TableColumn;
  TableRow: typeof TableRow;
  TableCell: typeof TableCell;
}
