---
label: New
imports:
  - import Signature from 'site/components/signature';
  - import { users, products, employees, type User, type Product, type Employee } from 'site/components/table-demo-data';
---

# Table

A powerful component for displaying structured data with features like sticky headers, sorting, column visibility, and scrollable containers.

**Key Features:**

- Automatic rendering with type-safe column definitions
- Row selection (single or multiple with checkboxes)
- Sticky elements (headers, footers, columns, rows)
- Scrollable containers for large datasets
- Column sorting and visibility controls
- Custom cell and header rendering
- Loading and empty states

For manual composition and custom layouts, use [SimpleTable](./simple-table) instead.

## Import

```js
import { Table, type ColumnConfig } from 'frontile';
```

## Basic Usage

Define columns and items to render a table automatically:

```gts preview
import Component from '@glimmer/component';
import { Table, type ColumnConfig } from 'frontile';
import { users, type User } from 'site/components/table-demo-data';

export default class DemoComponent extends Component {
  columns = [
    { key: 'id', name: 'ID' },
    { key: 'name', name: 'Name' },
    { key: 'email', name: 'Email' },
    { key: 'role', name: 'Role' }
  ] as const satisfies ColumnConfig<User>[];

  <template><Table @columns={{this.columns}} @items={{users}} /></template>
}
```

## Column Configuration

### Custom Value Functions

Transform or compute values dynamically:

```gts preview
import Component from '@glimmer/component';
import { Table, type ColumnConfig } from 'frontile';
import { users, type User } from 'site/components/table-demo-data';

export default class DemoComponent extends Component {
  columns = [
    { key: 'name', name: 'Name' },
    {
      key: 'email',
      name: 'Contact',
      value: (ctx) => ctx.row.data.email.toUpperCase()
    },
    {
      key: 'status',
      name: 'Admin',
      value: (ctx) => (ctx.row.data.role === 'admin' ? 'Yes' : 'No')
    }
  ] as const satisfies ColumnConfig<User>[];

  <template><Table @columns={{this.columns}} @items={{users}} /></template>
}
```

### Column-Level Cell Components

Define reusable Cell components in your column configuration:

```gts preview
import Component from '@glimmer/component';
import {
  Table,
  type ColumnConfig,
  type CellSignature
} from 'frontile';
import { Chip } from 'frontile';
import { users, type User } from 'site/components/table-demo-data';
import type { TOC } from '@ember/component/template-only';

const StatusCell: TOC<CellSignature<User>> = <template>
  <Chip
    @size='sm'
    @appearance='outlined'
    @intent='{{if (eq @row.data.status "active") "success" "danger"}}'
    @withDot={{true}}
  >
    {{@row.data.status}}
  </Chip>
</template>;

export default class DemoComponent extends Component {
  columns = [
    { key: 'name', name: 'Name' },
    { key: 'email', name: 'Email' },
    { key: 'status', name: 'Status', Cell: StatusCell }
  ] as const satisfies ColumnConfig<User>[];

  <template><Table @columns={{this.columns}} @items={{users}} /></template>
}

function eq(a: string | undefined, b: string) {
  return a === b;
}
```

## Styling

Control table appearance with size, striping, and layout options:

```gts preview
import Component from '@glimmer/component';
import { Table, type ColumnConfig } from 'frontile';
import { users, type User } from 'site/components/table-demo-data';
import { hash } from '@ember/helper';

export default class DemoComponent extends Component {
  columns = [
    { key: 'name', name: 'Name' },
    { key: 'email', name: 'Email' },
    { key: 'role', name: 'Role' }
  ] as const satisfies ColumnConfig<User>[];

  <template>
    <Table
      @columns={{this.columns}}
      @items={{users}}
      @size='sm'
      @isStriped={{true}}
      @classes={{hash wrapper='shadow-lg rounded-xl'}}
    />
  </template>
}
```

**Options:**

- `@size` - `sm`, `md` (default), `lg`
- `@isStriped` - Alternating row colors
- `@layout` - `auto` (default), `fixed`
- `@classes` - Custom CSS classes

## Scrollable Tables

Enable scrolling with fixed heights or widths:

