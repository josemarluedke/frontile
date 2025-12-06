---
label: New
imports:
  - import Signature from 'site/components/signature';
---

# Listbox

A listbox presents a list of options allowing users to select one or multiple items. It serves as the foundation for other components like Select and Dropdown menus, with full keyboard navigation and accessibility support.

## Import

```js
import { Listbox } from 'frontile';
```

## Key Features

- **Multiple Selection Modes**: None, single, or multiple item selection
- **Full Keyboard Navigation**: Arrow keys, Home/End, PageUp/PageDown, and type-ahead search
- **Dynamic or Static Items**: Render from an array or define items explicitly
- **Rich Item Content**: Icons, descriptions, shortcuts, and dividers
- **Accessible**: Complete ARIA support and screen reader friendly
- **Customizable**: Control appearance, intent, and styling
- **Flexible Selection**: Allow or require selection with `@allowEmpty`

## Usage

### Basic Listbox with Selection

A simple listbox with single selection mode.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { Listbox } from 'frontile';

export default class BasicListbox extends Component {
  @tracked selectedKeys: string[] = ['lion'];

  animals = [
    'cheetah',
    'crocodile',
    'elephant',
    'giraffe',
    'lion',
    'panda',
    'tiger',
    'zebra'
  ];

  @action
  onSelectionChange(keys: string[]) {
    this.selectedKeys = keys;
  }

  <template>
    <div class='flex flex-col gap-4'>
      <div class='w-[260px] border px-1 py-2 rounded border-neutral-subtle'>
        <Listbox
          @isKeyboardEventsEnabled={{true}}
          @selectionMode='single'
          @items={{this.animals}}
          @selectedKeys={{this.selectedKeys}}
          @onSelectionChange={{this.onSelectionChange}}
          @intent='primary'
        />
      </div>
      <div class='text-sm text-neutral-soft'>
        Selected:
        {{this.selectedKeys}}
      </div>
    </div>
  </template>
}
```

### Multiple Selection

Enable users to select multiple items from the list.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { Listbox } from 'frontile';

export default class MultipleSelection extends Component {
  @tracked selectedKeys: string[] = ['lion', 'tiger'];

  animals = [
    'cheetah',
    'crocodile',
    'elephant',
    'giraffe',
    'lion',
    'panda',
    'tiger',
    'zebra'
  ];

  @action
  onSelectionChange(keys: string[]) {
    this.selectedKeys = keys;
  }

  <template>
    <div class='flex flex-col gap-4'>
      <div class='w-[260px] border px-1 py-2 rounded border-neutral-subtle'>
        <Listbox
          @isKeyboardEventsEnabled={{true}}
          @allowEmpty={{true}}
          @selectionMode='multiple'
          @items={{this.animals}}
          @selectedKeys={{this.selectedKeys}}
          @onSelectionChange={{this.onSelectionChange}}
          @intent='primary'
        />
      </div>
      <div class='text-sm text-neutral-soft'>
        Selected:
        {{this.selectedKeys}}
      </div>
    </div>
  </template>
}
```

### Static Items with Rich Content

Define items explicitly with icons, descriptions, and shortcuts.

> **Note:** The `@shortcut` argument is for display purposes only. You'll need to implement actual keyboard shortcut handling in your application.

```gts preview
import Component from '@glimmer/component';
import { action } from '@ember/object';
import { Listbox } from 'frontile';
import {
  ViewIcon,
  EditIcon,
  ShareIcon,
  DeleteIcon
} from 'site/components/icons';

export default class StaticItems extends Component {
  disabledKeys = ['delete'];

  @action
  onAction(key: string) {
    // eslint-disable-next-line
    console.log('Action:', key);
  }

  <template>
    <div class='w-[280px] border px-1 py-2 rounded border-neutral-subtle'>
      <Listbox
        @isKeyboardEventsEnabled={{true}}
        @onAction={{this.onAction}}
        @appearance='faded'
        @disabledKeys={{this.disabledKeys}}
        as |l|
      >
        <l.Item
          @key='view'
          @description='View in read-only mode'
          @shortcut='⌘O'
        >
          <:start><ViewIcon /></:start>
          <:default>View Details</:default>
        </l.Item>
        <l.Item @key='edit' @description='Make changes' @shortcut='⌘E'>
          <:start><EditIcon /></:start>
          <:default>Edit</:default>
        </l.Item>
        <l.Item
          @key='share'
          @description='Share with team'
          @shortcut='⌘⇧S'
          @withDivider={{true}}
        >
          <:start><ShareIcon /></:start>
          <:default>Share</:default>
        </l.Item>
        <l.Item
          @key='delete'
          @description='Permanently delete'
          @intent='danger'
          @class='text-danger'
          @shortcut='⌘⌫'
        >
          <:start><DeleteIcon /></:start>
          <:default>Delete</:default>
        </l.Item>
      </Listbox>
    </div>
  </template>
}
```

