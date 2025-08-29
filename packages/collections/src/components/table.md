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
    <div>
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
    <div>
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
    <div>
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
    <div>
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
    <div class='space-y-4'>
      <div>
        <h4 class='font-medium mb-2'>Striped rows</h4>
        <Table
          @columns={{this.columns}}
          @items={{this.items}}
          @isStriped={{true}}
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
    <div>
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

## Scrollable Tables

For large datasets, enable scrolling with container-based sizing:

```gts preview
import Component from '@glimmer/component';
import { Table, type ColumnDefinition } from '@frontile/collections';
import { hash } from '@ember/helper';

interface User {
  id: string;
  name: string;
  email: string;
  department: string;
  role: string;
}

export default class DemoComponent extends Component {
  columns: ColumnDefinition<User>[] = [
    { key: 'id', label: 'ID' },
    { key: 'name', label: 'Name' },
    { key: 'email', label: 'Email' },
    { key: 'department', label: 'Department' },
    { key: 'role', label: 'Role' }
  ];

  items: User[] = [
    { id: '1', name: 'John Doe', email: 'john@example.com', department: 'Engineering', role: 'Senior Developer' },
    { id: '2', name: 'Jane Smith', email: 'jane@example.com', department: 'Design', role: 'UI/UX Designer' },
    { id: '3', name: 'Bob Johnson', email: 'bob@example.com', department: 'Product', role: 'Product Manager' },
    { id: '4', name: 'Alice Brown', email: 'alice@example.com', department: 'Engineering', role: 'Tech Lead' },
    { id: '5', name: 'Charlie Wilson', email: 'charlie@example.com', department: 'Marketing', role: 'Marketing Manager' }
  ];

  <template>
    <div class='space-y-4'>
      <div>
        <h4 class='font-medium mb-2'>Vertically scrollable table</h4>
        <Table
          @columns={{this.columns}}
          @items={{this.items}}
          @isScrollable={{true}}
          @classes={{hash wrapper="h-48"}}
        />
      </div>

      <div>
        <h4 class='font-medium mb-2'>Horizontally scrollable table</h4>
        <Table
          @columns={{this.columns}}
          @items={{this.items}}
          @isScrollable={{true}}
          @classes={{hash wrapper="max-w-sm"}}
        />
      </div>
    </div>
  </template>
}
```

## Frozen Columns and Rows

Freeze columns or rows to keep them visible during scrolling, perfect for large datasets where certain information should remain in view.

### Frozen Columns

Freeze columns to keep them visible during horizontal scrolling:

```gts preview
import Component from '@glimmer/component';
import { Table } from '@frontile/collections';
import { hash } from '@ember/helper';

export default class DemoComponent extends Component {
  items = [
    { 
      id: '001', 
      name: 'John Doe', 
      email: 'john.doe@company.com', 
      phone: '+1-555-0123',
      department: 'Engineering', 
      role: 'Senior Developer',
      location: 'San Francisco, CA',
      manager: 'Alice Brown'
    },
    { 
      id: '002', 
      name: 'Jane Smith', 
      email: 'jane.smith@company.com', 
      phone: '+1-555-0124',
      department: 'Design', 
      role: 'UI/UX Designer',
      location: 'New York, NY',
      manager: 'Bob Wilson'
    },
    { 
      id: '003', 
      name: 'Bob Johnson', 
      email: 'bob.johnson@company.com', 
      phone: '+1-555-0125',
      department: 'Product', 
      role: 'Product Manager',
      location: 'Austin, TX',
      manager: 'Carol Davis'
    }
  ];

  <template>
    <div>
      <h4 class='font-medium mb-2'>Frozen Employee ID (left) and Actions (right) columns</h4>
      <Table @isScrollable={{true}} @classes={{hash wrapper="max-w-2xl"}} as |t|>
        <t.Header>
          <t.Column @isFrozen={{true}} @frozenPosition="left">Employee ID</t.Column>
          <t.Column>Full Name</t.Column>
          <t.Column>Email Address</t.Column>
          <t.Column>Phone Number</t.Column>
          <t.Column>Department</t.Column>
          <t.Column>Job Title</t.Column>
          <t.Column>Office Location</t.Column>
          <t.Column>Manager</t.Column>
          <t.Column @isFrozen={{true}} @frozenPosition="right">Actions</t.Column>
        </t.Header>
        <t.Body>
          {{#each this.items as |item|}}
            <t.Row @item={{item}}>
              <t.Cell @isFrozen={{true}} @frozenPosition="left">{{item.id}}</t.Cell>
              <t.Cell>{{item.name}}</t.Cell>
              <t.Cell>{{item.email}}</t.Cell>
              <t.Cell>{{item.phone}}</t.Cell>
              <t.Cell>{{item.department}}</t.Cell>
              <t.Cell>{{item.role}}</t.Cell>
              <t.Cell>{{item.location}}</t.Cell>
              <t.Cell>{{item.manager}}</t.Cell>
              <t.Cell @isFrozen={{true}} @frozenPosition="right">
                <button type="button" class="text-primary hover:underline mr-2">Edit</button>
                <button type="button" class="text-danger hover:underline">Delete</button>
              </t.Cell>
            </t.Row>
          {{/each}}
        </t.Body>
      </Table>
    </div>
  </template>
}
```

