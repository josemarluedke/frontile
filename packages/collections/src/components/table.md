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

  <template><Table @columns={{this.columns}} @items={{this.items}} /></template>
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

  <template><Table @columns={{this.columns}} @items={{this.items}} /></template>
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
      @size='sm'
      @isStriped={{true}}
      @classes={{hash wrapper='shadow-lg rounded-xl'}}
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
      <h4 class='font-medium mb-2'>Sticky Employee ID (left) and Actions (right)
        columns</h4>
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
        ctx.row.data.amount < 0
          ? `-$${Math.abs(ctx.row.data.amount)}`
          : `$${ctx.row.data.amount}`
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

## Loading State

The Table component supports loading states with different color variants to indicate when data is being fetched or processed. Loading states provide visual feedback to users during async operations.

```gts preview
import Component from '@glimmer/component';
import { Table, type ColumnConfig } from '@frontile/collections';
import { Select } from '@frontile/forms';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { on } from '@ember/modifier';
import { Button } from '@frontile/buttons';

interface Product {
  id: string;
  name: string;
  price: number;
  category: string;
}

export default class DemoComponent extends Component {
  @tracked isLoading = true;
  @tracked loadingColor = 'primary';

  columns = [
    { key: 'id', name: 'ID' },
    { key: 'name', name: 'Product' },
    { key: 'price', name: 'Price', value: (ctx) => `$${ctx.row.data.price}` },
    { key: 'category', name: 'Category' }
  ] as const satisfies ColumnConfig<Product>[];

  items: Product[] = [
    {
      id: '1',
      name: 'Wireless Headphones',
      price: 199.99,
      category: 'Electronics'
    },
    { id: '2', name: 'Coffee Mug', price: 12.99, category: 'Kitchen' },
    { id: '3', name: 'Notebook Set', price: 24.99, category: 'Office' }
  ];

  colorOptions = [
    { key: 'default', name: 'Default' },
    { key: 'primary', name: 'Primary' },
    { key: 'success', name: 'Success' },
    { key: 'warning', name: 'Warning' },
    { key: 'danger', name: 'Danger' }
  ];

  @action
  toggleLoading() {
    this.isLoading = !this.isLoading;
  }

  @action
  updateLoadingColor(color) {
    this.loadingColor = color;
  }

  <template>
    <div class='space-y-4'>
      <div class='flex items-end space-x-4 justify-center'>
        <Button
          @onPress={{this.toggleLoading}}
          @size='sm'
          @appearance='outlined'
          @intent={{if this.isLoading 'danger' 'primary'}}
        >
          {{if this.isLoading 'Stop Loading' 'Start Loading'}}
        </Button>

        <Select
          @inputSize='sm'
          @label='Color'
          @items={{this.colorOptions}}
          @selectedKey={{this.loadingColor}}
          @onSelectionChange={{this.updateLoadingColor}}
          class='w-32'
        />
      </div>

      <Table
        @columns={{this.columns}}
        @items={{this.items}}
        @isLoading={{this.isLoading}}
        @loadingColor={{this.loadingColor}}
      />
    </div>
  </template>
}
```

## Empty State Handling

The table supports both simple text and rich custom content for empty states when no data is available.

### Simple Text Content

Use the `@emptyContent` parameter for simple text messages:

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

### Rich Empty Content with Named Block

Use the `empty` named block for custom HTML content, including headings, paragraphs, buttons, and other interactive elements:

