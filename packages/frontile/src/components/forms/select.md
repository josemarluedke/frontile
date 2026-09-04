---
imports:
  - import Signature from 'site/components/signature';
---

# Select

The `Select` component is a powerful and flexible dropdown component. It supports both **single** and **multiple** selection modes — multiple selections render as removable chips — provides built‐in filtering capabilities, and renders a hidden native `<select>` element to ensure full accessibility. Under the hood, it leverages the [Listbox](https://frontile.dev/docs/collections/listbox) and [Popover](https://frontile.dev/docs/overlays/popover) components to power its interactive behavior.

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
  <Select @placeholder='Select an option' @items={{options}} />
</template>
```

> **Modern Usage:** For forms with data binding and validation, use the Form and Field components as shown in the examples below. Form/Field provides automatic state management, validation, and error handling without manual `@onChange` handlers.

### Intent Colors

Use `@intent` to color the highlighted and selected options in the dropdown. Open each
Select to see how the active option adopts the intent color. Available intents are
`default`, `primary`, `secondary`, `tertiary`, `success`, `warning`, and `danger`.

```gts preview
import { Select } from 'frontile';

const options = ['Option 1', 'Option 2', 'Option 3'];

<template>
  <div class='grid grid-cols-2 gap-4'>
    <Select @intent='default' @placeholder='Default' @items={{options}} />
    <Select @intent='primary' @placeholder='Primary' @items={{options}} />
    <Select @intent='secondary' @placeholder='Secondary' @items={{options}} />
    <Select @intent='tertiary' @placeholder='Tertiary' @items={{options}} />
    <Select @intent='success' @placeholder='Success' @items={{options}} />
    <Select @intent='warning' @placeholder='Warning' @items={{options}} />
    <Select @intent='danger' @placeholder='Danger' @items={{options}} />
  </div>
</template>
```

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
      <Form
        @data={{this.formData}}
        @onChange={{this.handleFormChange}}
        as |form|
      >
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

The multiple select here is shown in a validation context; see [Multiple Selection](#multiple-selection) for the full reference on chips, removal and the arguments that configure them.

With `blur` in `@validateOn` (or your own `@onBlur`), the Select reports blur only once
focus has left the **whole control** — the field and its dropdown. Clicking an option
moves focus into the dropdown, and in multiple mode leaves it open, so selecting is never
reported as a blur: validation waits until the user is actually done with the field.

In multiple selection mode there is one extra step. The dropdown stays open across
selections, so the click that takes the user away from the field is first spent closing
it — and closing the dropdown returns focus to the trigger. Focus is therefore still
inside the control at that point, and `@onBlur` does not fire; it fires on the next
interaction, once focus genuinely leaves. Blur validation on a multiple Select runs one
interaction later than on a single one.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { array } from '@ember/helper';
import { Form, type FormResultData } from 'frontile';
import { Button } from 'frontile';
import * as v from 'valibot';

const countries = [
  'United States',
  'Canada',
  'Mexico',
  'United Kingdom',
  'Germany',
  'France',
  'Japan',
  'Australia'
];
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
        <div class='p-4 bg-success-subtle border border-success-subtle rounded'>
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
      <Form
        @data={{this.formData}}
        @onChange={{this.handleFormChange}}
        as |form|
      >
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

### Custom Selected Item Content

`<:item>` styles an option **in the dropdown**. To style it once it is **selected**, add a
`<:selectedItem>` block. It yields the same `{ item, key, label }` the `<:item>` block does,
so markup moves between the two without being renamed, and it renders wherever the selection
is drawn as markup: inside the single-mode trigger, inside each chip in multiple mode, and
once per selection under `@selectedItemsDisplay="text"`.

Typically the dropdown row is the rich one — avatar, name and email — while the trigger keeps
a compact version of it.

> **Note:** `selected.item` is your own entry from `@items`. It is `undefined` for options
> written out with `<:default>` block syntax, because there is no collection entry behind
> them; only `key` and `label` are available in that case — so guard on it, as the demo
> below does, before reaching into your own object.

> **Note:** A **filterable** Select's trigger is an `<input>`, which cannot hold markup, so
> the block does not render there: a filterable Select still shows the selection as plain
> text inside the input. The chips beside that input do use the block.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Select } from 'frontile';

export default class CustomSelectedItem extends Component {
  @tracked selectedKey: string | null = 'john-doe';
  @tracked selectedKeys: string[] = ['john-doe', 'jane-smith'];

  onSelectionChange = (key: string | null) => {
    this.selectedKey = key;
  };

  onMultipleSelectionChange = (keys: string[]) => {
    this.selectedKeys = keys;
  };

  <template>
    <Select
      @label='Assignee'
      @placeholder='Select a user'
      @items={{people}}
      @selectedKey={{this.selectedKey}}
      @onSelectionChange={{this.onSelectionChange}}
    >
      <:item as |o|>
        <o.Item>
          <div class='flex items-center space-x-4'>
            <img
              src='{{o.item.avatar}}'
              alt=''
              class='w-10 h-10 rounded-full'
            />
            <div>
              <div class='font-medium text-neutral-strong'>{{o.item.name}}</div>
              <div class='text-sm text-neutral-soft'>{{o.item.email}}</div>
            </div>
          </div>
        </o.Item>
      </:item>
      <:selectedItem as |selected|>
        <span class='flex items-center space-x-2'>
          {{#if selected.item}}
            <img
              src='{{selected.item.avatar}}'
              alt=''
              class='w-5 h-5 rounded-full'
            />
          {{/if}}
          <span>{{selected.label}}</span>
        </span>
      </:selectedItem>
    </Select>

    <Select
      @label='Reviewers'
      @selectionMode='multiple'
      @allowEmpty={{true}}
      @placeholder='Select reviewers'
      @items={{people}}
      @selectedKeys={{this.selectedKeys}}
      @onSelectionChange={{this.onMultipleSelectionChange}}
      class='mt-6'
    >
      <:item as |o|>
        <o.Item>
          <div class='flex items-center space-x-4'>
            <img
              src='{{o.item.avatar}}'
              alt=''
              class='w-10 h-10 rounded-full'
            />
            <div>
              <div class='font-medium text-neutral-strong'>{{o.item.name}}</div>
              <div class='text-sm text-neutral-soft'>{{o.item.email}}</div>
            </div>
          </div>
        </o.Item>
      </:item>
      <:selectedItem as |selected|>
        <span class='flex items-center space-x-1'>
          {{#if selected.item}}
            <img
              src='{{selected.item.avatar}}'
              alt=''
              class='w-4 h-4 rounded-full'
            />
          {{/if}}
          <span>{{selected.label}}</span>
        </span>
      </:selectedItem>
    </Select>
  </template>
}

const people = [
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
  }
];
```

In multiple mode the chip chrome is kept around your content — the appearance, `@chip`
options and the close button are still the Select's, so removal, `@allowEmpty` and the
`Backspace` keyboard path keep working unchanged.

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

It deliberately overrides `@allowEmpty`: that argument governs deselecting an *option*,
while `@isClearable` is a separate affordance you add for exactly the purpose of emptying
the field, and it would be dead in every default configuration otherwise (`@allowEmpty`
defaults to `false`). No clear button renders on a disabled Select, or with nothing
selected.

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
        <div class='p-2 text-center text-neutral'>
          No fruits found.
        </div>
      </:emptyContent>
    </Select>
    <p>Selected: {{this.selectedKey}}</p>
  </template>
}
```

### Using NativeSelect

When you want the browser's own picker instead of this custom listbox — the native dropdown on mobile, the OS list box on desktop — use [NativeSelect](./native-select). It renders a real `<select>` and takes the same `@items`, `@selectedKey` and `@onSelectionChange` arguments.

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
      @allowEmpty={{true}}
      @placeholder='Select an option'
      @items={{options}}
      @selectedKey={{this.selectedKey}}
      @onSelectionChange={{this.onSelectionChange}}
    />
    <p class='mt-4'>Selected: {{this.selectedKey}}</p>
  </template>
}
```

