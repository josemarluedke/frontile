---
label: New
---

# Select

The `Select` component is a powerful and flexible dropdown component. It supports both **single** and **multiple** selection modes, provides built‐in filtering capabilities, and renders a hidden native `<select>` element to ensure full accessibility. Under the hood, it leverages the [Listbox](https://frontile.dev/docs/collections/listbox) and [Popover](https://frontile.dev/docs/overlays/popover) components to power its interactive behavior.

## Import

```js
import { Select } from '@frontile/forms';
```

## Basic Single Select

A simple single-select dropdown with static string options:

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Select } from '@frontile/forms';

const options = ['Option 1', 'Option 2', 'Option 3'];

export default class BasicSingleSelect extends Component {
  @tracked selectedKeys: string[] = [];

  onSelectionChange = (keys: string[]) => {
    this.selectedKeys = keys;
  };

  <template>
    <Select
      @placeholder='Select an option'
      @items={{options}}
      @selectedKeys={{this.selectedKeys}}
      @onSelectionChange={{this.onSelectionChange}}
    />
    <p>Selected: {{this.selectedKeys}}</p>
  </template>
}
```

## Multiple Select

Configure the `Select` component for multiple selection mode. You can supply the options as objects (each with a `key` and `label`):

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Select } from '@frontile/forms';

const fruits = [
  { key: 'apple', label: 'Apple' },
  { key: 'banana', label: 'Banana' },
  { key: 'cherry', label: 'Cherry' },
  { key: 'date', label: 'Date' }
];

export default class MultipleSelectExample extends Component {
  @tracked selectedKeys: string[] = [];

  onSelectionChange = (keys: string[]) => {
    this.selectedKeys = keys;
  };

  <template>
    <Select
      @selectionMode='multiple'
      @placeholder='Select fruits'
      @items={{fruits}}
      @selectedKeys={{this.selectedKeys}}
      @onSelectionChange={{this.onSelectionChange}}
    >
      <:item as |o|>
        <o.Item>
          {{o.label}}
        </o.Item>
      </:item>
    </Select>
    <p>Selected: {{this.selectedKeys}}</p>
  </template>
}
```

## Filterable Select

Enable filtering so users can quickly search through the options. Filtering only applies when options are provided via the `@items` argument.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Select } from '@frontile/forms';

const countries = [
  'Argentina',
  'Brazil',
  'Canada',
  'Denmark',
  'Egypt',
  'France'
];

export default class FilterableSelectExample extends Component {
  @tracked selectedKeys: string[] = [];

  onSelectionChange = (keys: string[]) => {
    this.selectedKeys = keys;
  };

  <template>
    <Select
      @isFilterable={{true}}
      @placeholder='Select a country'
      @items={{countries}}
      @selectedKeys={{this.selectedKeys}}
      @onSelectionChange={{this.onSelectionChange}}
    />
    <p>Selected: {{this.selectedKeys}}</p>
  </template>
}
```

## Item Object Format

When using the `@items` argument, you can pass items as either primitives (strings or numbers) or objects. The `Select` component automatically extracts a key and label for each item using a flexible approach:

- **Key Extraction:**  
  The component first checks for a `key` property. If not present, it will look for an `id` property. If neither is available, it falls back to the string representation of the item.

- **Label Extraction:**  
  For the label, the component checks in order for `label`, `value`, `name`, or `title`. If none of these properties exist, it uses the string representation of the item.

This supports common object shapes such as:

- `{ key: 'apple', label: 'Apple' }`
- `{ key: 'apple', value: 'Apple' }`
- `{ id: 'user-1', name: 'John Doe', email: 'john@example.com' }`

## Custom Option Rendering

Customize the display of each option by yielding the item to a block. This is useful when you need to add extra information (such as a description or icon) alongside the label.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Select } from '@frontile/forms';

export default class CustomUserSelect extends Component {
  @tracked selectedKeys: string[] = [];

  onSelectionChange = (keys: string[]) => {
    this.selectedKeys = keys;
  };

  <template>
    <Select
      @isFilterable={{true}}
      @placeholder='Select a user'
      @items={{users}}
      @selectedKeys={{this.selectedKeys}}
      @onSelectionChange={{this.onSelectionChange}}
    >
      <:item as |o|>
        <o.Item>
          <div class='flex items-center space-x-4'>
            <img
              src='{{o.item.avatar}}'
              alt='{{o.item.name}}'
              class='w-10 h-10 rounded-full'
            />
            <div>
              <div class='font-medium text-default-900'>{{o.item.name}}</div>
              <div class='text-sm text-default-500'>{{o.item.email}}</div>
            </div>
          </div>
        </o.Item>
      </:item>
    </Select>
    <p class='mt-4'>Selected: {{this.selectedKeys}}</p>
  </template>
}

const users = [
  {
    id: 'john-doe',
    name: 'John Doe',
    email: 'john.doe@example.com',
    avatar: 'https://i.pravatar.cc/150?img=1'
  },
  {
    id: 'jane-smith',
    name: 'Jane Smith',
    email: 'jane.smith@example.com',
    avatar: 'https://i.pravatar.cc/150?img=2'
  },
  {
    id: 'alice-johnson',
    name: 'Alice Johnson',
    email: 'alice.johnson@example.com',
    avatar: 'https://i.pravatar.cc/150?img=3'
  },
  {
    id: 'bob-brown',
    name: 'Bob Brown',
    email: 'bob.brown@example.com',
    avatar: 'https://i.pravatar.cc/150?img=4'
  },
  {
    id: 'charlie-davis',
    name: 'Charlie Davis',
    email: 'charlie.davis@example.com',
    avatar: 'https://i.pravatar.cc/150?img=5'
  }
];
```

