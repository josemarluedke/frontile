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
  columns = [
    { key: 'id', name: 'ID' },
    { key: 'name', name: 'Name' },
    { key: 'email', name: 'Email' },
    { key: 'role', name: 'Role' }
  ] as const satisfies ColumnConfig<User>[];

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
  columns = [
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
  ] as const satisfies ColumnConfig<User>[];

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

const columns = [
  { key: 'name', name: 'Product Name' },
  {
    key: 'price',
    name: 'Price',
    value: (ctx) => `$${ctx.row.data.price.toFixed(2)}`
  }
] as const satisfies ColumnConfig<Product>[];
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
  columns = [
    { key: 'id', name: 'ID' },
    { key: 'name', name: 'Name' },
    { key: 'email', name: 'Email' }
  ] as const satisfies ColumnConfig<User>[];

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
  columns = [
    { key: 'name', name: 'Product' },
    { key: 'price', name: 'Price', value: (ctx) => `$${ctx.row.data.price}` },
    { key: 'category', name: 'Category' }
  ] as const satisfies ColumnConfig<Product>[];

  footerColumns = [
    { key: 'total_label', name: 'Total Items' },
    { key: 'total_price', name: '$127.97' },
    { key: 'categories', name: '3 Categories' }
  ] as const satisfies ColumnConfig[];

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
  columns = [
    { key: 'id', name: 'ID' },
    { key: 'name', name: 'Name' },
    { key: 'email', name: 'Email' },
    { key: 'department', name: 'Department' },
    { key: 'role', name: 'Role' }
  ] as const satisfies ColumnConfig<User>[];

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
  columns = [
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
  ] as const satisfies ColumnConfig<Employee>[];

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
  columns = [
    { key: 'id', name: 'ID' },
    { key: 'name', name: 'Name' },
    { key: 'email', name: 'Email' },
    { key: 'department', name: 'Department' }
  ] as const satisfies ColumnConfig<User>[];

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
  columns = [
    { key: 'id', name: 'ID' },
    { key: 'name', name: 'Name' },
    { key: 'email', name: 'Email' },
    { key: 'role', name: 'Role' }
  ] as const satisfies ColumnConfig<User>[];

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
  columns = [
    { key: 'date', name: 'Date' },
    { key: 'description', name: 'Description' },
    {
      key: 'amount',
      name: 'Amount',
      value: (ctx) =>
        ctx.row.data.amount < 0 ? `-$${Math.abs(ctx.row.data.amount)}` : `$${ctx.row.data.amount}`
    }
  ] as const satisfies ColumnConfig<Transaction>[];

  footerColumns = [
    { key: 'summary', name: 'Account Total' },
    { key: 'empty', name: '' },
    { key: 'total', name: '$1,234.56' }
  ] as const satisfies ColumnConfig[];

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
  columns = [
    { key: 'id', name: 'ID' },
    { key: 'name', name: 'Name' },
    { key: 'email', name: 'Email' }
  ] as const satisfies ColumnConfig[];

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

## Custom Cell Rendering

The Table component supports custom cell rendering through the `:cell` named block, allowing you to override the default cell content with custom components, formatting, or conditional rendering.

### Basic Cell Customization

Use the `:cell` named block to customize how individual cells are rendered:

```gts preview
import Component from '@glimmer/component';
import { Table, type ColumnConfig } from '@frontile/collections';

interface User {
  id: string;
  name: string;
  email: string;
  role: string;
  status: 'active' | 'inactive';
}

export default class DemoComponent extends Component {
  columns = [
    { key: 'name', name: 'Name' },
    { key: 'email', name: 'Email' },
    { key: 'role', name: 'Role' },
    { key: 'status', name: 'Status' }
  ] as const satisfies ColumnConfig<User>[];

  items: User[] = [
    {
      id: '1',
      name: 'John Doe',
      email: 'john@example.com',
      role: 'admin',
      status: 'active'
    },
    {
      id: '2',
      name: 'Jane Smith',
      email: 'jane@example.com',
      role: 'user',
      status: 'inactive'
    }
  ];

  <template>
    <Table @columns={{this.columns}} @items={{this.items}}>
      <:cell as |c|>
        <c.For @key="name">
          <div class="flex items-center space-x-2">
            <div class="w-8 h-8 bg-blue-500 rounded-full flex items-center justify-center text-white text-sm font-medium">
              {{c.value.[0]}}
            </div>
            <span class="font-medium">{{c.value}}</span>
          </div>
        </c.For>

        <c.For @key="email">
          <a href="mailto:{{c.value}}" class="text-blue-600 hover:underline">
            {{c.value}}
          </a>
        </c.For>

        <c.For @key="role">
          {{#if (this.isAdmin c.value)}}
            <span class="px-2 py-1 rounded-full text-xs font-medium bg-purple-100 text-purple-800">
              {{c.value}}
            </span>
          {{else}}
            <span class="px-2 py-1 rounded-full text-xs font-medium bg-gray-100 text-gray-800">
              {{c.value}}
            </span>
          {{/if}}
        </c.For>

        <c.For @key="status">
          <div class="flex items-center space-x-2">
            {{#if (this.isActive c.value)}}
              <div class="w-2 h-2 rounded-full bg-green-500"></div>
              <span class="capitalize text-green-700">{{c.value}}</span>
            {{else}}
              <div class="w-2 h-2 rounded-full bg-red-500"></div>
              <span class="capitalize text-red-700">{{c.value}}</span>
            {{/if}}
          </div>
        </c.For>
      </:cell>
    </Table>
  </template>

  get isAdmin() {
    return (role: string) => role === 'admin';
  }

  get isActive() {
    return (status: string) => status === 'active';
  }
}
```

