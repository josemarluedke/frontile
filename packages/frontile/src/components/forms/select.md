---
label: New
imports:
  - import Signature from 'site/components/signature';
---

# Select

The `Select` component is a powerful and flexible dropdown component. It supports both **single** and **multiple** selection modes, provides built‐in filtering capabilities, and renders a hidden native `<select>` element to ensure full accessibility. Under the hood, it leverages the [Listbox](https://frontile.dev/docs/collections/listbox) and [Popover](https://frontile.dev/docs/overlays/popover) components to power its interactive behavior.

## Import

```js
import { Select } from 'frontile';
```

## Usage

### Basic Single Select

The most basic usage of a single-select dropdown with static options.

```gts preview
import { Select } from 'frontile';

const options = ['Option 1', 'Option 2', 'Option 3'];

<template>
  <Select
    @placeholder='Select an option'
    @items={{options}}
  />
</template>
```

> **Modern Usage:** For forms with data binding and validation, use the Form and Field components as shown in the examples below. Form/Field provides automatic state management, validation, and error handling without manual `@onChange` handlers.

### Data Binding with Form/Field

When working with forms, the Form component automatically manages the selected value and provides data binding:

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Form, type FormResultData } from 'frontile';

const options = ['Option 1', 'Option 2', 'Option 3'];

export default class DataBoundSingleSelect extends Component {
  @tracked formData = { selectedOption: '' };

  handleFormChange = (result: FormResultData) => {
    this.formData = result.data;
  };

  <template>
    <div class='flex flex-col gap-4'>
      <Form @data={{this.formData}} @onChange={{this.handleFormChange}} as |form|>
        <form.Field @name='selectedOption' as |field|>
          <field.SingleSelect
            @placeholder='Select an option'
            @items={{options}}
          />
        </form.Field>
      </Form>
      <p>Selected: {{this.formData.selectedOption}}</p>
    </div>
  </template>
}
```

### Form Validation

The Select component integrates seamlessly with form validation by automatically displaying error messages and updating ARIA attributes. This example demonstrates both single and multiple select validation using Valibot schemas with the Form component. The example uses `@validateOn` to trigger validation on both change and submit events, providing immediate feedback as users make selections.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { array } from '@ember/helper';
import { Form, type FormResultData } from 'frontile';
import { Button } from 'frontile';
import * as v from 'valibot';

const countries = ['United States', 'Canada', 'Mexico', 'United Kingdom', 'Germany', 'France', 'Japan', 'Australia'];
const interests = [
  { key: 'tech', label: 'Technology' },
  { key: 'sports', label: 'Sports' },
  { key: 'music', label: 'Music' },
  { key: 'art', label: 'Art' },
  { key: 'travel', label: 'Travel' }
];

// Define validation schema
const schema = v.object({
  country: v.pipe(
    v.fallback(v.string(), ''),
    v.nonEmpty('Please select a country')
  ),
  interests: v.pipe(
    v.array(v.string()),
    v.minLength(1, 'Please select at least one interest'),
    v.maxLength(3, 'Please select no more than 3 interests')
  )
});

type Schema = v.InferOutput<typeof schema>;

export default class SelectFormValidation extends Component {
  @tracked formData = {
    country: '',
    interests: [] as string[]
  };
  @tracked submitMessage = '';

  @action
  handleFormChange(data: FormResultData<Schema>) {
    this.formData = data.data;
    this.submitMessage = '';
  }

  @action
  handleFormSubmit(data: FormResultData<Schema>) {
    this.submitMessage = 'Form submitted successfully!';
    console.log('Submitted data:', data.data);
  }

  <template>
    <div class='flex flex-col gap-6'>
      <Form
        @data={{this.formData}}
        @schema={{schema}}
        @onChange={{this.handleFormChange}}
        @onSubmit={{this.handleFormSubmit}}
        @validateOn={{array 'change' 'submit'}}
        as |form|
      >
        <div class='flex flex-col gap-4'>
          <form.Field @name='country' as |field|>
            <field.SingleSelect
              @label='Country'
              @description='Select your country of residence'
              @placeholder='Choose a country'
              @items={{countries}}
              @isRequired={{true}}
              @allowEmpty={{true}}
            />
          </form.Field>

          <form.Field @name='interests' as |field|>
            <field.MultiSelect
              @label='Interests'
              @description='Select 1-3 areas of interest'
              @placeholder='Choose your interests'
              @items={{interests}}
              @isRequired={{true}}
            >
              <:item as |o|>
                <o.Item>
                  {{o.label}}
                </o.Item>
              </:item>
            </field.MultiSelect>
          </form.Field>

          <Button type='submit'>Submit</Button>
        </div>
      </Form>

      {{#if this.submitMessage}}
        <div class='p-4 bg-success-50 border border-success-subtle rounded'>
          <p class='text-success-strong'>{{this.submitMessage}}</p>
          <div class='mt-2 text-sm'>
            <p><strong>Country:</strong> {{this.formData.country}}</p>
            <p><strong>Interests:</strong> {{this.formData.interests}}</p>
          </div>
        </div>
      {{/if}}
    </div>
  </template>
}
```

