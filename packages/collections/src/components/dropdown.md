---
label: New
imports:
  - import Signature from 'site/components/signature';
---

# Dropdown

A menu activated by a button, representing a set of actions or displaying a list of options for user selection. Built on top of Popover and Listbox components with keyboard navigation support.

## Import

```js
import { Dropdown } from 'frontile';
```

## Key Features

- **Action Menu**: Execute actions when items are selected
- **Selection Support**: Single or multiple item selection
- **Keyboard Navigation**: Arrow keys and Enter/Space for interaction
- **Flexible Positioning**: Control placement with Floating UI options
- **Accessible**: Full ARIA support and keyboard controls
- **Customizable**: Style trigger, menu, and items independently
- **Close Control**: Configure when the dropdown closes

## Usage

### Basic Dropdown

A feature-rich action menu showcasing icons, descriptions, shortcuts, dividers, and color intents.

```gts preview
import Component from '@glimmer/component';
import { action } from '@ember/object';
import { Dropdown } from 'frontile';
import {
  ViewIcon,
  EditIcon,
  DuplicateIcon,
  ShareIcon,
  DownloadIcon,
  ArchiveIcon,
  DeleteIcon
} from 'site/components/icons';

export default class BasicDropdown extends Component {
  @action
  onAction(key: string) {
    // eslint-disable-next-line
    console.log('Action triggered:', key);
  }

  <template>
    <Dropdown as |d|>
      <d.Trigger @intent='primary' @size='sm'>
        Project Actions
      </d.Trigger>

      <d.Menu @onAction={{this.onAction}} as |Item|>
        <Item @key='view' @description='Open in read-only mode' @shortcut='⌘O'>
          <:start><ViewIcon /></:start>
          <:default>View Details</:default>
        </Item>
        <Item @key='edit' @description='Make changes to project' @shortcut='⌘E'>
          <:start><EditIcon /></:start>
          <:default>Edit Project</:default>
        </Item>
        <Item
          @key='duplicate'
          @description='Create a copy'
          @shortcut='⌘D'
          @withDivider={{true}}
        >
          <:start><DuplicateIcon /></:start>
          <:default>Duplicate</:default>
        </Item>
        <Item
          @key='share'
          @intent='primary'
          @description='Invite team members'
          @shortcut='⌘⇧S'
        >
          <:start><ShareIcon /></:start>
          <:default>Share</:default>
        </Item>
        <Item @key='export' @intent='success' @description='Download as file'>
          <:start><DownloadIcon /></:start>
          <:default>Export</:default>
        </Item>
        <Item
          @key='archive'
          @intent='warning'
          @description='Move to archived projects'
          @withDivider={{true}}
        >
          <:start><ArchiveIcon /></:start>
          <:default>Archive Project</:default>
        </Item>
        <Item
          @key='delete'
          @intent='danger'
          @description='Permanently delete'
          @class='text-danger'
          @shortcut='⌘⌫'
        >
          <:start><DeleteIcon /></:start>
          <:default>Delete Project</:default>
        </Item>
      </d.Menu>
    </Dropdown>
  </template>
}
```

### With Descriptions and Shortcuts

Add descriptions and keyboard shortcuts to menu items for better UX.

> **Note:** The `@shortcut` argument is for display purposes only. You'll need to implement actual keyboard shortcut handling in your application using a library or custom implementation.

```gts preview
import Component from '@glimmer/component';
import { action } from '@ember/object';
import { Dropdown } from 'frontile';

export default class DropdownWithDetails extends Component {
  @action
  onAction(key: string) {
    // eslint-disable-next-line
    console.log('Action:', key);
  }

  <template>
    <Dropdown as |d|>
      <d.Trigger @intent='primary' @size='sm'>Account</d.Trigger>

      <d.Menu @onAction={{this.onAction}} @intent='primary' as |Item|>
        <Item @key='profile' @description='View and edit your profile'>
          My Profile
        </Item>
        <Item @key='settings' @description='Manage preferences' @shortcut='⌘,'>
          Settings
        </Item>
        <Item @key='billing' @description='View billing details'>
          Billing
        </Item>
        <Item
          @key='team'
          @description='Manage team members'
          @withDivider={{true}}
        >
          Team
        </Item>
        <Item @key='logout' @intent='danger' @class='text-danger'>
          Log Out
        </Item>
      </d.Menu>
    </Dropdown>
  </template>
}
```

### With Selection

Enable single or multiple selection mode for choosing options.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { Dropdown } from 'frontile';

export default class SelectableDropdown extends Component {
  @tracked selectedKeys = ['bold'];

