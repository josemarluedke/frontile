import type Button from './components/button';
import type Chip from './components/chip';
import type ToggleButton from './components/toggle-button';

export default interface Registry {
  Button: typeof Button;
  Chip: typeof Chip;
  ToggleButton: typeof ToggleButton;
}