```gts preview
import Component from '@glimmer/component';
import { Table, type ColumnConfig } from 'frontile';
import { employees, type Employee } from 'site/components/table-demo-data';
import { hash } from '@ember/helper';

export default class DemoComponent extends Component {
  columns = [
    { key: 'id', name: 'ID' },
    { key: 'name', name: 'Name' },
    { key: 'email', name: 'Email' },
    { key: 'department', name: 'Department' },
    { key: 'role', name: 'Role' }
  ] as const satisfies ColumnConfig<Employee>[];

  <template>
    <Table
      @columns={{this.columns}}
      @items={{employees}}
      @isScrollable={{true}}
      @classes={{hash wrapper='h-48'}}
    />
  </template>
}
```

## Sticky Elements

### Sticky Header

Keep the header visible while scrolling:

```gts preview
import Component from '@glimmer/component';
import { Table, type ColumnConfig } from 'frontile';
import { users, type User } from 'site/components/table-demo-data';
import { hash } from '@ember/helper';

export default class DemoComponent extends Component {
  columns = [
    { key: 'name', name: 'Name' },
    { key: 'email', name: 'Email' },
    { key: 'role', name: 'Role' }
  ] as const satisfies ColumnConfig<User>[];

  moreUsers = [
    ...users,
    ...users.map((u, i) => ({ ...u, id: `${parseInt(u.id) + 3 + i}` })),
    ...users.map((u, i) => ({ ...u, id: `${parseInt(u.id) + 6 + i}` }))
  ];

  <template>
    <Table
      @columns={{this.columns}}
      @items={{this.moreUsers}}
      @isStickyHeader={{true}}
      @isScrollable={{true}}
      @classes={{hash wrapper='h-48'}}
    />
  </template>
}
```

### Sticky Columns

Pin columns to the left or right during horizontal scrolling:

```gts preview
import Component from '@glimmer/component';
import { Table, type ColumnConfig } from 'frontile';
import { employees, type Employee } from 'site/components/table-demo-data';
import { hash } from '@ember/helper';

export default class DemoComponent extends Component {
  columns = [
    {
      key: 'id',
      name: 'ID',
      isSticky: true,
      stickyPosition: 'left'
    },
    { key: 'name', name: 'Name' },
    { key: 'email', name: 'Email' },
    { key: 'phone', name: 'Phone' },
    { key: 'department', name: 'Department' },
    { key: 'role', name: 'Role' },
    { key: 'location', name: 'Location' },
    {
      key: 'actions',
      name: 'Actions',
      isSticky: true,
      stickyPosition: 'right',
      value: () => 'Edit'
    }
  ] as const satisfies ColumnConfig<Employee>[];

  <template>
    <Table
      @columns={{this.columns}}
      @items={{employees}}
      @isScrollable={{true}}
      @classes={{hash wrapper='max-w-2xl'}}
    />
  </template>
}
```

### Sticky Rows

Freeze specific rows by their keys:

```gts preview
import Component from '@glimmer/component';
import { Table, type ColumnConfig } from 'frontile';
import { type User } from 'site/components/table-demo-data';
import { array, hash } from '@ember/helper';

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
    { id: '3', name: 'Bob Johnson', email: 'bob@example.com', role: 'Manager' },
    {
      id: 'guest',
      name: 'Guest User',
      email: 'guest@example.com',
      role: 'Read-only'
    }
  ];

  <template>
    <Table
      @columns={{this.columns}}
      @items={{this.items}}
      @stickyKeys={{array 'admin' 'guest'}}
      @isScrollable={{true}}
      @classes={{hash wrapper='h-48'}}
    />
  </template>
}
```

## Table Footer

Display summary information with `@footerColumns`:

```gts preview
import Component from '@glimmer/component';
import { Table, type ColumnConfig } from 'frontile';
import { products, type Product } from 'site/components/table-demo-data';

export default class DemoComponent extends Component {
  columns = [
    { key: 'name', name: 'Product' },
    { key: 'price', name: 'Price', value: (ctx) => `$${ctx.row.data.price}` },
    { key: 'category', name: 'Category' }
  ] as const satisfies ColumnConfig<Product>[];

  footerColumns = [
    { key: 'label', name: 'Total Items' },
    { key: 'total', name: '$1,109.97' },
    { key: 'categories', name: '2 Categories' }
  ] as const satisfies ColumnConfig[];

  <template>
    <Table
      @columns={{this.columns}}
      @items={{products}}
      @footerColumns={{this.footerColumns}}
    />
  </template>
}
```

**Sticky Footer:** Add `@isStickyFooter={{true}}` to keep the footer visible.