  @action
  handleSelectionChange(keys: Set<string>) {
    this.selectedKeys = Array.from(keys);
    // eslint-disable-next-line
    console.log('Selected:', this.selectedKeys);
  }

  <template>
    <div class='flex flex-col gap-2'>
      <Dropdown @closeOnItemSelect={{false}} as |d|>
        <d.Trigger @size='sm'>Text Formatting</d.Trigger>

        <d.Menu
          @selectionMode='multiple'
          @selectedKeys={{this.selectedKeys}}
          @onSelectionChange={{this.handleSelectionChange}}
          as |Item|
        >
          <Item @key='bold'>Bold</Item>
          <Item @key='italic'>Italic</Item>
          <Item @key='underline'>Underline</Item>
          <Item @key='strikethrough'>Strikethrough</Item>
        </d.Menu>
      </Dropdown>

      <div class='text-sm text-default-500'>
        Selected:
        {{this.selectedKeys}}
      </div>
    </div>
  </template>
}
```

### Different Trigger Styles

Customize the trigger button appearance.

```gts preview
import Component from '@glimmer/component';
import { action } from '@ember/object';
import { Dropdown } from 'frontile';

export default class TriggerStyles extends Component {
  @action
  onAction(key: string) {
    // eslint-disable-next-line
    console.log('Action:', key);
  }

  <template>
    <div class='flex gap-2 flex-wrap'>
      <Dropdown as |d|>
        <d.Trigger @intent='default' @size='sm'>Default</d.Trigger>
        <d.Menu @onAction={{this.onAction}} as |Item|>
          <Item @key='option1'>Option 1</Item>
          <Item @key='option2'>Option 2</Item>
        </d.Menu>
      </Dropdown>

      <Dropdown as |d|>
        <d.Trigger @intent='primary' @size='sm'>Primary</d.Trigger>
        <d.Menu @onAction={{this.onAction}} as |Item|>
          <Item @key='option1'>Option 1</Item>
          <Item @key='option2'>Option 2</Item>
        </d.Menu>
      </Dropdown>

      <Dropdown as |d|>
        <d.Trigger @intent='success' @size='sm'>Success</d.Trigger>
        <d.Menu @onAction={{this.onAction}} as |Item|>
          <Item @key='option1'>Option 1</Item>
          <Item @key='option2'>Option 2</Item>
        </d.Menu>
      </Dropdown>

      <Dropdown as |d|>
        <d.Trigger @intent='warning' @size='sm'>Warning</d.Trigger>
        <d.Menu @onAction={{this.onAction}} as |Item|>
          <Item @key='option1'>Option 1</Item>
          <Item @key='option2'>Option 2</Item>
        </d.Menu>
      </Dropdown>

      <Dropdown as |d|>
        <d.Trigger @intent='danger' @size='sm'>Danger</d.Trigger>
        <d.Menu @onAction={{this.onAction}} as |Item|>
          <Item @key='option1'>Option 1</Item>
          <Item @key='option2'>Option 2</Item>
        </d.Menu>
      </Dropdown>
    </div>
  </template>
}
```

### Menu Positioning

Control where the menu appears relative to the trigger.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { fn } from '@ember/helper';
import { Dropdown, ButtonGroup } from 'frontile';

export default class MenuPositioning extends Component {
  @tracked placement = 'bottom-start';

  placements = [
    'top',
    'top-start',
    'top-end',
    'bottom',
    'bottom-start',
    'bottom-end',
    'left',
    'right'
  ];

  @action
  setPlacement(placement: string) {
    this.placement = placement;
  }

  @action
  onAction(key: string) {
    // eslint-disable-next-line
    console.log('Action:', key);
  }

  isSelected = (p: string) => {
    return p === this.placement;
  };

  <template>
    <div class='flex flex-col gap-4'>
      <div class='flex gap-2 flex-wrap'>
        <ButtonGroup @size='xs' @intent='primary' as |g|>
          {{#each this.placements as |p|}}
            <g.ToggleButton
              @isSelected={{this.isSelected p}}
              @onChange={{fn this.setPlacement p}}
            >
              {{p}}
            </g.ToggleButton>
          {{/each}}
        </ButtonGroup>
      </div>

      <div class='flex justify-center items-center h-32'>
        <Dropdown @placement={{this.placement}} as |d|>
          <d.Trigger @intent='primary' @size='sm'>
            Menu ({{this.placement}})
          </d.Trigger>

          <d.Menu @onAction={{this.onAction}} as |Item|>
            <Item @key='option1'>Option 1</Item>
            <Item @key='option2'>Option 2</Item>
            <Item @key='option3'>Option 3</Item>
          </d.Menu>
        </Dropdown>
      </div>
    </div>
  </template>
}
```

