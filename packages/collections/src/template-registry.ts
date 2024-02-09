import type Listbox from './components/listbox';
import type Dropdown from './components/dropdown';

export default interface Registry {
  Listbox: typeof Listbox;
  Dropdown: typeof Dropdown;
}