## Loading State

Show loading indicators while data is being fetched:

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { Table, type ColumnConfig } from 'frontile';
import { products, type Product } from 'site/components/table-demo-data';
import { Button } from 'frontile';
import { Select } from 'frontile';

export default class DemoComponent extends Component {
  @tracked isLoading = true;
  @tracked loadingColor = 'primary';

  columns = [
    { key: 'name', name: 'Product' },
    { key: 'price', name: 'Price', value: (ctx) => `$${ctx.row.data.price}` },
    { key: 'category', name: 'Category' }
  ] as const satisfies ColumnConfig<Product>[];

  colorOptions = [
    { key: 'default', name: 'Default' },
    { key: 'primary', name: 'Primary' },
    { key: 'success', name: 'Success' },
    { key: 'warning', name: 'Warning' },
    { key: 'danger', name: 'Danger' }
  ];

  @action toggleLoading() {
    this.isLoading = !this.isLoading;
  }

  @action updateLoadingColor(color: string) {
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
        @items={{products}}
        @isLoading={{this.isLoading}}
        @loadingColor={{this.loadingColor}}
      />
    </div>
  </template>
}
```

### Custom Loading Indicator

Use the `loading` named block for custom indicators:

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { Table, type ColumnConfig } from 'frontile';
import { products, type Product } from 'site/components/table-demo-data';
import { Button } from 'frontile';
import { Spinner } from 'frontile';

export default class DemoComponent extends Component {
  @tracked isLoading = true;

  columns = [
    { key: 'name', name: 'Product' },
    { key: 'price', name: 'Price' },
    { key: 'category', name: 'Category' }
  ] as const satisfies ColumnConfig<Product>[];

  @action toggleLoading() {
    this.isLoading = !this.isLoading;
  }

  <template>
    <div class='space-y-4'>
      <Button @onPress={{this.toggleLoading}} @size='sm' @appearance='outlined'>
        {{if this.isLoading 'Stop Loading' 'Start Loading'}}
      </Button>
      <div class='relative'>
        <Table
          @columns={{this.columns}}
          @items={{products}}
          @isLoading={{this.isLoading}}
        >
          <:loading>
            <div
              class='absolute inset-0 z-10 bg-background/80 backdrop-blur-sm flex items-center justify-center'
            >
              <Spinner @size='lg' />
            </div>
          </:loading>
        </Table>
      </div>
    </div>
  </template>
}
```

## Empty State

### Custom Empty Content

Display custom content when there are no items:

```gts preview
import Component from '@glimmer/component';
import { Table, type ColumnConfig } from 'frontile';
import { type User } from 'site/components/table-demo-data';
import { Button } from 'frontile';

export default class DemoComponent extends Component {
  columns = [
    { key: 'id', name: 'ID' },
    { key: 'name', name: 'Name' },
    { key: 'email', name: 'Email' }
  ] as const satisfies ColumnConfig<User>[];

  emptyItems: User[] = [];

  <template>
    <Table @columns={{this.columns}} @items={{this.emptyItems}}>
      <:empty>
        <div class='text-center py-8'>
          <h3 class='text-lg font-medium mb-2'>No Users Found</h3>
          <p class='text-muted mb-4'>Get started by adding your first user.</p>
          <Button @intent='primary' @size='sm'>Add User</Button>
        </div>
      </:empty>
    </Table>
  </template>
}
```

### Simple Text

Use `@emptyContent` for plain text messages:

```gts preview
import Component from '@glimmer/component';
import { Table, type ColumnConfig } from 'frontile';
import { type User } from 'site/components/table-demo-data';

export default class DemoComponent extends Component {
  columns = [
    { key: 'id', name: 'ID' },
    { key: 'name', name: 'Name' },
    { key: 'email', name: 'Email' }
  ] as const satisfies ColumnConfig<User>[];

  emptyItems: User[] = [];

  <template>
    <Table
      @columns={{this.columns}}
      @items={{this.emptyItems}}
      @emptyContent='No users available'
    />
  </template>
}
```

## Custom Cell Rendering

Use the `:cell` block for custom cell content. Alternatively, you can define a `Cell` component in the [column configuration](#column-level-cell-components) for reusable cell rendering.

```gts preview
import Component from '@glimmer/component';
import { Table, type ColumnConfig } from 'frontile';
import { users, type User } from 'site/components/table-demo-data';
import { Avatar } from 'frontile';
import { Chip } from 'frontile';

export default class DemoComponent extends Component {
  columns = [
    { key: 'name', name: 'Name' },
    { key: 'email', name: 'Email' },
    { key: 'role', name: 'Role' },
    { key: 'status', name: 'Status' }
  ] as const satisfies ColumnConfig<User>[];

  <template>
    <Table @columns={{this.columns}} @items={{users}}>
      <:cell as |c|>
        <c.For @key='name'>
          <div class='flex items-center space-x-2'>
            <Avatar
              @name={{c.value}}
              @size='sm'
              @src='https://i.pravatar.cc/150?img={{c.value}}'
            />
            <span class='font-medium'>{{c.value}}</span>
          </div>
        </c.For>

        <c.For @key='status'>
          <Chip
            @size='sm'
            @appearance='outlined'
            @intent='{{if (eq c.value "active") "success" "danger"}}'
            @withDot={{true}}
          >
            {{c.value}}
          </Chip>

        </c.For>

        <c.Default>
          {{c.value}}
        </c.Default>
      </:cell>
    </Table>
  </template>
}

function eq(a: string | undefined, b: string) {
  return a === b;
}
```

**Context:**

- `c.column` - Column configuration
- `c.row` - Row data
- `c.value` - Computed cell value
- `c.For` - Render for specific column key
- `c.Default` - Fallback for unmatched columns

## Custom Header Rendering

Customize column headers with the `header` block:

```gts preview
import Component from '@glimmer/component';
import { Table, type ColumnConfig } from 'frontile';
import { users, type User } from 'site/components/table-demo-data';

export default class DemoComponent extends Component {
  columns = [
    { key: 'name', name: 'Full Name' },
    { key: 'email', name: 'Email' },
    { key: 'role', name: 'Role' }
  ] as const satisfies ColumnConfig<User>[];

  <template>
    <Table @columns={{this.columns}} @items={{users}}>
      <:header as |h|>
        {{#if (eq h.column.key 'name')}}
          <div class='flex items-center space-x-2'>
            <svg class='w-4 h-4' fill='currentColor' viewBox='0 0 20 20'>
              <path
                fill-rule='evenodd'
                d='M10 9a3 3 0 100-6 3 3 0 000 6zm-7 9a7 7 0 1114 0H3z'
                clip-rule='evenodd'
              />
            </svg>
            <span>{{h.column.name}}</span>
          </div>
        {{else}}
          {{h.column.name}}
        {{/if}}
      </:header>
    </Table>
  </template>
}

function eq(a: string, b: string) {
  return a === b;
}
```

## Body Sections

Add custom rows at the top or bottom of the table body:

```gts preview
import Component from '@glimmer/component';
import { Table, type ColumnConfig } from 'frontile';
import { products, type Product } from 'site/components/table-demo-data';

export default class DemoComponent extends Component {
  columns = [
    { key: 'name', name: 'Product' },
    { key: 'price', name: 'Price', value: (ctx) => `$${ctx.row.data.price}` }
  ] as const satisfies ColumnConfig<Product>[];

  get total() {
    return products.reduce((sum, p) => sum + p.price, 0).toFixed(2);
  }

  <template>
    <Table @columns={{this.columns}} @items={{products}}>
      <:bodyTop>
        <tr>
          <td colspan='2' class='bg-muted/30 px-4 py-2 font-medium'>
            Order Summary
          </td>
        </tr>
      </:bodyTop>
      <:bodyBottom>
        <tr>
          <td colspan='2' class='bg-muted/50 px-4 py-3 flex justify-between'>
            <span>Total:</span>
            <span class='font-semibold'>${{this.total}}</span>
          </td>
        </tr>
      </:bodyBottom>
    </Table>
  </template>
}
```

## Column Visibility

Enable users to show/hide columns with the toolbar:

```gts preview
import Component from '@glimmer/component';
import { Table, type ColumnConfig } from 'frontile';
import { users, type User } from 'site/components/table-demo-data';

export default class DemoComponent extends Component {
  columns = [
    { key: 'id', name: 'ID', isVisible: true },
    { key: 'name', name: 'Name', isVisible: true },
    { key: 'email', name: 'Email', isVisible: false },
    { key: 'role', name: 'Role', isVisible: true }
  ] as const satisfies ColumnConfig<User>[];

  <template>
    <Table @columns={{this.columns}} @items={{users}}>
      <:toolbar as |t|>
        <div class='flex items-center justify-between mb-4'>
          <h3 class='font-semibold'>User Management</h3>
          <t.ColumnVisibility />
        </div>
      </:toolbar>
    </Table>
  </template>
}
```

**Initial State:** Set `isVisible: false` in column config to hide by default.

## Sorting

Enable column sorting with `isSortable` and `@onSort`:

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Table, type ColumnConfig, type SortItem } from 'frontile';
import { type User } from 'site/components/table-demo-data';

export default class DemoComponent extends Component {
  @tracked items: User[] = [
    { id: '1', name: 'Charlie', email: 'charlie@example.com', role: 'user' },
    { id: '2', name: 'Alice', email: 'alice@example.com', role: 'admin' },
    { id: '3', name: 'Bob', email: 'bob@example.com', role: 'user' }
  ];

