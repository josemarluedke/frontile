import type {
  Button,
  ButtonGroup,
  Chip,
  CloseButton,
  ToggleButton
} from './index';

export default interface Registry {
  Button: typeof Button;
  Chip: typeof Chip;
  ToggleButton: typeof ToggleButton;
  ButtonGroup: typeof ButtonGroup;
  CloseButton: typeof CloseButton;
}