## Multiple Selection

Set `@selectionMode='multiple'` to let the user pick more than one option. The selection is
an array: pass it as `@selectedKeys`, and `@onSelectionChange` hands you the new array back.

Every selection renders as a removable [Chip](../buttons/chip) beside the trigger — that is the
default, with no extra configuration. Use `@selectedItemsDisplay='text'` to opt back out to a
comma-joined string.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Select } from 'frontile';

const languages = [
  { key: 'en', label: 'English' },
  { key: 'pt', label: 'Portuguese' },
  { key: 'es', label: 'Spanish' },
  { key: 'de', label: 'German' },
  { key: 'ja', label: 'Japanese' }
];

export default class BasicMultipleSelect extends Component {
  @tracked selectedKeys: string[] = ['en', 'pt'];

  onSelectionChange = (keys: string[]) => {
    this.selectedKeys = keys;
  };

  <template>
    <Select
      @selectionMode='multiple'
      @label='Languages'
      @placeholder='Select languages'
      @items={{languages}}
      @selectedKeys={{this.selectedKeys}}
      @onSelectionChange={{this.onSelectionChange}}
    />
    <p class='mt-4'>Selected: {{this.selectedKeys}}</p>
  </template>
}
```

Chips render in item order rather than click order, so they do not reorder underneath the
user as the selection grows.

Clicking anywhere in the field opens the dropdown, including a chip's own body — with a
single selection the trigger next to the chips can be a narrow sliver, so the whole field is a
click target. The one exception is a chip's close button, which removes that chip instead.

### Removing Selections

Each chip carries its own close button. `@allowEmpty` defaults to `false`, which means the
last remaining selection cannot be removed — its chip renders with **no close button at all**
rather than a dead one. Set `@allowEmpty={{true}}` to allow emptying the selection one chip
at a time.

`@isClearable` adds a clear button to the field that removes everything at once. It
deliberately ignores `@allowEmpty`, so a clearable Select can always be emptied even though
its last chip has no close button.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Select } from 'frontile';

const toppings = ['Basil', 'Mushroom', 'Olive', 'Onion', 'Pepper'];

export default class RemovableChipsSelect extends Component {
  @tracked required: string[] = ['Basil', 'Olive'];
  @tracked optional: string[] = ['Basil', 'Olive'];

  onRequiredChange = (keys: string[]) => {
    this.required = keys;
  };

  onOptionalChange = (keys: string[]) => {
    this.optional = keys;
  };

  <template>
    <div class='grid gap-4 md:grid-cols-2'>
      <Select
        @selectionMode='multiple'
        @label='At least one topping'
        @placeholder='Select toppings'
        @items={{toppings}}
        @selectedKeys={{this.required}}
        @onSelectionChange={{this.onRequiredChange}}
      />
      <Select
        @selectionMode='multiple'
        @label='Any number of toppings'
        @placeholder='Select toppings'
        @items={{toppings}}
        @selectedKeys={{this.optional}}
        @onSelectionChange={{this.onOptionalChange}}
        @allowEmpty={{true}}
        @isClearable={{true}}
      />
    </div>
  </template>
}
```

