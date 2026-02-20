import type {
  Button,
  ButtonGroup,
  Chip,
  CloseButton,
  ToggleButton
} from './components/buttons';

import type {
  Form,
  Checkbox,
  FormDescription,
  FormFeedback,
  Input,
  Label,
  NativeSelect,
  Select,
  Textarea,
  FormControl,
  RadioGroup,
  CheckboxGroup
} from './components/forms';

import type { Listbox, Dropdown, Table, SimpleTable } from './components/collections';

import type { Overlay, Modal, Drawer, Popover } from './components/overlays';

import type { NotificationCard, NotificationsContainer } from './components/notifications';

import type { ProgressBar } from './components/status';

import type { VisuallyHidden, Collapsible, Spinner, Divider } from './components/utilities';

export default interface Registry {
  // Buttons
  Button: typeof Button;
  Chip: typeof Chip;
  ToggleButton: typeof ToggleButton;
  ButtonGroup: typeof ButtonGroup;
  CloseButton: typeof CloseButton;

  // Forms
  Form: typeof Form;
  Checkbox: typeof Checkbox;
  FormDescription: typeof FormDescription;
  FormFeedback: typeof FormFeedback;
  Input: typeof Input;
  Label: typeof Label;
  NativeSelect: typeof NativeSelect;
  Select: typeof Select;
  Textarea: typeof Textarea;
  FormControl: typeof FormControl;
  CheckboxGroup: typeof CheckboxGroup;
  RadioGroup: typeof RadioGroup;

  // Collections
  Listbox: typeof Listbox;
  Dropdown: typeof Dropdown;
  Table: typeof Table;
  SimpleTable: typeof SimpleTable;

  // Overlays
  Overlay: typeof Overlay;
  Drawer: typeof Drawer;
  Modal: typeof Modal;
  Popover: typeof Popover;

  // Notifications
  NotificationCard: typeof NotificationCard;
  NotificationsContainer: typeof NotificationsContainer;

  // Status
  ProgressBar: typeof ProgressBar;

  // Utilities
  VisuallyHidden: typeof VisuallyHidden;
  Collapsible: typeof Collapsible;
  Spinner: typeof Spinner;
  Divider: typeof Divider;
}
