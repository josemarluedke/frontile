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
      <div class='text-sm text-neutral-firm'>
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
      <div class='text-sm text-neutral-firm'>
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
        <l.Item @key='secondary' @intent='secondary'>Secondary Color</l.Item>
        <l.Item @key='tertiary' @intent='tertiary'>Tertiary Color</l.Item>
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
      <div class='text-sm text-neutral-firm'>
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
                  class='text-xs text-neutral-firm ml-2'
                >({{o.item.role}})</span>
              </:default>
            </o.Item>
          </:item>
        </Listbox>
      </div>
      <div class='text-sm text-neutral-firm'>
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

      <div class='text-sm text-neutral-firm'>
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

### Grouped Options

`l.Group` renders a labelled section of options. It yields its own `Item`, and
`@withDivider` draws a separator after the group.

Grouping changes nothing about keyboard navigation: arrow keys traverse straight
across group boundaries, because navigation order is derived from the document
rather than from the nesting.

```gts preview
import { Listbox } from 'frontile';
import { array } from '@ember/helper';

<template>
  <Listbox @selectionMode='single' @disabledKeys={{array 'calculator'}} as |l|>
    <l.Group @title='Suggestions' @withDivider={{true}} as |g|>
      <g.Item @key='calendar'>Calendar</g.Item>
      <g.Item @key='emoji'>Search Emoji</g.Item>
      <g.Item @key='calculator'>Calculator</g.Item>
    </l.Group>
    <l.Group @title='Settings' as |g|>
      <g.Item @key='profile' @shortcut='⌘P'>Profile</g.Item>
      <g.Item @key='billing' @shortcut='⌘B'>Billing</g.Item>
    </l.Group>
  </Listbox>
</template>
```

A group without `@title` still groups its options but renders no heading, and
carries no `aria-labelledby` — there would be nothing for it to point at.

## Accessibility

| Element  | What it exposes                                                                                |
| -------- | ---------------------------------------------------------------------------------------------- |
| The list | `role="listbox"`, or `role="menu"` with `@type="menu"`                                         |
|          | `aria-multiselectable="true"` when `@selectionMode="multiple"` (listbox only)                  |
| Items    | `role="option"` (or `menuitem`), `aria-labelledby` pointing at the item's label                |
|          | `aria-selected` reflecting selection — options only, since it is invalid on a plain `menuitem` |
|          | `aria-disabled="true"` for keys in `@disabledKeys`                                             |
|          | a roving `tabindex` — exactly one option carries `0`, every other one `-1`                      |

The options form a composite you step into once and then navigate with the arrow keys, so only
one of them is ever in the tab order. That one is the active option; with nothing active it is
the first selected option, and failing that the first option that is not disabled. A
multiple-selection list with eight selections is therefore still a single stop for `Tab`, not
eight.

Keyboard, handled on the list itself:

| Key                     | Behavior                                                            |
| ----------------------- | ------------------------------------------------------------------- |
| `ArrowDown` / `ArrowUp` | Move the active item                                                |
| `Home` / `PageUp`       | Jump to the first item                                              |
| `End` / `PageDown`      | Jump to the last item                                               |
| `Enter`, `Space`        | Select the active item                                              |
| any single character    | Type-ahead: jumps to the item whose text starts with what you typed |

Two details worth knowing. Type-ahead means `Space` selects only when no search is in
progress, so a space typed mid-search is treated as part of the search string rather than as
a selection. And `@elementToAddKeyboardEvents` moves the key handling onto another element —
that is how Select and Autocomplete keep focus in their input while driving the list.

Groups render as `role="group"` labelled by their heading, with the list between
the group and its options marked `role="none"` so the `listbox` → `option`
ownership chain stays intact. A group with no `@title` carries no
`aria-labelledby`.

## API

<Signature @component="Listbox" />

### Listbox::Group

<Signature @component="ListboxGroup" />

### Listbox::Item

<Signature @component="ListboxItem" />