### Frozen Header

Keep the table header visible when scrolling through long data:

```gts preview
import Component from '@glimmer/component';
import { Table, type ColumnDefinition } from '@frontile/collections';
import { hash } from '@ember/helper';

interface User {
  id: string;
  name: string;
  email: string;
  department: string;
}

export default class DemoComponent extends Component {
  columns: ColumnDefinition<User>[] = [
    { key: 'id', label: 'ID' },
    { key: 'name', label: 'Name' },
    { key: 'email', label: 'Email' },
    { key: 'department', label: 'Department' }
  ];

  items: User[] = [
    { id: '1', name: 'John Doe', email: 'john@example.com', department: 'Engineering' },
    { id: '2', name: 'Jane Smith', email: 'jane@example.com', department: 'Design' },
    { id: '3', name: 'Bob Johnson', email: 'bob@example.com', department: 'Product' },
    { id: '4', name: 'Alice Brown', email: 'alice@example.com', department: 'Engineering' },
    { id: '5', name: 'Charlie Wilson', email: 'charlie@example.com', department: 'Marketing' },
    { id: '6', name: 'Diana Lee', email: 'diana@example.com', department: 'Sales' },
    { id: '7', name: 'Frank Miller', email: 'frank@example.com', department: 'Support' },
    { id: '8', name: 'Grace Chen', email: 'grace@example.com', department: 'Engineering' }
  ];

  <template>
    <div>
      <h4 class='font-medium mb-2'>Frozen header - scroll to see header stay in place</h4>
      <Table
        @columns={{this.columns}}
        @items={{this.items}}
        @isFrozenHeader={{true}}
        @isScrollable={{true}}
        @classes={{hash wrapper="h-48"}}
      />
    </div>
  </template>
}
```

### Frozen Rows

Freeze specific rows by their keys to keep important data visible:

```gts preview
import Component from '@glimmer/component';
import { Table, type ColumnDefinition } from '@frontile/collections';
import { array, hash } from '@ember/helper';

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
    { id: 'admin', name: 'Admin User', email: 'admin@example.com', role: 'Administrator' },
    { id: '1', name: 'John Doe', email: 'john@example.com', role: 'Developer' },
    { id: '2', name: 'Jane Smith', email: 'jane@example.com', role: 'Designer' },
    { id: '3', name: 'Bob Johnson', email: 'bob@example.com', role: 'Product Manager' },
    { id: '4', name: 'Alice Brown', email: 'alice@example.com', role: 'Tech Lead' },
    { id: 'guest', name: 'Guest User', email: 'guest@example.com', role: 'Read-only' }
  ];

  <template>
    <div>
      <h4 class='font-medium mb-2'>Frozen rows - Admin and Guest users stay visible</h4>
      <Table
        @columns={{this.columns}}
        @items={{this.items}}
        @frozenKeys={{array "admin" "guest"}}
        @isScrollable={{true}}
        @classes={{hash wrapper="h-48"}}
      />
    </div>
  </template>
}
```

### Combined Frozen Elements

Combine multiple frozen features for complex layouts:

```gts preview
import Component from '@glimmer/component';
import { Table, type ColumnDefinition } from '@frontile/collections';
import { array, hash } from '@ember/helper';

interface Employee {
  id: string;
  name: string;
  email: string;
  phone: string;
  department: string;
  role: string;
  location: string;
  manager: string;
  startDate: string;
  experience: number;
  salary: number;
  benefits: string;
  status: string;
}

export default class DemoComponent extends Component {
  columns: ColumnDefinition<Employee>[] = [
    { 
      key: 'id', 
      label: 'Employee ID', 
      isFrozen: true, 
      frozenPosition: 'left' 
    },
    { key: 'name', label: 'Full Name' },
    { key: 'email', label: 'Email Address' },
    { key: 'phone', label: 'Phone Number' },
    { key: 'department', label: 'Department' },
    { key: 'role', label: 'Job Title' },
    { key: 'location', label: 'Office Location' },
    { key: 'manager', label: 'Direct Manager' },
    { key: 'startDate', label: 'Start Date' },
    { key: 'experience', label: 'Years Experience' },
    { 
      key: 'salary', 
      label: 'Annual Salary',
      accessorFn: (item) => `$${item.salary.toLocaleString()}`
    },
    { key: 'benefits', label: 'Benefits Package' },
    { key: 'status', label: 'Employment Status' },
    { 
      key: 'actions', 
      label: 'Actions', 
      isFrozen: true, 
      frozenPosition: 'right',
      accessorFn: () => 'Edit'
    }
  ];

  items: Employee[] = [
    { 
      id: 'CEO001', 
      name: 'Sarah Johnson', 
      email: 'sarah.johnson@company.com', 
      phone: '+1-555-0001',
      department: 'Executive', 
      role: 'Chief Executive Officer', 
      location: 'New York, NY',
      manager: 'Board of Directors',
      startDate: '2018-01-15',
      experience: 15,
      salary: 250000,
      benefits: 'Executive Package',
      status: 'Full-time'
    },
    { 
      id: 'ENG001', 
      name: 'John Doe', 
      email: 'john.doe@company.com', 
      phone: '+1-555-0101',
      department: 'Engineering', 
      role: 'Senior Developer',
      location: 'San Francisco, CA',
      manager: 'Jane Smith',
      startDate: '2020-03-15',
      experience: 8,
      salary: 95000,
      benefits: 'Standard Plus',
      status: 'Full-time'
    },
    { 
      id: 'ENG002', 
      name: 'Jane Smith', 
      email: 'jane.smith@company.com', 
      phone: '+1-555-0102',
      department: 'Engineering', 
      role: 'Tech Lead',
      location: 'San Francisco, CA',
      manager: 'Sarah Johnson',
      startDate: '2019-07-20',
      experience: 10,
      salary: 120000,
      benefits: 'Standard Plus',
      status: 'Full-time'
    },
    { 
      id: 'DES001', 
      name: 'Bob Johnson', 
      email: 'bob.johnson@company.com', 
      phone: '+1-555-0201',
      department: 'Design', 
      role: 'UI/UX Designer',
      location: 'Austin, TX',
      manager: 'Alice Brown',
      startDate: '2021-11-08',
      experience: 5,
      salary: 85000,
      benefits: 'Standard',
      status: 'Full-time'
    },
    { 
      id: 'PRD001', 
      name: 'Alice Brown', 
      email: 'alice.brown@company.com', 
      phone: '+1-555-0301',
      department: 'Product', 
      role: 'Product Manager',
      location: 'Seattle, WA',
      manager: 'Sarah Johnson',
      startDate: '2020-09-12',
      experience: 7,
      salary: 100000,
      benefits: 'Standard Plus',
      status: 'Full-time'
    },
    { 
      id: 'MKT001', 
      name: 'Charlie Wilson', 
      email: 'charlie.wilson@company.com', 
      phone: '+1-555-0401',
      department: 'Marketing', 
      role: 'Marketing Manager',
      location: 'Chicago, IL',
      manager: 'Sarah Johnson',
      startDate: '2021-02-28',
      experience: 6,
      salary: 90000,
      benefits: 'Standard',
      status: 'Full-time'
    },
    { 
      id: 'INT001', 
      name: 'Diana Lee', 
      email: 'diana.lee@company.com', 
      phone: '+1-555-0501',
      department: 'Engineering', 
      role: 'Intern',
      location: 'San Francisco, CA',
      manager: 'John Doe',
      startDate: '2024-06-01',
      experience: 0,
      salary: 50000,
      benefits: 'Intern Package',
      status: 'Intern'
    }
  ];

  <template>
    <div>
      <h4 class='font-medium mb-2'>Combined: Frozen header, columns (ID & Actions), and rows (CEO & Intern)</h4>
      <Table
        @columns={{this.columns}}
        @items={{this.items}}
        @isFrozenHeader={{true}}
        @frozenKeys={{array "CEO001" "INT001"}}
        @scrollable={{true}}
        @classes={{hash wrapper="h-64 max-w-4xl"}}
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
  /** Whether this column should be frozen/sticky */
  isFrozen?: boolean;
  /** Position where frozen column should stick */
  frozenPosition?: 'left' | 'right';
}
```

**ContentValue** is a standard Glint type for values that are safe to render in templates, which includes: `string | number | boolean | null | undefined | SafeString`.