  columns = [
    { key: 'name', name: 'Name', isSortable: true },
    { key: 'email', name: 'Email', isSortable: true },
    { key: 'role', name: 'Role' }
  ] as const satisfies ColumnConfig<User>[];

  handleSort = (items: User[], sort: SortItem<User>) => {
    if (sort.direction === 'none') return items;

    return [...items].sort((a, b) => {
      const aVal = a[sort.property];
      const bVal = b[sort.property];
      if (!aVal || !bVal) return 0;

      if (sort.direction === 'ascending') {
        return aVal < bVal ? -1 : aVal > bVal ? 1 : 0;
      }
      return aVal > bVal ? -1 : aVal < bVal ? 1 : 0;
    });
  };

  <template>
    <Table
      @columns={{this.columns}}
      @items={{this.items}}
      @onSort={{this.handleSort}}
    />
  </template>
}
```

**Features:**

- Tri-state sorting: descending → ascending → none
- Custom sort property: Use `sortProperty` to sort by a different field
- Initial sort: Set with `@initialSort`

## Row Selection

Enable row selection with `@selectionMode` for single or multiple row selection.

### Multiple Selection

Use checkboxes for multi-select with `selectionMode="multiple"`:

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Table, type ColumnConfig } from 'frontile';
import { type User } from 'site/components/table-demo-data';

export default class DemoComponent extends Component {
  @tracked selectedKeys = new Set<string>();

  items: User[] = [
    { id: '1', name: 'Alice', email: 'alice@example.com', role: 'admin' },
    { id: '2', name: 'Bob', email: 'bob@example.com', role: 'user' },
    { id: '3', name: 'Charlie', email: 'charlie@example.com', role: 'user' }
  ];

  columns = [
    { key: 'name', name: 'Name' },
    { key: 'email', name: 'Email' },
    { key: 'role', name: 'Role' }
  ] as const satisfies ColumnConfig<User>[];

  handleSelectionChange = (keys: Set<string>) => {
    this.selectedKeys = keys;
  };

  <template>
    <div>
      <p class='mb-4 text-sm'>
        Selected: {{this.selectedKeys.size}} row(s)
      </p>
      <Table
        @columns={{this.columns}}
        @items={{this.items}}
        @selectionMode='multiple'
        @selectedKeys={{this.selectedKeys}}
        @onSelectionChange={{this.handleSelectionChange}}
      />
    </div>
  </template>
}
```

### Single Selection

Use row clicks for single selection with `selectionMode="single"`:

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Table, type ColumnConfig } from 'frontile';
import { type User } from 'site/components/table-demo-data';