## Declarative Items with Named Blocks

You can also define options directly inside the component using block syntax (referred to here as declarative items). In this case, filtering is not available. This example also demonstrates the use of the `@disabledKeys` and `@allowEmpty` options. When `@allowEmpty` is enabled, clicking a selected item will toggle its selection state (i.e. deselect it).

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { array } from '@ember/helper';
import { Select } from '@frontile/forms';

export default class DeclarativeItemsSelect extends Component {
  @tracked selectedKeys: string[] = [];

  onSelectionChange = (keys: string[]) => {
    this.selectedKeys = keys;
  };

  <template>
    <Select
      @placeholder='Select...'
      @onSelectionChange={{this.onSelectionChange}}
      @selectedKeys={{this.selectedKeys}}
      @disabledKeys={{array 'item-3' 'item-4'}}
      @allowEmpty={{true}}
      as |l|
    >
      <l.Item @key='item-1'>Item 1</l.Item>
      <l.Item @key='item-2'>Item 2</l.Item>
      <l.Item @key='item-3'>Item 3</l.Item>
      <l.Item @key='item-4'>Item 4</l.Item>
      <l.Item @key='item-5'>Item 5</l.Item>
    </Select>
    <p>Selected: {{this.selectedKeys}}</p>
  </template>
}
```

## Clearable Select

The built-in clear button can be enabled using the `@isClearable` flag. This allows users to reset the selection easily.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Select } from '@frontile/forms';

const colors = ['Red', 'Green', 'Blue'];

export default class ClearableSelectExample extends Component {
  @tracked selectedKeys: string[] = [];

  onSelectionChange = (keys: string[]) => {
    this.selectedKeys = keys;
  };

  <template>
    <Select
      @placeholder='Select a color'
      @items={{colors}}
      @selectedKeys={{this.selectedKeys}}
      @onSelectionChange={{this.onSelectionChange}}
      @isClearable={{true}}
    />
    <p>Selected: {{this.selectedKeys}}</p>
  </template>
}
```

## Loading Select

Display a loading spinner in place of the dropdown icon by enabling the `@isLoading` flag. This is useful when data is being fetched asynchronously.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Select } from '@frontile/forms';

const sizes = ['Small', 'Medium', 'Large'];

export default class LoadingSelectExample extends Component {
  @tracked selectedKeys: string[] = [];

  onSelectionChange = (keys: string[]) => {
    this.selectedKeys = keys;
  };

  <template>
    <Select
      @placeholder='Select a size'
      @items={{sizes}}
      @selectedKeys={{this.selectedKeys}}
      @onSelectionChange={{this.onSelectionChange}}
      @isLoading={{true}}
    />
    <p>Selected: {{this.selectedKeys}}</p>
  </template>
}
```

## Select with Custom Input Content and Empty State

This example demonstrates how to use the `:startContent`, `:endContent`, and `:emptyContent` blocks to customize the select’s trigger appearance and the empty state when no results match the filter. Here, the select is filterable, so the empty content is shown when there are no matching options.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Select } from '@frontile/forms';

const fruits = ['Apple', 'Banana', 'Cherry', 'Date'];

export default class CustomContentBlocksSelect extends Component {
  @tracked selectedKeys: string[] = [];

  onSelectionChange = (keys: string[]) => {
    this.selectedKeys = keys;
  };

  <template>
    <Select
      @isFilterable={{true}}
      @placeholder='Search fruits...'
      @items={{fruits}}
      @selectedKeys={{this.selectedKeys}}
      @onSelectionChange={{this.onSelectionChange}}
    >
      <:startContent>
        <span class='mr-2'>🔍</span>
      </:startContent>
      <:endContent>
        <span class='ml-2'>▼</span>
      </:endContent>
      <:emptyContent>
        <div class='p-2 text-center text-gray-500'>
          No fruits found.
        </div>
      </:emptyContent>
    </Select>
    <p>Selected: {{this.selectedKeys}}</p>
  </template>
}
```

## Using NativeSelect

The `NativeSelect` component is a lightweight version of the select component that renders a native HTML `<select>` element. This is especially useful when you need maximum accessibility or want to rely on the browser’s native behavior.
It supports most of the same features as the custom `Select` component, such as passing an array of items, managing selection state, and handling selection changes.
By using `NativeSelect` directly, you can simplify your markup while still benefiting from Frontile’s APIs.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { NativeSelect } from '@frontile/forms';

const options = ['Option 1', 'Option 2', 'Option 3'];

export default class NativeSelectExample extends Component {
  @tracked selectedKeys: string[] = [];

  onSelectionChange = (keys: string[]) => {
    this.selectedKeys = keys;
  };

  <template>
    <NativeSelect
      @placeholder='Select an option'
      @items={{options}}
      @selectedKeys={{this.selectedKeys}}
      @onSelectionChange={{this.onSelectionChange}}
    />
    <p class='mt-4'>Selected: {{this.selectedKeys}}</p>
  </template>
}
```

## API

<Signature @package="forms" @component="Select" />
<Signature @package="forms" @component="SelectItem" />
<Signature @package="forms" @component="NativeSelect" />
<Signature @package="forms" @component="NativeSelectItem" />