### Disabled Items

Disable specific menu items.

```gts preview
import Component from '@glimmer/component';
import { action } from '@ember/object';
import { Dropdown } from 'frontile';

export default class DisabledItems extends Component {
  disabledKeys = ['share', 'delete'];

  @action
  onAction(key: string) {
    // eslint-disable-next-line
    console.log('Action:', key);
  }

  <template>
    <Dropdown as |d|>
      <d.Trigger @intent='primary' @size='sm'>File Actions</d.Trigger>

      <d.Menu
        @onAction={{this.onAction}}
        @disabledKeys={{this.disabledKeys}}
        as |Item|
      >
        <Item @key='open'>Open</Item>
        <Item @key='rename'>Rename</Item>
        <Item @key='share'>Share (Coming Soon)</Item>
        <Item @key='download'>Download</Item>
        <Item @key='delete' @intent='danger' @class='text-danger'>
          Delete (Unavailable)
        </Item>
      </d.Menu>
    </Dropdown>
  </template>
}
```

### Keep Open on Select

Prevent the menu from closing when items are selected.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { Dropdown } from 'frontile';

export default class KeepOpenDropdown extends Component {
  @tracked filters = ['recent'];

  @action
  handleSelectionChange(keys: Set<string>) {
    this.filters = Array.from(keys);
    // eslint-disable-next-line
    console.log('Filters:', this.filters);
  }

  <template>
    <div class='flex flex-col gap-2'>
      <Dropdown @closeOnItemSelect={{false}} as |d|>
        <d.Trigger @size='sm'>Filter Options</d.Trigger>

        <d.Menu
          @selectionMode='multiple'
          @selectedKeys={{this.filters}}
          @onSelectionChange={{this.handleSelectionChange}}
          as |Item|
        >
          <Item @key='recent'>Recent</Item>
          <Item @key='starred'>Starred</Item>
          <Item @key='shared'>Shared with me</Item>
          <Item @key='archived'>Archived</Item>
        </d.Menu>
      </Dropdown>

      <div class='text-sm text-default-500'>
        Active filters:
        {{this.filters}}
      </div>
    </div>
  </template>
}
```

### With Dividers and Sections

Organize menu items into logical groups.

```gts preview
import Component from '@glimmer/component';
import { action } from '@ember/object';
import { Dropdown } from 'frontile';

export default class SectionedDropdown extends Component {
  @action
  onAction(key: string) {
    // eslint-disable-next-line
    console.log('Action:', key);
  }

  <template>
    <Dropdown as |d|>
      <d.Trigger @intent='primary' @size='sm'>More Options</d.Trigger>

      <d.Menu @onAction={{this.onAction}} as |Item|>
        <Item @key='new-file'>New File</Item>
        <Item @key='new-folder'>New Folder</Item>
        <Item @key='upload' @withDivider={{true}}>Upload</Item>
        <Item @key='copy'>Copy</Item>
        <Item @key='move'>Move</Item>
        <Item @key='rename' @withDivider={{true}}>Rename</Item>
        <Item @key='export'>Export</Item>
        <Item @key='share'>Share</Item>
        <Item @key='delete' @intent='danger' @class='text-danger'>
          Delete
        </Item>
      </d.Menu>
    </Dropdown>
  </template>
}
```

### Custom Click Handlers

Use individual click handlers for specific items.

```gts preview
import Component from '@glimmer/component';
import { action } from '@ember/object';
import { Dropdown } from 'frontile';

export default class CustomHandlers extends Component {
  @action
  handleEdit() {
    alert('Edit clicked');
  }

  @action
  handleDelete() {
    if (confirm('Are you sure you want to delete?')) {
      alert('Deleted!');
    }
  }

  @action
  handleDownload() {
    alert('Downloading...');
  }

  <template>
    <Dropdown as |d|>
      <d.Trigger @intent='primary' @size='sm'>Actions</d.Trigger>

