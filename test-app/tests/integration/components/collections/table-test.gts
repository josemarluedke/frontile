import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, settled, click } from '@ember/test-helpers';
import {
  Table,
  type ColumnConfig,
  type CellSignature
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
        await settled();

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
        await settled();

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
        await settled();

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
        await settled();

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
        await settled();

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
        await settled();

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
  }
);