### Filterable Select

Enable filtering so users can quickly search through the options. Filtering only applies when options are provided via the `@items` argument. The Select component works seamlessly with Form/Field data binding while providing search functionality:

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Form, type FormResultData } from 'frontile';

const countries = [
  'Argentina',
  'Brazil',
  'Canada',
  'Denmark',
  'Egypt',
  'France',
  'Germany',
  'Italy',
  'Japan',
  'Mexico'
];

export default class FilterableSelect extends Component {
  @tracked formData = { country: '' };

  handleFormChange = (result: FormResultData) => {
    this.formData = result.data;
  };

  <template>
    <div class='flex flex-col gap-4'>
      <Form @data={{this.formData}} @onChange={{this.handleFormChange}} as |form|>
        <form.Field @name='country' as |field|>
          <field.SingleSelect
            @isFilterable={{true}}
            @placeholder='Select a country'
            @items={{countries}}
          />
        </form.Field>
      </Form>
      <p>Selected: {{this.formData.country}}</p>
    </div>
  </template>
}
```

### Item Object Format

When using the `@items` argument, you can pass items as either primitives (strings or numbers) or objects. The `Select` component automatically extracts a key and label for each item using a flexible approach:

- **Key Extraction:**  
  The component first checks for a `key` property. If not present, it will look for an `id` property. If neither is available, it falls back to the string representation of the item.

- **Label Extraction:**  
  For the label, the component checks in order for `label`, `value`, `name`, or `title`. If none of these properties exist, it uses the string representation of the item.

This supports common object shapes such as:

- `{ key: 'apple', label: 'Apple' }`
- `{ key: 'apple', value: 'Apple' }`
- `{ id: 'user-1', name: 'John Doe', email: 'john@example.com' }`

### Custom Option Rendering

Customize the display of each option by yielding the item to a block. This is useful when you need to add extra information (such as a description or icon) alongside the label.

> **Note:** This example uses direct component state management (`@selectedKey` and `@onSelectionChange`) to focus on demonstrating the custom rendering feature. For form-integrated examples with validation and automatic data binding, see the "Form Validation" section.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Select } from 'frontile';

export default class CustomUserSelect extends Component {
  @tracked selectedKey: string | null = null;

  onSelectionChange = (key: string | null) => {
    this.selectedKey = key;
  };

  <template>
    <Select
      @isFilterable={{true}}
      @placeholder='Select a user'
      @items={{users}}
      @selectedKey={{this.selectedKey}}
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
              <div class='font-medium text-neutral-strong'>{{o.item.name}}</div>
              <div class='text-sm text-neutral-soft'>{{o.item.email}}</div>
            </div>
          </div>
        </o.Item>
      </:item>
    </Select>
    <p class='mt-4'>Selected: {{this.selectedKey}}</p>
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

### Declarative Items with Named Blocks

You can also define options directly inside the component using block syntax (referred to here as declarative items). In this case, filtering is not available. This example also demonstrates the use of the `@disabledKeys` and `@allowEmpty` options. When `@allowEmpty` is enabled, clicking a selected item will toggle its selection state (i.e. deselect it).

> **Note:** This example uses direct state management to demonstrate the declarative items feature. For most form use cases, prefer using `@items` with Form/Field as shown in earlier examples.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { array } from '@ember/helper';
import { Select } from 'frontile';

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

### Clearable Select

The built-in clear button can be enabled using the `@isClearable` flag. This allows users to reset the selection easily.

> **Note:** This example demonstrates the clearable feature with direct state management. The `@isClearable` option also works with Form/Field integration.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Select } from 'frontile';

const colors = ['Red', 'Green', 'Blue'];

export default class ClearableSelectExample extends Component {
  @tracked selectedKey: string | null = null;

  onSelectionChange = (key: string | null) => {
    this.selectedKey = key;
  };

  <template>
    <Select
      @placeholder='Select a color'
      @items={{colors}}
      @selectedKey={{this.selectedKey}}
      @onSelectionChange={{this.onSelectionChange}}
      @isClearable={{true}}
    />
    <p>Selected: {{this.selectedKey}}</p>
  </template>
}
```