### Customizing the Chips

`@chip` forwards appearance options to every chip: `appearance` (defaults to `faded`),
`intent`, `size` (defaults to `sm`), `radius` and `withDot`.

`@chip.intent` defaults to the Select's own `@intent`, so `@intent='primary'` colors the
listbox options and the chips together and you only set `@chip.intent` when you want them to
differ.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { hash } from '@ember/helper';
import { Select } from 'frontile';

const tags = ['Accessibility', 'Design', 'Performance', 'Testing'];

export default class ChipOptionsSelect extends Component {
  @tracked inherited: string[] = ['Design', 'Testing'];
  @tracked customized: string[] = ['Design', 'Testing'];

  onInheritedChange = (keys: string[]) => {
    this.inherited = keys;
  };

  onCustomizedChange = (keys: string[]) => {
    this.customized = keys;
  };

  <template>
    <div class='grid gap-4 md:grid-cols-2'>
      <Select
        @selectionMode='multiple'
        @intent='primary'
        @label='Inherits @intent'
        @placeholder='Select tags'
        @items={{tags}}
        @selectedKeys={{this.inherited}}
        @onSelectionChange={{this.onInheritedChange}}
      />
      <Select
        @selectionMode='multiple'
        @label='Custom @chip'
        @placeholder='Select tags'
        @items={{tags}}
        @selectedKeys={{this.customized}}
        @onSelectionChange={{this.onCustomizedChange}}
        @chip={{hash
          appearance='outlined'
          intent='success'
          size='md'
          radius='full'
          withDot=true
        }}
      />
    </div>
  </template>
}
```

### Text Display

`@selectedItemsDisplay='text'` renders the selection as a comma-joined string inside the
trigger instead of as chips. This was the only presentation before `0.18`, and it is worth
keeping for a dense field where a growing stack of chips would push the layout around.
Nothing is individually removable in this mode — use `@isClearable` or reopen the dropdown.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Select } from 'frontile';

const permissions = ['Read', 'Write', 'Deploy', 'Administer'];

export default class TextDisplayMultipleSelect extends Component {
  @tracked selectedKeys: string[] = ['Read', 'Write'];

  onSelectionChange = (keys: string[]) => {
    this.selectedKeys = keys;
  };

  <template>
    <Select
      @selectionMode='multiple'
      @selectedItemsDisplay='text'
      @label='Permissions'
      @placeholder='Select permissions'
      @items={{permissions}}
      @selectedKeys={{this.selectedKeys}}
      @onSelectionChange={{this.onSelectionChange}}
    />
  </template>
}
```

