import type { Listbox, Dropdown } from './index';

export default interface Registry {
  Listbox: typeof Listbox;
  Dropdown: typeof Dropdown;
}
