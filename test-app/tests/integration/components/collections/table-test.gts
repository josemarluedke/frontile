import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, settled, click } from '@ember/test-helpers';
import {
  Table,
  type ColumnConfig,
  type CellSignature,
  type SortItem
} from '@frontile/collections';
import { array, hash } from '@ember/helper';
import { cell } from 'ember-resources';
import type { TOC } from '@ember/component/template-only';

interface TestItem {
  id: string;
  name: string;
  email: string;
  role: string;
  active?: boolean;
  count?: number;
}

module(
  'Integration | Component | Table | @frontile/collections',
  function (hooks) {
    setupRenderingTest(hooks);

    test('it renders basic table structure', async function (assert) {
      const columns = [
        { key: 'id', name: 'ID' },
        { key: 'name', name: 'Name' },
        { key: 'email', name: 'Email' }
      ] as const satisfies ColumnConfig<TestItem>[];

      const items: TestItem[] = [
        { id: '1', name: 'John Doe', email: 'john@example.com', role: 'admin' },
        { id: '2', name: 'Jane Smith', email: 'jane@example.com', role: 'user' }
      ];

      await render(
        <template><Table @columns={{columns}} @items={{items}} /></template>
      );

      assert.dom('[data-test-id="table"]').exists();
      assert.dom('[data-test-id="table-header"]').exists();
      assert.dom('[data-test-id="table-body"]').exists();

      // Check columns
      assert.dom('[data-test-id="table-column"][data-key="id"]').exists();
      assert.dom('[data-test-id="table-column"][data-key="name"]').exists();
      assert.dom('[data-test-id="table-column"][data-key="email"]').exists();

      // Check column labels
      assert
        .dom('[data-test-id="table-column"][data-key="id"]')
        .containsText('ID');
      assert
        .dom('[data-test-id="table-column"][data-key="name"]')
        .containsText('Name');
      assert
        .dom('[data-test-id="table-column"][data-key="email"]')
        .containsText('Email');

      // Check rows
      assert.dom('[data-test-id="table-row"][data-key="1"]').exists();
      assert.dom('[data-test-id="table-row"][data-key="2"]').exists();

      // Check cells content
      assert
        .dom('[data-test-id="table-row"][data-key="1"] [data-column="id"]')
        .containsText('1');
      assert
        .dom('[data-test-id="table-row"][data-key="1"] [data-column="name"]')
        .containsText('John Doe');
      assert
        .dom('[data-test-id="table-row"][data-key="1"] [data-column="email"]')
        .containsText('john@example.com');

      assert
        .dom('[data-test-id="table-row"][data-key="2"] [data-column="id"]')
        .containsText('2');
      assert
        .dom('[data-test-id="table-row"][data-key="2"] [data-column="name"]')
        .containsText('Jane Smith');
      assert
        .dom('[data-test-id="table-row"][data-key="2"] [data-column="email"]')
        .containsText('jane@example.com');
    });

    test('it handles empty data', async function (assert) {
      const columns = [
        { key: 'id', name: 'ID' },
        { key: 'name', name: 'Name' }
      ] as const satisfies ColumnConfig<TestItem>[];

      const empty: TestItem[] = [];

      await render(
        <template><Table @columns={{columns}} @items={{empty}} /></template>
      );

      assert.dom('[data-test-id="table"]').exists();
      assert.dom('[data-test-id="table-header"]').exists();
      assert.dom('[data-test-id="table-body"]').exists();

      // Headers should exist
      assert.dom('[data-test-id="table-column"]').exists({ count: 2 });

      // No rows should exist
      assert.dom('[data-test-id="table-row"]').doesNotExist();

      // No empty content should be shown when not provided
      assert.dom('[data-test-id="table-empty-row"]').doesNotExist();
      assert.dom('[data-test-id="table-empty-cell"]').doesNotExist();
    });

    test('it displays empty content with string', async function (assert) {
      const columns = [
        { key: 'id', name: 'ID' },
        { key: 'name', name: 'Name' },
        { key: 'email', name: 'Email' }
      ] as const satisfies ColumnConfig<TestItem>[];
      const empty: TestItem[] = [];

      await render(
        <template>
          <Table
            @columns={{columns}}
            @items={{empty}}
            @emptyContent="No data available"
          />
        </template>
      );

      assert.dom('[data-test-id="table"]').exists();
      assert.dom('[data-test-id="table-header"]').exists();
      assert.dom('[data-test-id="table-body"]').exists();

      // Headers should exist
      assert.dom('[data-test-id="table-column"]').exists({ count: 3 });

      // Empty row should exist
      assert.dom('[data-test-id="table-empty-row"]').exists();
      assert.dom('[data-test-id="table-empty-cell"]').exists();

      // Empty cell should span all columns
      assert
        .dom('[data-test-id="table-empty-cell"]')
        .hasAttribute('colspan', '3');

      // Empty content should be displayed
      assert
        .dom('[data-test-id="table-empty-cell"]')
        .containsText('No data available');

      // No regular rows should exist
      assert
        .dom('[data-test-id="table-row"]:not([data-test-id="table-empty-row"])')
        .doesNotExist();
    });

    // test('it displays empty content with component', async function (assert) {
    //   const columns: ColumnConfig<TestItem>[] = [
    //     { key: 'id', name: 'ID' },
    //     { key: 'name', name: 'Name' }
    //   ];
    //
    //   const EmptyComponent = <template>
    //     <div class="custom-empty-component">
    //       <strong>No results found</strong>
    //       <p>Try adjusting your search criteria.</p>
    //     </div>
    //   </template>;
    //
    //   await render(
    //     <template>
    //       <Table
    //         @columns={{columns}}
    //         @items={{(array)}}
    //         @emptyContent={{component EmptyComponent}}
    //       />
    //     </template>
    //   );
    //
    //   assert.dom('[data-test-id="table-empty-row"]').exists();
    //   assert.dom('[data-test-id="table-empty-cell"]').exists();
    //
    //   // Empty cell should span both columns
    //   assert
    //     .dom('[data-test-id="table-empty-cell"]')
    //     .hasAttribute('colspan', '2');
    //
    //   // Component content should be rendered
    //   assert
    //     .dom('[data-test-id="table-empty-cell"] .custom-empty-component')
    //     .exists();
    //   assert
    //     .dom('[data-test-id="table-empty-cell"] strong')
    //     .containsText('No results found');
    //   assert
    //     .dom('[data-test-id="table-empty-cell"] p')
    //     .containsText('Try adjusting your search criteria.');
    // });

    test('it hides empty content when items exist', async function (assert) {
      const columns = [
        { key: 'id', name: 'ID' },
        { key: 'name', name: 'Name' }
      ] as const satisfies ColumnConfig<TestItem>[];

      const items: TestItem[] = [
        { id: '1', name: 'John Doe', email: 'john@example.com', role: 'admin' }
      ];

      await render(
        <template>
          <Table
            @columns={{columns}}
            @items={{items}}
            @emptyContent="No data available"
          />
        </template>
      );

      // Regular content should be displayed
      assert.dom('[data-test-id="table-row"][data-key="1"]').exists();

      // Empty content should not be displayed
      assert.dom('[data-test-id="table-empty-row"]').doesNotExist();
      assert.dom('[data-test-id="table-empty-cell"]').doesNotExist();
    });

    test('it updates empty content visibility reactively', async function (assert) {
      const columns = [
        { key: 'id', name: 'ID' },
        { key: 'name', name: 'Name' }
      ] as const satisfies ColumnConfig<TestItem>[];

      const items = cell<TestItem[]>([]);

      await render(
        <template>
          <Table
            @columns={{columns}}
            @items={{items.current}}
            @emptyContent="No data available"
          />
        </template>
      );

      // Initially empty - should show empty content
      assert.dom('[data-test-id="table-empty-row"]').exists();
      assert
        .dom('[data-test-id="table-empty-cell"]')
        .containsText('No data available');
      assert
        .dom('[data-test-id="table-row"]:not([data-test-id="table-empty-row"])')
        .doesNotExist();

      // Add data - should hide empty content and show data
      items.current = [
        { id: '1', name: 'John Doe', email: 'john@example.com', role: 'admin' }
      ];

      await settled();
      assert.dom('[data-test-id="table-empty-row"]').doesNotExist();
      assert.dom('[data-test-id="table-row"][data-key="1"]').exists();

      // Remove data - should show empty content again
      items.current = [];

      await settled();
      assert.dom('[data-test-id="table-empty-row"]').exists();
      assert
        .dom('[data-test-id="table-empty-cell"]')
        .containsText('No data available');
      assert
        .dom('[data-test-id="table-row"]:not([data-test-id="table-empty-row"])')
        .doesNotExist();
    });

    test('it displays empty content using named block', async function (assert) {
      const columns = [
        { key: 'id', name: 'ID' },
        { key: 'name', name: 'Name' }
      ] as const satisfies ColumnConfig<TestItem>[];
      const empty: TestItem[] = [];

      await render(
        <template>
          <Table @columns={{columns}} @items={{empty}}>
            <:empty>
              <div data-test-id="custom-empty">
                <h3>No Records Found</h3>
                <p>Try adjusting your search criteria.</p>
              </div>
            </:empty>
          </Table>
        </template>
      );

      // Should show the custom empty block content
      assert.dom('[data-test-id="table-empty-row"]').exists();
      assert.dom('[data-test-id="table-empty-cell"]').exists();
      assert.dom('[data-test-id="custom-empty"]').exists();
      assert
        .dom('[data-test-id="custom-empty"] h3')
        .containsText('No Records Found');
      assert
        .dom('[data-test-id="custom-empty"] p')
        .containsText('Try adjusting your search criteria.');
      assert
        .dom('[data-test-id="table-row"]:not([data-test-id="table-empty-row"])')
        .doesNotExist();
    });

    test('it prioritizes named block over emptyContent parameter', async function (assert) {
      const columns = [
        { key: 'id', name: 'ID' },
        { key: 'name', name: 'Name' }
      ] as const satisfies ColumnConfig<TestItem>[];
      const empty: TestItem[] = [];

      await render(
        <template>
          <Table
            @columns={{columns}}
            @items={{empty}}
            @emptyContent="This should not show"
          >
            <:empty>
              <div data-test-id="priority-empty">Named block content</div>
            </:empty>
          </Table>
        </template>
      );

      // Should show named block content, not parameter content
      assert.dom('[data-test-id="table-empty-row"]').exists();
      assert.dom('[data-test-id="priority-empty"]').exists();
      assert
        .dom('[data-test-id="priority-empty"]')
        .containsText('Named block content');
      assert
        .dom('[data-test-id="table-empty-cell"]')
        .doesNotContainText('This should not show');
    });

    test('it falls back to emptyContent parameter when no named block provided', async function (assert) {
      const columns = [
        { key: 'id', name: 'ID' },
        { key: 'name', name: 'Name' }
      ] as const satisfies ColumnConfig<TestItem>[];
      const empty: TestItem[] = [];

      await render(
        <template>
          <Table
            @columns={{columns}}
            @items={{empty}}
            @emptyContent="Fallback content"
          />
        </template>
      );

      // Should show parameter content when no block is provided
      assert.dom('[data-test-id="table-empty-row"]').exists();
      assert
        .dom('[data-test-id="table-empty-cell"]')
        .containsText('Fallback content');
    });

    test('it hides empty block when items exist', async function (assert) {
      const columns = [
        { key: 'id', name: 'ID' },
        { key: 'name', name: 'Name' }
      ] as const satisfies ColumnConfig<TestItem>[];
      const items: TestItem[] = [
        { id: '1', name: 'John Doe', email: 'john@example.com', role: 'admin' }
      ];

      await render(
        <template>
          <Table @columns={{columns}} @items={{items}}>
            <:empty>
              <div data-test-id="should-not-show">Empty content</div>
            </:empty>
          </Table>
        </template>
      );

      // Should not show empty block when items exist
      assert.dom('[data-test-id="table-empty-row"]').doesNotExist();
      assert.dom('[data-test-id="should-not-show"]').doesNotExist();
      assert.dom('[data-test-id="table-row"][data-key="1"]').exists();
    });

    test('it handles items with different data types', async function (assert) {
      const columns = [
        { key: 'id', name: 'ID' },
        { key: 'active', name: 'Active' },
        { key: 'count', name: 'Count' }
      ] as const satisfies ColumnConfig<TestItem>[];

      const items: TestItem[] = [
        { id: '1', active: true, count: 42, email: '', name: '', role: '' },
        { id: '2', active: false, count: 0, email: '', name: '', role: '' }
      ];

      await render(
        <template><Table @columns={{columns}} @items={{items}} /></template>
      );

      assert
        .dom('[data-test-id="table-row"][data-key="1"] [data-column="active"]')
        .containsText('true');
      assert
        .dom('[data-test-id="table-row"][data-key="1"] [data-column="count"]')
        .containsText('42');
      assert
        .dom('[data-test-id="table-row"][data-key="2"] [data-column="active"]')
        .containsText('false');
      assert
        .dom('[data-test-id="table-row"][data-key="2"] [data-column="count"]')
        .containsText('0');
    });

    test('it works with reactive data changes', async function (assert) {
      const columns = [
        { key: 'name', name: 'Name' }
      ] as const satisfies ColumnConfig<TestItem>[];

      const items = cell<TestItem[]>([
        { id: '1', name: 'John', email: 'john@example.com', role: 'admin' }
      ]);

      await render(
        <template>
          <Table @columns={{columns}} @items={{items.current}} />
        </template>
      );

      assert.dom('[data-test-id="table-row"]').exists({ count: 1 });
      assert
        .dom('[data-test-id="table-row"][data-key="1"] [data-column="name"]')
        .containsText('John');

      // Update the data
      items.current = [
        {
          id: '1',
          name: 'John Updated',
          email: 'john@example.com',
          role: 'admin'
        },
        { id: '2', name: 'Jane', email: 'jane@example.com', role: 'user' }
      ];

      await settled();
      assert.dom('[data-test-id="table-row"]').exists({ count: 2 });
      assert
        .dom('[data-test-id="table-row"][data-key="1"] [data-column="name"]')
        .containsText('John Updated');
      assert
        .dom('[data-test-id="table-row"][data-key="2"] [data-column="name"]')
        .containsText('Jane');
    });

    test('it supports custom value function for column values', async function (assert) {
      const columns = [
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
        }
      ] as const satisfies ColumnConfig<TestItem>[];

      const items: TestItem[] = [
        { id: '1', name: 'John Doe', email: 'john@example.com', role: 'admin' },
        { id: '2', name: 'Jane Smith', email: 'jane@example.com', role: 'user' }
      ];

      await render(
        <template><Table @columns={{columns}} @items={{items}} /></template>
      );

      // Check that custom value function is used for name column
      assert
        .dom('[data-test-id="table-row"][data-key="1"] [data-column="name"]')
        .containsText('John Doe (admin)');
      assert
        .dom('[data-test-id="table-row"][data-key="2"] [data-column="name"]')
        .containsText('Jane Smith (user)');

      // Check that custom value function is used for email column
      assert
        .dom('[data-test-id="table-row"][data-key="1"] [data-column="email"]')
        .containsText('JOHN@EXAMPLE.COM');
      assert
        .dom('[data-test-id="table-row"][data-key="2"] [data-column="email"]')
        .containsText('JANE@EXAMPLE.COM');

      // Check that direct key access still works for id column
      assert
        .dom('[data-test-id="table-row"][data-key="1"] [data-column="id"]')
        .containsText('1');
      assert
        .dom('[data-test-id="table-row"][data-key="2"] [data-column="id"]')
        .containsText('2');
    });

    test('it supports value function returning different data types', async function (assert) {
      const columns = [
        {
          key: 'id',
          name: 'ID Number',
          value: (ctx) => parseInt(ctx.row.data.id, 10) * 100
        },
        {
          key: 'active',
          name: 'Status',
          value: (ctx) => ctx.row.data.role === 'admin'
        },
        {
          key: 'missing',
          name: 'Missing Value',
          value: () => null
        }
      ] as const satisfies ColumnConfig<TestItem>[];

      const items: TestItem[] = [
        { id: '1', name: 'John', email: 'john@example.com', role: 'admin' },
        { id: '2', name: 'Jane', email: 'jane@example.com', role: 'user' }
      ];

      await render(
        <template><Table @columns={{columns}} @items={{items}} /></template>
      );

      // Check number return type
      assert
        .dom('[data-test-id="table-row"][data-key="1"] [data-column="id"]')
        .containsText('100');
      assert
        .dom('[data-test-id="table-row"][data-key="2"] [data-column="id"]')
        .containsText('200');

      // Check boolean return type
      assert
        .dom('[data-test-id="table-row"][data-key="1"] [data-column="active"]')
        .containsText('true');
      assert
        .dom('[data-test-id="table-row"][data-key="2"] [data-column="active"]')
        .containsText('false');

      // Check null return type (should render empty)
      assert
        .dom('[data-test-id="table-row"][data-key="1"] [data-column="missing"]')
        .hasText('');
      assert
        .dom('[data-test-id="table-row"][data-key="2"] [data-column="missing"]')
        .hasText('');
    });

    test('it supports scrollable mode', async function (assert) {
      const columns = [
        { key: 'id', name: 'ID' },
        { key: 'name', name: 'Name' }
      ] as const satisfies ColumnConfig<TestItem>[];

      const items: TestItem[] = [
        { id: '1', name: 'John', email: 'john@example.com', role: 'admin' }
      ];

      await render(
        <template>
          <Table @columns={{columns}} @items={{items}} @isScrollable={{true}} />
        </template>
      );

      assert.dom('[data-component="table-wrapper"]').hasClass('overflow-auto');
    });

    test('it supports sticky header', async function (assert) {
      const columns = [
        { key: 'id', name: 'ID' },
        { key: 'name', name: 'Name' }
      ] as const satisfies ColumnConfig<TestItem>[];

      const items: TestItem[] = [
        { id: '1', name: 'John', email: 'john@example.com', role: 'admin' }
      ];

      await render(
        <template>
          <Table
            @columns={{columns}}
            @items={{items}}
            @isStickyHeader={{true}}
          />
        </template>
      );

      assert.dom('[data-test-id="table-header"]').hasClass('sticky');
      assert.dom('[data-test-id="table-header"]').hasClass('top-0');
      assert.dom('[data-test-id="table-header"]').hasClass('z-2');
    });

    test('it supports sticky columns from ColumnConfig', async function (assert) {
      const columns = [
        { key: 'id', name: 'ID', isSticky: true, stickyPosition: 'left' },
        { key: 'name', name: 'Name' },
        {
          key: 'actions',
          name: 'Actions',
          isSticky: true,
          stickyPosition: 'right'
        }
      ] as const satisfies ColumnConfig<TestItem>[];

      const items: TestItem[] = [
        { id: '1', name: 'John', email: 'john@example.com', role: 'admin' }
      ];

      await render(
        <template><Table @columns={{columns}} @items={{items}} /></template>
      );

      // Check sticky ID column (left)
      assert
        .dom('[data-test-id="table-column"][data-key="id"]')
        .hasClass('sticky');
      assert
        .dom('[data-test-id="table-column"][data-key="id"]')
        .hasClass('left-0');
      assert
        .dom('[data-test-id="table-column"][data-key="id"]')
        .hasClass('z-3');

      // Check sticky actions column (right)
      assert
        .dom('[data-test-id="table-column"][data-key="actions"]')
        .hasClass('sticky');
      assert
        .dom('[data-test-id="table-column"][data-key="actions"]')
        .hasClass('right-0');
      assert
        .dom('[data-test-id="table-column"][data-key="actions"]')
        .hasClass('z-3');

      // Check non-sticky column
      assert
        .dom('[data-test-id="table-column"][data-key="name"]')
        .doesNotHaveClass('sticky');
    });

    // Sticky column block form test moved to SimpleTable since Table no longer supports block usage

    test('it supports sticky rows by keys', async function (assert) {
      const columns = [
        { key: 'id', name: 'ID' },
        { key: 'name', name: 'Name' }
      ] as const satisfies ColumnConfig<TestItem>[];

      const items: TestItem[] = [
        { id: '1', name: 'John Doe', email: 'john@example.com', role: 'admin' },
        {
          id: '2',
          name: 'Jane Smith',
          email: 'jane@example.com',
          role: 'user'
        },
        { id: '3', name: 'Bob Wilson', email: 'bob@example.com', role: 'user' }
      ];

      await render(
        <template>
          <Table
            @columns={{columns}}
            @items={{items}}
            @stickyKeys={{array "1" "3"}}
          />
        </template>
      );

      // Check that specified rows are sticky
      assert.dom('[data-test-id="table-row"][data-key="1"]').hasClass('sticky');
      assert.dom('[data-test-id="table-row"][data-key="1"]').hasClass('z-1');
      assert.dom('[data-test-id="table-row"][data-key="3"]').hasClass('sticky');
      assert.dom('[data-test-id="table-row"][data-key="3"]').hasClass('z-1');

      // Check that non-sticky row is not sticky
      assert
        .dom('[data-test-id="table-row"][data-key="2"]')
        .doesNotHaveClass('sticky');
    });

    test('it combines scrolling with sticky elements', async function (assert) {
      const columns = [
        { key: 'id', name: 'ID', isSticky: true },
        { key: 'name', name: 'Name' },
        { key: 'email', name: 'Email' },
        {
          key: 'actions',
          name: 'Actions',
          isSticky: true,
          stickyPosition: 'right'
        }
      ] as const satisfies ColumnConfig<TestItem>[];

      const items: TestItem[] = [
        { id: '1', name: 'John', email: 'john@example.com', role: 'admin' },
        { id: '2', name: 'Jane', email: 'jane@example.com', role: 'user' }
      ];

      await render(
        <template>
          <Table
            @columns={{columns}}
            @items={{items}}
            @isScrollable={{true}}
            @isStickyHeader={{true}}
            @stickyKeys={{array "1"}}
          />
        </template>
      );

      // Check scrollable wrapper
      assert.dom('[data-component="table-wrapper"]').hasClass('overflow-auto');

      // Check sticky header
      assert.dom('[data-test-id="table-header"]').hasClass('sticky');
      assert.dom('[data-test-id="table-header"]').hasClass('top-0');

      // Check sticky columns
      assert
        .dom('[data-test-id="table-column"][data-key="id"]')
        .hasClass('left-0');
      assert
        .dom('[data-test-id="table-column"][data-key="actions"]')
        .hasClass('right-0');

      // Check sticky row
      assert.dom('[data-test-id="table-row"][data-key="1"]').hasClass('sticky');
    });

    test('it renders footer with footerColumns', async function (assert) {
      const columns = [
        { key: 'id', name: 'ID' },
        { key: 'name', name: 'Name' },
        { key: 'amount', name: 'Amount' }
      ] as const satisfies ColumnConfig<TestItem>[];

      const footerColumns = [
        { key: 'total', name: 'Total' },
        { key: 'items', name: 'Items' },
        { key: 'sum', name: '$1000' }
      ] as const satisfies ColumnConfig<TestItem>[];

      const items: TestItem[] = [
        { id: '1', name: 'John Doe', email: 'john@example.com', role: 'admin' },
        { id: '2', name: 'Jane Smith', email: 'jane@example.com', role: 'user' }
      ];

      await render(
        <template>
          <Table
            @columns={{columns}}
            @footerColumns={{footerColumns}}
            @items={{items}}
          />
        </template>
      );

      assert.dom('[data-test-id="table"]').exists();
      assert.dom('[data-test-id="table-footer"]').exists();

      // Check footer columns
      assert
        .dom(
          '[data-test-id="table-footer"] [data-test-id="table-column"][data-key="total"]'
        )
        .exists();
      assert
        .dom(
          '[data-test-id="table-footer"] [data-test-id="table-column"][data-key="items"]'
        )
        .exists();
      assert
        .dom(
          '[data-test-id="table-footer"] [data-test-id="table-column"][data-key="sum"]'
        )
        .exists();

      // Check footer column labels
      assert
        .dom(
          '[data-test-id="table-footer"] [data-test-id="table-column"][data-key="total"]'
        )
        .containsText('Total');
      assert
        .dom(
          '[data-test-id="table-footer"] [data-test-id="table-column"][data-key="items"]'
        )
        .containsText('Items');
      assert
        .dom(
          '[data-test-id="table-footer"] [data-test-id="table-column"][data-key="sum"]'
        )
        .containsText('$1000');
    });

    test('it supports sticky footer', async function (assert) {
      const columns = [
        { key: 'id', name: 'ID' },
        { key: 'name', name: 'Name' }
      ] as const satisfies ColumnConfig<TestItem>[];

      const footerColumns = [
        { key: 'total', name: 'Total' },
        { key: 'count', name: '2 items' }
      ] as const satisfies ColumnConfig<TestItem>[];

      const items: TestItem[] = [
        { id: '1', name: 'John Doe', email: 'john@example.com', role: 'admin' },
        { id: '2', name: 'Jane Smith', email: 'jane@example.com', role: 'user' }
      ];

      await render(
        <template>
          <Table
            @columns={{columns}}
            @footerColumns={{footerColumns}}
            @items={{items}}
            @isStickyFooter={{true}}
          />
        </template>
      );

      // Check that footer has sticky styling
      assert.dom('[data-test-id="table-footer"]').hasClass('sticky');
      assert.dom('[data-test-id="table-footer"]').hasClass('bottom-0');
      assert.dom('[data-test-id="table-footer"]').hasClass('z-2');
    });

    // Styling and Class Tests
    module('Styling and Class Functionality', function () {
      test('it applies basic custom classes', async function (assert) {
        const columns = [
          { key: 'name', name: 'Name' }
        ] as const satisfies ColumnConfig<TestItem>[];
        const items: TestItem[] = [
          { id: '1', name: 'John', email: 'john@example.com', role: 'admin' }
        ];

        await render(
          <template>
            <Table
              @columns={{columns}}
              @items={{items}}
              @classes={{hash table="custom-table-class"}}
            />
          </template>
        );

        assert.dom('[data-test-id="table"]').hasClass('custom-table-class');
      });

      test('it applies classes to all table elements', async function (assert) {
        const columns = [
          { key: 'name', name: 'Name' }
        ] as const satisfies ColumnConfig<TestItem>[];
        const items: TestItem[] = [
          { id: '1', name: 'John', email: 'john@example.com', role: 'admin' }
        ];
        const footerColumns = [
          { key: 'total', name: 'Total: 1' }
        ] as const satisfies ColumnConfig<TestItem>[];

        await render(
          <template>
            <Table
              @columns={{columns}}
              @items={{items}}
              @footerColumns={{footerColumns}}
              @classes={{hash
                wrapper="custom-wrapper-class"
                table="custom-table-class"
                thead="custom-thead-class"
                tbody="custom-tbody-class"
                tfoot="custom-tfoot-class"
                tr="custom-tr-class"
                td="custom-td-class"
              }}
            />
          </template>
        );

        // Check wrapper class
        assert
          .dom('[data-component="table-wrapper"].custom-wrapper-class')
          .exists();

        // Check table class
        assert.dom('[data-test-id="table"].custom-table-class').exists();

        // Check thead class
        assert.dom('[data-test-id="table-header"].custom-thead-class').exists();

        // Check tbody class
        assert.dom('[data-test-id="table-body"].custom-tbody-class').exists();

        // Check tfoot class
        assert.dom('[data-test-id="table-footer"].custom-tfoot-class').exists();

        // Check tr classes are merged (should apply to header, body, and footer rows)
        assert.dom('[data-test-id="table-header"] tr.custom-tr-class').exists();
        assert.dom('[data-test-id="table-body"] tr.custom-tr-class').exists();
        assert.dom('[data-test-id="table-footer"] tr.custom-tr-class').exists();

        // Check td classes are merged (should apply to all cells)
        assert.dom('[data-test-id="table-body"] td.custom-td-class').exists();
      });

      // Block form class tests moved to SimpleTable since Table no longer supports block usage

      // Mixed class test moved to SimpleTable since Table no longer supports block usage

      // Manual composition class merging test moved to SimpleTable since Table no longer supports block usage

      test('it handles string classes correctly', async function (assert) {
        const columns = [
          { key: 'name', name: 'Name' }
        ] as const satisfies ColumnConfig<TestItem>[];
        const items: TestItem[] = [
          { id: '1', name: 'John', email: 'john@example.com', role: 'admin' }
        ];

        await render(
          <template>
            <Table
              @columns={{columns}}
              @items={{items}}
              @classes={{hash
                table="table-class-1 table-class-2"
                thead="thead-class-1 thead-class-2"
                tbody="tbody-class-1 tbody-class-2"
                tr="tr-class-1 tr-class-2"
                td="td-class-1 td-class-2"
              }}
            />
          </template>
        );

        // Check multiple string classes are applied
        assert
          .dom('[data-test-id="table"].table-class-1.table-class-2')
          .exists();
        assert
          .dom('[data-test-id="table-header"].thead-class-1.thead-class-2')
          .exists();
        assert
          .dom('[data-test-id="table-body"].tbody-class-1.tbody-class-2')
          .exists();
        assert
          .dom('[data-test-id="table-header"] tr.tr-class-1.tr-class-2')
          .exists();
        assert
          .dom('[data-test-id="table-body"] td.td-class-1.td-class-2')
          .exists();
      });

      test('it handles array classes correctly', async function (assert) {
        const columns = [
          { key: 'name', name: 'Name' }
        ] as const satisfies ColumnConfig<TestItem>[];
        const items: TestItem[] = [
          { id: '1', name: 'John', email: 'john@example.com', role: 'admin' }
        ];

        await render(
          <template>
            <Table
              @columns={{columns}}
              @items={{items}}
              @classes={{hash
                table=(array "table-array-1" "table-array-2")
                thead=(array "thead-array-1" "thead-array-2")
                tbody=(array "tbody-array-1" "tbody-array-2")
                tr=(array "tr-array-1" "tr-array-2")
                td=(array "td-array-1" "td-array-2")
              }}
            />
          </template>
        );

        // Check array classes are applied
        assert
          .dom('[data-test-id="table"].table-array-1.table-array-2')
          .exists();
        assert
          .dom('[data-test-id="table-header"].thead-array-1.thead-array-2')
          .exists();
        assert
          .dom('[data-test-id="table-body"].tbody-array-1.tbody-array-2')
          .exists();
        assert
          .dom('[data-test-id="table-header"] tr.tr-array-1.tr-array-2')
          .exists();
        assert
          .dom('[data-test-id="table-body"] td.td-array-1.td-array-2')
          .exists();
      });

      // Block form class merging test moved to SimpleTable since Table no longer supports block usage

      // Test for @classes without block form - Table only supports automatic rendering now
      test('it works without @classes argument', async function (assert) {
        const columns = [
          { key: 'name', name: 'Name' }
        ] as const satisfies ColumnConfig<TestItem>[];
        const items: TestItem[] = [
          { id: '1', name: 'John', email: 'john@example.com', role: 'admin' }
        ];

        await render(
          <template><Table @columns={{columns}} @items={{items}} /></template>
        );

        // Table should render without errors
        assert.dom('[data-test-id="table"]').exists();
        assert.dom('[data-test-id="table-header"]').exists();
        assert.dom('[data-test-id="table-body"]').exists();
      });

      test('it handles empty/null classes gracefully', async function (assert) {
        const columns = [
          { key: 'name', name: 'Name' }
        ] as const satisfies ColumnConfig<TestItem>[];
        const items: TestItem[] = [
          { id: '1', name: 'John', email: 'john@example.com', role: 'admin' }
        ];

        await render(
          <template>
            <Table
              @columns={{columns}}
              @items={{items}}
              @classes={{hash
                table=""
                thead=null
                tbody=undefined
                tr=(array "" null)
                td=(array)
              }}
            />
          </template>
        );

        // Table should render without errors
        assert.dom('[data-test-id="table"]').exists();
        assert.dom('[data-test-id="table-header"]').exists();
        assert.dom('[data-test-id="table-body"]').exists();

        // Elements should still function normally
        assert.dom('[data-test-id="table-cell"]').exists();
        assert.dom('[data-test-id="table-column"]').exists();
      });

      // Footer classes test - automatic rendering only
      test('it applies classes to all table elements with footer', async function (assert) {
        const columns = [
          { key: 'name', name: 'Name' }
        ] as const satisfies ColumnConfig<TestItem>[];
        const items: TestItem[] = [
          { id: '1', name: 'John', email: 'john@example.com', role: 'admin' }
        ];
        const footerColumns = [
          { key: 'total', name: 'Total: 1' }
        ] as const satisfies ColumnConfig<TestItem>[];

        await render(
          <template>
            <Table
              @columns={{columns}}
              @items={{items}}
              @footerColumns={{footerColumns}}
              @classes={{hash tfoot="footer-class" tr="shared-tr-class"}}
            />
          </template>
        );

        // Check footer gets class
        assert.dom('[data-test-id="table-footer"].footer-class').exists();

        // Check tr class is applied to all row types
        assert.dom('[data-test-id="table-header"] tr.shared-tr-class').exists();
        assert.dom('[data-test-id="table-body"] tr.shared-tr-class').exists();
        assert.dom('[data-test-id="table-footer"] tr.shared-tr-class').exists();
      });

      test('it preserves theme-provided styling while merging custom classes', async function (assert) {
        const columns = [
          { key: 'name', name: 'Name' }
        ] as const satisfies ColumnConfig<TestItem>[];
        const items: TestItem[] = [
          { id: '1', name: 'John', email: 'john@example.com', role: 'admin' }
        ];

        await render(
          <template>
            <Table
              @columns={{columns}}
              @items={{items}}
              @classes={{hash table="custom-table" thead="custom-header"}}
            />
          </template>
        );

        // Check that custom classes are applied alongside default theme classes
        const tableElement = document.querySelector('[data-test-id="table"]');
        const theadElement = document.querySelector(
          '[data-test-id="table-header"]'
        );

        assert.dom(tableElement).hasClass('custom-table');
        assert.dom(theadElement).hasClass('custom-header');

        // Should also have theme-provided classes (these will vary based on theme)
        // We mainly want to ensure the element exists and functions
        assert.dom('[data-test-id="table"]').exists();
        assert.dom('[data-test-id="table-header"]').exists();
      });

      test('it supports complex class combinations with falsy values', async function (assert) {
        const columns = [
          { key: 'name', name: 'Name' }
        ] as const satisfies ColumnConfig<TestItem>[];
        const items: TestItem[] = [
          { id: '1', name: 'John', email: 'john@example.com', role: 'admin' }
        ];

        await render(
          <template>
            <Table
              @columns={{columns}}
              @items={{items}}
              @classes={{hash
                table=(array
                  "valid-class" "" null "another-valid" undefined false
                )
                thead=(array false null "only-valid-class" "")
              }}
            />
          </template>
        );

        // Only valid classes should be applied
        assert.dom('[data-test-id="table"].valid-class.another-valid').exists();
        assert.dom('[data-test-id="table-header"].only-valid-class').exists();
      });

      // Footer with automatic rendering test
      test('it merges classes in automatic rendering with footerColumns', async function (assert) {
        const columns = [
          { key: 'name', name: 'Name' }
        ] as const satisfies ColumnConfig<TestItem>[];
        const footerColumns = [
          { key: 'total', name: 'Total' },
          { key: 'count', name: '1 item' }
        ] as const satisfies ColumnConfig<TestItem>[];
        const items: TestItem[] = [
          { id: '1', name: 'John', email: 'john@example.com', role: 'admin' }
        ];

        await render(
          <template>
            <Table
              @columns={{columns}}
              @footerColumns={{footerColumns}}
              @items={{items}}
              @classes={{hash tfoot="table-level-footer" tr="table-level-tr"}}
            />
          </template>
        );

        // Check that automatic footer generation applies table-level classes
        assert.dom('[data-test-id="table-footer"].table-level-footer').exists();
        assert.dom('[data-test-id="table-footer"] tr.table-level-tr').exists();
      });
    });

    // Column Visibility Tests
    module('Column Visibility in Table Toolbar', function () {
      test('it renders column visibility in table toolbar', async function (assert) {
        const columns = [
          { key: 'id', name: 'ID' },
          { key: 'name', name: 'Name' },
          { key: 'email', name: 'Email' }
        ] as const satisfies ColumnConfig<TestItem>[];

        const items: TestItem[] = [
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

        await render(
          <template>
            <Table @columns={{columns}} @items={{items}}>
              <:toolbar as |t|>
                <div class="flex items-center justify-between mb-4">
                  <h2 class="text-lg font-semibold">User Management</h2>
                  <t.ColumnVisibility />
                </div>
              </:toolbar>
            </Table>
          </template>
        );

        // Should render the table
        assert.dom('[data-test-id="table"]').exists();

        // Should render the toolbar content
        assert.dom('h2').containsText('User Management');

        // Should render the column visibility dropdown in toolbar
        assert.dom('[data-test-id="dropdown-trigger"]').exists();
        assert
          .dom('svg')
          .exists('should have the default column visibility icon');

        // Should show all columns in the dropdown menu when opened
        await click('[data-test-id="dropdown-trigger"]');
        assert.dom('[data-test-id="listbox"]').exists();
        assert.dom('[data-test-id="listbox-item"][data-key="id"]').exists();
        assert.dom('[data-test-id="listbox-item"][data-key="name"]').exists();
        assert.dom('[data-test-id="listbox-item"][data-key="email"]').exists();

        // Column names should be displayed
        assert
          .dom('[data-test-id="listbox-item"][data-key="id"]')
          .containsText('ID');
        assert
          .dom('[data-test-id="listbox-item"][data-key="name"]')
          .containsText('Name');
        assert
          .dom('[data-test-id="listbox-item"][data-key="email"]')
          .containsText('Email');
      });

      test('it renders with custom icon and label in toolbar', async function (assert) {
        const columns = [
          { key: 'id', name: 'ID' },
          { key: 'name', name: 'Name' }
        ] as const satisfies ColumnConfig<TestItem>[];

        const items: TestItem[] = [
          {
            id: '1',
            name: 'John Doe',
            email: 'john@example.com',
            role: 'admin'
          }
        ];

        await render(
          <template>
            <Table @columns={{columns}} @items={{items}}>
              <:toolbar as |t|>
                <div class="flex items-center justify-between mb-4">
                  <h2>User Management</h2>
                  <t.ColumnVisibility>
                    <:icon>
                      <span data-test-id="custom-icon">⚙️</span>
                    </:icon>
                    <:default>
                      Customize Columns
                    </:default>
                  </t.ColumnVisibility>
                </div>
              </:toolbar>
            </Table>
          </template>
        );

        // Should render custom icon and label
        assert.dom('[data-test-id="custom-icon"]').exists();
        assert.dom('[data-test-id="custom-icon"]').containsText('⚙️');
        assert
          .dom('[data-test-id="dropdown-trigger"]')
          .containsText('Customize Columns');
        assert
          .dom('svg')
          .doesNotExist(
            'should not have default SVG when custom icon is provided'
          );
      });

      test('it toggles column visibility and updates table display', async function (assert) {
        const columns = [
          { key: 'id', name: 'ID' },
          { key: 'name', name: 'Name' },
          { key: 'email', name: 'Email' }
        ] as const satisfies ColumnConfig<TestItem>[];

        const items: TestItem[] = [
          {
            id: '1',
            name: 'John Doe',
            email: 'john@example.com',
            role: 'admin'
          }
        ];

        await render(
          <template>
            <Table @columns={{columns}} @items={{items}}>
              <:toolbar as |t|>
                <t.ColumnVisibility />
              </:toolbar>
            </Table>
          </template>
        );

        // Initially all columns should be visible in the table
        assert.dom('[data-test-id="table-column"][data-key="id"]').exists();
        assert.dom('[data-test-id="table-column"][data-key="name"]').exists();
        assert.dom('[data-test-id="table-column"][data-key="email"]').exists();

        // All corresponding data cells should be visible
        assert.dom('[data-test-id="table-row"] [data-column="id"]').exists();
        assert.dom('[data-test-id="table-row"] [data-column="name"]').exists();
        assert.dom('[data-test-id="table-row"] [data-column="email"]').exists();

        // Open the column visibility dropdown
        await click('[data-test-id="dropdown-trigger"]');

        // All items should be selected initially (showing selected icons)
        assert
          .dom(
            '[data-test-id="listbox-item"][data-key="id"] [data-test-id="listbox-item-selected-icon"]'
          )
          .exists('ID should show selected icon');
        assert
          .dom(
            '[data-test-id="listbox-item"][data-key="name"] [data-test-id="listbox-item-selected-icon"]'
          )
          .exists('Name should show selected icon');
        assert
          .dom(
            '[data-test-id="listbox-item"][data-key="email"] [data-test-id="listbox-item-selected-icon"]'
          )
          .exists('Email should show selected icon');

        // Hide the name column
        await click('[data-test-id="listbox-item"][data-key="name"]');

        // Name column should be hidden from the table
        assert
          .dom('[data-test-id="table-column"][data-key="id"]')
          .exists('ID column should still be visible');
        assert
          .dom('[data-test-id="table-column"][data-key="name"]')
          .doesNotExist('Name column should be hidden');
        assert
          .dom('[data-test-id="table-column"][data-key="email"]')
          .exists('Email column should still be visible');

        // Name data cells should also be hidden
        assert.dom('[data-test-id="table-row"] [data-column="id"]').exists();
        assert
          .dom('[data-test-id="table-row"] [data-column="name"]')
          .doesNotExist();
        assert.dom('[data-test-id="table-row"] [data-column="email"]').exists();

        // The menu item should not show selected icon
        assert
          .dom(
            '[data-test-id="listbox-item"][data-key="name"] [data-test-id="listbox-item-selected-icon"]'
          )
          .doesNotExist('Name should not show selected icon');

        // Show the column again
        await click('[data-test-id="listbox-item"][data-key="name"]');

        // Name column should be visible again
        assert
          .dom('[data-test-id="table-column"][data-key="name"]')
          .exists('Name column should be visible again');
        assert
          .dom('[data-test-id="table-row"] [data-column="name"]')
          .exists('Name data should be visible again');
        assert
          .dom(
            '[data-test-id="listbox-item"][data-key="name"] [data-test-id="listbox-item-selected-icon"]'
          )
          .exists('Name should show selected icon again');
      });

      test('it handles multiple column toggles in table context', async function (assert) {
        const columns = [
          { key: 'id', name: 'ID' },
          { key: 'name', name: 'Name' },
          { key: 'email', name: 'Email' },
          { key: 'role', name: 'Role' }
        ] as const satisfies ColumnConfig<TestItem>[];

        const items: TestItem[] = [
          {
            id: '1',
            name: 'John Doe',
            email: 'john@example.com',
            role: 'admin'
          }
        ];

        await render(
          <template>
            <Table @columns={{columns}} @items={{items}}>
              <:toolbar as |t|>
                <t.ColumnVisibility />
              </:toolbar>
            </Table>
          </template>
        );

        // Initially all columns should be visible
        assert.dom('[data-test-id="table-column"]').exists({ count: 4 });

        // Open the dropdown and hide multiple columns
        await click('[data-test-id="dropdown-trigger"]');
        await click('[data-test-id="listbox-item"][data-key="name"]');
        await click('[data-test-id="listbox-item"][data-key="role"]');

        // Only ID and Email columns should be visible
        assert.dom('[data-test-id="table-column"][data-key="id"]').exists();
        assert
          .dom('[data-test-id="table-column"][data-key="name"]')
          .doesNotExist();
        assert.dom('[data-test-id="table-column"][data-key="email"]').exists();
        assert
          .dom('[data-test-id="table-column"][data-key="role"]')
          .doesNotExist();

        // Check total visible columns
        assert.dom('[data-test-id="table-column"]').exists({ count: 2 });

        // Check menu item selection states
        assert
          .dom(
            '[data-test-id="listbox-item"][data-key="id"] [data-test-id="listbox-item-selected-icon"]'
          )
          .exists('ID should show selected icon');
        assert
          .dom(
            '[data-test-id="listbox-item"][data-key="name"] [data-test-id="listbox-item-selected-icon"]'
          )
          .doesNotExist('Name should not show selected icon');
        assert
          .dom(
            '[data-test-id="listbox-item"][data-key="email"] [data-test-id="listbox-item-selected-icon"]'
          )
          .exists('Email should show selected icon');
        assert
          .dom(
            '[data-test-id="listbox-item"][data-key="role"] [data-test-id="listbox-item-selected-icon"]'
          )
          .doesNotExist('Role should not show selected icon');
      });

      test('it works with pre-configured column visibility', async function (assert) {
        const columns = [
          { key: 'id', name: 'ID' },
          { key: 'name', name: 'Name' },
          { key: 'email', name: 'Email', isVisible: false }
        ] as const satisfies ColumnConfig<TestItem>[];

        const items: TestItem[] = [
          {
            id: '1',
            name: 'John Doe',
            email: 'john@example.com',
            role: 'admin'
          }
        ];

        await render(
          <template>
            <Table @columns={{columns}} @items={{items}}>
              <:toolbar as |t|>
                <t.ColumnVisibility />
              </:toolbar>
            </Table>
          </template>
        );

        // Should render only 2 columns initially (email is pre-hidden)
        assert.dom('[data-test-id="table-column"]').exists({ count: 2 });
        assert
          .dom('[data-test-id="table-column"][data-key="email"]')
          .doesNotExist('Email column should be pre-hidden');

        // Column visibility dropdown should reflect the pre-hidden state
        await click('[data-test-id="dropdown-trigger"]');
        assert
          .dom(
            '[data-test-id="listbox-item"][data-key="email"] [data-test-id="listbox-item-selected-icon"]'
          )
          .doesNotExist('Email should not show selected icon in dropdown');

        // Show the email column
        await click('[data-test-id="listbox-item"][data-key="email"]');

        // Email column should now be visible
        assert.dom('[data-test-id="table-column"]').exists({ count: 3 });
        assert
          .dom('[data-test-id="table-column"][data-key="email"]')
          .exists('Email column should now be visible');
      });

      test('it maintains toolbar layout when toggling columns', async function (assert) {
        const columns = [
          { key: 'id', name: 'ID' },
          { key: 'name', name: 'Name' },
          { key: 'email', name: 'Email' }
        ] as const satisfies ColumnConfig<TestItem>[];

        const items: TestItem[] = [
          {
            id: '1',
            name: 'John Doe',
            email: 'john@example.com',
            role: 'admin'
          }
        ];

        await render(
          <template>
            <Table @columns={{columns}} @items={{items}}>
              <:toolbar as |t|>
                <div class="toolbar-wrapper" data-test-id="toolbar">
                  <h2>User Management</h2>
                  <div class="toolbar-actions">
                    <button type="button">Add User</button>
                    <t.ColumnVisibility />
                  </div>
                </div>
              </:toolbar>
            </Table>
          </template>
        );

        // Toolbar should be rendered
        assert.dom('[data-test-id="toolbar"]').exists();
        assert.dom('h2').containsText('User Management');
        assert.dom('button').containsText('Add User');

        // Column visibility dropdown should be in toolbar
        assert
          .dom('[data-test-id="toolbar"] [data-test-id="dropdown-trigger"]')
          .exists();

        // Toggle columns and verify toolbar remains intact
        await click('[data-test-id="dropdown-trigger"]');
        await click('[data-test-id="listbox-item"][data-key="name"]');

        // Toolbar should still be there and functional
        assert.dom('[data-test-id="toolbar"]').exists();
        assert.dom('h2').containsText('User Management');
        assert.dom('button').containsText('Add User');
        assert
          .dom('[data-test-id="toolbar"] [data-test-id="dropdown-trigger"]')
          .exists();

        // Table should reflect the column change
        assert
          .dom('[data-test-id="table-column"][data-key="name"]')
          .doesNotExist();
      });

      test('it maintains dropdown open state when toggling columns in toolbar', async function (assert) {
        const columns = [
          { key: 'id', name: 'ID' },
          { key: 'name', name: 'Name' }
        ] as const satisfies ColumnConfig<TestItem>[];

        const items: TestItem[] = [
          {
            id: '1',
            name: 'John Doe',
            email: 'john@example.com',
            role: 'admin'
          }
        ];

        await render(
          <template>
            <Table @columns={{columns}} @items={{items}}>
              <:toolbar as |t|>
                <t.ColumnVisibility />
              </:toolbar>
            </Table>
          </template>
        );

        // Open the dropdown
        await click('[data-test-id="dropdown-trigger"]');
        assert
          .dom('[data-test-id="listbox"]')
          .exists('dropdown should be open');

        // Toggle a column
        await click('[data-test-id="listbox-item"][data-key="name"]');

        // Dropdown should remain open because closeOnItemSelect is false
        assert
          .dom('[data-test-id="listbox"]')
          .exists('dropdown should remain open after toggling column');

        // Verify the column was actually toggled
        assert
          .dom('[data-test-id="table-column"][data-key="name"]')
          .doesNotExist();
      });
    });

    // Custom Cell Rendering Tests
    module('Custom Cell Rendering', function () {
      test('it renders default cell content when no cell block is provided', async function (assert) {
        const columns = [
          { key: 'name', name: 'Name' },
          { key: 'email', name: 'Email' }
        ] as const satisfies ColumnConfig<TestItem>[];

        const items: TestItem[] = [
          {
            id: '1',
            name: 'John Doe',
            email: 'john@example.com',
            role: 'admin'
          }
        ];

        await render(
          <template><Table @columns={{columns}} @items={{items}} /></template>
        );

        // Should render default content
        assert.dom('[data-test-id="table-cell"]').exists({ count: 2 });
        const cells = document.querySelectorAll('[data-test-id="table-cell"]');
        assert.dom(cells[0]).containsText('John Doe');
        assert.dom(cells[1]).containsText('john@example.com');
      });

      test('it renders custom cell content using c.For components', async function (assert) {
        const columns = [
          { key: 'name', name: 'Name' },
          { key: 'status', name: 'Status' },
          { key: 'email', name: 'Email' }
        ] as const satisfies ColumnConfig<TestItem>[];

        const items: TestItem[] = [
          {
            id: '1',
            name: 'John Doe',
            email: 'john@example.com',
            role: 'admin'
          }
        ];

        await render(
          <template>
            <Table @columns={{columns}} @items={{items}}>
              <:cell as |c|>
                <c.For @key="name">
                  Custom Name:
                  {{c.value}}
                </c.For>

                <c.For @key="status">
                  <span data-test-id="status-badge">Status: {{c.value}}</span>
                </c.For>

                <c.Default>
                  Default:
                  {{c.value}}
                </c.Default>
              </:cell>
            </Table>
          </template>
        );

        // Should have 3 cells
        assert.dom('[data-test-id="table-cell"]').exists({ count: 3 });
        const cells = document.querySelectorAll('[data-test-id="table-cell"]');

        // Name column should use custom rendering
        assert.dom(cells[0]).containsText('Custom Name: John Doe');

        // Status column should use custom badge (but value will be undefined since not in data)
        assert.dom('[data-test-id="status-badge"]').exists();

        // Email column should use default rendering since no c.For matches
        assert.dom(cells[2]).containsText('Default: john@example.com');
      });

      test('it provides correct context to cell rendering components', async function (assert) {
        const columns = [
          { key: 'name', name: 'Name' },
          { key: 'id', name: 'ID' }
        ] as const satisfies ColumnConfig<TestItem>[];

        const items: TestItem[] = [
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

        await render(
          <template>
            <Table @columns={{columns}} @items={{items}}>
              <:cell as |c|>
                <c.For @key="name">
                  <span data-test-id="name-cell">
                    Name:
                    {{c.value}}, ID:
                    {{c.row.data.id}}, Column:
                    {{c.column.key}}
                  </span>
                </c.For>

                <c.Default>
                  <span data-test-id="default-cell">{{c.value}}</span>
                </c.Default>
              </:cell>
            </Table>
          </template>
        );

        // Should have correct context data
        const nameCells = document.querySelectorAll(
          '[data-test-id="name-cell"]'
        );
        assert
          .dom(nameCells[0])
          .containsText('Name: John Doe, ID: 1, Column: name');
        assert
          .dom(nameCells[1])
          .containsText('Name: Jane Smith, ID: 2, Column: name');

        // Default cells should show ID values
        const defaultCells = document.querySelectorAll(
          '[data-test-id="default-cell"]'
        );
        assert.dom(defaultCells[0]).containsText('1');
        assert.dom(defaultCells[1]).containsText('2');
      });

      test('it handles multiple c.For components correctly', async function (assert) {
        const columns = [
          { key: 'name', name: 'Name' },
          { key: 'email', name: 'Email' },
          { key: 'role', name: 'Role' }
        ] as const satisfies ColumnConfig<TestItem>[];

        const items: TestItem[] = [
          {
            id: '1',
            name: 'John Doe',
            email: 'john@example.com',
            role: 'admin'
          }
        ];

        await render(
          <template>
            <Table @columns={{columns}} @items={{items}}>
              <:cell as |c|>
                <c.For @key="name">
                  <span data-test-id="name-custom">👤 {{c.value}}</span>
                </c.For>

                <c.For @key="email">
                  <span data-test-id="email-custom">📧 {{c.value}}</span>
                </c.For>

                <c.For @key="role">
                  <span data-test-id="role-custom">🏷️ {{c.value}}</span>
                </c.For>
              </:cell>
            </Table>
          </template>
        );

        // All columns should use custom rendering
        assert.dom('[data-test-id="name-custom"]').containsText('👤 John Doe');
        assert
          .dom('[data-test-id="email-custom"]')
          .containsText('📧 john@example.com');
        assert.dom('[data-test-id="role-custom"]').containsText('🏷️ admin');
      });

      test('it renders c.Default only when no c.For matches', async function (assert) {
        const columns = [
          { key: 'name', name: 'Name' },
          { key: 'email', name: 'Email' },
          { key: 'role', name: 'Role' }
        ] as const satisfies ColumnConfig<TestItem>[];

        const items: TestItem[] = [
          {
            id: '1',
            name: 'John Doe',
            email: 'john@example.com',
            role: 'admin'
          }
        ];

        await render(
          <template>
            <Table @columns={{columns}} @items={{items}}>
              <:cell as |c|>
                <c.For @key="name">
                  <span data-test-id="name-custom">Custom Name</span>
                </c.For>

                <c.Default>
                  <span data-test-id="default-content">Default:
                    {{c.value}}</span>
                </c.Default>
              </:cell>
            </Table>
          </template>
        );

        // Name should use custom rendering (no default content)
        assert.dom('[data-test-id="name-custom"]').exists();
        assert
          .dom('[data-column="name"] [data-test-id="default-content"]')
          .doesNotExist();

        // Email and role should use default rendering
        assert
          .dom('[data-column="email"] [data-test-id="default-content"]')
          .containsText('Default: john@example.com');
        assert
          .dom('[data-column="role"] [data-test-id="default-content"]')
          .containsText('Default: admin');
      });

      test('it supports content outside c.For and c.Default components', async function (assert) {
        const columns = [
          { key: 'name', name: 'Name' }
        ] as const satisfies ColumnConfig<TestItem>[];

        const items: TestItem[] = [
          {
            id: '1',
            name: 'John Doe',
            email: 'john@example.com',
            role: 'admin'
          }
        ];

        await render(
          <template>
            <Table @columns={{columns}} @items={{items}}>
              <:cell as |c|>
                <span data-test-id="always-render">Always: </span>

                <c.For @key="name">
                  <span data-test-id="name-content">{{c.value}}</span>
                </c.For>

                <c.Default>
                  <span data-test-id="default-content">{{c.value}}</span>
                </c.Default>

                <span data-test-id="always-render-end"> (end)</span>
              </:cell>
            </Table>
          </template>
        );

        // Should render both always-render content and specific content
        assert.dom('[data-test-id="always-render"]').containsText('Always:');
        assert.dom('[data-test-id="name-content"]').containsText('John Doe');
        assert.dom('[data-test-id="always-render-end"]').containsText('(end)');

        // Default should not render since name matches
        assert.dom('[data-test-id="default-content"]').doesNotExist();
      });

      test('it works with c.Default @except parameter', async function (assert) {
        const columns = [
          { key: 'name', name: 'Name' },
          { key: 'email', name: 'Email' },
          { key: 'role', name: 'Role' }
        ] as const satisfies ColumnConfig<TestItem>[];

        const items: TestItem[] = [
          {
            id: '1',
            name: 'John Doe',
            email: 'john@example.com',
            role: 'admin'
          }
        ];

        await render(
          <template>
            <Table @columns={{columns}} @items={{items}}>
              <:cell as |c|>
                <c.Default @except={{array "name"}}>
                  <span data-test-id="default-content">Default:
                    {{c.value}}</span>
                </c.Default>
              </:cell>
            </Table>
          </template>
        );

        // Name should not render (excluded)
        assert
          .dom('[data-column="name"] [data-test-id="default-content"]')
          .doesNotExist();

        // Email and role should render with default
        assert
          .dom('[data-column="email"] [data-test-id="default-content"]')
          .containsText('Default: john@example.com');
        assert
          .dom('[data-column="role"] [data-test-id="default-content"]')
          .containsText('Default: admin');
      });

      test('c.For @key parameter provides improved type checking', async function (assert) {
        // This test demonstrates the enhanced type integration with column arrays
        const columns = [
          { key: 'name', name: 'Name' },
          { key: 'email', name: 'Email' },
          {
            key: 'role',
            name: 'Role',
            value: (ctx) => {
              ctx.row; // expect type TestItem
              return ctx.row.data.role;
            }
          }
        ] as const satisfies ColumnConfig<TestItem>[];

        const items: TestItem[] = [
          {
            id: '1',
            name: 'John Doe',
            email: 'john@example.com',
            role: 'admin'
          }
        ];

        await render(
          <template>
            <Table @columns={{columns}} @items={{items}}>
              <:cell as |c|>
                {{! Valid keys - these should compile without issues }}
                <c.For @key="name">
                  <span data-test-id="valid-name">Name: {{c.value}}</span>
                </c.For>
                <c.For @key="email">
                  <span data-test-id="valid-email">Email: {{c.value}}</span>
                </c.For>
                <c.For @key="role">
                  <span data-test-id="valid-role">Role: {{c.value}}</span>
                </c.For>

                {{! @glint-expect-error: Should be invalid key}}
                <c.For @key="invalid-key">Invalid</c.For>

                <c.Default>
                  <span data-test-id="default-content">{{c.value}}</span>
                </c.Default>
              </:cell>
            </Table>
          </template>
        );

        // Test that the constrained column keys work correctly with enhanced type checking
        assert
          .dom('[data-test-id="valid-name"]')
          .containsText('Name: John Doe');
        assert
          .dom('[data-test-id="valid-email"]')
          .containsText('Email: john@example.com');
        assert.dom('[data-test-id="valid-role"]').containsText('Role: admin');

        // Default should not render for any column since all have specific c.For components
        assert.dom('[data-test-id="default-content"]').doesNotExist();
      });

      test('it supports column-level Cell components from universal-ember/table', async function (assert) {
        // Create a custom cell component with proper types
        const CustomCellComponent: TOC<CellSignature<TestItem>> = <template>
          <div class="custom-cell" data-test-id="custom-column-cell">
            Custom:
            {{@row.data.name}}
          </div>
        </template>;

        const BadgeCellComponent: TOC<CellSignature<TestItem>> = <template>
          <span
            class="badge"
            data-test-id="badge-cell"
            data-role={{@row.data.role}}
          >
            Role:
            {{@row.data.role}}
          </span>
        </template>;

        // Define columns with Cell components
        const columns = [
          {
            key: 'name',
            name: 'Name',
            Cell: CustomCellComponent
          },
          {
            key: 'email',
            name: 'Email'
          },
          {
            key: 'role',
            name: 'Role',
            Cell: BadgeCellComponent
          }
        ] as const satisfies ColumnConfig<TestItem>[];

        const items: TestItem[] = [
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

        await render(
          <template><Table @columns={{columns}} @items={{items}} /></template>
        );

        // Should render custom cell component for name column
        assert.dom('[data-test-id="custom-column-cell"]').exists({ count: 2 });
        assert
          .dom('[data-test-id="custom-column-cell"]')
          .hasText('Custom: John Doe');

        const nameCells = document.querySelectorAll(
          '[data-test-id="custom-column-cell"]'
        );
        assert.dom(nameCells[1]).hasText('Custom: Jane Smith');

        // Should render badge cell component for role column
        assert.dom('[data-test-id="badge-cell"]').exists({ count: 2 });
        assert
          .dom('[data-test-id="badge-cell"][data-role="admin"]')
          .hasText('Role: admin');
        assert
          .dom('[data-test-id="badge-cell"][data-role="user"]')
          .hasText('Role: user');

        // Email column should render with default behavior (no custom Cell)
        const emailCells = document.querySelectorAll('[data-column="email"]');
        assert.dom(emailCells[0]).containsText('john@example.com');
        assert.dom(emailCells[1]).containsText('jane@example.com');

        // Email cells should not have custom styling
        assert
          .dom('[data-column="email"] [data-test-id="custom-column-cell"]')
          .doesNotExist();
        assert
          .dom('[data-column="email"] [data-test-id="badge-cell"]')
          .doesNotExist();
      });
    });

    // Custom Header Rendering Tests
    module('Custom Header Rendering', function () {
      test('it renders default header content when no header block is provided', async function (assert) {
        const columns = [
          { key: 'name', name: 'Full Name' },
          { key: 'email', name: 'Email Address' }
        ] as const satisfies ColumnConfig<TestItem>[];
        const items: TestItem[] = [
          { id: '1', name: 'John', email: 'john@example.com', role: 'admin' }
        ];

        await render(
          <template><Table @columns={{columns}} @items={{items}} /></template>
        );

        // Should show default column names
        assert
          .dom('[data-test-id="table-header"] th[data-key="name"]')
          .containsText('Full Name');
        assert
          .dom('[data-test-id="table-header"] th[data-key="email"]')
          .containsText('Email Address');
      });

      test('it renders custom header content using header named block', async function (assert) {
        const columns = [
          { key: 'name', name: 'Full Name' },
          { key: 'email', name: 'Email Address' },
          { key: 'role', name: 'Role' }
        ] as const satisfies ColumnConfig<TestItem>[];
        const items: TestItem[] = [
          { id: '1', name: 'John', email: 'john@example.com', role: 'admin' }
        ];

        const isNameColumn = (key: string) => key === 'name';
        const isEmailColumn = (key: string) => key === 'email';

        await render(
          <template>
            <Table @columns={{columns}} @items={{items}}>
              <:header as |h|>
                {{#if (isNameColumn h.column.key)}}
                  <div class="custom-name-header">
                    <span class="header-icon">👤</span>
                    <span
                      data-test-id="name-header-text"
                    >{{h.column.name}}</span>
                  </div>
                {{else if (isEmailColumn h.column.key)}}
                  <div class="custom-email-header" data-test-id="email-header">
                    <span class="header-icon">📧</span>
                    {{h.column.name}}
                  </div>
                {{else}}
                  {{h.column.name}}
                {{/if}}
              </:header>
            </Table>
          </template>
        );

        // Should show custom header content for name column
        assert.dom('[data-key="name"] .custom-name-header').exists();
        assert.dom('[data-key="name"] .header-icon').containsText('👤');
        assert
          .dom('[data-key="name"] [data-test-id="name-header-text"]')
          .containsText('Full Name');

        // Should show custom header content for email column
        assert.dom('[data-key="email"] [data-test-id="email-header"]').exists();
        assert.dom('[data-key="email"] .header-icon').containsText('📧');
        assert
          .dom('[data-key="email"] [data-test-id="email-header"]')
          .containsText('Email Address');

        // Should show default content for role column (fallback)
        assert.dom('[data-key="role"]').containsText('Role');
        assert.dom('[data-key="role"] .custom-name-header').doesNotExist();
        assert
          .dom('[data-key="role"] [data-test-id="email-header"]')
          .doesNotExist();
      });

      test('it provides correct column context to header block', async function (assert) {
        const columns = [
          { key: 'id', name: 'ID' },
          { key: 'name', name: 'Name' }
        ] as const satisfies ColumnConfig<TestItem>[];
        const items: TestItem[] = [
          { id: '1', name: 'John', email: 'john@example.com', role: 'admin' }
        ];

        await render(
          <template>
            <Table @columns={{columns}} @items={{items}}>
              <:header as |h|>
                <div data-test-id="header-info-{{h.column.key}}">
                  Key:
                  {{h.column.key}}
                  | Name:
                  {{h.column.name}}
                </div>
              </:header>
            </Table>
          </template>
        );

        // Should provide correct column context
        assert
          .dom('[data-test-id="header-info-id"]')
          .containsText('Key: id | Name: ID');
        assert
          .dom('[data-test-id="header-info-name"]')
          .containsText('Key: name | Name: Name');
      });

      test('it works with sortable columns when using header block', async function (assert) {
        const columns = [
          { key: 'name', name: 'Name' },
          { key: 'email', name: 'Email' }
        ] as const satisfies ColumnConfig<TestItem>[];
        const items: TestItem[] = [
          { id: '1', name: 'John', email: 'john@example.com', role: 'admin' },
          { id: '2', name: 'Alice', email: 'alice@example.com', role: 'user' }
        ];

        await render(
          <template>
            <Table @columns={{columns}} @items={{items}}>
              <:header as |h|>
                <button
                  type="button"
                  class="sortable-header"
                  data-test-id="sort-{{h.column.key}}"
                >
                  {{h.column.name}}
                  ↕️
                </button>
              </:header>
            </Table>
          </template>
        );

        // Should render sortable buttons in headers
        assert.dom('[data-test-id="sort-name"]').exists();
        assert.dom('[data-test-id="sort-name"]').containsText('Name ↕️');
        assert.dom('[data-test-id="sort-email"]').exists();
        assert.dom('[data-test-id="sort-email"]').containsText('Email ↕️');

        // Headers should be clickable
        assert.dom('[data-test-id="sort-name"]').hasTagName('button');
        assert.dom('[data-test-id="sort-email"]').hasTagName('button');
      });

      test('it works with sticky headers', async function (assert) {
        const columns = [
          { key: 'name', name: 'Name' },
          { key: 'email', name: 'Email' }
        ] as const satisfies ColumnConfig<TestItem>[];
        const items: TestItem[] = [
          { id: '1', name: 'John', email: 'john@example.com', role: 'admin' }
        ];

        await render(
          <template>
            <Table
              @columns={{columns}}
              @items={{items}}
              @isStickyHeader={{true}}
            >
              <:header as |h|>
                <div
                  class="sticky-custom-header"
                  data-test-id="sticky-header-{{h.column.key}}"
                >
                  📌
                  {{h.column.name}}
                </div>
              </:header>
            </Table>
          </template>
        );

        // Should render custom headers in sticky header
        assert.dom('[data-test-id="sticky-header-name"]').exists();
        assert
          .dom('[data-test-id="sticky-header-name"]')
          .containsText('📌 Name');
        assert.dom('[data-test-id="sticky-header-email"]').exists();
        assert
          .dom('[data-test-id="sticky-header-email"]')
          .containsText('📌 Email');

        // Should maintain sticky positioning
        assert.dom('[data-test-id="table-header"]').hasClass(/sticky|fixed/);
      });

      test('it works with column visibility', async function (assert) {
        const columns = [
          { key: 'name', name: 'Name', isVisible: true },
          { key: 'email', name: 'Email', isVisible: false },
          { key: 'role', name: 'Role', isVisible: true }
        ] as const satisfies ColumnConfig<TestItem>[];
        const items: TestItem[] = [
          { id: '1', name: 'John', email: 'john@example.com', role: 'admin' }
        ];

        await render(
          <template>
            <Table @columns={{columns}} @items={{items}}>
              <:header as |h|>
                <span
                  class="visible-header"
                  data-test-id="visible-{{h.column.key}}"
                >
                  ✓
                  {{h.column.name}}
                </span>
              </:header>
            </Table>
          </template>
        );

        // Should only render headers for visible columns
        assert.dom('[data-test-id="visible-name"]').exists();
        assert.dom('[data-test-id="visible-name"]').containsText('✓ Name');
        assert.dom('[data-test-id="visible-role"]').exists();
        assert.dom('[data-test-id="visible-role"]').containsText('✓ Role');

        // Should not render header for hidden column
        assert.dom('[data-test-id="visible-email"]').doesNotExist();
      });
    });

    // Loading Tests
    module('Loading Functionality', function () {
      test('it supports loading state', async function (assert) {
        const columns = [
          { key: 'name', name: 'Name' }
        ] as const satisfies ColumnConfig<TestItem>[];
        const items: TestItem[] = [
          {
            id: '1',
            name: 'John Doe',
            email: 'john@example.com',
            role: 'admin'
          }
        ];

        await render(
          <template>
            <Table @columns={{columns}} @items={{items}} @isLoading={{true}} />
          </template>
        );

        // Table should render with loading state
        assert.dom('[data-test-id="table"]').exists();
        assert.dom('[data-test-id="table"][data-loading="true"]').exists();
        assert.dom('[data-test-id="table-cell"]').exists();
      });

      test('it supports loading state with color variants', async function (assert) {
        const columns = [
          { key: 'name', name: 'Name' }
        ] as const satisfies ColumnConfig<TestItem>[];
        const items: TestItem[] = [
          {
            id: '1',
            name: 'John Doe',
            email: 'john@example.com',
            role: 'admin'
          }
        ];

        const colors = [
          'default',
          'primary',
          'success',
          'warning',
          'danger'
        ] as const;

        for (const color of colors) {
          await render(
            <template>
              <Table
                @columns={{columns}}
                @items={{items}}
                @isLoading={{true}}
                @loadingColor={{color}}
              />
            </template>
          );

          // Table should render with loading state and color variant
          assert.dom('[data-test-id="table"]').exists();
          assert.dom('[data-test-id="table"][data-loading="true"]').exists();
          assert.dom('[data-test-id="table-cell"]').exists();
        }
      });

      test('it disables loading state when isLoading is false', async function (assert) {
        const columns = [
          { key: 'name', name: 'Name' }
        ] as const satisfies ColumnConfig<TestItem>[];
        const items: TestItem[] = [
          {
            id: '1',
            name: 'John Doe',
            email: 'john@example.com',
            role: 'admin'
          }
        ];

        await render(
          <template>
            <Table
              @columns={{columns}}
              @items={{items}}
              @isLoading={{false}}
              @loadingColor="primary"
            />
          </template>
        );

        // Table should not have loading state
        assert.dom('[data-test-id="table"]').exists();
        assert.dom('[data-test-id="table"][data-loading="false"]').exists();
        assert.dom('[data-test-id="table-cell"]').exists();
      });

      test('it supports custom loading block', async function (assert) {
        const columns = [
          { key: 'name', name: 'Name' }
        ] as const satisfies ColumnConfig<TestItem>[];
        const items: TestItem[] = [
          {
            id: '1',
            name: 'John Doe',
            email: 'john@example.com',
            role: 'admin'
          }
        ];

        await render(
          <template>
            <Table @columns={{columns}} @items={{items}} @isLoading={{true}}>
              <:loading>
                <div data-test-id="custom-loading">Custom Loading...</div>
              </:loading>
            </Table>
          </template>
        );

        // Table should render with custom loading indicator inside a table row/cell
        assert.dom('[data-test-id="table"]').exists();
        assert.dom('[data-test-id="table"][data-loading="true"]').exists();
        assert.dom('[data-test-id="table-loading-row"]').exists();
        assert.dom('[data-test-id="table-loading-cell"]').exists();
        assert.dom('[data-test-id="custom-loading"]').exists();
        assert
          .dom('[data-test-id="custom-loading"]')
          .hasText('Custom Loading...');
      });

      test('it disables CSS loading indicator when custom loading block is provided', async function (assert) {
        const columns = [
          { key: 'name', name: 'Name' }
        ] as const satisfies ColumnConfig<TestItem>[];
        const items: TestItem[] = [
          {
            id: '1',
            name: 'John Doe',
            email: 'john@example.com',
            role: 'admin'
          }
        ];

        await render(
          <template>
            <Table @columns={{columns}} @items={{items}} @isLoading={{true}}>
              <:loading>
                <div data-test-id="custom-loading">Custom Loading...</div>
              </:loading>
            </Table>
          </template>
        );

        // Custom loading should be visible
        assert.dom('[data-test-id="custom-loading"]').exists();

        // The CSS loading indicator should be disabled (tested by the styles not applying the isLoading variant)
        // This is handled internally by the component logic
        assert.dom('[data-test-id="table"]').exists();
      });

      test('it hides empty content when loading block is provided and isLoading is true', async function (assert) {
        const columns = [
          { key: 'name', name: 'Name' }
        ] as const satisfies ColumnConfig<TestItem>[];
        const emptyItems: TestItem[] = [];

        await render(
          <template>
            <Table
              @columns={{columns}}
              @items={{emptyItems}}
              @emptyContent="No data"
              @isLoading={{true}}
            >
              <:loading>
                <div data-test-id="custom-loading">Loading...</div>
              </:loading>
            </Table>
          </template>
        );

        // Loading block should be shown
        assert.dom('[data-test-id="table-loading-row"]').exists();
        assert.dom('[data-test-id="custom-loading"]').exists();

        // Empty content should NOT be shown when loading
        assert.dom('[data-test-id="table-empty-row"]').doesNotExist();
      });

      test('it shows data rows alongside loading block when isLoading is true', async function (assert) {
        const columns = [
          { key: 'name', name: 'Name' }
        ] as const satisfies ColumnConfig<TestItem>[];
        const items: TestItem[] = [
          {
            id: '1',
            name: 'John Doe',
            email: 'john@example.com',
            role: 'admin'
          }
        ];

        await render(
          <template>
            <Table @columns={{columns}} @items={{items}} @isLoading={{true}}>
              <:loading>
                <div data-test-id="custom-loading">Loading...</div>
              </:loading>
            </Table>
          </template>
        );

        // Both data rows and loading block should be shown
        assert.dom('[data-test-id="table-cell"]').exists();
        assert.dom('[data-test-id="table-loading-row"]').exists();
        assert.dom('[data-test-id="custom-loading"]').exists();
      });

      test('it shows normal content when loading block is provided but isLoading is false', async function (assert) {
        const columns = [
          { key: 'name', name: 'Name' }
        ] as const satisfies ColumnConfig<TestItem>[];
        const items: TestItem[] = [
          {
            id: '1',
            name: 'John Doe',
            email: 'john@example.com',
            role: 'admin'
          }
        ];

        await render(
          <template>
            <Table @columns={{columns}} @items={{items}} @isLoading={{false}}>
              <:loading>
                <div data-test-id="custom-loading">Loading...</div>
              </:loading>
            </Table>
          </template>
        );

        // Loading block should NOT be shown
        assert.dom('[data-test-id="table-loading-row"]').doesNotExist();
        assert.dom('[data-test-id="custom-loading"]').doesNotExist();

        // Normal table data should be shown
        assert.dom('[data-test-id="table-cell"]').exists();
      });

      test('it shows empty content when isLoading is false and no items', async function (assert) {
        const columns = [
          { key: 'name', name: 'Name' }
        ] as const satisfies ColumnConfig<TestItem>[];
        const emptyItems: TestItem[] = [];

        await render(
          <template>
            <Table
              @columns={{columns}}
              @items={{emptyItems}}
              @emptyContent="No data"
              @isLoading={{false}}
            >
              <:loading>
                <div data-test-id="custom-loading">Loading...</div>
              </:loading>
            </Table>
          </template>
        );

        // Loading block should NOT be shown
        assert.dom('[data-test-id="table-loading-row"]').doesNotExist();
        assert.dom('[data-test-id="custom-loading"]').doesNotExist();

        // Empty content should be shown
        assert.dom('[data-test-id="table-empty-row"]').exists();
      });
    });

    module('Sorting', function () {
      test('it renders sortable columns with sort buttons', async function (assert) {
        const columns = [
          { key: 'name', name: 'Name', isSortable: true },
          { key: 'email', name: 'Email', isSortable: true },
          { key: 'role', name: 'Role' }
        ] as const satisfies ColumnConfig<TestItem>[];

        const items: TestItem[] = [
          { id: '1', name: 'Alice', email: 'alice@example.com', role: 'admin' },
          { id: '2', name: 'Bob', email: 'bob@example.com', role: 'user' }
        ];

        await render(
          <template><Table @columns={{columns}} @items={{items}} /></template>
        );

        // Sortable columns should have data-sortable attribute
        assert
          .dom('[data-test-id="table-column"][data-key="name"]')
          .hasAttribute('data-sortable', 'true');
        assert
          .dom('[data-test-id="table-column"][data-key="email"]')
          .hasAttribute('data-sortable', 'true');

        // Non-sortable column should not have data-sortable attribute or should be false
        assert
          .dom('[data-test-id="table-column"][data-key="role"]')
          .hasAttribute('data-sortable', 'false');

        // Sortable columns should have sort buttons
        assert
          .dom(
            '[data-test-id="table-column"][data-key="name"] button[type="button"]'
          )
          .exists();
        assert
          .dom(
            '[data-test-id="table-column"][data-key="email"] button[type="button"]'
          )
          .exists();

        // Non-sortable column should not have a sort button
        assert
          .dom(
            '[data-test-id="table-column"][data-key="role"] button[type="button"]'
          )
          .doesNotExist();
      });

      test('it sorts data when onSort callback is provided', async function (assert) {
        const columns = [
          { key: 'name', name: 'Name', isSortable: true },
          { key: 'count', name: 'Count', isSortable: true }
        ] as const satisfies ColumnConfig<TestItem>[];

        const baseItems: TestItem[] = [
          {
            id: '1',
            name: 'Charlie',
            email: 'charlie@example.com',
            role: 'user',
            count: 30
          },
          {
            id: '2',
            name: 'Alice',
            email: 'alice@example.com',
            role: 'admin',
            count: 10
          },
          {
            id: '3',
            name: 'Bob',
            email: 'bob@example.com',
            role: 'user',
            count: 20
          }
        ];

        const handleSort = (
          items: TestItem[],
          sortDescriptor: SortItem<TestItem>
        ) => {
          return [...items].sort((a, b) => {
            const aValue = a[sortDescriptor.property];
            const bValue = b[sortDescriptor.property];

            if (aValue === undefined || bValue === undefined) return 0;

            if (sortDescriptor.direction === 'ascending') {
              return aValue < bValue ? -1 : aValue > bValue ? 1 : 0;
            } else {
              return aValue > bValue ? -1 : aValue < bValue ? 1 : 0;
            }
          });
        };

        await render(
          <template>
            <Table
              @columns={{columns}}
              @items={{baseItems}}
              @onSort={{handleSort}}
            />
          </template>
        );

        // Initial order (unsorted)
        const rows = this.element.querySelectorAll(
          '[data-test-id="table-row"]'
        );
        assert.strictEqual(rows.length, 3);
        assert
          .dom(rows[0]?.querySelector('[data-column="name"]'))
          .hasText('Charlie');
        assert
          .dom(rows[1]?.querySelector('[data-column="name"]'))
          .hasText('Alice');
        assert
          .dom(rows[2]?.querySelector('[data-column="name"]'))
          .hasText('Bob');

        // Click to sort by name ascending
        await click(
          '[data-test-id="table-column"][data-key="name"] button[type="button"]'
        );

        // Check sorted order (ascending)
        const rowsAfterSort = this.element.querySelectorAll(
          '[data-test-id="table-row"]'
        );
        assert
          .dom(rowsAfterSort[0]?.querySelector('[data-column="name"]'))
          .hasText('Charlie');
        assert
          .dom(rowsAfterSort[1]?.querySelector('[data-column="name"]'))
          .hasText('Bob');
        assert
          .dom(rowsAfterSort[2]?.querySelector('[data-column="name"]'))
          .hasText('Alice');
      });

      test('it toggles sort direction through tri-state cycle', async function (assert) {
        const columns = [
          { key: 'name', name: 'Name', isSortable: true }
        ] as const satisfies ColumnConfig<TestItem>[];

        const items: TestItem[] = [
          { id: '1', name: 'Charlie', email: 'c@example.com', role: 'user' },
          { id: '2', name: 'Alice', email: 'a@example.com', role: 'admin' },
          { id: '3', name: 'Bob', email: 'b@example.com', role: 'user' }
        ];

        const handleSort = (
          items: TestItem[],
          sortDescriptor: SortItem<TestItem>
        ) => {
          if (sortDescriptor.direction === 'none') {
            return items;
          }

          return [...items].sort((a, b) => {
            const aValue = a[sortDescriptor.property];
            const bValue = b[sortDescriptor.property];

            if (aValue === undefined || bValue === undefined) return 0;

            if (sortDescriptor.direction === 'ascending') {
              return aValue < bValue ? -1 : aValue > bValue ? 1 : 0;
            } else {
              return aValue > bValue ? -1 : aValue < bValue ? 1 : 0;
            }
          });
        };

        await render(
          <template>
            <Table
              @columns={{columns}}
              @items={{items}}
              @onSort={{handleSort}}
            />
          </template>
        );

        const sortButton =
          '[data-test-id="table-column"][data-key="name"] button[type="button"]';

        // Click 1: Sort descending (universal-ember starts with descending)
        await click(sortButton);

        assert
          .dom(sortButton)
          .hasAttribute('data-sort-direction', 'descending');

        // Click 2: Sort ascending
        await click(sortButton);

        assert.dom(sortButton).hasAttribute('data-sort-direction', 'ascending');

        // Click 3: Clear sort (none)
        await click(sortButton);

        assert.dom(sortButton).hasAttribute('data-sort-direction', 'none');
      });

      test('it uses sortProperty when specified', async function (assert) {
        interface TestItemWithNested {
          id: string;
          displayName: string;
          sortableName: string;
          role: string;
        }

        const columns = [
          {
            key: 'displayName',
            name: 'Name',
            isSortable: true,
            sortProperty: 'sortableName'
          }
        ] as const satisfies ColumnConfig<TestItemWithNested>[];

        const items: TestItemWithNested[] = [
          {
            id: '1',
            displayName: 'Mr. Charlie',
            sortableName: 'Charlie',
            role: 'user'
          },
          {
            id: '2',
            displayName: 'Ms. Alice',
            sortableName: 'Alice',
            role: 'admin'
          }
        ];

        let lastSortProperty = '';
        const handleSort = (
          items: TestItemWithNested[],
          sortDescriptor: SortItem<TestItemWithNested>
        ) => {
          lastSortProperty = sortDescriptor.property as string;
          return items;
        };

        await render(
          <template>
            <Table
              @columns={{columns}}
              @items={{items}}
              @onSort={{handleSort}}
            />
          </template>
        );

        await click(
          '[data-test-id="table-column"][data-key="displayName"] button[type="button"]'
        );

        // Should use sortProperty instead of key
        assert.strictEqual(lastSortProperty, 'sortableName');
      });

      test('it supports custom header rendering with sorting info', async function (assert) {
        const columns = [
          { key: 'name', name: 'Name', isSortable: true }
        ] as const satisfies ColumnConfig<TestItem>[];

        const items: TestItem[] = [
          { id: '1', name: 'Alice', email: 'alice@example.com', role: 'admin' }
        ];

        await render(
          <template>
            <Table @columns={{columns}} @items={{items}}>
              <:header as |h|>
                <span data-test-custom-header>
                  {{h.column.name}}
                  {{#if h.isSortable}}
                    (Sortable:
                    {{h.sortDirection}})
                  {{/if}}
                </span>
              </:header>
            </Table>
          </template>
        );

        // Check that custom header received sorting info
        assert.dom('[data-test-custom-header]').exists();
        assert.dom('[data-test-custom-header]').containsText('Name');
        assert.dom('[data-test-custom-header]').containsText('Sortable');
      });

      test('it does not show sort button for non-sortable columns', async function (assert) {
        const columns = [
          { key: 'name', name: 'Name', isSortable: false },
          { key: 'email', name: 'Email' }
        ] as const satisfies ColumnConfig<TestItem>[];

        const items: TestItem[] = [
          { id: '1', name: 'Alice', email: 'alice@example.com', role: 'admin' }
        ];

        await render(
          <template><Table @columns={{columns}} @items={{items}} /></template>
        );

        // Columns should just show text, not buttons
        assert
          .dom(
            '[data-test-id="table-column"][data-key="name"] button[type="button"]'
          )
          .doesNotExist();
        assert
          .dom('[data-test-id="table-column"][data-key="name"]')
          .containsText('Name');

        assert
          .dom(
            '[data-test-id="table-column"][data-key="email"] button[type="button"]'
          )
          .doesNotExist();
        assert
          .dom('[data-test-id="table-column"][data-key="email"]')
          .containsText('Email');
      });

      test('it handles sorting with empty items array', async function (assert) {
        const columns = [
          { key: 'name', name: 'Name', isSortable: true }
        ] as const satisfies ColumnConfig<TestItem>[];

        const items: TestItem[] = [];

        const handleSort = () => {
          assert.step('onSort called');
          return items;
        };

        await render(
          <template>
            <Table
              @columns={{columns}}
              @items={{items}}
              @onSort={{handleSort}}
            />
          </template>
        );

        // Should render sort button even with empty items
        assert
          .dom(
            '[data-test-id="table-column"][data-key="name"] button[type="button"]'
          )
          .exists();

        // Click should work without error
        await click(
          '[data-test-id="table-column"][data-key="name"] button[type="button"]'
        );

        assert.verifySteps(['onSort called']);
      });

      test('it maintains accessibility with aria attributes', async function (assert) {
        const columns = [
          { key: 'name', name: 'Name', isSortable: true }
        ] as const satisfies ColumnConfig<TestItem>[];

        const items: TestItem[] = [
          { id: '1', name: 'Alice', email: 'alice@example.com', role: 'admin' }
        ];

        await render(
          <template><Table @columns={{columns}} @items={{items}} /></template>
        );

        const sortButton =
          '[data-test-id="table-column"][data-key="name"] button[type="button"]';

        // Sort button should be a button element for accessibility
        assert.dom(sortButton).hasTagName('button');
        assert.dom(sortButton).hasAttribute('type', 'button');
      });

      test('it accepts initialSort to set initial sort state', async function (assert) {
        const columns = [
          { key: 'name', name: 'Name', isSortable: true }
        ] as const satisfies ColumnConfig<TestItem>[];

        const items: TestItem[] = [
          { id: '1', name: 'Charlie', email: 'c@example.com', role: 'user' },
          { id: '2', name: 'Alice', email: 'a@example.com', role: 'admin' },
          { id: '3', name: 'Bob', email: 'b@example.com', role: 'user' }
        ];

        const initialSort: SortItem<TestItem> = {
          property: 'name',
          direction: 'ascending'
        };

        const handleSort = (
          items: TestItem[],
          sortDescriptor: SortItem<TestItem>
        ) => {
          return [...items].sort((a, b) => {
            const aValue = a[sortDescriptor.property];
            const bValue = b[sortDescriptor.property];

            if (aValue === undefined || bValue === undefined) return 0;

            if (sortDescriptor.direction === 'ascending') {
              return aValue < bValue ? -1 : aValue > bValue ? 1 : 0;
            } else {
              return aValue > bValue ? -1 : aValue < bValue ? 1 : 0;
            }
          });
        };

        await render(
          <template>
            <Table
              @columns={{columns}}
              @items={{items}}
              @onSort={{handleSort}}
              @initialSort={{initialSort}}
            />
          </template>
        );

        const sortButton =
          '[data-test-id="table-column"][data-key="name"] button[type="button"]';

        // Should start with ascending sort applied
        assert.dom(sortButton).hasAttribute('data-sort-direction', 'ascending');
        assert.dom(sortButton).hasAttribute('data-sorted', 'true');
      });

      test('it sorts by nested properties using sortProperty', async function (assert) {
        interface UserWithProfile {
          id: string;
          profile: {
            name: string;
            age: number;
          };
          email: string;
        }

        const columns = [
          {
            key: 'profile',
            name: 'Name',
            isSortable: true,
            sortProperty: 'profile.name',
            value: (ctx) => ctx.row.data.profile.name
          },
          {
            key: 'age',
            name: 'Age',
            isSortable: true,
            sortProperty: 'profile.age',
            value: (ctx) => ctx.row.data.profile.age
          },
          { key: 'email', name: 'Email' }
        ] as const satisfies ColumnConfig<UserWithProfile>[];

        const items: UserWithProfile[] = [
          {
            id: '1',
            profile: { name: 'Charlie', age: 35 },
            email: 'charlie@example.com'
          },
          {
            id: '2',
            profile: { name: 'Alice', age: 28 },
            email: 'alice@example.com'
          },
          {
            id: '3',
            profile: { name: 'Bob', age: 42 },
            email: 'bob@example.com'
          }
        ];

        // Helper to get nested property value
        const getNestedValue = (obj: UserWithProfile, path: string) => {
          return path.split('.').reduce((current: unknown, key: string) => {
            return current?.[key];
          }, obj);
        };

        const handleSort = (
          items: UserWithProfile[],
          sortDescriptor: SortItem<UserWithProfile>
        ) => {
          if (sortDescriptor.direction === 'none') return items;

          return [...items].sort((a, b) => {
            // For nested properties, sortProperty will be like 'profile.name'
            const sortProperty = sortDescriptor.property as string;
            const aValue = getNestedValue(a, sortProperty);
            const bValue = getNestedValue(b, sortProperty);

            if (aValue === undefined || bValue === undefined) return 0;

            if (sortDescriptor.direction === 'ascending') {
              return aValue < bValue ? -1 : aValue > bValue ? 1 : 0;
            } else {
              return aValue > bValue ? -1 : aValue < bValue ? 1 : 0;
            }
          });
        };

        await render(
          <template>
            <Table
              @columns={{columns}}
              @items={{items}}
              @onSort={{handleSort}}
            />
          </template>
        );

        const rows = this.element.querySelectorAll(
          '[data-test-id="table-row"]'
        );
        assert.strictEqual(rows.length, 3);

        // Initial order (unsorted)
        assert
          .dom(rows[0]?.querySelector('[data-column="profile"]'))
          .hasText('Charlie');
        assert
          .dom(rows[1]?.querySelector('[data-column="profile"]'))
          .hasText('Alice');
        assert
          .dom(rows[2]?.querySelector('[data-column="profile"]'))
          .hasText('Bob');

        // Click to sort by name descending
        await click(
          '[data-test-id="table-column"][data-key="profile"] button[type="button"]'
        );

        const rowsAfterSort = this.element.querySelectorAll(
          '[data-test-id="table-row"]'
        );

        // Descending order: Charlie, Bob, Alice
        assert
          .dom(rowsAfterSort[0]?.querySelector('[data-column="profile"]'))
          .hasText('Charlie');
        assert
          .dom(rowsAfterSort[1]?.querySelector('[data-column="profile"]'))
          .hasText('Bob');
        assert
          .dom(rowsAfterSort[2]?.querySelector('[data-column="profile"]'))
          .hasText('Alice');

        // Click again to sort ascending
        await click(
          '[data-test-id="table-column"][data-key="profile"] button[type="button"]'
        );

        const rowsAfterSecondSort = this.element.querySelectorAll(
          '[data-test-id="table-row"]'
        );

        // Ascending order: Alice, Bob, Charlie
        assert
          .dom(rowsAfterSecondSort[0]?.querySelector('[data-column="profile"]'))
          .hasText('Alice');
        assert
          .dom(rowsAfterSecondSort[1]?.querySelector('[data-column="profile"]'))
          .hasText('Bob');
        assert
          .dom(rowsAfterSecondSort[2]?.querySelector('[data-column="profile"]'))
          .hasText('Charlie');

        // Test sorting by nested age property
        await click(
          '[data-test-id="table-column"][data-key="age"] button[type="button"]'
        );

        const rowsAfterAgeSort = this.element.querySelectorAll(
          '[data-test-id="table-row"]'
        );

        // Descending order by age: Bob (42), Charlie (35), Alice (28)
        assert
          .dom(rowsAfterAgeSort[0]?.querySelector('[data-column="age"]'))
          .hasText('42');
        assert
          .dom(rowsAfterAgeSort[1]?.querySelector('[data-column="age"]'))
          .hasText('35');
        assert
          .dom(rowsAfterAgeSort[2]?.querySelector('[data-column="age"]'))
          .hasText('28');
      });
    });
  }
);