      <d.Menu as |Item|>
        <Item @key='view'>View Details</Item>
        <Item @key='edit' @onClick={{this.handleEdit}}>Edit</Item>
        <Item @key='download' @onClick={{this.handleDownload}}>
          Download
        </Item>
        <Item
          @key='delete'
          @intent='danger'
          @class='text-danger'
          @onClick={{this.handleDelete}}
          @withDivider={{true}}
        >
          Delete
        </Item>
      </d.Menu>
    </Dropdown>
  </template>
}
```

### With Backdrop

Control the backdrop appearance behind the dropdown menu.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { fn } from '@ember/helper';
import { Dropdown, ButtonGroup } from 'frontile';

export default class DropdownBackdrop extends Component {
  @tracked backdrop = 'none';

  @action
  setBackdrop(type: string) {
    this.backdrop = type;
  }

  @action
  onAction(key: string) {
    // eslint-disable-next-line
    console.log('Action:', key);
  }

  isActiveBackdrop = (type: string) => {
    return this.backdrop === type;
  };

  <template>
    <div class='flex flex-col gap-4'>
      <ButtonGroup @size='xs' @intent='primary' as |g|>
        <g.ToggleButton
          @isSelected={{this.isActiveBackdrop 'none'}}
          @onChange={{fn this.setBackdrop 'none'}}
        >
          No Backdrop
        </g.ToggleButton>
        <g.ToggleButton
          @isSelected={{this.isActiveBackdrop 'faded'}}
          @onChange={{fn this.setBackdrop 'faded'}}
        >
          Faded
        </g.ToggleButton>
        <g.ToggleButton
          @isSelected={{this.isActiveBackdrop 'blur'}}
          @onChange={{fn this.setBackdrop 'blur'}}
        >
          Blur
        </g.ToggleButton>
      </ButtonGroup>

      <Dropdown as |d|>
        <d.Trigger @intent='primary' @size='sm'>
          Open Menu ({{this.backdrop}})
        </d.Trigger>

        <d.Menu
          @backdrop={{this.backdrop}}
          @onAction={{this.onAction}}
          as |Item|
        >
          <Item @key='option1'>Option 1</Item>
          <Item @key='option2'>Option 2</Item>
          <Item @key='option3'>Option 3</Item>
        </d.Menu>
      </Dropdown>
    </div>
  </template>
}
```

### With Close Callback

Execute a callback when the dropdown closes.

```gts preview
import Component from '@glimmer/component';
import { action } from '@ember/object';
import { Dropdown } from 'frontile';

export default class DropdownWithCallback extends Component {
  @action
  handleDidClose() {
    // eslint-disable-next-line
    console.log('Dropdown closed');
  }

  @action
  onAction(key: string) {
    // eslint-disable-next-line
    console.log('Action:', key);
  }

  <template>
    <Dropdown @didClose={{this.handleDidClose}} as |d|>
      <d.Trigger @intent='primary' @size='sm'>Dropdown</d.Trigger>

      <d.Menu @onAction={{this.onAction}} as |Item|>
        <Item @key='option1'>Option 1</Item>
        <Item @key='option2'>Option 2</Item>
        <Item @key='option3'>Option 3</Item>
      </d.Menu>
    </Dropdown>
  </template>
}
```

## Important Notes

### Keyboard Navigation

The Dropdown component includes built-in keyboard support:

- **Arrow Down/Arrow Up**: Opens the dropdown when trigger is focused
- **Arrow Down/Arrow Up**: Navigates through menu items when open
- **Enter/Space**: Selects the focused item
- **Escape**: Closes the dropdown
- **Tab**: Moves focus out and closes the dropdown

### Accessibility

The Dropdown component includes full accessibility features:

- **ARIA Attributes**: Proper `aria-haspopup`, `aria-expanded`, and `aria-controls` on trigger
- **Focus Management**: Automatic focus handling when opening/closing
- **Keyboard Support**: Complete keyboard navigation
- **Screen Reader Support**: Proper semantic structure and labels

### Close Behavior

By default, the dropdown closes when:

- An item is selected (disable with `@closeOnItemSelect={{false}}`)
- User clicks outside the menu
- User presses Escape key
- Trigger is clicked again

### Selection Modes

The Menu supports different selection modes via `@selectionMode`:

- **`"none"`** (default): No selection, only actions
- **`"single"`**: Single item selection
- **`"multiple"`**: Multiple items can be selected

When using selection modes, use `@selectedKeys` and `@onSelectionChange` to control the selection state.

### Item Actions

There are two ways to handle item interactions:

1. **Menu-level handler**: Use `@onAction` on the Menu to handle all item clicks
2. **Item-level handler**: Use `@onClick` on individual Items for specific behavior

Both can be used together - the Item's `@onClick` fires first, then the Menu's `@onAction`.

### Positioning

The Dropdown uses Floating UI for smart positioning:

- Automatically flips to stay in viewport
- Shifts to avoid overflow
- Customizable via `@placement`, `@flipOptions`, `@shiftOptions`, `@offsetOptions`

### Menu Variants

The Menu component inherits appearance options from Listbox:

- **`@appearance`**: Style variant for menu items
- **`@intent`**: Color intent for the menu

## API

<Signature @package="collections" @component="Dropdown" />
