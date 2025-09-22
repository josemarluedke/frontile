---
name: New
imports:
  - import Signature from 'site/components/signature';
---

# Table

The Table component provides a powerful and flexible way to display structured data with advanced features like sticky headers, columns, and rows, scrollable containers, and type-safe column definitions. It supports three distinct usage patterns to accommodate different needs from simple data display to fully customized implementations.

**Key Features:**

- **Three usage patterns** - simple, manual, and hybrid approaches
- **Automatic rendering** with type-safe column definitions
- **Sticky elements** - headers, footers, columns, and specific rows
- **Scrollable containers** for large datasets
- **Flexible styling** with size variants and striped rows
- **Manual composition** for complete control over structure
- **Empty state handling** with custom content
- **Table footers** for summaries, totals, and additional information

## Import

```js
import {
  Table,
  TableFooter,
  type ColumnConfig
} from '@frontile/collections';
```

## Usage Patterns

The Table component supports three distinct usage patterns, each optimized for different use cases:

### Pattern 1: Simple/Dynamic Usage

The simplest approach - just pass `@columns` and `@items` for automatic rendering:

```gts preview
import Component from '@glimmer/component';
import { Table, type ColumnConfig } from '@frontile/collections';

interface User {
  id: string;
  name: string;
  email: string;
  role: string;
}

export default class DemoComponent extends Component {
  columns: ColumnConfig<User>[] = [
    { key: 'id', name: 'ID' },
    { key: 'name', name: 'Name' },
    { key: 'email', name: 'Email' },
    { key: 'role', name: 'Role' }
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

### Pattern 2: Manual Composition

Full manual control without `@columns` or `@items` - perfect for custom layouts and complex cell content:

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

### Pattern 3: Hybrid Approach

Combines automatic rendering with manual customization - pass `@columns` and `@items` while customizing specific parts:

#### Pattern 3a: Custom Headers, Automatic Body

```gts preview
import Component from '@glimmer/component';
import { Table, type ColumnConfig } from '@frontile/collections';

interface User {
  id: string;
  name: string;
  email: string;
  role: string;
}

export default class DemoComponent extends Component {
  columns: ColumnConfig<User>[] = [
    { key: 'id', name: 'ID' },
    { key: 'name', name: 'Name' },
    { key: 'email', name: 'Email' }
  ];

  items: User[] = [
    { id: '1', name: 'John Doe', email: 'john@example.com', role: 'admin' },
    { id: '2', name: 'Jane Smith', email: 'jane@example.com', role: 'user' }
  ];

