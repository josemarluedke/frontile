import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, settled } from '@ember/test-helpers';
import { Table, type ColumnDefinition } from '@frontile/collections';
import { array } from '@ember/helper';
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
    });

    test('it renders with manual header composition', async function (assert) {
      const items: TestItem[] = [
        { id: '1', name: 'John Doe', email: 'john@example.com', role: 'admin' }
      ];

      await render(
        <template>
          <Table as |t|>
            <t.Header>
              <t.Column class="custom-header">ID (Custom)</t.Column>
              <t.Column class="custom-header">Name (Custom)</t.Column>
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
                  <t.Cell class="custom-cell">Custom: {{item.id}}</t.Cell>
                  <t.Cell class="custom-cell">Custom: {{item.name}}</t.Cell>
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

    test('it applies custom CSS classes', async function (assert) {
      const columns: ColumnDefinition[] = [{ key: 'name', label: 'Name' }];

      const items: TestItem[] = [
        { id: '1', name: 'John', email: 'john@example.com', role: 'admin' }
      ];

      await render(
        <template>
          <Table
            @columns={{columns}}
            @items={{items}}
            class="custom-table-class"
          />
        </template>
      );

      assert.dom('[data-test-id="table"]').hasClass('custom-table-class');
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
  }
);
