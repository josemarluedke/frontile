import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, settled } from '@ember/test-helpers';
import { Table, type ColumnDefinition } from '@frontile/collections';
import { array, hash } from '@ember/helper';
import { cell } from 'ember-resources';

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
      const columns: ColumnDefinition[] = [
        { key: 'id', label: 'ID' },
        { key: 'name', label: 'Name' },
        { key: 'email', label: 'Email' }
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

    test('it renders static table with manual components', async function (assert) {
      const items: TestItem[] = [
        { id: '1', name: 'John Doe', email: 'john@example.com', role: 'admin' }
      ];

      await render(
        <template>
          <Table as |t|>
            <t.Header>
              <t.Column>ID</t.Column>
              <t.Column>Name</t.Column>
              <t.Column>Email</t.Column>
            </t.Header>
            <t.Body>
              {{#each items as |item|}}
                <t.Row @item={{item}}>
                  <t.Cell>{{item.id}}</t.Cell>
                  <t.Cell>{{item.name}}</t.Cell>
                  <t.Cell>{{item.email}}</t.Cell>
                </t.Row>
              {{/each}}
            </t.Body>
          </Table>
        </template>
      );

      assert.dom('[data-test-id="table"]').exists();
      assert.dom('[data-test-id="table-header"]').exists();
      assert.dom('[data-test-id="table-body"]').exists();

      // Check static columns
      assert.dom('[data-test-id="table-column"]').exists({ count: 3 });

      // Check row content
      assert.dom('[data-test-id="table-row"][data-key="1"]').exists();
      assert.dom('[data-test-id="table-cell"]').exists({ count: 3 });

      // Check cell content
      const cells = document.querySelectorAll('[data-test-id="table-cell"]');
      assert.dom(cells[0]).containsText('1');
      assert.dom(cells[1]).containsText('John Doe');
      assert.dom(cells[2]).containsText('john@example.com');
    });

    test('it handles empty data', async function (assert) {
      const columns: ColumnDefinition[] = [
        { key: 'id', label: 'ID' },
        { key: 'name', label: 'Name' }
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
      const columns: ColumnDefinition[] = [
        { key: 'id', label: 'ID' },
        { key: 'name', label: 'Name' },
        { key: 'email', label: 'Email' }
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
      const columns: ColumnDefinition[] = [
        { key: 'id', label: 'ID' },
        { key: 'name', label: 'Name' }
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
      const columns: ColumnDefinition[] = [
        { key: 'id', label: 'ID' },
        { key: 'name', label: 'Name' }
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
      const columns: ColumnDefinition[] = [
        { key: 'id', label: 'ID' },
        { key: 'name', label: 'Name' }
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

    test('it renders with manual header composition', async function (assert) {
      const items: TestItem[] = [
        { id: '1', name: 'John Doe', email: 'john@example.com', role: 'admin' }
      ];

      await render(
        <template>
          <Table as |t|>
            <t.Header>
              <t.Column @class="custom-header">ID (Custom)</t.Column>
              <t.Column @class="custom-header">Name (Custom)</t.Column>
            </t.Header>
            <t.Body>
              {{#each items as |item|}}
                <t.Row @item={{item}}>
                  <t.Cell>{{item.id}}</t.Cell>
                  <t.Cell>{{item.name}}</t.Cell>
                </t.Row>
              {{/each}}
            </t.Body>
          </Table>
        </template>
      );

      assert.dom('[data-test-id="table"]').exists();
      assert.dom('th.custom-header').exists({ count: 2 });
      assert.dom('th.custom-header').containsText('ID (Custom)');
    });

    test('it supports manual cell composition', async function (assert) {
      const items: TestItem[] = [
        { id: '1', name: 'John Doe', email: 'john@example.com', role: 'admin' }
      ];

      await render(
        <template>
          <Table as |t|>
            <t.Header>
              <t.Column>ID</t.Column>
              <t.Column>Name</t.Column>
            </t.Header>
            <t.Body>
              {{#each items as |item|}}
                <t.Row @item={{item}}>
                  <t.Cell @class="custom-cell">Custom: {{item.id}}</t.Cell>
                  <t.Cell @class="custom-cell">Custom: {{item.name}}</t.Cell>
                </t.Row>
              {{/each}}
            </t.Body>
          </Table>
        </template>
      );

      assert.dom('[data-test-id="table"]').exists();
      assert.dom('td.custom-cell').exists({ count: 2 });
      assert.dom('td.custom-cell').containsText('Custom: 1');
    });

    test('it handles items with different data types', async function (assert) {
      const columns: ColumnDefinition[] = [
        { key: 'id', label: 'ID' },
        { key: 'active', label: 'Active' },
        { key: 'count', label: 'Count' }
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
      const columns: ColumnDefinition[] = [{ key: 'name', label: 'Name' }];

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

    test('it supports custom accessorFn for column values', async function (assert) {
      const columns: ColumnDefinition<TestItem>[] = [
        { key: 'id', label: 'ID' },
        {
          key: 'name',
          label: 'Display Name',
          accessorFn: (item) => `${item.name} (${item.role})`
        },
        {
          key: 'email',
          label: 'Contact',
          accessorFn: (item) => item.email.toUpperCase()
        }
      ];

      const items: TestItem[] = [
        { id: '1', name: 'John Doe', email: 'john@example.com', role: 'admin' },
        { id: '2', name: 'Jane Smith', email: 'jane@example.com', role: 'user' }
      ];

      await render(
        <template><Table @columns={{columns}} @items={{items}} /></template>
      );

      // Check that custom accessorFn is used for name column
      assert
        .dom('[data-test-id="table-row"][data-key="1"] [data-column="name"]')
        .containsText('John Doe (admin)');
      assert
        .dom('[data-test-id="table-row"][data-key="2"] [data-column="name"]')
        .containsText('Jane Smith (user)');

      // Check that custom accessorFn is used for email column
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

    test('it supports accessorFn returning different data types', async function (assert) {
      const columns: ColumnDefinition<TestItem>[] = [
        {
          key: 'id',
          label: 'ID Number',
          accessorFn: (item) => parseInt(item.id, 10) * 100
        },
        {
          key: 'active',
          label: 'Status',
          accessorFn: (item) => item.role === 'admin'
        },
        {
          key: 'missing',
          label: 'Missing Value',
          accessorFn: () => null
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

    test('it supports styling variants', async function (assert) {
      const columns: ColumnDefinition[] = [
        { key: 'name', label: 'Name' },
        { key: 'email', label: 'Email' }
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
            @size="sm"
            @isStriped={{true}}
            @layout="fixed"
          />
        </template>
      );

      assert.dom('[data-test-id="table"]').exists();
      // The specific classes will depend on the theme implementation
      // but we can verify the table renders with the variant props
      assert.dom('[data-test-id="table-row"]').exists({ count: 2 });
    });

    test('it supports scrollable mode', async function (assert) {
      const columns: ColumnDefinition[] = [
        { key: 'id', label: 'ID' },
        { key: 'name', label: 'Name' }
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

    test('it supports frozen header', async function (assert) {
      const columns: ColumnDefinition[] = [
        { key: 'id', label: 'ID' },
        { key: 'name', label: 'Name' }
      ];

      const items: TestItem[] = [
        { id: '1', name: 'John', email: 'john@example.com', role: 'admin' }
      ];

      await render(
        <template>
          <Table
            @columns={{columns}}
            @items={{items}}
            @isFrozenHeader={{true}}
          />
        </template>
      );

      assert.dom('[data-test-id="table-header"]').hasClass('sticky');
      assert.dom('[data-test-id="table-header"]').hasClass('top-0');
      assert.dom('[data-test-id="table-header"]').hasClass('z-2');
    });

    test('it supports frozen columns from ColumnDefinition', async function (assert) {
      const columns: ColumnDefinition[] = [
        { key: 'id', label: 'ID', isFrozen: true, frozenPosition: 'left' },
        { key: 'name', label: 'Name' },
        {
          key: 'actions',
          label: 'Actions',
          isFrozen: true,
          frozenPosition: 'right'
        }
      ];

      const items: TestItem[] = [
        { id: '1', name: 'John', email: 'john@example.com', role: 'admin' }
      ];

      await render(
        <template><Table @columns={{columns}} @items={{items}} /></template>
      );

      // Check frozen ID column (left)
      assert
        .dom('[data-test-id="table-column"][data-key="id"]')
        .hasClass('sticky');
      assert
        .dom('[data-test-id="table-column"][data-key="id"]')
        .hasClass('left-0');
      assert
        .dom('[data-test-id="table-column"][data-key="id"]')
        .hasClass('z-3');

      // Check frozen actions column (right)
      assert
        .dom('[data-test-id="table-column"][data-key="actions"]')
        .hasClass('sticky');
      assert
        .dom('[data-test-id="table-column"][data-key="actions"]')
        .hasClass('right-0');
      assert
        .dom('[data-test-id="table-column"][data-key="actions"]')
        .hasClass('z-3');

      // Check non-frozen column
      assert
        .dom('[data-test-id="table-column"][data-key="name"]')
        .doesNotHaveClass('sticky');
    });

    test('it supports frozen columns in block form', async function (assert) {
      const items: TestItem[] = [
        { id: '1', name: 'John Doe', email: 'john@example.com', role: 'admin' }
      ];

      await render(
        <template>
          <Table as |t|>
            <t.Header>
              <t.Column @isFrozen={{true}} @frozenPosition="left">ID</t.Column>
              <t.Column>Name</t.Column>
              <t.Column
                @isFrozen={{true}}
                @frozenPosition="right"
              >Actions</t.Column>
            </t.Header>
            <t.Body>
              {{#each items as |item|}}
                <t.Row @item={{item}}>
                  <t.Cell
                    @isFrozen={{true}}
                    @frozenPosition="left"
                  >{{item.id}}</t.Cell>
                  <t.Cell>{{item.name}}</t.Cell>
                  <t.Cell
                    @isFrozen={{true}}
                    @frozenPosition="right"
                  >Edit</t.Cell>
                </t.Row>
              {{/each}}
            </t.Body>
          </Table>
        </template>
      );

      // Check that frozen column classes are applied
      const headers = document.querySelectorAll(
        '[data-test-id="table-column"]'
      );
      assert.dom(headers[0]).hasClass('sticky');
      assert.dom(headers[0]).hasClass('left-0');
      assert.dom(headers[2]).hasClass('sticky');
      assert.dom(headers[2]).hasClass('right-0');

      const cells = document.querySelectorAll('[data-test-id="table-cell"]');
      assert.dom(cells[0]).hasClass('sticky');
      assert.dom(cells[0]).hasClass('left-0');
      assert.dom(cells[2]).hasClass('sticky');
      assert.dom(cells[2]).hasClass('right-0');
    });

    test('it supports frozen rows by keys', async function (assert) {
      const columns: ColumnDefinition[] = [
        { key: 'id', label: 'ID' },
        { key: 'name', label: 'Name' }
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
            @frozenKeys={{(array "1" "3")}}
          />
        </template>
      );

      // Check that specified rows are frozen
      assert.dom('[data-test-id="table-row"][data-key="1"]').hasClass('sticky');
      assert.dom('[data-test-id="table-row"][data-key="1"]').hasClass('z-1');
      assert.dom('[data-test-id="table-row"][data-key="3"]').hasClass('sticky');
      assert.dom('[data-test-id="table-row"][data-key="3"]').hasClass('z-1');

      // Check that non-frozen row is not sticky
      assert
        .dom('[data-test-id="table-row"][data-key="2"]')
        .doesNotHaveClass('sticky');
    });

    test('it combines scrolling with frozen elements', async function (assert) {
      const columns: ColumnDefinition[] = [
        { key: 'id', label: 'ID', isFrozen: true },
        { key: 'name', label: 'Name' },
        { key: 'email', label: 'Email' },
        {
          key: 'actions',
          label: 'Actions',
          isFrozen: true,
          frozenPosition: 'right'
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
            @isFrozenHeader={{true}}
            @frozenKeys={{(array "1")}}
          />
        </template>
      );

      // Check scrollable wrapper
      assert.dom('[data-component="table-wrapper"]').hasClass('overflow-auto');

      // Check frozen header
      assert.dom('[data-test-id="table-header"]').hasClass('sticky');
      assert.dom('[data-test-id="table-header"]').hasClass('top-0');

      // Check frozen columns
      assert
        .dom('[data-test-id="table-column"][data-key="id"]')
        .hasClass('left-0');
      assert
        .dom('[data-test-id="table-column"][data-key="actions"]')
        .hasClass('right-0');

      // Check frozen row
      assert.dom('[data-test-id="table-row"][data-key="1"]').hasClass('sticky');
    });

    test('it renders footer with footerColumns', async function (assert) {
      const columns: ColumnDefinition[] = [
        { key: 'id', label: 'ID' },
        { key: 'name', label: 'Name' },
        { key: 'amount', label: 'Amount' }
      ];

      const footerColumns: ColumnDefinition[] = [
        { key: 'total', label: 'Total' },
        { key: 'items', label: 'Items' },
        { key: 'sum', label: '$1000' }
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

    test('it supports frozen footer', async function (assert) {
      const columns: ColumnDefinition[] = [
        { key: 'id', label: 'ID' },
        { key: 'name', label: 'Name' }
      ];

      const footerColumns: ColumnDefinition[] = [
        { key: 'total', label: 'Total' },
        { key: 'count', label: '2 items' }
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
            @isFrozenFooter={{true}}
          />
        </template>
      );

      // Check that footer has frozen styling
      assert.dom('[data-test-id="table-footer"]').hasClass('sticky');
      assert.dom('[data-test-id="table-footer"]').hasClass('bottom-0');
      assert.dom('[data-test-id="table-footer"]').hasClass('z-2');
    });

    // Styling and Class Tests
    module('Styling and Class Functionality', function () {
      test('it applies basic custom classes', async function (assert) {
        const columns: ColumnDefinition[] = [{ key: 'name', label: 'Name' }];
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
        const columns: ColumnDefinition[] = [{ key: 'name', label: 'Name' }];
        const items: TestItem[] = [
          { id: '1', name: 'John', email: 'john@example.com', role: 'admin' }
        ];
        const footerColumns: ColumnDefinition[] = [
          { key: 'total', label: 'Total: 1' }
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

      test('it applies class arguments to individual components in block form', async function (assert) {
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
            <Table as |t|>
              <t.Header @class="custom-header-class">
                <t.Column @class="custom-column-class">Name</t.Column>
                <t.Column @class="custom-column-class">Email</t.Column>
              </t.Header>
              <t.Body @class="custom-body-class">
                {{#each items as |item|}}
                  <t.Row @item={{item}} @class="custom-row-class">
                    <t.Cell @class="custom-cell-class">{{item.name}}</t.Cell>
                    <t.Cell @class="custom-cell-class">{{item.email}}</t.Cell>
                  </t.Row>
                {{/each}}
              </t.Body>
            </Table>
          </template>
        );

        // Check that custom classes are applied
        assert.dom('thead.custom-header-class').exists();
        assert.dom('th.custom-column-class').exists({ count: 2 });
        assert.dom('tbody.custom-body-class').exists();
        assert.dom('tr.custom-row-class').exists();
        assert.dom('td.custom-cell-class').exists({ count: 2 });
      });

      test('it supports mixed class arguments with component composition', async function (assert) {
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
            <Table @classes={{hash table="table-level-class"}} as |t|>
              <t.Header>
                <t.Column @class="header-column-class">Name</t.Column>
              </t.Header>
              <t.Body>
                {{#each items as |item|}}
                  <t.Row @item={{item}}>
                    <t.Cell @class="body-cell-class">{{item.name}}</t.Cell>
                  </t.Row>
                {{/each}}
              </t.Body>
            </Table>
          </template>
        );

        // Check that both table-level and component-level classes are applied
        assert.dom('[data-test-id="table"].table-level-class').exists();
        assert.dom('th.header-column-class').exists();
        assert.dom('td.body-cell-class').exists();
      });

      test('it supports styling variants', async function (assert) {
        const columns: ColumnDefinition[] = [
          { key: 'name', label: 'Name' },
          { key: 'email', label: 'Email' }
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
              @size="sm"
              @isStriped={{true}}
              @layout="fixed"
            />
          </template>
        );

        assert.dom('[data-test-id="table"]').exists();
        // The specific classes will depend on the theme implementation
        // but we can verify the table renders with the variant props
        assert.dom('[data-test-id="table-row"]').exists({ count: 2 });
      });

      test('it merges @classes with @class arguments in manual composition', async function (assert) {
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
        const footerColumns: ColumnDefinition[] = [
          { key: 'total', label: 'Total' },
          { key: 'count', label: '2 items' }
        ];

        await render(
          <template>
            <Table
              @classes={{hash
                wrapper="table-level-wrapper"
                table="table-level-table"
                thead="table-level-thead"
                tbody="table-level-tbody"
                tfoot="table-level-tfoot"
                tr="table-level-tr"
                td="table-level-td"
              }}
              as |t|
            >
              <t.Header @class="component-level-header">
                <t.Column @class="component-level-column-1">Name</t.Column>
                <t.Column @class="component-level-column-2">Email</t.Column>
              </t.Header>
              <t.Body @class="component-level-body">
                {{#each items as |item|}}
                  <t.Row @item={{item}} @class="component-level-row">
                    <t.Cell
                      @class="component-level-cell-1"
                    >{{item.name}}</t.Cell>
                    <t.Cell
                      @class="component-level-cell-2"
                    >{{item.email}}</t.Cell>
                  </t.Row>
                {{/each}}
              </t.Body>
              <t.Footer @class="component-level-footer">
                {{#each footerColumns as |column|}}
                  <t.Column
                    @class="component-level-footer-column"
                  >{{column.label}}</t.Column>
                {{/each}}
              </t.Footer>
            </Table>
          </template>
        );

        // Check that wrapper gets table-level class
        assert
          .dom('[data-component="table-wrapper"].table-level-wrapper')
          .exists();

        // Check that table gets table-level class
        assert.dom('[data-test-id="table"].table-level-table').exists();

        // Check that header gets both table-level and component-level classes merged
        assert
          .dom(
            '[data-test-id="table-header"].table-level-thead.component-level-header'
          )
          .exists();

        // Check that body gets both table-level and component-level classes merged
        assert
          .dom(
            '[data-test-id="table-body"].table-level-tbody.component-level-body'
          )
          .exists();

        // Check that footer gets both table-level and component-level classes merged
        assert
          .dom(
            '[data-test-id="table-footer"].table-level-tfoot.component-level-footer'
          )
          .exists();

        // Check that header columns get component-level classes
        assert
          .dom('[data-test-id="table-header"] th.component-level-column-1')
          .exists();
        assert
          .dom('[data-test-id="table-header"] th.component-level-column-2')
          .exists();

        // Check that footer columns get component-level classes
        assert
          .dom('[data-test-id="table-footer"] th.component-level-footer-column')
          .exists({ count: 2 });

        // Check that rows get both table-level and component-level classes merged
        assert
          .dom(
            '[data-test-id="table-body"] tr.table-level-tr.component-level-row'
          )
          .exists({ count: 2 });

        // Check that cells get both table-level and component-level classes merged
        assert
          .dom(
            '[data-test-id="table-body"] td.table-level-td.component-level-cell-1'
          )
          .exists({ count: 2 });
        assert
          .dom(
            '[data-test-id="table-body"] td.table-level-td.component-level-cell-2'
          )
          .exists({ count: 2 });

        // Check that header row gets table-level tr class
        assert.dom('[data-test-id="table-header"] tr.table-level-tr').exists();

        // Check that footer row gets table-level tr class
        assert.dom('[data-test-id="table-footer"] tr.table-level-tr').exists();
      });

      test('it handles string classes correctly', async function (assert) {
        const columns: ColumnDefinition[] = [{ key: 'name', label: 'Name' }];
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
        const columns: ColumnDefinition[] = [{ key: 'name', label: 'Name' }];
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

      test('it merges classes with component-level classes in block form', async function (assert) {
        const items: TestItem[] = [
          { id: '1', name: 'John', email: 'john@example.com', role: 'admin' }
        ];

        await render(
          <template>
            <Table
              @classes={{hash
                thead="table-level-thead"
                tbody="table-level-tbody"
                tr="table-level-tr"
                td="table-level-td"
              }}
              as |t|
            >
              <t.Header @class="component-level-thead">
                <t.Column @class="component-level-th">Name</t.Column>
              </t.Header>
              <t.Body @class="component-level-tbody">
                {{#each items as |item|}}
                  <t.Row @item={{item}} @class="component-level-tr">
                    <t.Cell @class="component-level-td">{{item.name}}</t.Cell>
                  </t.Row>
                {{/each}}
              </t.Body>
            </Table>
          </template>
        );

        // Check that both table-level and component-level classes are merged
        assert.dom('thead.table-level-thead.component-level-thead').exists();
        assert.dom('tbody.table-level-tbody.component-level-tbody').exists();
        assert.dom('tr.table-level-tr.component-level-tr').exists();
        assert.dom('td.table-level-td.component-level-td').exists();
        assert.dom('th.component-level-th').exists();
      });

      test('it works without @classes argument', async function (assert) {
        const columns: ColumnDefinition[] = [{ key: 'name', label: 'Name' }];
        const items: TestItem[] = [
          { id: '1', name: 'John', email: 'john@example.com', role: 'admin' }
        ];

        await render(
          <template>
            <Table @columns={{columns}} @items={{items}} as |t|>
              <t.Header @class="header-only-class">
                <t.Column>Name</t.Column>
              </t.Header>
              <t.Body @class="body-only-class">
                {{#each items as |item|}}
                  <t.Row @item={{item}} @class="row-only-class">
                    <t.Cell @class="cell-only-class">{{item.name}}</t.Cell>
                  </t.Row>
                {{/each}}
              </t.Body>
            </Table>
          </template>
        );

        // Check that component-only classes still work
        assert.dom('thead.header-only-class').exists();
        assert.dom('tbody.body-only-class').exists();
        assert.dom('tr.row-only-class').exists();
        assert.dom('td.cell-only-class').exists();
      });

      test('it handles empty/null classes gracefully', async function (assert) {
        const columns: ColumnDefinition[] = [{ key: 'name', label: 'Name' }];
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

      test('it applies classes to all table elements with footer', async function (assert) {
        const columns: ColumnDefinition[] = [{ key: 'name', label: 'Name' }];
        const items: TestItem[] = [
          { id: '1', name: 'John', email: 'john@example.com', role: 'admin' }
        ];
        const footerColumns: ColumnDefinition[] = [
          { key: 'total', label: 'Total: 1' }
        ];

        await render(
          <template>
            <Table
              @columns={{columns}}
              @items={{items}}
              @footerColumns={{footerColumns}}
              @classes={{hash tfoot="footer-class" tr="shared-tr-class"}}
              as |t|
            >
              <t.Header>
                <t.Column>Name</t.Column>
              </t.Header>
              <t.Body>
                {{#each items as |item|}}
                  <t.Row @item={{item}}>
                    <t.Cell>{{item.name}}</t.Cell>
                  </t.Row>
                {{/each}}
              </t.Body>
              <t.Footer @class="component-footer-class">
                {{#each footerColumns as |column|}}
                  <t.Column>{{column.label}}</t.Column>
                {{/each}}
              </t.Footer>
            </Table>
          </template>
        );

        // Check footer gets both internal and component classes
        assert.dom('tfoot.footer-class.component-footer-class').exists();

        // Check tr class is applied to all row types
        assert.dom('[data-test-id="table-header"] tr.shared-tr-class').exists();
        assert.dom('[data-test-id="table-body"] tr.shared-tr-class').exists();
        assert.dom('[data-test-id="table-footer"] tr.shared-tr-class').exists();
      });

      test('it preserves theme-provided styling while merging custom classes', async function (assert) {
        const columns: ColumnDefinition[] = [{ key: 'name', label: 'Name' }];
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
        const columns: ColumnDefinition[] = [{ key: 'name', label: 'Name' }];
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

      test('it merges classes in manual composition with footerColumns', async function (assert) {
        const footerColumns: ColumnDefinition[] = [
          { key: 'total', label: 'Total' },
          { key: 'count', label: '1 item' }
        ];
        const items: TestItem[] = [
          { id: '1', name: 'John', email: 'john@example.com', role: 'admin' }
        ];

        await render(
          <template>
            <Table
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
  }
);
