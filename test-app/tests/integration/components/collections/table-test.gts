import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, settled } from '@ember/test-helpers';
import { Table, type ColumnConfig } from '@frontile/collections';
import { array, hash, get } from '@ember/helper';
import { cell } from 'ember-resources';

function eq(a: unknown, b: unknown): boolean {
  return a === b;
}

interface TestItem {
  id: string;
  name: string;
  email: string;
  role: string;
}

module(
  'Integration | Component | Table | @frontile/collections',
  function (hooks) {
    setupRenderingTest(hooks);

    test('it renders basic table structure', async function (assert) {
      const columns: ColumnConfig[] = [
        { key: 'id', name: 'ID' },
        { key: 'name', name: 'Name' },
        { key: 'email', name: 'Email' }
      ];

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
      const columns: ColumnConfig[] = [
        { key: 'id', name: 'ID' },
        { key: 'name', name: 'Name' }
      ];

      await render(
        <template><Table @columns={{columns}} @items={{(array)}} /></template>
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
      const columns: ColumnConfig[] = [
        { key: 'id', name: 'ID' },
        { key: 'name', name: 'Name' },
        { key: 'email', name: 'Email' }
      ];

      await render(
        <template>
          <Table
            @columns={{columns}}
            @items={{(array)}}
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

    test('it displays empty content with component', async function (assert) {
      const columns: ColumnConfig[] = [
        { key: 'id', name: 'ID' },
        { key: 'name', name: 'Name' }
      ];

      const EmptyComponent = <template>
        <div class="custom-empty-component">
          <strong>No results found</strong>
          <p>Try adjusting your search criteria.</p>
        </div>
      </template>;

      await render(
        <template>
          <Table
            @columns={{columns}}
            @items={{(array)}}
            @emptyContent={{component EmptyComponent}}
          />
        </template>
      );

      assert.dom('[data-test-id="table-empty-row"]').exists();
      assert.dom('[data-test-id="table-empty-cell"]').exists();

      // Empty cell should span both columns
      assert
        .dom('[data-test-id="table-empty-cell"]')
        .hasAttribute('colspan', '2');

      // Component content should be rendered
      assert
        .dom('[data-test-id="table-empty-cell"] .custom-empty-component')
        .exists();
      assert
        .dom('[data-test-id="table-empty-cell"] strong')
        .containsText('No results found');
      assert
        .dom('[data-test-id="table-empty-cell"] p')
        .containsText('Try adjusting your search criteria.');
    });

    test('it hides empty content when items exist', async function (assert) {
      const columns: ColumnConfig[] = [
        { key: 'id', name: 'ID' },
        { key: 'name', name: 'Name' }
      ];

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
      const columns: ColumnConfig[] = [
        { key: 'id', name: 'ID' },
        { key: 'name', name: 'Name' }
      ];

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


    test('it handles items with different data types', async function (assert) {
      const columns: ColumnConfig[] = [
        { key: 'id', name: 'ID' },
        { key: 'active', name: 'Active' },
        { key: 'count', name: 'Count' }
      ];

      const items = [
        { id: '1', active: true, count: 42 },
        { id: '2', active: false, count: 0 }
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
      const columns: ColumnConfig[] = [{ key: 'name', name: 'Name' }];

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
      const columns: ColumnConfig<TestItem>[] = [
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
      ];

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
      const columns: ColumnConfig<TestItem>[] = [
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
      ];

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
      const columns: ColumnConfig[] = [
        { key: 'id', name: 'ID' },
        { key: 'name', name: 'Name' }
      ];

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
      const columns: ColumnConfig[] = [
        { key: 'id', name: 'ID' },
        { key: 'name', name: 'Name' }
      ];

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
      const columns: ColumnConfig[] = [
        { key: 'id', name: 'ID', isSticky: true, stickyPosition: 'left' },
        { key: 'name', name: 'Name' },
        {
          key: 'actions',
          name: 'Actions',
          isSticky: true,
          stickyPosition: 'right'
        }
      ];

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
      const columns: ColumnConfig[] = [
        { key: 'id', name: 'ID' },
        { key: 'name', name: 'Name' }
      ];

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
            @stickyKeys={{(array "1" "3")}}
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
      const columns: ColumnConfig[] = [
        { key: 'id', name: 'ID', isSticky: true },
        { key: 'name', name: 'Name' },
        { key: 'email', name: 'Email' },
        {
          key: 'actions',
          name: 'Actions',
          isSticky: true,
          stickyPosition: 'right'
        }
      ];

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
            @stickyKeys={{(array "1")}}
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
      const columns: ColumnConfig[] = [
        { key: 'id', name: 'ID' },
        { key: 'name', name: 'Name' },
        { key: 'amount', name: 'Amount' }
      ];

      const footerColumns: ColumnConfig[] = [
        { key: 'total', name: 'Total' },
        { key: 'items', name: 'Items' },
        { key: 'sum', name: '$1000' }
      ];

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
      const columns: ColumnConfig[] = [
        { key: 'id', name: 'ID' },
        { key: 'name', name: 'Name' }
      ];

      const footerColumns: ColumnConfig[] = [
        { key: 'total', name: 'Total' },
        { key: 'count', name: '2 items' }
      ];

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
        const columns: ColumnConfig[] = [{ key: 'name', name: 'Name' }];
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
        const columns: ColumnConfig[] = [{ key: 'name', name: 'Name' }];
        const items: TestItem[] = [
          { id: '1', name: 'John', email: 'john@example.com', role: 'admin' }
        ];
        const footerColumns: ColumnConfig[] = [
          { key: 'total', name: 'Total: 1' }
        ];

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
        const columns: ColumnConfig[] = [{ key: 'name', name: 'Name' }];
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
        const columns: ColumnConfig[] = [{ key: 'name', name: 'Name' }];
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
        const columns: ColumnConfig[] = [{ key: 'name', name: 'Name' }];
        const items: TestItem[] = [
          { id: '1', name: 'John', email: 'john@example.com', role: 'admin' }
        ];

        await render(
          <template>
            <Table @columns={{columns}} @items={{items}} />
          </template>
        );

        // Table should render without errors
        assert.dom('[data-test-id="table"]').exists();
        assert.dom('[data-test-id="table-header"]').exists();
        assert.dom('[data-test-id="table-body"]').exists();
      });

      test('it handles empty/null classes gracefully', async function (assert) {
        const columns: ColumnConfig[] = [{ key: 'name', name: 'Name' }];
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
        const columns: ColumnConfig[] = [{ key: 'name', name: 'Name' }];
        const items: TestItem[] = [
          { id: '1', name: 'John', email: 'john@example.com', role: 'admin' }
        ];
        const footerColumns: ColumnConfig[] = [
          { key: 'total', name: 'Total: 1' }
        ];

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
        const columns: ColumnConfig[] = [{ key: 'name', name: 'Name' }];
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
        const columns: ColumnConfig[] = [{ key: 'name', name: 'Name' }];
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
        const columns: ColumnConfig[] = [{ key: 'name', name: 'Name' }];
        const footerColumns: ColumnConfig[] = [
          { key: 'total', name: 'Total' },
          { key: 'count', name: '1 item' }
        ];
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

    // Block-form and hybrid patterns removed - Table now only supports automatic rendering
    // For manual composition, use SimpleTable component instead
  }
);
