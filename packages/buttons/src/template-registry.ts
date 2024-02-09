import type {
  Button,
  ButtonGroup,
  Chip,
  CloseButton,
  ProgressBar,
  ToggleButton
} from './index';

export default interface Registry {
  Button: typeof Button;
  Chip: typeof Chip;
  ToggleButton: typeof ToggleButton;
  ButtonGroup: typeof ButtonGroup;
  ProgressBar: typeof ProgressBar;
  CloseButton: typeof CloseButton;
}