### Loading Select

Display a loading spinner in place of the dropdown icon by enabling the `@isLoading` flag. This is useful when data is being fetched asynchronously.

> **Note:** This example shows the loading state feature. The `@isLoading` option works with both standalone and Form/Field usage.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Select } from 'frontile';

const sizes = ['Small', 'Medium', 'Large'];

export default class LoadingSelectExample extends Component {
  @tracked selectedKey: string | null = null;

  onSelectionChange = (key: string | null) => {
    this.selectedKey = key;
  };

  <template>
    <Select
      @placeholder='Select a size'
      @items={{sizes}}
      @selectedKey={{this.selectedKey}}
      @onSelectionChange={{this.onSelectionChange}}
      @isLoading={{true}}
    />
    <p>Selected: {{this.selectedKey}}</p>
  </template>
}
```

### Select with Custom Input Content and Empty State

This example demonstrates how to use the `:startContent`, `:endContent`, and `:emptyContent` blocks to customize the select's trigger appearance and the empty state when no results match the filter. Here, the select is filterable, so the empty content is shown when there are no matching options.

> **Note:** This example focuses on demonstrating custom content blocks. These blocks also work with Form/Field integration.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Select } from 'frontile';

const fruits = ['Apple', 'Banana', 'Cherry', 'Date'];

export default class CustomContentBlocksSelect extends Component {
  @tracked selectedKey: string | null = null;

  onSelectionChange = (key: string | null) => {
    this.selectedKey = key;
  };

  <template>
    <Select
      @isFilterable={{true}}
      @placeholder='Search fruits...'
      @items={{fruits}}
      @selectedKey={{this.selectedKey}}
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
    <p>Selected: {{this.selectedKey}}</p>
  </template>
}
```

### Using NativeSelect

The `NativeSelect` component is a lightweight version of the select component that renders a native HTML `<select>` element. This is especially useful when you need maximum accessibility or want to rely on the browser’s native behavior.
It supports most of the same features as the custom `Select` component, such as passing an array of items, managing selection state, and handling selection changes.
By using `NativeSelect` directly, you can simplify your markup while still benefiting from Frontile’s APIs.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { NativeSelect } from 'frontile';

const options = ['Option 1', 'Option 2', 'Option 3'];

export default class NativeSelectExample extends Component {
  @tracked selectedKey: string | null = null;

  onSelectionChange = (key: string | null) => {
    this.selectedKey = key;
  };

  <template>
    <NativeSelect
      @placeholder='Select an option'
      @items={{options}}
      @selectedKey={{this.selectedKey}}
      @onSelectionChange={{this.onSelectionChange}}
    />
    <p class='mt-4'>Selected: {{this.selectedKey}}</p>
  </template>
}
```

## API

<Signature @component="Select" />
<Signature @component="SelectItem" />
<Signature @component="NativeSelect" />
<Signature @component="NativeSelectItem" />
