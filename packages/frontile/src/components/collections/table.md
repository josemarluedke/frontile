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

## Usage

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
import { Table, type ColumnConfig, type CellSignature } from 'frontile';
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

Sticky parts of a table — a frozen header or footer, sticky rows, pinned columns
— are painted with `surface-table`, the same opaque surface as the table itself,
so they cover the rows and columns that scroll under them. Pinned columns keep
their row's selection, hover, and striping.

Tables assume they sit on a canvas-backed page. On any other background, point
`--color-surface-table` at it — in CSS, or through `@classes`:

```gts
<Table
  @columns={{this.columns}}
  @items={{this.items}}
  @isScrollable={{true}}
  @classes={{hash wrapper='[--color-surface-table:var(--color-surface-app)]'}}
/>
```

Whatever you point it at has to be opaque. See
[Surfaces](/docs/theming/design-tokens/surfaces) for the role itself.

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

The hairline under the header shown above is deliberately subtle — it is meant
for tables that already have content and are merely refreshing it. When a
table is loading with nothing on screen yet, prefer the built-in skeleton rows
below instead.

### Built-in skeleton rows

`@skeletonRows` renders placeholder rows while the table is loading and has no
items. It is opt-in, and the number is required rather than defaulted: the row
count is the one thing the table cannot infer, and a wrong default promises ten
rows and delivers three.

Load the data below to watch the placeholders hand off to real rows.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { on } from '@ember/modifier';
import { Table, Button, type ColumnConfig } from 'frontile';
import { users, type User } from 'site/components/table-demo-data';

export default class DemoComponent extends Component {
  columns = [
    { key: 'name', name: 'Name' },
    { key: 'email', name: 'Email' },
    { key: 'role', name: 'Role' }
  ] as const satisfies ColumnConfig<User>[];

  @tracked isLoading = true;
  @tracked items: User[] = [];

  timer?: ReturnType<typeof setTimeout>;

  load = () => {
    this.reset();
    this.timer = setTimeout(() => {
      this.items = users;
      this.isLoading = false;
    }, 1600);
  };

  reset = () => {
    clearTimeout(this.timer);
    this.isLoading = true;
    this.items = [];
  };

  willDestroy() {
    super.willDestroy();
    clearTimeout(this.timer);
  }

  <template>
    <div class='w-full space-y-3'>
      <div class='flex gap-2'>
        <Button @size='sm' @intent='primary' {{on 'click' this.load}}>
          Load data
        </Button>
        <Button @size='sm' @appearance='outlined' {{on 'click' this.reset}}>
          Back to loading
        </Button>
      </div>

      <Table
        @columns={{this.columns}}
        @items={{this.items}}
        @isLoading={{this.isLoading}}
        @skeletonRows={{5}}
      />
    </div>
  </template>
}
```

Placeholder rows fade in one after another, 60ms apart, so they arrive the way
the real rows will rather than appearing as one block. The stagger stops
growing after ten rows — past that the last row would sit blank longer than
many requests take — and `prefers-reduced-motion` turns it off entirely.

Skeleton rows render only when `@isLoading` is true **and** there are no items,
so a refresh, a filter requery, or loading page two never throws away rows the
user is already reading. `@emptyContent` and the `empty` block stay suppressed
while they render, and a `loading` block takes precedence when present.

Each placeholder cell is a [`Skeleton`](/docs/components/utilities/skeleton)
component, sized from the table's `@size` so the bars match the row height.

#### Shaping a column's placeholder

A text bar is wrong for a column that holds an avatar. Set `skeleton` on the
column to pick a shape — it accepts the same values as `Skeleton`'s `@shape`,
and columns that omit it stay text bars.

```gts preview
import { array } from '@ember/helper';
import { Table } from 'frontile';

const columns = [
  { key: 'avatar', name: '', skeleton: 'circle' },
  { key: 'name', name: 'Name' },
  { key: 'thumb', name: 'Preview', skeleton: 'square' },
  { key: 'role', name: 'Role' }
];

<template>
  <Table
    @columns={{columns}}
    @items={{(array)}}
    @isLoading={{true}}
    @skeletonRows={{4}}
  />