### Cell Context and Components

The `:cell` block provides access to cell context and utility components:

- **`c.column`** - The current column configuration
- **`c.row`** - The current row data
- **`c.value`** - The computed value for the current cell
- **`c.For`** - Component for conditional rendering based on column key
- **`c.Default`** - Component for default rendering of unmatched columns

### Type-Safe Column Keys

When using `as const satisfies ColumnConfig<T>[]`, the `@key` parameter in `c.For` is type-checked against your column keys:

```gts preview
import Component from '@glimmer/component';
import { Table, type ColumnConfig } from '@frontile/collections';

interface Product {
  id: string;
  name: string;
  price: number;
  inStock: boolean;
}

export default class DemoComponent extends Component {
  columns = [
    { key: 'name', name: 'Product' },
    { key: 'price', name: 'Price' },
    { key: 'inStock', name: 'Availability' }
  ] as const satisfies ColumnConfig<Product>[];

  items: Product[] = [
    { id: '1', name: 'Laptop', price: 999.99, inStock: true },
    { id: '2', name: 'Mouse', price: 29.99, inStock: false },
    { id: '3', name: 'Keyboard', price: 79.99, inStock: true }
  ];

  <template>
    <Table @columns={{this.columns}} @items={{this.items}}>
      <:cell as |c|>
        {{! Type-safe keys - these will be validated by TypeScript }}
        <c.For @key="name">
          <strong>{{c.value}}</strong>
        </c.For>

        <c.For @key="price">
          <span class="font-mono">${{c.value}}</span>
        </c.For>

        <c.For @key="inStock">
          {{#if c.value}}
            <span class="text-green-600">✓ In Stock</span>
          {{else}}
            <span class="text-red-600">✗ Out of Stock</span>
          {{/if}}
        </c.For>
      </:cell>
    </Table>
  </template>
}
```

### Default Cell Rendering

Use `c.Default` to provide fallback rendering for columns that don't have specific `c.For` components:

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
  columns = [
    { key: 'name', name: 'Name' },
    { key: 'email', name: 'Email' },
    { key: 'role', name: 'Role' }
  ] as const satisfies ColumnConfig<User>[];

  items: User[] = [
    {
      id: '1',
      name: 'John Doe',
      email: 'john@example.com',
      role: 'admin'
    },
    {
      id: '2',
      name: 'Jane Smith',
      email: 'jane@example.com',
      role: 'user'
    }
  ];

  <template>
    <Table @columns={{this.columns}} @items={{this.items}}>
      <:cell as |c|>
        {{! Only customize the name column }}
        <c.For @key="name">
          <div class="flex items-center">
            <div class="w-6 h-6 bg-gray-300 rounded-full mr-2"></div>
            <span class="font-semibold">{{c.value}}</span>
          </div>
        </c.For>

        {{! All other columns use default rendering }}
        <c.Default>
          <span class="text-gray-700">{{c.value}}</span>
        </c.Default>
      </:cell>
    </Table>
  </template>
}
```

### Excluding Columns from Default

Use `c.Default` with the `@except` parameter to exclude specific columns from default rendering:

```gts preview
import Component from '@glimmer/component';
import { Table, type ColumnConfig } from '@frontile/collections';
import { array } from '@ember/helper';

interface User {
  id: string;
  name: string;
  email: string;
  role: string;
}