### Action Menu (No Selection)

Use selection mode "none" for action menus where items trigger actions rather than being selected.

```gts preview
import Component from '@glimmer/component';
import { action } from '@ember/object';
import { Listbox } from 'frontile';

export default class ActionMenu extends Component {
  @action
  onAction(key: string) {
    // eslint-disable-next-line
    alert(`Action triggered: ${key}`);
  }

  <template>
    <div class='w-[260px] border px-1 py-2 rounded border-neutral-subtle'>
      <Listbox
        @isKeyboardEventsEnabled={{true}}
        @selectionMode='none'
        @onAction={{this.onAction}}
        as |l|
      >
        <l.Item @key='new'>New File</l.Item>
        <l.Item @key='open'>Open...</l.Item>
        <l.Item @key='save' @shortcut='⌘S'>Save</l.Item>
        <l.Item @key='save-as' @shortcut='⌘⇧S' @withDivider={{true}}>
          Save As...
        </l.Item>
        <l.Item @key='export'>Export</l.Item>
        <l.Item @key='print' @shortcut='⌘P'>Print</l.Item>
      </Listbox>
    </div>
  </template>
}
```

### Different Appearances

Control the visual style with the `@appearance` argument.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { fn } from '@ember/helper';
import { Listbox, ButtonGroup } from 'frontile';

export default class Appearances extends Component {
  @tracked appearance = 'default';
  @tracked selectedKeys: string[] = ['option2'];

  options = ['option1', 'option2', 'option3', 'option4'];

  @action
  setAppearance(appearance: string) {
    this.appearance = appearance;
  }

  @action
  onSelectionChange(keys: string[]) {
    this.selectedKeys = keys;
  }

  isSelected = (type: string) => {
    return this.appearance === type;
  };

  <template>
    <div class='flex flex-col gap-4'>
      <ButtonGroup @size='xs' @intent='primary' as |g|>
        <g.ToggleButton
          @isSelected={{this.isSelected 'default'}}
          @onChange={{fn this.setAppearance 'default'}}
        >
          Default
        </g.ToggleButton>
        <g.ToggleButton
          @isSelected={{this.isSelected 'outlined'}}
          @onChange={{fn this.setAppearance 'outlined'}}
        >
          Outlined
        </g.ToggleButton>
        <g.ToggleButton
          @isSelected={{this.isSelected 'faded'}}
          @onChange={{fn this.setAppearance 'faded'}}
        >
          Faded
        </g.ToggleButton>
      </ButtonGroup>

      <div class='w-[260px] border px-1 py-2 rounded border-neutral-subtle'>
        <Listbox
          @isKeyboardEventsEnabled={{true}}
          @selectionMode='single'
          @items={{this.options}}
          @selectedKeys={{this.selectedKeys}}
          @onSelectionChange={{this.onSelectionChange}}
          @appearance={{this.appearance}}
          @intent='primary'
        />
      </div>
    </div>
  </template>
}
```

### Different Intents

Apply color intents to individual items or the entire listbox.

```gts preview
import Component from '@glimmer/component';
import { Listbox } from 'frontile';