export default class DemoComponent extends Component {
  @tracked selectedKeys = new Set<string>();

  items: User[] = [
    { id: '1', name: 'Alice', email: 'alice@example.com', role: 'admin' },
    { id: '2', name: 'Bob', email: 'bob@example.com', role: 'user' },
    { id: '3', name: 'Charlie', email: 'charlie@example.com', role: 'user' }
  ];

  columns = [
    { key: 'name', name: 'Name' },
    { key: 'email', name: 'Email' },
    { key: 'role', name: 'Role' }
  ] as const satisfies ColumnConfig<User>[];

  handleSelectionChange = (keys: Set<string>) => {
    this.selectedKeys = keys;
  };

  get selectedUser() {
    const key = [...this.selectedKeys][0];
    return this.items.find((item) => item.id === key);
  }

  <template>
    <div>
      <p class='mb-4 text-sm'>
        Selected: {{if this.selectedUser this.selectedUser.name 'None'}}
      </p>
      <Table
        @columns={{this.columns}}
        @items={{this.items}}
        @selectionMode='single'
        @selectedKeys={{this.selectedKeys}}
        @onSelectionChange={{this.handleSelectionChange}}
      />
    </div>
  </template>
}
```

### Disabled Rows

Prevent specific rows from being selected with `@disabledKeys`:

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Table, type ColumnConfig } from 'frontile';
import { type User } from 'site/components/table-demo-data';

export default class DemoComponent extends Component {
  @tracked selectedKeys = new Set<string>();

  items: User[] = [
    { id: '1', name: 'Alice', email: 'alice@example.com', role: 'admin' },
    { id: '2', name: 'Bob', email: 'bob@example.com', role: 'user' },
    { id: '3', name: 'Charlie', email: 'charlie@example.com', role: 'user' }
  ];

  columns = [
    { key: 'name', name: 'Name' },
    { key: 'email', name: 'Email' },
    { key: 'role', name: 'Role' }
  ] as const satisfies ColumnConfig<User>[];

  disabledKeys = ['1'];

  handleSelectionChange = (keys: Set<string>) => {
    this.selectedKeys = keys;
  };

  <template>
    <div>
      <p class='mb-4 text-sm'>
        Note: Admin users cannot be selected
      </p>
      <Table
        @columns={{this.columns}}
        @items={{this.items}}
        @selectionMode='multiple'
        @selectedKeys={{this.selectedKeys}}
        @onSelectionChange={{this.handleSelectionChange}}
        @disabledKeys={{this.disabledKeys}}
      />
    </div>
  </template>
}
```

