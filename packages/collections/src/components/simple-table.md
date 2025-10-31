---
label: New
imports:
  - import Signature from 'site/components/signature';
---

# SimpleTable

The SimpleTable component provides a foundational HTML table structure with consistent styling and theming support. It's designed for manual composition when you need complete control over your table layout without the advanced features of the Table component.

**Key Features:**

- **Manual composition** with block-form yielding
- **Flexible styling** with size variants and striped rows
- **Consistent theming** with the Frontile design system
- **Sticky support** when used with the Table component
- **Lightweight** - no data management or complex behaviors

For automatic rendering with advanced features like sticky elements and data management, use [Table](./table) instead.

## Import

```js
import { SimpleTable } from 'frontile';
```

## Basic Usage

SimpleTable uses block form composition where you manually define the table structure:

```gts preview
import Component from '@glimmer/component';
import { SimpleTable } from 'frontile';

export default class DemoComponent extends Component {
  items = [
    { id: '1', name: 'John Doe', email: 'john@example.com', role: 'admin' },
    { id: '2', name: 'Jane Smith', email: 'jane@example.com', role: 'user' }
  ];

  <template>
    <SimpleTable as |t|>
      <t.Header>
        <t.Column>ID</t.Column>
        <t.Column>Name</t.Column>
        <t.Column>Email</t.Column>
        <t.Column>Role</t.Column>
      </t.Header>
      <t.Body>
        {{#each this.items as |item|}}
          <t.Row>
            <t.Cell>{{item.id}}</t.Cell>
            <t.Cell>{{item.name}}</t.Cell>
            <t.Cell>{{item.email}}</t.Cell>
            <t.Cell>{{item.role}}</t.Cell>
          </t.Row>
        {{/each}}
      </t.Body>
    </SimpleTable>
  </template>
}
```

## Advanced Composition

### Custom Headers

Create complex header layouts with custom content:

```gts preview
import Component from '@glimmer/component';
import { SimpleTable } from 'frontile';
import { Button, Chip } from 'frontile';

export default class DemoComponent extends Component {
  users = [
    {
      id: '1',
      name: 'John Doe',
      email: 'john@example.com',
      status: 'Active',
      chipIntent: 'success'
    },
    {
      id: '2',
      name: 'Jane Smith',
      email: 'jane@example.com',
      status: 'Inactive',
      chipIntent: 'default'
    },
    {
      id: '3',
      name: 'Bob Wilson',
      email: 'bob@example.com',
      status: 'Pending',
      chipIntent: 'warning'
    }
  ];

  <template>
    <SimpleTable as |t|>
      <t.Header>
        <t.Column>
          <span class='flex items-center gap-2'>
            👤 User Info
          </span>
        </t.Column>
        <t.Column>
          <span class='flex items-center gap-2'>
            📧 Contact
          </span>
        </t.Column>
        <t.Column>
          <span class='flex items-center gap-2'>
            🔄 Status
          </span>
        </t.Column>
        <t.Column>
          <span class='flex items-center gap-2'>
            ⚡ Actions
          </span>
        </t.Column>
      </t.Header>
      <t.Body>
        {{#each this.users as |user|}}
          <t.Row>
            <t.Cell>
              <div>
                <div class='font-medium'>{{user.name}}</div>
                <div class='text-sm text-default-500'>ID: {{user.id}}</div>
              </div>
            </t.Cell>
            <t.Cell>{{user.email}}</t.Cell>
            <t.Cell>
              <Chip @intent={{user.chipIntent}} @size='sm'>
                {{user.status}}
              </Chip>
            </t.Cell>
            <t.Cell>
              <Button @variant='link' @size='sm'>
                Edit
              </Button>
            </t.Cell>
          </t.Row>
        {{/each}}
      </t.Body>
    </SimpleTable>
  </template>
}
```

### Custom Cell Content

SimpleTable excels at complex cell layouts and interactive content:

```gts preview
import Component from '@glimmer/component';
import { SimpleTable } from 'frontile';
import { Button, Chip } from 'frontile';

export default class DemoComponent extends Component {
  products = [
    {
      id: '1',
      name: 'Wireless Headphones',
      price: 99.99,
      stock: 15,
      stockStatus: 'In Stock',
      stockChipIntent: 'success'
    },
    {
      id: '2',
      name: 'Smart Watch',
      price: 299.99,
      stock: 3,
      stockStatus: 'Low Stock',
      stockChipIntent: 'warning'
    },
    {
      id: '3',
      name: 'Bluetooth Speaker',
      price: 59.99,
      stock: 0,
      stockStatus: 'Out of Stock',
      stockChipIntent: 'danger'
    }
  ];

  <template>
    <SimpleTable as |t|>
      <t.Header>
        <t.Column>Product</t.Column>
        <t.Column>Price</t.Column>
        <t.Column>Stock</t.Column>
        <t.Column>Actions</t.Column>
      </t.Header>
      <t.Body>
        {{#each this.products as |product|}}
          <t.Row>
            <t.Cell>
              <div>
                <div class='font-medium'>{{product.name}}</div>
                <div class='text-sm text-default-500'>ID: {{product.id}}</div>
              </div>
            </t.Cell>
            <t.Cell>
              <span class='font-medium'>${{product.price}}</span>
            </t.Cell>
            <t.Cell>
              <div class='flex flex-col gap-1'>
                <div class='font-medium'>{{product.stock}} units</div>
                <Chip @intent={{product.stockChipIntent}} @size='sm'>
                  {{product.stockStatus}}
                </Chip>
              </div>
            </t.Cell>
            <t.Cell>
              <div class='flex gap-2'>
                <Button @intent='primary' @size='sm'>
                  Edit
                </Button>
                <Button @intent='danger' @size='sm'>
                  Delete
                </Button>
              </div>
            </t.Cell>
          </t.Row>
        {{/each}}
      </t.Body>
    </SimpleTable>
  </template>
}
```

## Styling & Layout

### Size Variants

Control table spacing with size variants:

```gts preview
import Component from '@glimmer/component';
import { SimpleTable } from 'frontile';

export default class DemoComponent extends Component {
  data = [
    { name: 'John Doe', role: 'Developer' },
    { name: 'Jane Smith', role: 'Designer' }
  ];

  <template>
    <div class='space-y-6'>
      <div>
        <h4 class='font-medium mb-2'>Small (sm) - Compact spacing</h4>
        <SimpleTable @size='sm' as |t|>
          <t.Header>
            <t.Column>Name</t.Column>
            <t.Column>Role</t.Column>
          </t.Header>
          <t.Body>
            {{#each this.data as |item|}}
              <t.Row>
                <t.Cell>{{item.name}}</t.Cell>
                <t.Cell>{{item.role}}</t.Cell>
              </t.Row>
            {{/each}}
          </t.Body>
        </SimpleTable>
      </div>

      <div>
        <h4 class='font-medium mb-2'>Medium (md) - Default spacing</h4>
        <SimpleTable @size='md' as |t|>
          <t.Header>
            <t.Column>Name</t.Column>
            <t.Column>Role</t.Column>
          </t.Header>
          <t.Body>
            {{#each this.data as |item|}}
              <t.Row>
                <t.Cell>{{item.name}}</t.Cell>
                <t.Cell>{{item.role}}</t.Cell>
              </t.Row>
            {{/each}}
          </t.Body>
        </SimpleTable>
      </div>

      <div>
        <h4 class='font-medium mb-2'>Large (lg) - Spacious layout</h4>
        <SimpleTable @size='lg' as |t|>
          <t.Header>
            <t.Column>Name</t.Column>
            <t.Column>Role</t.Column>
          </t.Header>
          <t.Body>
            {{#each this.data as |item|}}
              <t.Row>
                <t.Cell>{{item.name}}</t.Cell>
                <t.Cell>{{item.role}}</t.Cell>
              </t.Row>
            {{/each}}
          </t.Body>
        </SimpleTable>
      </div>
    </div>
  </template>
}
```

### Layout Options

Control column sizing behavior:

```gts preview
import Component from '@glimmer/component';
import { SimpleTable } from 'frontile';

export default class DemoComponent extends Component {
  data = [
    {
      id: '1',
      name: 'John Doe',
      email: 'john.doe.longname@example-company.com',
      department: 'Engineering'
    },
    {
      id: '2',
      name: 'Jane',
      email: 'jane@ex.co',
      department: 'Design'
    }
  ];

  <template>
    <div class='space-y-6'>
      <div>
        <h4 class='font-medium mb-2'>Auto Layout (default) - Content-based
          sizing</h4>
        <SimpleTable @layout='auto' as |t|>
          <t.Header>
            <t.Column>ID</t.Column>
            <t.Column>Name</t.Column>
            <t.Column>Email</t.Column>
            <t.Column>Department</t.Column>
          </t.Header>
          <t.Body>
            {{#each this.data as |item|}}
              <t.Row>
                <t.Cell>{{item.id}}</t.Cell>
                <t.Cell>{{item.name}}</t.Cell>
                <t.Cell>{{item.email}}</t.Cell>
                <t.Cell>{{item.department}}</t.Cell>
              </t.Row>
            {{/each}}
          </t.Body>
        </SimpleTable>
      </div>

      <div>
        <h4 class='font-medium mb-2'>Fixed Layout - Equal column widths</h4>
        <SimpleTable @layout='fixed' as |t|>
          <t.Header>
            <t.Column>ID</t.Column>
            <t.Column>Name</t.Column>
            <t.Column>Email</t.Column>
            <t.Column>Department</t.Column>
          </t.Header>
          <t.Body>
            {{#each this.data as |item|}}
              <t.Row>
                <t.Cell>{{item.id}}</t.Cell>
                <t.Cell>{{item.name}}</t.Cell>
                <t.Cell>{{item.email}}</t.Cell>
                <t.Cell>{{item.department}}</t.Cell>
              </t.Row>
            {{/each}}
          </t.Body>
        </SimpleTable>
      </div>
    </div>
  </template>
}
```

### Striped Rows

Enable alternating row colors for better readability:

```gts preview
import Component from '@glimmer/component';
import { SimpleTable } from 'frontile';
import { Chip } from 'frontile';

export default class DemoComponent extends Component {
  users = [
    {
      name: 'John Doe',
      email: 'john@example.com',
      status: 'Active',
      statusIntent: 'success'
    },
    {
      name: 'Jane Smith',
      email: 'jane@example.com',
      status: 'Active',
      statusIntent: 'success'
    },
    {
      name: 'Bob Johnson',
      email: 'bob@example.com',
      status: 'Inactive',
      statusIntent: 'default'
    },
    {
      name: 'Alice Brown',
      email: 'alice@example.com',
      status: 'Active',
      statusIntent: 'success'
    }
  ];

  <template>
    <SimpleTable @isStriped={{true}} as |t|>
      <t.Header>
        <t.Column>Name</t.Column>
        <t.Column>Email</t.Column>
        <t.Column>Status</t.Column>
      </t.Header>
      <t.Body>
        {{#each this.users as |user|}}
          <t.Row>
            <t.Cell>{{user.name}}</t.Cell>
            <t.Cell>{{user.email}}</t.Cell>
            <t.Cell>
              <Chip @intent={{user.statusIntent}} @size='sm'>
                {{user.status}}
              </Chip>
            </t.Cell>
          </t.Row>
        {{/each}}
      </t.Body>
    </SimpleTable>
  </template>
}
```

### Custom Classes

Apply custom styling to specific table elements:

```gts preview
import Component from '@glimmer/component';
import { SimpleTable } from 'frontile';
import { Chip } from 'frontile';
import { hash } from '@ember/helper';

export default class DemoComponent extends Component {
  items = [
    {
      name: 'Critical Server Issue',
      value: '$1,000',
      priority: 'High',
      priorityIntent: 'danger'
    },
    {
      name: 'Feature Enhancement',
      value: '$500',
      priority: 'Medium',
      priorityIntent: 'warning'
    },
    {
      name: 'Documentation Update',
      value: '$100',
      priority: 'Low',
      priorityIntent: 'success'
    }
  ];

  <template>
    <SimpleTable
      @classes={{hash
        wrapper='border-2 border-primary-200 rounded-lg overflow-hidden'
        table='border-separate border-spacing-0'
        thead='bg-gradient-to-r from-primary-50 to-primary-100'
        th='font-bold text-primary-900 border-b border-primary-200'
        tr='hover:bg-primary-25 transition-colors'
        td='border-b border-primary-100'
      }}
      as |t|
    >
      <t.Header>
        <t.Column>Task Name</t.Column>
        <t.Column>Estimated Value</t.Column>
        <t.Column>Priority</t.Column>
      </t.Header>
      <t.Body>
        {{#each this.items as |item|}}
          <t.Row>
            <t.Cell>{{item.name}}</t.Cell>
            <t.Cell class='font-mono'>{{item.value}}</t.Cell>
            <t.Cell>
              <Chip @intent={{item.priorityIntent}} @size='sm'>
                {{item.priority}}
              </Chip>
            </t.Cell>
          </t.Row>
        {{/each}}
      </t.Body>
    </SimpleTable>
  </template>
}
```