```gts preview
import Component from '@glimmer/component';
import { Table, type ColumnConfig } from '@frontile/collections';
import { Button } from '@frontile/buttons';

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

  emptyItems: User[] = [];

  <template>
    <Table @columns={{this.columns}} @items={{this.emptyItems}}>
      <:empty>
        <div class='text-center py-8 px-4'>
          <div class='w-16 h-16 mx-auto mb-4 text-muted'>
            <svg fill='none' stroke='currentColor' viewBox='0 0 48 48'>
              <path
                stroke-linecap='round'
                stroke-linejoin='round'
                stroke-width='2'
                d='M34 40h10v-4a6 6 0 00-10.712-3.714M34 40H14m20 0v-4a9.971 9.971 0 00-.712-3.714M14 40H4v-4a6 6 0 0110.713-3.714M14 40v-4c0-1.313.253-2.566.713-3.714m0 0A10.003 10.003 0 0124 26c4.21 0 7.813 2.602 9.288 6.286M30 14a6 6 0 11-12 0 6 6 0 0112 0zm12 6a4 4 0 11-8 0 4 4 0 018 0zm-28 0a4 4 0 11-8 0 4 4 0 018 0z'
              />
            </svg>
          </div>
          <h3 class='text-lg font-medium text-foreground mb-2'>No Users Found</h3>
          <p class='text-muted mb-4'>
            There are no users in your system yet. Get started by adding your
            first user.
          </p>
          <Button @intent='primary' @size='sm'>
            Add First User
          </Button>
        </div>
      </:empty>
    </Table>
  </template>
}
```

When both `@emptyContent` parameter and `empty` named block are provided, the named block takes precedence:

```gts preview
import Component from '@glimmer/component';
import { Table, type ColumnConfig } from '@frontile/collections';

interface Product {
  id: string;
  name: string;
  price: number;
}

export default class DemoComponent extends Component {
  columns = [
    { key: 'name', name: 'Product' },
    { key: 'price', name: 'Price' }
  ] as const satisfies ColumnConfig<Product>[];

  emptyItems: Product[] = [];

  <template>
    {{! The named block content will be shown, not the @emptyContent text }}
    <Table
      @columns={{this.columns}}
      @items={{this.emptyItems}}
      @emptyContent='This text will be ignored'
    >
      <:empty>
        <div class='text-center py-6'>
          <h4 class='text-md font-medium text-primary mb-2'>Named Block Priority</h4>
          <p class='text-muted'>
            This content from the named block takes precedence over the
            @emptyContent parameter.
          </p>
        </div>
      </:empty>
    </Table>
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
        <c.For @key='name'>
          <div class='flex items-center space-x-2'>
            <div
              class='w-8 h-8 bg-primary rounded-full flex items-center justify-center text-white text-sm font-medium'
            >
              {{c.value.[0]}}
            </div>
            <span class='font-medium'>{{c.value}}</span>
          </div>
        </c.For>

        <c.For @key='email'>
          <a href='mailto:{{c.value}}' class='text-primary hover:underline'>
            {{c.value}}
          </a>
        </c.For>

        <c.For @key='role'>
          {{#if (this.isAdmin c.value)}}
            <span
              class='px-2 py-1 rounded-full text-xs font-medium bg-primary/10 text-primary'
            >
              {{c.value}}
            </span>
          {{else}}
            <span
              class='px-2 py-1 rounded-full text-xs font-medium bg-default/10 text-default'
            >
              {{c.value}}
            </span>
          {{/if}}
        </c.For>

        <c.For @key='status'>
          <div class='flex items-center space-x-2'>
            {{#if (this.isActive c.value)}}
              <div class='w-2 h-2 rounded-full bg-success'></div>
              <span class='capitalize text-success'>{{c.value}}</span>
            {{else}}
              <div class='w-2 h-2 rounded-full bg-danger'></div>
              <span class='capitalize text-danger'>{{c.value}}</span>
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
        <c.For @key='name'>
          <strong>{{c.value}}</strong>
        </c.For>

        <c.For @key='price'>
          <span class='font-mono'>${{c.value}}</span>
        </c.For>

        <c.For @key='inStock'>
          {{#if c.value}}
            <span class='text-success'>✓ In Stock</span>
          {{else}}
            <span class='text-danger'>✗ Out of Stock</span>
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
        <c.For @key='name'>
          <div class='flex items-center'>
            <div class='w-6 h-6 bg-muted rounded-full mr-2'></div>
            <span class='font-semibold'>{{c.value}}</span>
          </div>
        </c.For>

        {{! All other columns use default rendering }}
        <c.Default>
          <span class='text-default'>{{c.value}}</span>
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
        <c.Default @except={{array 'name'}}>
          <span class='italic'>{{c.value}}</span>
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
        <c.For @key='amount'>
          <div class='text-right font-mono'>
            {{#if (this.isIncome c.row.data.type)}}
              <span class='text-success'>+${{c.value}}</span>
            {{else}}
              <span class='text-danger'>-${{c.value}}</span>
            {{/if}}
          </div>
        </c.For>

        <c.For @key='actions'>
          <div class='flex space-x-2'>
            <button
              type='button'
              class='text-xs px-2 py-1 bg-primary/10 text-primary rounded hover:bg-primary/20'
            >
              Edit
            </button>
            <button
              type='button'
              class='text-xs px-2 py-1 bg-danger/10 text-danger rounded hover:bg-danger/20'
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

## Column-Level Cell Components

In addition to the `:cell` named block approach, you can define custom Cell components directly in your column configuration. This approach is useful when you want to encapsulate cell rendering logic in reusable components.

### Basic Column Cell Components

Define Cell components in your column configuration using the `Cell` property:

```gts preview
import Component from '@glimmer/component';
import {
  Table,
  type ColumnConfig,
  type CellSignature
} from '@frontile/collections';
import type { TOC } from '@ember/component/template-only';