### Custom Key Extraction

Provide a custom function to extract unique keys from items:

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Table, type ColumnConfig } from 'frontile';

interface Product {
  sku: string;
  name: string;
  price: number;
}

export default class DemoComponent extends Component {
  @tracked selectedKeys = new Set<string>();

  items: Product[] = [
    { sku: 'ABC-123', name: 'Widget', price: 29.99 },
    { sku: 'DEF-456', name: 'Gadget', price: 49.99 },
    { sku: 'GHI-789', name: 'Doohickey', price: 19.99 }
  ];

  columns = [
    { key: 'sku', name: 'SKU' },
    { key: 'name', name: 'Product' },
    { key: 'price', name: 'Price' }
  ] as const satisfies ColumnConfig<Product>[];

  getItemKey = (item: Product) => item.sku;

  handleSelectionChange = (keys: Set<string>) => {
    this.selectedKeys = keys;
  };

  <template>
    <Table
      @columns={{this.columns}}
      @items={{this.items}}
      @selectionMode='multiple'
      @selectedKeys={{this.selectedKeys}}
      @onSelectionChange={{this.handleSelectionChange}}
      @getKey={{this.getItemKey}}
    />
  </template>
}
```

### Uncontrolled Selection

The Table supports uncontrolled selection where internal state is managed automatically. Simply omit `@selectedKeys` and provide `@onSelectionChange` to monitor selections:

```gts preview
import Component from '@glimmer/component';
import { Table, type ColumnConfig } from 'frontile';
import { type User } from 'site/components/table-demo-data';

export default class DemoComponent extends Component {
  items: User[] = [
    { id: '1', name: 'Alice', email: 'alice@example.com', role: 'admin' },
    { id: '2', name: 'Bob', email: 'bob@example.com', role: 'user' },
    { id: '3', name: 'Charlie', email: 'charlie@example.com', role: 'user' }
  ];

  columns = [
    { key: 'name', name: 'Name' },
    { key: 'email', name: 'Email' },
    { key: 'role', name: 'Role' }
  ] as const satisfies ColumnConfig<User>[];

  handleSelectionChange = (keys: Set<string>) => {
    console.log('Selected keys:', Array.from(keys));
  };

  <template>
    <Table
      @columns={{this.columns}}
      @items={{this.items}}
      @selectionMode='multiple'
      @onSelectionChange={{this.handleSelectionChange}}
    />
  </template>
}
```

### Keyboard Navigation

When selection is enabled, rows can be selected using keyboard:

- **Space** or **Enter**: Toggle selection (multiple mode) or select row (single mode)
- Rows are focusable with `tabindex="0"` for keyboard accessibility
- Disabled rows cannot be selected via keyboard

```gts preview
import Component from '@glimmer/component';
import { Table, type ColumnConfig } from 'frontile';
import { type User } from 'site/components/table-demo-data';