export default class IntentColors extends Component {
  <template>
    <div class='w-[260px] border px-1 py-2 rounded border-neutral-subtle'>
      <Listbox @isKeyboardEventsEnabled={{true}} @appearance='faded' as |l|>
        <l.Item @key='default'>Default Color</l.Item>
        <l.Item @key='primary' @intent='primary'>Primary Color</l.Item>
        <l.Item @key='success' @intent='success'>Success Color</l.Item>
        <l.Item @key='warning' @intent='warning'>Warning Color</l.Item>
        <l.Item @key='danger' @intent='danger'>Danger Color</l.Item>
      </Listbox>
    </div>
  </template>
}
```

### Disabled Items

Prevent interaction with specific items using `@disabledKeys`.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { Listbox } from 'frontile';

export default class DisabledItems extends Component {
  @tracked selectedKeys: string[] = ['feature1'];

  disabledKeys = ['feature3', 'feature4'];

  features = ['feature1', 'feature2', 'feature3', 'feature4', 'feature5'];

  @action
  onSelectionChange(keys: string[]) {
    this.selectedKeys = keys;
  }

  <template>
    <div class='flex flex-col gap-4'>
      <div class='w-[260px] border px-1 py-2 rounded border-neutral-subtle'>
        <Listbox
          @isKeyboardEventsEnabled={{true}}
          @selectionMode='single'
          @items={{this.features}}
          @selectedKeys={{this.selectedKeys}}
          @disabledKeys={{this.disabledKeys}}
          @onSelectionChange={{this.onSelectionChange}}
          @intent='primary'
        />
      </div>
      <div class='text-sm text-neutral-soft'>
        Items "feature3" and "feature4" are disabled
      </div>
    </div>
  </template>
}
```

### Custom Item Rendering

Render complex objects with custom templates.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { Listbox } from 'frontile';

export default class CustomItems extends Component {
  @tracked selectedKeys: string[] = ['user-2'];

  users = [
    {
      id: 'user-1',
      name: 'Alice Johnson',
      role: 'Admin',
      email: 'alice@example.com'
    },
    {
      id: 'user-2',
      name: 'Bob Smith',
      role: 'Developer',
      email: 'bob@example.com'
    },
    {
      id: 'user-3',
      name: 'Carol White',
      role: 'Designer',
      email: 'carol@example.com'
    },
    {
      id: 'user-4',
      name: 'David Brown',
      role: 'Manager',
      email: 'david@example.com'
    }
  ];

  @action
  onSelectionChange(keys: string[]) {
    this.selectedKeys = keys;
  }

  <template>
    <div class='flex flex-col gap-4'>
      <div class='w-[320px] border px-1 py-2 rounded border-neutral-subtle'>
        <Listbox
          @isKeyboardEventsEnabled={{true}}
          @selectionMode='single'
          @items={{this.users}}
          @selectedKeys={{this.selectedKeys}}
          @onSelectionChange={{this.onSelectionChange}}
          @intent='primary'
        >
          <:item as |o|>
            <o.Item @key={{o.item.id}} @description={{o.item.email}}>
              <:default>
                {{o.item.name}}
                <span
                  class='text-xs text-neutral-soft ml-2'
                >({{o.item.role}})</span>
              </:default>
            </o.Item>
          </:item>
        </Listbox>
      </div>
      <div class='text-sm text-neutral-soft'>
        Selected:
        {{this.selectedKeys}}
      </div>
    </div>
  </template>
}
```

### With Dividers

Organize items into logical groups using dividers.

```gts preview
import Component from '@glimmer/component';
import { action } from '@ember/object';
import { Listbox } from 'frontile';

export default class WithDividers extends Component {
  @action
  onAction(key: string) {
    // eslint-disable-next-line
    console.log('Action:', key);
  }

