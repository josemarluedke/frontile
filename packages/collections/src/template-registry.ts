import type { Listbox, Dropdown, Table, SimpleTable } from './index';

export default interface Registry {
  Listbox: typeof Listbox;
  Dropdown: typeof Dropdown;
  Table: typeof Table;
  SimpleTable: typeof SimpleTable;
}