export default class DemoComponent extends Component {
  items: User[] = [
    { id: '1', name: 'Alice', email: 'alice@example.com', role: 'admin' },
    { id: '2', name: 'Bob', email: 'bob@example.com', role: 'user' },
    { id: '3', name: 'Charlie', email: 'charlie@example.com', role: 'user' }
  ];

  columns = [
    { key: 'name', name: 'Name' },
    { key: 'email', name: 'Email' },
    { key: 'role', name: 'Role' }
  ] as const satisfies ColumnConfig<User>[];

  <template>
    <div>
      <p class='mb-4 text-sm text-foreground-600'>
        Focus a row and press Space or Enter to select it
      </p>
      <Table
        @columns={{this.columns}}
        @items={{this.items}}
        @selectionMode='multiple'
      />
    </div>
  </template>
}
```

### Selection Color

Customize the selection highlight color with `@selectionColor`. Available colors: `default`, `primary`, `success`, `warning`, `danger`:

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { Table, type ColumnConfig } from 'frontile';
import { type User } from 'site/components/table-demo-data';
import { Select } from 'frontile';

export default class DemoComponent extends Component {
  @tracked selectedKeys = new Set(['1', '2']);
  @tracked selectionColor = 'primary';

  items: User[] = [
    { id: '1', name: 'Alice', email: 'alice@example.com', role: 'admin' },
    { id: '2', name: 'Bob', email: 'bob@example.com', role: 'user' },
    { id: '3', name: 'Charlie', email: 'charlie@example.com', role: 'user' }
  ];

  columns = [
    { key: 'name', name: 'Name' },
    { key: 'email', name: 'Email' },
    { key: 'role', name: 'Role' }
  ] as const satisfies ColumnConfig<User>[];

  colorOptions = [
    { key: 'default', name: 'Default' },
    { key: 'primary', name: 'Primary' },
    { key: 'success', name: 'Success' },
    { key: 'warning', name: 'Warning' },
    { key: 'danger', name: 'Danger' }
  ];

  handleSelectionChange = (keys: Set<string>) => {
    this.selectedKeys = keys;
  };

  @action updateSelectionColor(color: string) {
    this.selectionColor = color;
  }

  <template>
    <div class='space-y-4'>
      <div class='flex items-end justify-center'>
        <Select
          @inputSize='sm'
          @label='Selection Color'
          @items={{this.colorOptions}}
          @selectedKey={{this.selectionColor}}
          @onSelectionChange={{this.updateSelectionColor}}
          class='w-40'
        />
      </div>
      <Table
        @columns={{this.columns}}
        @items={{this.items}}
        @selectionMode='multiple'
        @selectedKeys={{this.selectedKeys}}
        @onSelectionChange={{this.handleSelectionChange}}
        @selectionColor={{this.selectionColor}}
      />
    </div>
  </template>
}
```

**Features:**

- **Multiple selection**: Checkbox column with select all/none and indeterminate state
- **Single selection**: Row clicks, no checkboxes
- **Controlled/Uncontrolled modes**: Provide `@selectedKeys` for controlled, omit for uncontrolled
- **Keyboard navigation**: Use Space or Enter keys to select rows
- **Disabled rows**: Prevent selection with `@disabledKeys`
- **Custom keys**: Use `@getKey` for non-standard key extraction
- **Selection colors**: Customize highlight with `@selectionColor` (default, primary, success, warning, danger)
- **Sticky selection column**: Auto-sticky on horizontal scroll
- **Select all control**: Hide with `@showSelectAll={{false}}`

## API

<Signature @component="Table" />

### ColumnConfig

```ts
interface ColumnConfig<T = unknown> {
  key: string;
  name: string;
  value?: (ctx: CellContext<T>) => ContentValue;
  isSticky?: boolean;
  stickyPosition?: 'left' | 'right';
  isVisible?: boolean;
  isSortable?: boolean;
  sortProperty?: string;
  Cell?: ComponentLike<CellSignature<T>>;
}
```

### CellSignature

```ts
interface CellSignature<T> {
  Args: {
    row: { data: T };
    column: ColumnConfig<T>;
    value?: ContentValue;
  };
}
```
