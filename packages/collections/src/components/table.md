---
name: New
imports:
  - import Signature from 'site/components/signature';
---

# Table

The Table component provides a powerful way to display structured data with advanced features like sticky headers, columns, and rows, scrollable containers, and type-safe column definitions. It focuses on **automatic rendering** from data configurations for feature-rich data tables.

**Key Features:**

- **Automatic rendering** with type-safe column definitions
- **Sticky elements** - headers, footers, columns, and specific rows
- **Scrollable containers** for large datasets
- **Flexible styling** with size variants and striped rows
- **Empty state handling** with custom content
- **Table footers** for summaries, totals, and additional information
- **Universal-ember integration** for advanced table behaviors

For manual composition and custom layouts, use [SimpleTable](./simple-table) instead.

## Import

```js
import {
  Table,
  type ColumnConfig
} from '@frontile/collections';
```

## Basic Usage

The Table component requires `@columns` and `@items` arguments for automatic rendering:

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
    <Table @columns={{this.columns}} @items={{this.items}} />
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
    <Table @columns={{this.columns}} @items={{this.items}} />
  </template>
}
```

### Type Safety

Column configurations provide full TypeScript support. The `value` function receives a typed `CellContext<T>` parameter:

```ts
interface Product {
  id: number;
  name: string;
  price: number;
}

const columns: ColumnConfig<Product>[] = [
  { key: 'name', name: 'Product Name' },
  {
    key: 'price',
    name: 'Price',
    value: (ctx) => `$${ctx.row.data.price.toFixed(2)}`
  }
];
```

## Styling Options

Table supports the same styling options as SimpleTable:

- `@size` - Controls spacing: `sm`, `md` (default), `lg`
- `@isStriped` - Enables alternating row background colors
- `@layout` - Column sizing: `auto` (default), `fixed`
- `@classes` - Custom CSS classes for specific elements

For detailed styling examples, see the [SimpleTable styling documentation](./simple-table#styling--layout).

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
    <Table
      @columns={{this.columns}}
      @items={{this.items}}
      @size="sm"
      @isStriped={{true}}
      @classes={{hash wrapper="shadow-lg rounded-xl"}}
    />
  </template>
}
```

## Table Footers

Table footers provide a way to display summary information, totals, or additional context at the bottom of your table.

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
    <Table
      @columns={{this.columns}}
      @items={{this.items}}
      @footerColumns={{this.footerColumns}}
    />
  </template>
}
```

## Scrollable Tables

Enable scrolling for large datasets using the `@isScrollable` argument with container sizing:

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
    { id: '1', name: 'John Doe', email: 'john@example.com', department: 'Engineering', role: 'Senior Developer' },
    { id: '2', name: 'Jane Smith', email: 'jane@example.com', department: 'Design', role: 'UI/UX Designer' },
    { id: '3', name: 'Bob Johnson', email: 'bob@example.com', department: 'Product', role: 'Product Manager' },
    { id: '4', name: 'Alice Brown', email: 'alice@example.com', department: 'Engineering', role: 'Tech Lead' },
    { id: '5', name: 'Charlie Wilson', email: 'charlie@example.com', department: 'Marketing', role: 'Marketing Manager' }
  ];

  <template>
    <div class='space-y-4'>
      <div>
        <h4 class='font-medium mb-2'>Vertical scrolling with fixed height</h4>
        <Table
          @columns={{this.columns}}
          @items={{this.items}}
          @isScrollable={{true}}
          @classes={{hash wrapper='h-48'}}
        />
      </div>

      <div>
        <h4 class='font-medium mb-2'>Horizontal scrolling with limited width</h4>
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

### Sticky Columns

Make columns sticky to keep them visible during horizontal scrolling by defining sticky behavior in the column configuration:

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
    {
      key: 'actions',
      name: 'Actions',
      isSticky: true,
      stickyPosition: 'right',
      value: () => 'Edit'
    }
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
      <h4 class='font-medium mb-2'>Sticky Employee ID (left) and Actions (right) columns</h4>
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
      <h4 class='font-medium mb-2'>Sticky header - scroll to see header stay in place</h4>
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
      <h4 class='font-medium mb-2'>Sticky rows - Admin and Guest users stay visible</h4>
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

Make the footer sticky during vertical scrolling by setting `@isStickyFooter` to true:

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
      value: (ctx) =>
        ctx.row.data.amount < 0 ? `-$${Math.abs(ctx.row.data.amount)}` : `$${ctx.row.data.amount}`
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
      <h4 class='font-medium mb-2'>Sticky footer - scroll to see footer stay at bottom</h4>
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
    <Table
      @columns={{this.columns}}
      @items={{this.emptyItems}}
      @emptyContent='No data to display'
    />
  </template>
}
```

## Performance & Best Practices

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

### When to Use SimpleTable

Use [SimpleTable](./simple-table) instead of Table when you need:

- Complete manual control over table structure
- Custom cell content with complex layouts
- Block-form composition patterns
- Minimal styling without advanced features

## API

<Signature @component="Table" />

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