export default class DemoComponent extends Component {
  columns = [
    { key: 'name', name: 'Name' },
    { key: 'email', name: 'Email' },
    { key: 'role', name: 'Role' }
  ] as const satisfies ColumnConfig<User>[];

  items: User[] = [
    {
      id: '1',
      name: 'John Doe',
      email: 'john@example.com',
      role: 'admin'
    },
    {
      id: '2',
      name: 'Jane Smith',
      email: 'jane@example.com',
      role: 'user'
    }
  ];

  <template>
    <Table @columns={{this.columns}} @items={{this.items}}>
      <:cell as |c|>
        {{! The name column will not render anything }}
        {{! since it's excluded from default and has no c.For }}

        {{! Email and role columns will use default rendering }}
        <c.Default @except={{array "name"}}>
          <span class="italic">{{c.value}}</span>
        </c.Default>
      </:cell>
    </Table>
  </template>
}
```

### Advanced Cell Customization

You can access the full row data and column information for complex customizations:

```gts preview
import Component from '@glimmer/component';
import { Table, type ColumnConfig } from '@frontile/collections';

interface Transaction {
  id: string;
  type: 'income' | 'expense';
  description: string;
  amount: number;
  date: string;
}

export default class DemoComponent extends Component {
  columns = [
    { key: 'date', name: 'Date' },
    { key: 'description', name: 'Description' },
    { key: 'amount', name: 'Amount' },
    { key: 'actions', name: 'Actions' }
  ] as const satisfies ColumnConfig<Transaction>[];

  items: Transaction[] = [
    {
      id: '1',
      type: 'income',
      description: 'Salary',
      amount: 3000,
      date: '2024-01-15'
    },
    {
      id: '2',
      type: 'expense',
      description: 'Groceries',
      amount: 150,
      date: '2024-01-16'
    }
  ];

  <template>
    <Table @columns={{this.columns}} @items={{this.items}}>
      <:cell as |c|>
        <c.For @key="amount">
          <div class="text-right font-mono">
            {{#if (this.isIncome c.row.data.type)}}
              <span class="text-green-600">+${{c.value}}</span>
            {{else}}
              <span class="text-red-600">-${{c.value}}</span>
            {{/if}}
          </div>
        </c.For>

        <c.For @key="actions">
          <div class="flex space-x-2">
            <button
              type="button"
              class="text-xs px-2 py-1 bg-blue-100 text-blue-700 rounded hover:bg-blue-200"
            >
              Edit
            </button>
            <button
              type="button"
              class="text-xs px-2 py-1 bg-red-100 text-red-700 rounded hover:bg-red-200"
            >
              Delete
            </button>
          </div>
        </c.For>

        <c.Default>
          {{c.value}}
        </c.Default>
      </:cell>
    </Table>
  </template>

  get isIncome() {
    return (type: string) => type === 'income';
  }
}
```

## Toolbar & Column Visibility

The Table component supports a toolbar area that can render additional controls and features before the table content. The most common use case is providing column visibility controls to let users show/hide columns interactively.

### Basic Toolbar Usage

Use the `toolbar` named block to add controls above your table:

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
  columns = [
    { key: 'id', name: 'ID', isVisible: true },
    { key: 'name', name: 'Name', isVisible: true },
    { key: 'email', name: 'Email', isVisible: false },
    { key: 'role', name: 'Role', isVisible: true }
  ] as const satisfies ColumnConfig<User>[];

  items: User[] = [
    { id: '1', name: 'John Doe', email: 'john@example.com', role: 'Admin' },
    { id: '2', name: 'Jane Smith', email: 'jane@example.com', role: 'User' },
    { id: '3', name: 'Bob Johnson', email: 'bob@example.com', role: 'Editor' }
  ];

  <template>
    <Table @columns={{this.columns}} @items={{this.items}}>
      <:toolbar as |t|>
        <div class="flex items-center justify-between mb-4">
          <h3 class="text-lg font-semibold">User Management</h3>
          <t.ColumnVisibility />
        </div>
      </:toolbar>
    </Table>
  </template>
}
```

### Column Visibility

The ColumnVisibility component allows users to interactively show and hide columns. It integrates with the universal-ember ColumnVisibility plugin to provide persistent state management.

#### Setting Initial Visibility

Control which columns are visible by default using the `isVisible` property in your column configuration:

```ts
columns = [
  { key: 'id', name: 'ID', isVisible: true },
  { key: 'name', name: 'Name', isVisible: true },
  { key: 'email', name: 'Email', isVisible: false }, // Hidden by default
  { key: 'role', name: 'Role', isVisible: true }
] as const satisfies ColumnConfig<User>[];
```

#### Custom Icon

You can provide a custom icon for the ColumnVisibility trigger button using the `icon` named block:

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
  columns = [
    { key: 'name', name: 'Product Name', isVisible: true },
    { key: 'price', name: 'Price', value: (ctx) => `$${ctx.row.data.price}`, isVisible: true },
    { key: 'category', name: 'Category', isVisible: false }
  ] as const satisfies ColumnConfig<Product>[];

  items: Product[] = [
    { id: '1', name: 'Laptop', price: 99.99, category: 'Electronics' },
    { id: '2', name: 'Coffee Mug', price: 12.99, category: 'Kitchen' },
    { id: '3', name: 'Notebook', price: 4.99, category: 'Office' }
  ];

  <template>
    <Table @columns={{this.columns}} @items={{this.items}}>
      <:toolbar as |t|>
        <div class="flex items-center justify-between mb-4">
          <h3 class="text-lg font-semibold">Products</h3>
          <t.ColumnVisibility>
            <:icon>
              <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-4">
                <path stroke-linecap="round" stroke-linejoin="round" d="M10.5 6h9.75M10.5 6a1.5 1.5 0 1 1-3 0m3 0a1.5 1.5 0 1 0-3 0M3.75 6H7.5m0 0h9.75m-9.75 0a1.5 1.5 0 0 1 3 0m3 0a1.5 1.5 0 0 0 3 0m0 0a1.5 1.5 0 0 1 3 0m6 0a1.5 1.5 0 1 1-3 0M10.5 12h9.75m-9.75 0a1.5 1.5 0 1 1-3 0m3 0a1.5 1.5 0 1 0-3 0M3.75 12H7.5m0 0h9.75m-9.75 0a1.5 1.5 0 0 1 3 0m3 0a1.5 1.5 0 0 0 3 0m0 0a1.5 1.5 0 0 1 3 0m6 0a1.5 1.5 0 1 1-3 0M10.5 18h9.75m-9.75 0a1.5 1.5 0 1 1-3 0m3 0a1.5 1.5 0 1 0-3 0M3.75 18H7.5m0 0h9.75m-9.75 0a1.5 1.5 0 0 1 3 0m3 0a1.5 1.5 0 0 0 3 0m0 0a1.5 1.5 0 0 1 3 0m6 0a1.5 1.5 0 1 1-3 0" />
              </svg>
            </:icon>
            <:default>
              Manage Columns
            </:default>
          </t.ColumnVisibility>
        </div>
      </:toolbar>
    </Table>
  </template>
}
```

### Features

The ColumnVisibility component provides:

- **Multi-select interface** - Users can select multiple columns to show/hide
- **Show All / Hide All actions** - Quick bulk operations
- **Persistent state** - Column visibility state is managed by the universal-ember plugin
- **Automatic integration** - No additional event handling required
- **Dropdown interface** - Built using Frontile's Dropdown and Listbox components

### Advanced Toolbar Usage

You can add multiple controls to the toolbar area:

```gts
<Table @columns={{this.columns}} @items={{this.items}}>
  <:toolbar as |t|>
    <div class="flex items-center justify-between mb-4">
      <div class="flex items-center space-x-4">
        <h3 class="text-lg font-semibold">Data Table</h3>
        <span class="text-sm text-gray-500">{{this.items.length}} items</span>
      </div>
      <div class="flex items-center space-x-2">
        <button type="button" class="btn btn-sm">Export</button>
        <button type="button" class="btn btn-sm">Filter</button>
        <t.ColumnVisibility />
      </div>
    </div>
  </:toolbar>
</Table>
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
  /** Whether this column should be visible by default */
  isVisible?: boolean;
}
```

**Note**: `ColumnConfig` extends `@universal-ember/table`'s ColumnConfig and provides the foundation for advanced table features like sorting and filtering. The `value` function receives a `CellContext<T>` parameter with structure `{ row: { data: T } }`.

**ContentValue** is a standard Glint type for values that are safe to render in templates, which includes: `string | number | boolean | null | undefined | SafeString`.

#### Sticky Column Properties

- **`isSticky`**: When `true`, the column will remain visible during horizontal scrolling
- **`stickyPosition`**: Determines which side the column sticks to (`'left'` or `'right'`). Defaults to `'left'`

These properties take precedence over component-level sticky settings when both are provided.

#### Column Visibility Properties

- **`isVisible`**: Controls whether the column is visible by default when using the ColumnVisibility feature. When `undefined`, columns are visible by default

This property integrates with the universal-ember ColumnVisibility plugin to provide persistent column state management.