interface User {
  id: string;
  name: string;
  email: string;
  role: string;
  status: 'active' | 'inactive';
}

// Helper functions
const isAdmin = (role: string) => role === 'admin';
const isActive = (status: string) => status === 'active';

// Define reusable cell components
const NameCellComponent: TOC<CellSignature<User>> = <template>
  <div class='flex items-center space-x-3'>
    <div
      class='w-10 h-10 bg-primary rounded-full flex items-center justify-center text-white font-medium'
    >
      {{@row.data.name.[0]}}
    </div>
    <div>
      <div class='font-semibold'>{{@row.data.name}}</div>
      <div class='text-sm text-muted'>ID: {{@row.data.id}}</div>
    </div>
  </div>
</template>;

const RoleBadgeComponent: TOC<CellSignature<User>> = <template>
  {{#if (isAdmin @row.data.role)}}
    <span
      class='inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-primary/10 text-primary'
    >
      <svg class='w-3 h-3 mr-1' fill='currentColor' viewBox='0 0 20 20'>
        <path
          fill-rule='evenodd'
          d='M9.664 1.319a.75.75 0 01.672 0 41.059 41.059 0 018.198 5.424.75.75 0 01-.254 1.285 31.372 31.372 0 00-7.86 3.83.75.75 0 01-.84 0 31.508 31.508 0 00-2.08-1.287V9.394c0-.244.116-.463.302-.592a35.504 35.504 0 0113.305-2.033.75.75 0 00-.714-1.319 37 37 0 00-3.446 2.12A2.216 2.216 0 006 9.393v.38a31.293 31.293 0 00-4.28-1.746.75.75 0 01-.254-1.285 41.059 41.059 0 018.198-5.424zM6 11.459a29.848 29.848 0 00-2.455-1.158 41.029 41.029 0 00-.39 3.114.75.75 0 00.419.74c.528.256 1.046.53 1.554.82-.21-.899-.385-1.83-.385-2.516zM21 12.61c0 .088-.006.175-.018.261a3.756 3.756 0 01-2.612 3.218c-.583.162-1.18.24-1.8.24a6.24 6.24 0 01-1.8-.24 3.756 3.756 0 01-2.612-3.218.77.77 0 00-.018-.261V9.394a26.136 26.136 0 0 1 3.915 2.375c.786.54 1.54 1.102 2.237 1.693a25.298 25.298 0 0 1 2.708-1.693V12.61z'
          clip-rule='evenodd'
        ></path>
      </svg>
      {{@row.data.role}}
    </span>
  {{else}}
    <span
      class='inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-muted/50 text-default'
    >
      {{@row.data.role}}
    </span>
  {{/if}}
</template>;

const StatusIndicatorComponent: TOC<CellSignature<User>> = <template>
  {{#if (isActive @row.data.status)}}
    <div class='flex items-center space-x-2'>
      <div class='w-2 h-2 rounded-full bg-success'></div>
      <span class='capitalize text-success'>{{@row.data.status}}</span>
    </div>
  {{else}}
    <div class='flex items-center space-x-2'>
      <div class='w-2 h-2 rounded-full bg-danger'></div>
      <span class='capitalize text-danger'>{{@row.data.status}}</span>
    </div>
  {{/if}}
</template>;

export default class DemoComponent extends Component {
  columns = [
    {
      key: 'name',
      name: 'User',
      Cell: NameCellComponent
    },
    {
      key: 'email',
      name: 'Email'
    },
    {
      key: 'role',
      name: 'Role',
      Cell: RoleBadgeComponent
    },
    {
      key: 'status',
      name: 'Status',
      Cell: StatusIndicatorComponent
    }
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
    },
    {
      id: '3',
      name: 'Bob Johnson',
      email: 'bob@example.com',
      role: 'editor',
      status: 'active'
    }
  ];

  <template><Table @columns={{this.columns}} @items={{this.items}} /></template>
}
```

### Cell Component Signature

Cell components receive `@row` and `@column` arguments with full type safety:

```ts
import type { CellSignature } from '@frontile/collections';

interface Product {
  id: string;
  name: string;
  price: number;
  inStock: boolean;
}

const PriceCellComponent: TOC<CellSignature<Product>> = <template>
  <div class="text-right font-mono">
    <span class="text-lg font-semibold">${{@row.data.price}}</span>
    {{#unless @row.data.inStock}}
      <div class="text-xs text-danger">Out of Stock</div>
    {{/unless}}
  </div>
</template>;
```

### Reusable Cell Components

Create reusable cell components that can be shared across different tables:

```gts preview
import Component from '@glimmer/component';
import {
  Table,
  type ColumnConfig,
  type CellSignature
} from '@frontile/collections';
import type { TOC } from '@ember/component/template-only';

interface Product {
  id: string;
  name: string;
  price: number;
  inStock: boolean;
  category: string;
}

// Reusable components
const PriceCellComponent: TOC<CellSignature<Product>> = <template>
  <div class='text-right'>
    <div class='font-mono text-lg'>${{@row.data.price}}</div>
    {{#unless @row.data.inStock}}
      <div class='text-xs text-danger font-medium'>Out of Stock</div>
    {{/unless}}
  </div>
</template>;

const StockStatusComponent: TOC<CellSignature<Product>> = <template>
  {{#if @row.data.inStock}}
    <span
      class='inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-success/10 text-success'
    >
      <svg class='w-3 h-3 mr-1' fill='currentColor' viewBox='0 0 20 20'>
        <path
          fill-rule='evenodd'
          d='M16.704 4.153a.75.75 0 01.143 1.052l-8 10.5a.75.75 0 01-1.127.075l-4.5-4.5a.75.75 0 011.06-1.06l3.894 3.893 7.48-9.817a.75.75 0 011.05-.143z'
          clip-rule='evenodd'
        ></path>
      </svg>
      In Stock
    </span>
  {{else}}
    <span
      class='inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-danger/10 text-danger'
    >
      <svg class='w-3 h-3 mr-1' fill='currentColor' viewBox='0 0 20 20'>
        <path
          fill-rule='evenodd'
          d='M10 18a8 8 0 100-16 8 8 0 000 16zM8.28 7.22a.75.75 0 00-1.06 1.06L8.94 10l-1.72 1.72a.75.75 0 101.06 1.06L10 11.06l1.72 1.72a.75.75 0 101.06-1.06L11.06 10l1.72-1.72a.75.75 0 00-1.06-1.06L10 8.94 8.28 7.22z'
          clip-rule='evenodd'
        ></path>
      </svg>
      Out of Stock
    </span>
  {{/if}}
</template>;

const CategoryBadgeComponent: TOC<CellSignature<Product>> = <template>
  <span
    class='inline-block px-2 py-1 text-xs font-medium rounded bg-muted/30 text-default'
  >
    {{@row.data.category}}
  </span>
</template>;

export default class DemoComponent extends Component {
  columns = [
    {
      key: 'name',
      name: 'Product Name'
    },
    {
      key: 'category',
      name: 'Category',
      Cell: CategoryBadgeComponent
    },
    {
      key: 'price',
      name: 'Price',
      Cell: PriceCellComponent
    },
    {
      key: 'inStock',
      name: 'Availability',
      Cell: StockStatusComponent
    }
  ] as const satisfies ColumnConfig<Product>[];

  items: Product[] = [
    {
      id: '1',
      name: 'Wireless Headphones',
      price: 199.99,
      inStock: true,
      category: 'Electronics'
    },
    {
      id: '2',
      name: 'Coffee Mug',
      price: 12.99,
      inStock: false,
      category: 'Kitchen'
    },
    {
      id: '3',
      name: 'Notebook Set',
      price: 24.99,
      inStock: true,
      category: 'Office'
    }
  ];

  <template><Table @columns={{this.columns}} @items={{this.items}} /></template>
}
```

### Combining Cell Components with Value Functions

You can use both `Cell` components and `value` functions together. The `value` function will be called first to compute the data, then passed to the Cell component:

```gts preview
import Component from '@glimmer/component';
import {
  Table,
  type ColumnConfig,
  type CellSignature
} from '@frontile/collections';
import type { TOC } from '@ember/component/template-only';

interface Sale {
  id: string;
  product: string;
  amount: number;
  date: string;
  salesPerson: string;
}
const FormattedAmountComponent: TOC<CellSignature<Sale>> = <template>
  <div class='text-right'>
    <div class='font-bold text-lg text-success'>{{@value}}</div>
    <div class='text-xs text-muted'>{{@row.data.salesPerson}}</div>
  </div>
</template>;

export default class DemoComponent extends Component {
  columns = [
    {
      key: 'product',
      name: 'Product'
    },
    {
      key: 'amount',
      name: 'Sale Amount',
      value: (ctx) => `$${ctx.row.data.amount.toLocaleString()}`,
      Cell: FormattedAmountComponent
    },
    {
      key: 'date',
      name: 'Date',
      value: (ctx) => new Date(ctx.row.data.date).toLocaleDateString()
    }
  ] as const satisfies ColumnConfig<Sale>[];

  items: Sale[] = [
    {
      id: '1',
      product: 'Enterprise License',
      amount: 50000,
      date: '2024-01-15',
      salesPerson: 'Alice Johnson'
    },
    {
      id: '2',
      product: 'Pro Subscription',
      amount: 1200,
      date: '2024-01-16',
      salesPerson: 'Bob Smith'
    }
  ];

  <template><Table @columns={{this.columns}} @items={{this.items}} /></template>
}
```

### When to Use Cell Components vs :cell Block

Choose the approach that best fits your needs:

#### Use **Column-Level Cell Components** when

- You want to create reusable cell components
- Each column has its own complex rendering logic
- You prefer component composition over conditional rendering
- You're building a component library with standard cell types

#### Use the **:cell Named Block** when

- You need conditional rendering across multiple columns
- You want to share logic between different column types
- You prefer template-based customization
- You need access to the full cell context in one place

Both approaches can be used together in the same table - columns without a `Cell` component will fall back to the `:cell` block or default rendering.

## Custom Header Rendering

The Table component supports custom header content through the `header` named block, allowing you to override the default column names with custom styling, sorting controls, icons, or interactive elements.

### Basic Header Customization

Use the `header` named block to customize how column headers are rendered:

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
    { key: 'name', name: 'Full Name' },
    { key: 'email', name: 'Email Address' },
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

  isNameColumn = (key: string) => key === 'name';
  isEmailColumn = (key: string) => key === 'email';
  isStatusColumn = (key: string) => key === 'status';

  <template>
    <Table @columns={{this.columns}} @items={{this.items}}>
      <:header as |h|>
        {{#if (this.isNameColumn h.column.key)}}
          <div class='flex items-center space-x-2'>
            <svg
              class='w-4 h-4 text-primary'
              fill='currentColor'
              viewBox='0 0 20 20'
            >
              <path
                fill-rule='evenodd'
                d='M10 9a3 3 0 100-6 3 3 0 000 6zm-7 9a7 7 0 1114 0H3z'
                clip-rule='evenodd'
              />
            </svg>
            <span class='font-semibold'>{{h.column.name}}</span>
          </div>
        {{else if (this.isEmailColumn h.column.key)}}
          <div class='flex items-center space-x-2'>
            <svg
              class='w-4 h-4 text-primary'
              fill='currentColor'
              viewBox='0 0 20 20'
            >
              <path
                d='M2.003 5.884L10 9.882l7.997-3.998A2 2 0 0016 4H4a2 2 0 00-1.997 1.884z'
              />
              <path
                d='M18 8.118l-8 4-8-4V14a2 2 0 002 2h12a2 2 0 002-2V8.118z'
              />
            </svg>
            <span class='font-semibold'>{{h.column.name}}</span>
          </div>
        {{else if (this.isStatusColumn h.column.key)}}
          <div class='flex items-center space-x-2'>
            <div class='w-2 h-2 bg-success rounded-full'></div>
            <span class='font-semibold'>{{h.column.name}}</span>
          </div>
        {{else}}
          <span class='font-semibold text-muted'>{{h.column.name}}</span>
        {{/if}}
      </:header>
    </Table>
  </template>
}
```

### Header Context

The `header` block provides access to column information through the yielded context:

- **`h.column`** - The current column configuration object
- **`h.column.key`** - The column key for conditional rendering
- **`h.column.name`** - The display name defined in the column config

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
        <div class='flex items-center justify-between mb-4'>
          <h3 class='text-lg font-semibold'>User Management</h3>
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
    {
      key: 'price',
      name: 'Price',
      value: (ctx) => `$${ctx.row.data.price}`,
      isVisible: true
    },
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
        <div class='flex items-center justify-between mb-4'>
          <h3 class='text-lg font-semibold'>Products</h3>
          <t.ColumnVisibility>
            <:icon>
              <svg
                xmlns='http://www.w3.org/2000/svg'
                fill='none'
                viewBox='0 0 24 24'
                stroke-width='1.5'
                stroke='currentColor'
                class='size-4'
              >
                <path
                  stroke-linecap='round'
                  stroke-linejoin='round'
                  d='M10.5 6h9.75M10.5 6a1.5 1.5 0 1 1-3 0m3 0a1.5 1.5 0 1 0-3 0M3.75 6H7.5m0 0h9.75m-9.75 0a1.5 1.5 0 0 1 3 0m3 0a1.5 1.5 0 0 0 3 0m0 0a1.5 1.5 0 0 1 3 0m6 0a1.5 1.5 0 1 1-3 0M10.5 12h9.75m-9.75 0a1.5 1.5 0 1 1-3 0m3 0a1.5 1.5 0 1 0-3 0M3.75 12H7.5m0 0h9.75m-9.75 0a1.5 1.5 0 0 1 3 0m3 0a1.5 1.5 0 0 0 3 0m0 0a1.5 1.5 0 0 1 3 0m6 0a1.5 1.5 0 1 1-3 0M10.5 18h9.75m-9.75 0a1.5 1.5 0 1 1-3 0m3 0a1.5 1.5 0 1 0-3 0M3.75 18H7.5m0 0h9.75m-9.75 0a1.5 1.5 0 0 1 3 0m3 0a1.5 1.5 0 0 0 3 0m0 0a1.5 1.5 0 0 1 3 0m6 0a1.5 1.5 0 1 1-3 0'
                />
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
        <span class="text-sm text-muted">{{this.items.length}} items</span>
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