  <template>
    <div>
      <Table @columns={{this.columns}} @items={{this.items}} as |t|>
        <t.Header as |h|>
          {{#each h.columns as |column|}}
            <h.Column @column={{column}}>
              🔸
              {{column.name}}
            </h.Column>
          {{/each}}
        </t.Header>
        <t.Body />
      </Table>
    </div>
  </template>
}
```

#### Pattern 3b: Automatic Headers, Custom Body

```gts preview
import Component from '@glimmer/component';
import { Table, type ColumnConfig } from '@frontile/collections';
import { get } from '@ember/helper';

interface User {
  id: string;
  name: string;
  role: string;
  email: string;
}

export default class DemoComponent extends Component {
  columns: ColumnConfig<User>[] = [
    { key: 'name', name: 'Name' },
    { key: 'role', name: 'Role' }
  ];

  items: User[] = [
    { id: '1', name: 'John Doe', email: 'john@example.com', role: 'admin' },
    { id: '2', name: 'Jane Smith', email: 'jane@example.com', role: 'user' }
  ];

  <template>
    <div>
      <Table @columns={{this.columns}} @items={{this.items}} as |t|>
        <t.Header />
        <t.Body as |b|>
          {{#each b.rows as |row|}}
            <t.Row @row={{row}} as |r|>
              {{#each r.columns as |column|}}
                <t.Cell @row={{row}} @column={{column}}>
                  {{column.getValueForRow row}}
                </t.Cell>
              {{/each}}
            </t.Row>
          {{/each}}
        </t.Body>
      </Table>
    </div>
  </template>
}
```

## Column Configurations

### Custom Value Functions

Use `value` functions to transform data or compute values dynamically for each column:

```gts preview
import Component from '@glimmer/component';
import { Table, type ColumnConfig } from '@frontile/collections';

interface User {
  id: string;
  name: string;
  email: string;
  role: string;
}

export default class DemoComponent extends Component {
  columns: ColumnConfig<User>[] = [
    { key: 'id', name: 'ID' },
    {
      key: 'name',
      name: 'Display Name',
      value: (ctx) => `${ctx.row.data.name} (${ctx.row.data.role})`
    },
    {
      key: 'email',
      name: 'Contact',
      value: (ctx) => ctx.row.data.email.toUpperCase()
    },
    {
      key: 'status',
      name: 'Admin Status',
      value: (ctx) => (ctx.row.data.role === 'admin' ? 'Yes' : 'No')
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

### Type Safety

The Table component provides full TypeScript support with generic types:

```ts
// Define your data interface
interface Product {
  id: number;
  name: string;
  price: number;
  category: string;
}

// Use typed column configurations
const columns: ColumnConfig<Product>[] = [
  { key: 'name', name: 'Product Name' },
  {
    key: 'price',
    name: 'Price',
    // value receives typed CellContext<Product> parameter
    value: (ctx) => `$${ctx.row.data.price.toFixed(2)}`
  }
];
```

## Styling & Layout

### Table Layout

Control how the table calculates column widths using the `@layout` argument:

```gts preview
import Component from '@glimmer/component';
import { Table, type ColumnConfig } from '@frontile/collections';

interface User {
  id: string;
  name: string;
  email: string;
  department: string;
}

export default class DemoComponent extends Component {
  columns: ColumnConfig<User>[] = [
    { key: 'id', name: 'ID' },
    { key: 'name', name: 'Name' },
    { key: 'email', name: 'Email' },
    { key: 'department', name: 'Department' }
  ];

  items: User[] = [
    {
      id: '1',
      name: 'John Doe',
      email: 'john@example.com',
      department: 'Engineering'
    },
    {
      id: '2',
      name: 'Jane Smith',
      email: 'jane@example.com',
      department: 'Design'
    }
  ];

  <template>
    <div class='space-y-4'>
      <div>
        <h4 class='font-medium mb-2'>Auto layout (default) - sizes by content</h4>
        <Table @columns={{this.columns}} @items={{this.items}} @layout='auto' />
      </div>

      <div>
        <h4 class='font-medium mb-2'>Fixed layout - uses first row for sizing</h4>
        <Table
          @columns={{this.columns}}
          @items={{this.items}}
          @layout='fixed'
        />
      </div>
    </div>
  </template>
}
```

- **Auto layout** (`@layout="auto"`) - Columns size based on content (default)
- **Fixed layout** (`@layout="fixed"`) - Faster rendering, uses first row for column widths

### Styling Variants

The Table component supports several styling variants:

- `@size` - Controls spacing: `sm`, `md` (default), `lg`
- `@isStriped` - Enables alternating row background colors
- `@layout` - Column sizing: `auto` (default), `fixed`
- `@classes` - Custom CSS classes for specific elements

```gts preview
import Component from '@glimmer/component';
import { Table, type ColumnConfig } from '@frontile/collections';

interface User {
  id: string;
  name: string;
  email: string;
}

export default class DemoComponent extends Component {
  columns: ColumnConfig<User>[] = [
    { key: 'id', name: 'ID' },
    { key: 'name', name: 'Name' },
    { key: 'email', name: 'Email' }
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
        <h4 class='font-medium mb-2'>Small size - compact spacing</h4>
        <Table @columns={{this.columns}} @items={{this.items}} @size='sm' />
      </div>

      <div>
        <h4 class='font-medium mb-2'>Large size - spacious layout</h4>
        <Table @columns={{this.columns}} @items={{this.items}} @size='lg' />
      </div>
    </div>
  </template>
}
```

### Custom Classes

Use the `classes` argument to customize specific table elements:

```gts preview
import Component from '@glimmer/component';
import { Table, type ColumnConfig } from '@frontile/collections';
import { hash } from '@ember/helper';

interface User {
  id: string;
  name: string;
  email: string;
}

export default class DemoComponent extends Component {
  columns: ColumnConfig<User>[] = [
    { key: 'id', name: 'ID' },
    { key: 'name', name: 'Name' },
    { key: 'email', name: 'Email' }
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

## Table Footers

Table footers provide a way to display summary information, totals, or additional context at the bottom of your table. Footers support both automatic generation from column definitions and manual composition for complete control.

### Automatic Footer with Column Definitions

Use `@footerColumns` to automatically generate a footer with predefined columns:

```gts preview
import Component from '@glimmer/component';
import { Table, type ColumnConfig } from '@frontile/collections';

interface Product {
  id: string;
  name: string;
  price: number;
  category: string;
}

export default class DemoComponent extends Component {
  columns: ColumnConfig<Product>[] = [
    { key: 'name', name: 'Product' },
    { key: 'price', name: 'Price', value: (ctx) => `$${ctx.row.data.price}` },
    { key: 'category', name: 'Category' }
  ];

  footerColumns: ColumnConfig[] = [
    { key: 'total_label', name: 'Total Items' },
    { key: 'total_price', name: '$127.97' },
    { key: 'categories', name: '3 Categories' }
  ];

  items: Product[] = [
    { id: '1', name: 'Laptop', price: 99.99, category: 'Electronics' },
    { id: '2', name: 'Coffee Mug', price: 12.99, category: 'Kitchen' },
    { id: '3', name: 'Notebook', price: 4.99, category: 'Office' },
    { id: '4', name: 'Wireless Mouse', price: 9.99, category: 'Electronics' }
  ];

  <template>
    <div>
      <Table
        @columns={{this.columns}}
        @items={{this.items}}
        @footerColumns={{this.footerColumns}}
      />
    </div>
  </template>
}
```

### Manual Footer Composition

For complete control over footer content, use the block form with the Footer component:

```gts preview
import Component from '@glimmer/component';
import { Table } from '@frontile/collections';

export default class DemoComponent extends Component {
  items = [
    { id: '1', product: 'Laptop', price: 999.99, qty: 1 },
    { id: '2', product: 'Mouse', price: 29.99, qty: 2 },
    { id: '3', product: 'Keyboard', price: 79.99, qty: 1 }
  ];

  get totalAmount() {
    return this.items.reduce((sum, item) => sum + item.price * item.qty, 0);
  }

  get totalItems() {
    return this.items.reduce((sum, item) => sum + item.qty, 0);
  }

  calculateTotal = (price, qty) => (price * qty).toFixed(2);

  <template>
    <div>
      <Table as |t|>
        <t.Header>
          <t.Column>Product</t.Column>
          <t.Column>Price</t.Column>
          <t.Column>Quantity</t.Column>
          <t.Column>Total</t.Column>
        </t.Header>
        <t.Body>
          {{#each this.items as |item|}}
            <t.Row @item={{item}}>
              <t.Cell>{{item.product}}</t.Cell>
              <t.Cell>${{item.price}}</t.Cell>
              <t.Cell>{{item.qty}}</t.Cell>
              <t.Cell>${{this.calculateTotal item.price item.qty}}</t.Cell>
            </t.Row>
          {{/each}}
        </t.Body>
        <t.Footer>
          <t.Column colspan='2'>Order Summary</t.Column>
          <t.Column>{{this.totalItems}} items</t.Column>
          <t.Column>${{this.totalAmount}}</t.Column>
        </t.Footer>
      </Table>
    </div>
  </template>
}
```

## Scrollable Tables

For large datasets, enable scrolling with container-based sizing:

```gts preview
import Component from '@glimmer/component';
import { Table, type ColumnConfig } from '@frontile/collections';
import { hash } from '@ember/helper';

interface User {
  id: string;
  name: string;
  email: string;
  department: string;
  role: string;
}

export default class DemoComponent extends Component {
  columns: ColumnConfig<User>[] = [
    { key: 'id', name: 'ID' },
    { key: 'name', name: 'Name' },
    { key: 'email', name: 'Email' },
    { key: 'department', name: 'Department' },
    { key: 'role', name: 'Role' }
  ];

  items: User[] = [
    {
      id: '1',
      name: 'John Doe',
      email: 'john@example.com',
      department: 'Engineering',
      role: 'Senior Developer'
    },
    {
      id: '2',
      name: 'Jane Smith',
      email: 'jane@example.com',
      department: 'Design',
      role: 'UI/UX Designer'
    },
    {
      id: '3',
      name: 'Bob Johnson',
      email: 'bob@example.com',
      department: 'Product',
      role: 'Product Manager'
    },
    {
      id: '4',
      name: 'Alice Brown',
      email: 'alice@example.com',
      department: 'Engineering',
      role: 'Tech Lead'
    },
    {
      id: '5',
      name: 'Charlie Wilson',
      email: 'charlie@example.com',
      department: 'Marketing',
      role: 'Marketing Manager'
    }
  ];

  <template>
    <div class='space-y-4'>
      <div>
        <h4 class='font-medium mb-2'>Vertically scrollable table</h4>
        <Table
          @columns={{this.columns}}
          @items={{this.items}}
          @isScrollable={{true}}
          @classes={{hash wrapper='h-48'}}
        />
      </div>

      <div>
        <h4 class='font-medium mb-2'>Horizontally scrollable table</h4>
        <Table
          @columns={{this.columns}}
          @items={{this.items}}
          @isScrollable={{true}}
          @classes={{hash wrapper='max-w-sm'}}
        />
      </div>
    </div>
  </template>
}
```

## Advanced Features

### Sticky Columns and Rows

Make columns or rows sticky to keep them visible during scrolling, perfect for large datasets where certain information should remain in view.

### Sticky Columns

Make columns sticky to keep them visible during horizontal scrolling. You can define sticky behavior either in the column configuration or directly on components.

#### Method 1: Column Configuration (Recommended)

Define sticky columns directly in your column configuration:

```gts preview
import Component from '@glimmer/component';
import { Table, type ColumnConfig } from '@frontile/collections';
import { hash } from '@ember/helper';

interface Employee {
  id: string;
  name: string;
  email: string;
  phone: string;
  department: string;
  role: string;
  location: string;
  manager: string;
}

export default class DemoComponent extends Component {
  columns: ColumnConfig<Employee>[] = [
    {
      key: 'id',
      name: 'Employee ID',
      isSticky: true,
      stickyPosition: 'left'
    },
    { key: 'name', name: 'Full Name' },
    { key: 'email', name: 'Email Address' },
    { key: 'phone', name: 'Phone Number' },
    { key: 'department', name: 'Department' },
    { key: 'role', name: 'Job Title' },
    { key: 'location', name: 'Office Location' },
    { key: 'manager', name: 'Manager' }
  ];

  items: Employee[] = [
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
      <h4 class='font-medium mb-2'>Sticky Employee ID column defined in
        configuration</h4>
      <Table
        @columns={{this.columns}}
        @items={{this.items}}
        @isScrollable={{true}}
        @classes={{hash wrapper='max-w-2xl'}}
      />
    </div>
  </template>
}
```

#### Method 2: Component-Level Configuration

For manual composition, apply sticky properties directly to components:

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
    }
  ];

  <template>
    <div>
      <h4 class='font-medium mb-2'>Sticky Employee ID (left) and Actions (right)
        columns</h4>
      <Table
        @isScrollable={{true}}
        @classes={{hash wrapper='max-w-2xl'}}
        as |t|
      >
        <t.Header>
          <t.Column @isSticky={{true}} @stickyPosition='left'>Employee ID</t.Column>
          <t.Column>Full Name</t.Column>
          <t.Column>Email Address</t.Column>
          <t.Column>Phone Number</t.Column>
          <t.Column>Department</t.Column>
          <t.Column>Job Title</t.Column>
          <t.Column>Office Location</t.Column>
          <t.Column>Manager</t.Column>
          <t.Column
            @isSticky={{true}}
            @stickyPosition='right'
          >Actions</t.Column>
        </t.Header>
        <t.Body>
          {{#each this.items as |item|}}
            <t.Row @item={{item}}>
              <t.Cell
                @isSticky={{true}}
                @stickyPosition='left'
              >{{item.id}}</t.Cell>
              <t.Cell>{{item.name}}</t.Cell>
              <t.Cell>{{item.email}}</t.Cell>
              <t.Cell>{{item.phone}}</t.Cell>
              <t.Cell>{{item.department}}</t.Cell>
              <t.Cell>{{item.role}}</t.Cell>
              <t.Cell>{{item.location}}</t.Cell>
              <t.Cell>{{item.manager}}</t.Cell>
              <t.Cell @isSticky={{true}} @stickyPosition='right'>
                <button
                  type='button'
                  class='text-primary hover:underline mr-2'
                >Edit</button>
                <button
                  type='button'
                  class='text-danger hover:underline'
                >Delete</button>
              </t.Cell>
            </t.Row>
          {{/each}}
        </t.Body>
      </Table>
    </div>
  </template>
}
```

### Sticky Header

Keep the table header visible when scrolling through long data:

```gts preview
import Component from '@glimmer/component';
import { Table, type ColumnConfig } from '@frontile/collections';
import { hash } from '@ember/helper';

interface User {
  id: string;
  name: string;
  email: string;
  department: string;
}

export default class DemoComponent extends Component {
  columns: ColumnConfig<User>[] = [
    { key: 'id', name: 'ID' },
    { key: 'name', name: 'Name' },
    { key: 'email', name: 'Email' },
    { key: 'department', name: 'Department' }
  ];

  items: User[] = [
    {
      id: '1',
      name: 'John Doe',
      email: 'john@example.com',
      department: 'Engineering'
    },
    {
      id: '2',
      name: 'Jane Smith',
      email: 'jane@example.com',
      department: 'Design'
    },
    {
      id: '3',
      name: 'Bob Johnson',
      email: 'bob@example.com',
      department: 'Product'
    },
    {
      id: '4',
      name: 'Alice Brown',
      email: 'alice@example.com',
      department: 'Engineering'
    },
    {
      id: '5',
      name: 'Charlie Wilson',
      email: 'charlie@example.com',
      department: 'Marketing'
    },
    {
      id: '6',
      name: 'Diana Lee',
      email: 'diana@example.com',
      department: 'Sales'
    },
    {
      id: '7',
      name: 'Frank Miller',
      email: 'frank@example.com',
      department: 'Support'
    },
    {
      id: '8',
      name: 'Grace Chen',
      email: 'grace@example.com',
      department: 'Engineering'
    }
  ];

  <template>
    <div>
      <h4 class='font-medium mb-2'>Sticky header - scroll to see header stay in
        place</h4>
      <Table
        @columns={{this.columns}}
        @items={{this.items}}
        @isStickyHeader={{true}}
        @isScrollable={{true}}
        @classes={{hash wrapper='h-48'}}
      />
    </div>
  </template>
}
```

### Sticky Rows

Freeze specific rows by their keys to keep important data visible:

```gts preview
import Component from '@glimmer/component';
import { Table, type ColumnConfig } from '@frontile/collections';
import { array, hash } from '@ember/helper';

interface User {
  id: string;
  name: string;
  email: string;
  role: string;
}

export default class DemoComponent extends Component {
  columns: ColumnConfig<User>[] = [
    { key: 'id', name: 'ID' },
    { key: 'name', name: 'Name' },
    { key: 'email', name: 'Email' },
    { key: 'role', name: 'Role' }
  ];

  items: User[] = [
    {
      id: 'admin',
      name: 'Admin User',
      email: 'admin@example.com',
      role: 'Administrator'
    },
    { id: '1', name: 'John Doe', email: 'john@example.com', role: 'Developer' },
    {
      id: '2',
      name: 'Jane Smith',
      email: 'jane@example.com',
      role: 'Designer'
    },
    {
      id: '3',
      name: 'Bob Johnson',
      email: 'bob@example.com',
      role: 'Product Manager'
    },
    {
      id: '4',
      name: 'Alice Brown',
      email: 'alice@example.com',
      role: 'Tech Lead'
    },
    {
      id: 'guest',
      name: 'Guest User',
      email: 'guest@example.com',
      role: 'Read-only'
    }
  ];

  <template>
    <div>
      <h4 class='font-medium mb-2'>Sticky rows - Admin and Guest users stay
        visible</h4>
      <Table
        @columns={{this.columns}}
        @items={{this.items}}
        @stickyKeys={{array 'admin' 'guest'}}
        @isScrollable={{true}}
        @classes={{hash wrapper='h-48'}}
      />
    </div>
  </template>
}
```

### Sticky Footer

Make the footer sticky during vertical scrolling by setting `@isStickyFooter` to true. This keeps summary information visible when scrolling through long tables:

```gts preview
import Component from '@glimmer/component';
import { Table, type ColumnConfig } from '@frontile/collections';
import { hash } from '@ember/helper';

interface Transaction {
  id: string;
  date: string;
  description: string;
  amount: number;
}

export default class DemoComponent extends Component {
  columns: ColumnConfig<Transaction>[] = [
    { key: 'date', name: 'Date' },
    { key: 'description', name: 'Description' },
    {
      key: 'amount',
      name: 'Amount',
      value: (item) =>
        item.amount < 0 ? `-$${Math.abs(item.amount)}` : `$${item.amount}`
    }
  ];

  footerColumns: ColumnConfig[] = [
    { key: 'summary', name: 'Account Total' },
    { key: 'empty', name: '' },
    { key: 'total', name: '$1,234.56' }
  ];

  items: Transaction[] = [
    {
      id: '1',
      date: '2024-01-15',
      description: 'Salary Deposit',
      amount: 3500.0
    },
    {
      id: '2',
      date: '2024-01-16',
      description: 'Grocery Store',
      amount: -125.43
    },
    { id: '3', date: '2024-01-17', description: 'Gas Station', amount: -45.2 },
    {
      id: '4',
      date: '2024-01-18',
      description: 'Online Purchase',
      amount: -89.99
    },
    { id: '5', date: '2024-01-19', description: 'Restaurant', amount: -67.5 },
    {
      id: '6',
      date: '2024-01-20',
      description: 'ATM Withdrawal',
      amount: -100.0
    },
    {
      id: '7',
      date: '2024-01-21',
      description: 'Utility Bill',
      amount: -150.75
    },
    { id: '8', date: '2024-01-22', description: 'Coffee Shop', amount: -8.25 },
    {
      id: '9',
      date: '2024-01-23',
      description: 'Freelance Payment',
      amount: 450.0
    },
    {
      id: '10',
      date: '2024-01-24',
      description: 'Subscription',
      amount: -29.99
    }
  ];

  <template>
    <div>
      <h4 class='font-medium mb-2'>Sticky footer - scroll to see footer stay at
        bottom</h4>
      <Table
        @columns={{this.columns}}
        @items={{this.items}}
        @footerColumns={{this.footerColumns}}
        @isStickyFooter={{true}}
        @isScrollable={{true}}
        @classes={{hash wrapper='h-64' tfoot='font-semibold'}}
      />
    </div>
  </template>
}
```

## Empty State Handling

The table gracefully handles empty data by displaying headers without rows:

```gts preview
import Component from '@glimmer/component';
import { Table, type ColumnConfig } from '@frontile/collections';

export default class DemoComponent extends Component {
  columns: ColumnConfig[] = [
    { key: 'id', name: 'ID' },
    { key: 'name', name: 'Name' },
    { key: 'email', name: 'Email' }
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

## Performance & Best Practices

### Pattern Selection

Choose the right pattern for your use case:

- **Pattern 1 (Simple)**: Best for basic data display with minimal customization needs
- **Pattern 2 (Manual)**: Best for heavily customized layouts, complex cell content, or when you don't need advanced table features
- **Pattern 3 (Hybrid)**: Best when you need some customization while maintaining access to data structures

### Large Datasets

For optimal performance with large datasets:

- Use `@layout="fixed"` for faster rendering
- Enable scrolling with container-based sizing
- Consider sticky headers to maintain context while scrolling

```gts
<Table
  @columns={{this.columns}}
  @items={{this.largeDataset}}
  @layout="fixed"
  @isScrollable={{true}}
  @isStickyHeader={{true}}
  @classes={{hash wrapper="h-96 max-w-4xl"}}
/>
```

## API

<Signature @component="Table" />
<Signature @component="TableHeader" />
<Signature @component="TableBody" />
<Signature @component="TableFooter" />
<Signature @component="TableColumn" />
<Signature @component="TableRow" />
<Signature @component="TableCell" />

### ColumnConfig

```ts
interface ColumnConfig<T = unknown> {
  /** The key to extract data from items */
  key: string;
  /** Display name for the column header */
  name: string;
  /** Optional function to transform/compute column values */
  value?: (ctx: CellContext<T>) => ContentValue;
  /** Whether this column should be sticky during horizontal scrolling */
  isSticky?: boolean;
  /** Position where the sticky column should stick. @default 'left' */
  stickyPosition?: 'left' | 'right';
}
```

**Note**: `ColumnConfig` extends `@universal-ember/table`'s ColumnConfig and provides the foundation for advanced table features like sorting and filtering. The `value` function receives a `CellContext<T>` parameter with structure `{ row: { data: T } }`.

**ContentValue** is a standard Glint type for values that are safe to render in templates, which includes: `string | number | boolean | null | undefined | SafeString`.

#### Sticky Column Properties

- **`isSticky`**: When `true`, the column will remain visible during horizontal scrolling
- **`stickyPosition`**: Determines which side the column sticks to (`'left'` or `'right'`). Defaults to `'left'`

These properties take precedence over component-level sticky settings when both are provided.
