---
label: Table
imports:
  - import Signature from 'site/components/signature';
---

# Table

Tables display data in rows and columns, providing an organized way to present structured information. The Table component supports both automatic rendering from data arrays and manual composition for fine-grained control.

## Import

```js
import {
  Table,
  type ColumnDefinition
} from '@frontile/collections';
```

## Usage

The Table component can automatically render data using column definitions and items, making it simple to display structured data.

### Automatic Rendering

```gts preview
import Component from '@glimmer/component';
import { Table, type ColumnDefinition } from '@frontile/collections';

interface User {
  id: string;
  name: string;
  email: string;
  role: string;
}

export default class DemoComponent extends Component {
  columns: ColumnDefinition<User>[] = [
    { key: 'id', label: 'ID' },
    { key: 'name', label: 'Name' },
    { key: 'email', label: 'Email' },
    { key: 'role', label: 'Role' }
  ];

  items: User[] = [
    { id: '1', name: 'John Doe', email: 'john@example.com', role: 'admin' },
    { id: '2', name: 'Jane Smith', email: 'jane@example.com', role: 'user' }
  ];

  <template>
    <div class='not-prose'>
      <Table @columns={{this.columns}} @items={{this.items}} />
    </div>
  </template>
}
```

### Manual Composition

For more control over rendering, you can manually compose the table structure:

```gts preview
import Component from '@glimmer/component';
import { Table } from '@frontile/collections';

export default class DemoComponent extends Component {
  items = [
    { id: '1', name: 'John Doe', email: 'john@example.com', role: 'admin' },
    { id: '2', name: 'Jane Smith', email: 'jane@example.com', role: 'user' }
  ];

  <template>
    <div class='not-prose'>
      <Table as |t|>
        <t.Header>
          <t.Column>Name</t.Column>
          <t.Column>Email</t.Column>
          <t.Column>Actions</t.Column>
        </t.Header>
        <t.Body>
          {{#each this.items as |item|}}
            <t.Row @item={{item}}>
              <t.Cell>{{item.name}}</t.Cell>
              <t.Cell>{{item.email}}</t.Cell>
              <t.Cell>
                <button
                  type='button'
                  class='text-primary hover:underline'
                >Edit</button>
              </t.Cell>
            </t.Row>
          {{/each}}
        </t.Body>
      </Table>
    </div>
  </template>
}
```

## Custom Accessor Functions

Use `accessorFn` to transform data or compute values dynamically for each column:

```gts preview
import Component from '@glimmer/component';
import { Table, type ColumnDefinition } from '@frontile/collections';

interface User {
  id: string;
  name: string;
  email: string;
  role: string;
}

export default class DemoComponent extends Component {
  columns: ColumnDefinition<User>[] = [
    { key: 'id', label: 'ID' },
    {
      key: 'name',
      label: 'Display Name',
      accessorFn: (user) => `${user.name} (${user.role})`
    },
    {
      key: 'email',
      label: 'Contact',
      accessorFn: (user) => user.email.toUpperCase()
    },
    {
      key: 'status',
      label: 'Admin Status',
      accessorFn: (user) => (user.role === 'admin' ? 'Yes' : 'No')
    }
  ];

  items: User[] = [
    { id: '1', name: 'John Doe', email: 'john@example.com', role: 'admin' },
    { id: '2', name: 'Jane Smith', email: 'jane@example.com', role: 'user' }
  ];

  <template>
    <div class='not-prose'>
      <Table @columns={{this.columns}} @items={{this.items}} />
    </div>
  </template>
}
```

## Empty State

The table gracefully handles empty data by displaying headers without rows:

```gts preview
import Component from '@glimmer/component';
import { Table, type ColumnDefinition } from '@frontile/collections';

export default class DemoComponent extends Component {
  columns: ColumnDefinition[] = [
    { key: 'id', label: 'ID' },
    { key: 'name', label: 'Name' },
    { key: 'email', label: 'Email' }
  ];

  emptyItems = [];

  <template>
    <div class='not-prose'>
      <Table
        @columns={{this.columns}}
        @items={{this.emptyItems}}
        @emptyContent='No data to display'
      />
    </div>
  </template>
}
```

## Type Safety

The Table component provides full TypeScript support with generic types:

```ts
// Define your data interface
interface Product {
  id: number;
  name: string;
  price: number;
  category: string;
}

// Use typed column definitions
const columns: ColumnDefinition<Product>[] = [
  { key: 'name', label: 'Product Name' },
  {
    key: 'price',
    label: 'Price',
    // accessorFn receives typed Product parameter
    accessorFn: (product) => `$${product.price.toFixed(2)}`
  }
];
```

## Styling

The Table component supports various styling options through the `classes` argument and built-in variants for different table appearances.

### Styling Variants

```gts preview
import Component from '@glimmer/component';
import { Table, type ColumnDefinition } from '@frontile/collections';

interface User {
  id: string;
  name: string;
  email: string;
}

export default class DemoComponent extends Component {
  columns: ColumnDefinition<User>[] = [
    { key: 'id', label: 'ID' },
    { key: 'name', label: 'Name' },
    { key: 'email', label: 'Email' }
  ];

  items: User[] = [
    { id: '1', name: 'John Doe', email: 'john@example.com' },
    { id: '2', name: 'Jane Smith', email: 'jane@example.com' },
    { id: '3', name: 'Bob Johnson', email: 'bob@example.com' }
  ];

  <template>
    <div class='not-prose space-y-4'>
      <div>
        <h4 class='font-medium mb-2'>Striped rows</h4>
        <Table
          @columns={{this.columns}}
          @items={{this.items}}
          @striped={{true}}
        />
      </div>

      <div>
        <h4 class='font-medium mb-2'>Small/Compact size</h4>
        <Table @columns={{this.columns}} @items={{this.items}} @size='sm' />
      </div>
    </div>
  </template>
}
```

### Custom Classes

Use the `classes` argument to customize specific table elements:

```gts preview
import Component from '@glimmer/component';
import { Table, type ColumnDefinition } from '@frontile/collections';
import { hash } from '@ember/helper';

interface User {
  id: string;
  name: string;
  email: string;
}

export default class DemoComponent extends Component {
  columns: ColumnDefinition<User>[] = [
    { key: 'id', label: 'ID' },
    { key: 'name', label: 'Name' },
    { key: 'email', label: 'Email' }
  ];

  items: User[] = [
    { id: '1', name: 'John Doe', email: 'john@example.com' },
    { id: '2', name: 'Jane Smith', email: 'jane@example.com' }
  ];

  <template>
    <div class='not-prose'>
      <Table
        @columns={{this.columns}}
        @items={{this.items}}
        @classes={{hash
          wrapper='shadow-lg rounded-xl'
          table='border-separate border-spacing-0'
          th='bg-primary-100 first:rounded-tl-lg last:rounded-tr-lg'
          td='border-t border-default-100'
        }}
      />
    </div>
  </template>
}
```

## API

<Signature @component="Table" />
<Signature @component="TableHeader" />
<Signature @component="TableBody" />
<Signature @component="TableColumn" />
<Signature @component="TableRow" />
<Signature @component="TableCell" />

### ColumnDefinition

```ts
interface ColumnDefinition<T = unknown> {
  /** The key to extract data from items */
  key: string;
  /** Display label for the column header */
  label: string;
  /** Optional function to transform/compute column values */
  accessorFn?: (item: T) => ContentValue;
}
```

**ContentValue** is a standard Glint type for values that are safe to render in templates, which includes: `string | number | boolean | null | undefined | SafeString`.