  <template>
    <div class='w-[260px] border px-1 py-2 rounded border-neutral-subtle'>
      <Listbox
        @isKeyboardEventsEnabled={{true}}
        @selectionMode='none'
        @onAction={{this.onAction}}
        as |l|
      >
        <l.Item @key='new-file'>New File</l.Item>
        <l.Item @key='new-folder' @withDivider={{true}}>New Folder</l.Item>
        <l.Item @key='copy'>Copy</l.Item>
        <l.Item @key='paste'>Paste</l.Item>
        <l.Item @key='cut' @withDivider={{true}}>Cut</l.Item>
        <l.Item @key='rename'>Rename</l.Item>
        <l.Item @key='delete' @intent='danger'>Delete</l.Item>
      </Listbox>
    </div>
  </template>
}
```

### Controlled Empty Selection

Control whether users can deselect all items.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { Listbox, Button } from 'frontile';

export default class EmptySelection extends Component {
  @tracked allowEmpty = true;
  @tracked selectedKeys: string[] = ['option2'];

  options = ['option1', 'option2', 'option3'];

  @action
  toggleAllowEmpty() {
    this.allowEmpty = !this.allowEmpty;
  }

  @action
  onSelectionChange(keys: string[]) {
    this.selectedKeys = keys;
  }

  <template>
    <div class='flex flex-col gap-4'>
      <div class='flex items-center gap-2'>
        <Button @size='xs' @onPress={{this.toggleAllowEmpty}}>
          Toggle Allow Empty ({{if this.allowEmpty 'ON' 'OFF'}})
        </Button>
      </div>

      <div class='w-[260px] border px-1 py-2 rounded border-neutral-subtle'>
        <Listbox
          @isKeyboardEventsEnabled={{true}}
          @selectionMode='single'
          @allowEmpty={{this.allowEmpty}}
          @items={{this.options}}
          @selectedKeys={{this.selectedKeys}}
          @onSelectionChange={{this.onSelectionChange}}
          @intent='primary'
        />
      </div>

      <div class='text-sm text-neutral-soft'>
        {{#if this.allowEmpty}}
          You can deselect all items by clicking the selected item.
        {{else}}
          At least one item must remain selected.
        {{/if}}
      </div>
    </div>
  </template>
}
```

## Important Notes

### Keyboard Navigation

The Listbox component includes comprehensive keyboard support:

- **Arrow Up/Down**: Navigate through items
- **Home**: Jump to first item
- **End**: Jump to last item
- **Page Up**: Jump to first item
- **Page Down**: Jump to last item
- **Enter/Space**: Select the active item
- **Type-ahead**: Type letters to jump to matching items

To enable keyboard events, set `@isKeyboardEventsEnabled={{true}}`.

### Selection Modes

Three selection modes are available via `@selectionMode`:

- **`"none"`**: No selection, items trigger actions via `@onAction`
- **`"single"`**: Only one item can be selected at a time
- **`"multiple"`**: Multiple items can be selected

### Auto-Activation

Control which item is initially active using `@autoActivateMode`:

- **`"first"`** (default): First item becomes active
- **`"selected"`**: First selected item becomes active
- **`"none"`**: No item is initially active

### Allow Empty Selection

- **`@allowEmpty={{true}}`**: Users can deselect all items
- **`@allowEmpty={{false}}`** (default): At least one item must be selected (only affects single/multiple modes)

### Dynamic vs Static Items

**Dynamic Items**: Pass an array to `@items` and the component renders them automatically

```gts
<Listbox @items={{this.myArray}} />
```

**Static Items**: Use the yielded `Item` component for full control

```gts
<Listbox as |l|>
  <l.Item @key="option1">Option 1</l.Item>
  <l.Item @key="option2">Option 2</l.Item>
</Listbox>
```

**Custom Rendering**: Combine `@items` with the `:item` block

```gts
<Listbox @items={{this.users}}>
  <:item as |o|>
    <o.Item @key={{o.item.id}}>{{o.item.name}}</o.Item>
  </:item>
</Listbox>
```

### Item Blocks

ListboxItem supports named blocks:

- **`:start`**: Content before the label (e.g., icons)
- **`:default`**: The main label
- **`:end`**: Content after the label
- **`:selectedIcon`**: Custom selection indicator

### Callbacks

- **`@onAction`**: Called when an item is clicked (selection mode "none")
- **`@onSelectionChange`**: Called when selection changes (returns array of keys)
- **`@onActiveItemChange`**: Called when the active item changes (keyboard navigation)

### Accessibility

The Listbox component is fully accessible:

- **ARIA Attributes**: Proper `role="listbox"` or `role="menu"` based on `@type`
- **Focus Management**: Keyboard navigation with visual focus indicators
- **Screen Reader Support**: Descriptive labels and state announcements
- **Disabled State**: Proper handling of disabled items

## API

<Signature @component="Listbox" />
<Signature @component="ListboxItem" />