### Filterable Multiple Selection

`@isFilterable={{true}}` turns the trigger into a text input that sits alongside the chips,
the familiar tag-input shape. The filter never echoes the selection, so there is always room
to type, and the chips reflect the selection rather than the filter — a chip stays put even
when its option is filtered out of the list.

Pressing `Backspace` while the filter is empty removes the last chip. With text in the
filter, `Backspace` edits the text as usual, and the final chip is still protected by
`@allowEmpty`.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Select } from 'frontile';

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

export default class FilterableMultipleSelect extends Component {
  @tracked selectedKeys: string[] = ['Brazil', 'Japan'];

  onSelectionChange = (keys: string[]) => {
    this.selectedKeys = keys;
  };

  <template>
    <Select
      @selectionMode='multiple'
      @isFilterable={{true}}
      @allowEmpty={{true}}
      @label='Countries'
      @placeholder='Search countries'
      @items={{countries}}
      @selectedKeys={{this.selectedKeys}}
      @onSelectionChange={{this.onSelectionChange}}
    />
  </template>
}
```

### Styling the Chips Area

Three `@classes` keys cover the chips: `chipsField` is the field shell that wraps the chips
and the trigger together, `chipsContainer` is the flex row holding the chips, and `chip` is
merged onto every individual chip.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { hash } from '@ember/helper';
import { Select } from 'frontile';

const teams = ['Design', 'Engineering', 'Marketing', 'Support'];

export default class StyledChipsSelect extends Component {
  @tracked selectedKeys: string[] = ['Design', 'Engineering'];

  onSelectionChange = (keys: string[]) => {
    this.selectedKeys = keys;
  };

  <template>
    <Select
      @selectionMode='multiple'
      @label='Teams'
      @placeholder='Select teams'
      @items={{teams}}
      @selectedKeys={{this.selectedKeys}}
      @onSelectionChange={{this.onSelectionChange}}
      @allowEmpty={{true}}
      @classes={{hash
        chipsField='border-primary-soft'
        chipsContainer='gap-2'
        chip='bg-primary-subtle text-primary-strong'
      }}
    />
  </template>
}
```

## Accessibility

Select is a custom listbox, not a native `<select>`, so its semantics are assembled from
several pieces:

