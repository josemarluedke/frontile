import type Button from './components/button';
import type Chip from './components/chip';
import type ToggleButton from './components/toggle-button';
import type ButtonGroup from './components/button-group';
import type ProgressBar from './components/progress-bar';
import type Listbox from './components/listbox';

export default interface Registry {
  Button: typeof Button;
  Chip: typeof Chip;
  ToggleButton: typeof ToggleButton;
  ButtonGroup: typeof ButtonGroup;
  ProgressBar: typeof ProgressBar;
  Listbox: typeof Listbox;
}