## Table Footers

Add footers for summaries and totals:

```gts preview
import Component from '@glimmer/component';
import { SimpleTable } from 'frontile';

export default class DemoComponent extends Component {
  orders = [
    { id: '#001', product: 'Laptop', quantity: 2, price: 999.99 },
    { id: '#002', product: 'Mouse', quantity: 5, price: 29.99 },
    { id: '#003', product: 'Keyboard', quantity: 3, price: 79.99 }
  ];

  get totalQuantity() {
    return this.orders.reduce((sum, order) => sum + order.quantity, 0);
  }

  get totalValue() {
    return this.orders.reduce(
      (sum, order) => sum + order.quantity * order.price,
      0
    );
  }

  calculateTotal = (quantity, price) => (quantity * price).toFixed(2);

  <template>
    <SimpleTable as |t|>
      <t.Header>
        <t.Column>Order ID</t.Column>
        <t.Column>Product</t.Column>
        <t.Column>Quantity</t.Column>
        <t.Column>Unit Price</t.Column>
        <t.Column>Total</t.Column>
      </t.Header>
      <t.Body>
        {{#each this.orders as |order|}}
          <t.Row>
            <t.Cell>{{order.id}}</t.Cell>
            <t.Cell>{{order.product}}</t.Cell>
            <t.Cell>{{order.quantity}}</t.Cell>
            <t.Cell>${{order.price}}</t.Cell>
            <t.Cell>${{this.calculateTotal order.quantity order.price}}</t.Cell>
          </t.Row>
        {{/each}}
      </t.Body>
      <t.Footer>
        <t.Column colspan='2' class='font-semibold'>Order Summary</t.Column>
        <t.Column class='font-semibold'>{{this.totalQuantity}} items</t.Column>
        <t.Column />
        <t.Column class='font-bold text-lg'>${{this.totalValue}}</t.Column>
      </t.Footer>
    </SimpleTable>
  </template>
}
```

## Loading State

The SimpleTable component supports loading states with different color variants to indicate when data is being fetched or processed. Loading states provide visual feedback to users during async operations.

```gts preview
import Component from '@glimmer/component';
import { SimpleTable } from 'frontile';
import { Select } from 'frontile';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { on } from '@ember/modifier';
import { Button } from 'frontile';

interface Product {
  id: string;
  name: string;
  price: number;
  category: string;
}

export default class DemoComponent extends Component {
  @tracked isLoading = true;
  @tracked loadingColor = 'primary';

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

      <SimpleTable
        @isLoading={{this.isLoading}}
        @loadingColor={{this.loadingColor}}
        as |t|
      >
        <t.Header>
          <t.Column>ID</t.Column>
          <t.Column>Product</t.Column>
          <t.Column>Price</t.Column>
          <t.Column>Category</t.Column>
        </t.Header>
        <t.Body>
          {{#each this.items as |item|}}
            <t.Row>
              <t.Cell>{{item.id}}</t.Cell>
              <t.Cell>{{item.name}}</t.Cell>
              <t.Cell>${{item.price}}</t.Cell>
              <t.Cell>{{item.category}}</t.Cell>
            </t.Row>
          {{/each}}
        </t.Body>
      </SimpleTable>
    </div>
  </template>
}
```

The loading feature supports five color variants:

- **`default`** - Standard gray loading animation
- **`primary`** - Uses the primary theme color
- **`success`** - Green loading animation for success states
- **`warning`** - Orange/yellow loading animation for warnings
- **`danger`** - Red loading animation for error states

## API

<Signature @component="SimpleTable" />
<Signature @component="SimpleTableHeader" />
<Signature @component="SimpleTableBody" />
<Signature @component="SimpleTableFooter" />
<Signature @component="SimpleTableColumn" />
<Signature @component="SimpleTableRow" />
<Signature @component="SimpleTableCell" />