| Element    | What it exposes                                                                                                                                                                                                                    |
| ---------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Trigger    | `aria-haspopup="true"`, `aria-controls` pointing at the dropdown, and `aria-expanded` kept in sync — supplied by Popover's `trigger` modifier                                                                                      |
| Dropdown   | `role="listbox"`, plus `aria-multiselectable="true"` when `@selectionMode="multiple"`                                                                                                                                              |
| Options    | `role="option"` with `aria-labelledby`, `aria-selected` reflecting selection, and `aria-disabled="true"` on disabled keys                                                                                                          |
| Form value | A visually hidden native `<select>` mirrors the options, so `@name` submits normally                                                                                                                                               |
| Chips      | Each chip's close button is named `Remove <label>` with visually hidden text, so the buttons are announced distinctly. The chips sit beside the trigger rather than inside it, so no interactive element is nested in the combobox. The close buttons carry `tabindex="-1"` — see the keyboard model below |
| `<:selectedItem>` | Supplying the block gives the **button** trigger an explicit `aria-label` composed from the field label and the option's text — see below |

Keyboard handling comes from the listbox:

| Key                                   | Behavior                    |
| ------------------------------------- | --------------------------- |
| `ArrowDown` / `ArrowUp`               | Move between options        |
| `Home` / `PageUp`, `End` / `PageDown` | Jump to first / last option |
| `Enter`, `Space`                      | Select the active option    |
| `Escape`                              | Closes the dropdown         |

### The chips keyboard model

Chip close buttons are **pointer affordances**: they are set to `tabindex="-1"` and are not
tab stops. This is deliberate. A field holding five selections would otherwise put five Tab
stops in front of the combobox, so a keyboard user Tabbing into the control would land on
"Remove ..." rather than on the field itself.

Keyboard removal is on the field instead, in **both** modes:

| Context                                 | Key                    | Behavior                                       |
| --------------------------------------- | ---------------------- | ---------------------------------------------- |
| Chips, `@isFilterable={{true}}`         | `Backspace`            | Removes the last chip **when the filter is empty**; with text in the filter it edits the text as usual |
| Chips, non-filterable (button trigger)  | `Backspace` or `Delete`| Removes the last chip                          |
| Either                                  | `Enter` / `Space` on an option | Toggles that selection off from the dropdown |

The `@allowEmpty` rule applies throughout: with the default `@allowEmpty={{false}}` the final
selection cannot be removed, so its chip renders without a close button and `Backspace` leaves
it alone.

If you set `@chip` or restyle the chips, do not re-enable the close buttons as tab stops
without also removing this keyboard path — a visual order that disagrees with focus order is
its own WCAG 2.4.3 problem.

### Naming the trigger with `<:selectedItem>`

Left alone, the single-mode trigger takes its accessible name from its own text — the selected
label, or the placeholder. A `<:selectedItem>` block owns that text and may render nothing
readable at all (an avatar, an icon), which would leave the combobox announced as an unnamed
button.

So whenever the block is supplied, the **button** trigger carries an explicit `aria-label`
composed from two halves: the field label (falling back to `@placeholder`) and the selected
options' own text — `Assignee, John Doe` for the example above. Either half on its own is used
alone when the other is missing, so the name is never `Assignee, ` and never prefixes the
selection with the untranslatable `Select options`.

**This name replaces whatever your block renders, so keep the two in agreement.** If your
block's visible text is the option's `label`, they already agree and there is nothing to do —
hiding decorative images from assistive technology (`alt=''`) is enough. If your block shows
something *else* — an email address, an abbreviation, an initial — then the announced name and
the visible text disagree, which fails WCAG 2.5.3 *Label in Name* and leaves speech-input
users unable to say what they see. In that case, render the option's `label` somewhere in the
block, or set `@label` / `@placeholder` to the wording that is actually visible.

> **Note:** `aria-label` passed to `<Select>` itself does **not** override this. Attributes on
> `<Select>` land on the field's wrapper element, not on the combobox, so the composed name is
> what the trigger announces either way. The block's own text is the lever you have.

A **filterable** Select is not affected at all: its trigger is an `<input>` whose value is the
selection as text, so it is already named by that value and gets no `aria-label` — one that
duplicated the value would also change as the user typed.

Chips mode is unaffected: the trigger there is already named by `aria-label`, and the chips
are its siblings, so they are read on their own. Chip close buttons keep taking their
`Remove <label>` text from the option, never from your block, so a purely graphical chip is
still removable by name.

## API

<Signature @component="Select" />
<Signature @component="ListboxItem" />