</template>
```

Because `circle` and `square` reuse Avatar's size scale, a placeholder in an
`@size="md"` table is the same 32px as the `<Avatar @size="md">` it stands in
for.

This is deliberately only a shape. For anything richer — cells that stack an
icon, a name and a chip, or per-column widths — use `bodyTop` with the yielded
columns and render `Skeleton` yourself for each piece of content.

If neither the built-in skeleton rows nor a custom `bodyTop` layout fit —
for example, an overlay that needs to sit over content that is already on
screen — use the `loading` named block described next.

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
              class='absolute inset-0 z-10 bg-surface-canvas/80 backdrop-blur-sm flex items-center justify-center'
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
import { UserIcon } from 'site/components/icons';

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
            <UserIcon />
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

### Column-aligned rows in `bodyTop` / `bodyBottom`

`bodyTop` and `bodyBottom` yield the columns the table is actually rendering,
along with style-bound `Row` and `Cell` components. Use these instead of
hand-written `<tr>`/`<td>` so your rows stay aligned when a column is hidden
via `ColumnVisibility` and when `@selectionMode="multiple"` adds its checkbox
column.

```gts preview
import { array } from '@ember/helper';
import { Table, Skeleton } from 'frontile';

const columns = [
  { key: 'name', name: 'Name' },
  { key: 'email', name: 'Email' }
];

<template>
  <Table @columns={{columns}} @items={{(array)}}>
    <:bodyTop as |b|>
      <b.Row>
        {{#each b.columns as |column|}}
          <b.Cell data-column={{column.key}}>
            <Skeleton />
          </b.Cell>
        {{/each}}
      </b.Row>
    </:bodyTop>
  </Table>
</template>
```

`b.columns` is the rendered column list, not the `@columns` argument you passed
in. Treat `b.columns` as read-only. It is the table's live column list, not a
copy — mutating it in place (`sort`, `push`, `splice`) will corrupt the header
and the rendered rows. Copy it first if you need a different order. `b.Row`
and `b.Cell` carry the table's resolved `@size` padding, sticky handling, and
`@classes` overrides.

The `loading` block yields `{ columns }` only — it renders inside a single
spanning cell, so `Row` and `Cell` would not be valid there. Use it for an
overlay or spinner over a table that already has content; use `bodyTop` for
rows that stand in for content that has not arrived yet.

### Data attributes

These are a supported contract, stable across minor versions:

| Attribute     | Element | Value                         |
| ------------- | ------- | ----------------------------- |
| `data-key`    | `<th>`  | the column's `key`            |
| `data-column` | `<td>`  | the column's `key`            |
| `data-key`    | `<tr>`  | the row's key, from `@getKey` |

Use them for column-targeted styling and test selectors.

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
        Selected:
        {{this.selectedKeys.size}}
        row(s)
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
        Selected:
        {{if this.selectedUser this.selectedUser.name 'None'}}
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

When selection is enabled, rows follow the WAI-ARIA grid pattern:

- **Tab**: Moves into the rows. The table is a single tab stop — it uses a
  roving `tabindex`, so exactly one row is tabbable at a time. That is the first
  selected row, or the first row when nothing is selected.
- **Arrow Down** / **Arrow Up**: Move focus between rows, carrying the
  `tabindex="0"` along with focus.
- **Space** or **Enter**: Toggle selection (multiple mode) or select row (single mode)
- Disabled rows cannot be selected via keyboard, but can still be focused
- Interactive content inside cells keeps its own keys: a button, link or input in
  a cell handles Enter, Space and the arrow keys itself, and the row does not
  toggle its selection. Row keyboard handling only applies to keys pressed on the
  row itself.

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
      <p class='mb-4 text-sm text-neutral-strong'>
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

## Accessibility

Table builds on [SimpleTable](./simple-table.md), so it inherits real table markup and
`scope="col"` header cells — structure and navigation come from the browser rather than ARIA.
On top of that:

| Feature             | What it exposes                                                                              |
| ------------------- | -------------------------------------------------------------------------------------------- |
| Sortable column     | `aria-sort` on the header cell, tracking `none` / `ascending` / `descending`                 |
| Sort control        | A real `<button>` inside the header, so it is focusable and activates on `Enter` and `Space` |
| Sort direction icon | `aria-hidden="true"` — the chevron is decoration, `aria-sort` carries the meaning            |
| Row selection       | A checkbox per row labelled "Select row", and "Select all rows" in the header                |
| Skeleton rows       | `aria-hidden="true"` while loading, so placeholder rows are not announced as data            |

`aria-sort` comes from the underlying table library's header-cell modifier, which applies it
to every header cell — including non-sortable ones, where it reads `none`. That is harmless
but means the attribute's presence is not a reliable signal of whether a column can be
sorted; `data-sortable` is.

Two things to supply yourself:

- **An accessible name for the table.** Add a `<caption>`, or `aria-labelledby` pointing at
  the heading above it.
- **Better selection labels when rows are identifiable.** Every row checkbox is labelled
  "Select row", which is unambiguous only when a screen reader user is already inside the
  row. If your rows have a natural name, render your own checkbox in a cell with a label
  that includes it.

Sticky headers and footers are positioned with CSS and do not change the reading order.

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
