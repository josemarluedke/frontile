import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render } from '@ember/test-helpers';
import { SimpleTable } from 'frontile';
import { hash } from '@ember/helper';

interface TestItem {
  id: string;
  name: string;
  email: string;
  role: string;
}

module(
  'Integration | Component | SimpleTable | @frontile/collections',
  function (hooks) {
    setupRenderingTest(hooks);

    test('it renders basic table structure with manual composition', async function (assert) {
      const items: TestItem[] = [
        { id: '1', name: 'John Doe', email: 'john@example.com', role: 'admin' },
        { id: '2', name: 'Jane Smith', email: 'jane@example.com', role: 'user' }
      ];

      await render(
        <template>
          <SimpleTable as |t|>
            <t.Header>
              <t.Column>ID</t.Column>
              <t.Column>Name</t.Column>
              <t.Column>Email</t.Column>
            </t.Header>
            <t.Body>
              {{#each items as |item|}}
                <t.Row>
                  <t.Cell>{{item.id}}</t.Cell>
                  <t.Cell>{{item.name}}</t.Cell>
                  <t.Cell>{{item.email}}</t.Cell>
                </t.Row>
              {{/each}}
            </t.Body>
          </SimpleTable>
        </template>
      );

      assert.dom('[data-test-id="table"]').exists();
      assert.dom('[data-test-id="table-header"]').exists();
      assert.dom('[data-test-id="table-body"]').exists();

      // Check static columns
      assert.dom('[data-test-id="table-column"]').exists({ count: 3 });

      // Check rows
      assert.dom('[data-test-id="table-row"]').exists({ count: 2 });

      // Check cells content
      const cells = document.querySelectorAll('[data-test-id="table-cell"]');
      assert.dom(cells[0]).containsText('1');
      assert.dom(cells[1]).containsText('John Doe');
      assert.dom(cells[2]).containsText('john@example.com');
      assert.dom(cells[3]).containsText('2');
      assert.dom(cells[4]).containsText('Jane Smith');
      assert.dom(cells[5]).containsText('jane@example.com');
    });

    test('it supports custom header composition', async function (assert) {
      const items: TestItem[] = [
        { id: '1', name: 'John Doe', email: 'john@example.com', role: 'admin' }
      ];

      await render(
        <template>
          <SimpleTable as |t|>
            <t.Header @class="custom-header">
              <t.Column @class="custom-column">ID (Custom)</t.Column>
              <t.Column @class="custom-column">Name (Custom)</t.Column>
            </t.Header>
            <t.Body>
              {{#each items as |item|}}
                <t.Row>
                  <t.Cell>{{item.id}}</t.Cell>
                  <t.Cell>{{item.name}}</t.Cell>
                </t.Row>
              {{/each}}
            </t.Body>
          </SimpleTable>
        </template>
      );

      assert.dom('[data-test-id="table"]').exists();
      assert.dom('thead.custom-header').exists();
      assert.dom('th.custom-column').exists({ count: 2 });
      assert.dom('th.custom-column').containsText('ID (Custom)');
    });

    test('it supports custom cell composition', async function (assert) {
      const items: TestItem[] = [
        { id: '1', name: 'John Doe', email: 'john@example.com', role: 'admin' }
      ];

      await render(
        <template>
          <SimpleTable as |t|>
            <t.Header>
              <t.Column>ID</t.Column>
              <t.Column>Name</t.Column>
            </t.Header>
            <t.Body>
              {{#each items as |item|}}
                <t.Row>
                  <t.Cell @class="custom-cell">Custom: {{item.id}}</t.Cell>
                  <t.Cell @class="custom-cell">Custom: {{item.name}}</t.Cell>
                </t.Row>
              {{/each}}
            </t.Body>
          </SimpleTable>
        </template>
      );

      assert.dom('[data-test-id="table"]').exists();
      assert.dom('td.custom-cell').exists({ count: 2 });
      assert.dom('td.custom-cell').containsText('Custom: 1');
    });

    test('it applies basic custom classes', async function (assert) {
      await render(
        <template>
          <SimpleTable @classes={{hash table="custom-table-class"}} as |t|>
            <t.Header>
              <t.Column>Name</t.Column>
            </t.Header>
            <t.Body>
              <t.Row>
                <t.Cell>Content</t.Cell>
              </t.Row>
            </t.Body>
          </SimpleTable>
        </template>
      );

      assert.dom('[data-test-id="table"].custom-table-class').exists();
    });

    test('it supports footer composition', async function (assert) {
      await render(
        <template>
          <SimpleTable as |t|>
            <t.Header>
              <t.Column>Name</t.Column>
            </t.Header>
            <t.Body>
              <t.Row>
                <t.Cell>John</t.Cell>
              </t.Row>
            </t.Body>
            <t.Footer>
              <t.Column>Total: 1 item</t.Column>
            </t.Footer>
          </SimpleTable>
        </template>
      );

      assert.dom('[data-test-id="table"]').exists();
      assert.dom('[data-test-id="table-header"]').exists();
      assert.dom('[data-test-id="table-body"]').exists();
      assert.dom('[data-test-id="table-footer"]').exists();
      assert
        .dom('[data-test-id="table-footer"] [data-test-id="table-column"]')
        .containsText('Total: 1 item');
    });

    test('it supports size variants', async function (assert) {
      await render(
        <template>
          <SimpleTable @size="sm" as |t|>
            <t.Header>
              <t.Column>Name</t.Column>
            </t.Header>
            <t.Body>
              <t.Row>
                <t.Cell>Content</t.Cell>
              </t.Row>
            </t.Body>
          </SimpleTable>
        </template>
      );

      // The table should render successfully with size variant
      assert.dom('[data-test-id="table"]').exists();
      assert.dom('[data-test-id="table-cell"]').exists();
    });

    test('it supports layout variants', async function (assert) {
      await render(
        <template>
          <SimpleTable @layout="fixed" as |t|>
            <t.Header>
              <t.Column>Name</t.Column>
            </t.Header>
            <t.Body>
              <t.Row>
                <t.Cell>Content</t.Cell>
              </t.Row>
            </t.Body>
          </SimpleTable>
        </template>
      );

      // The table should render successfully with layout variant
      assert.dom('[data-test-id="table"]').exists();
      assert.dom('[data-test-id="table-cell"]').exists();
    });

    test('it supports striped variant', async function (assert) {
      await render(
        <template>
          <SimpleTable @isStriped={{true}} as |t|>
            <t.Header>
              <t.Column>Name</t.Column>
            </t.Header>
            <t.Body>
              <t.Row>
                <t.Cell>Content</t.Cell>
              </t.Row>
            </t.Body>
          </SimpleTable>
        </template>
      );

      // The table should render successfully with striped variant
      assert.dom('[data-test-id="table"]').exists();
      assert.dom('[data-test-id="table-cell"]').exists();
    });

    test('it supports loading state', async function (assert) {
      await render(
        <template>
          <SimpleTable @isLoading={{true}} as |t|>
            <t.Header>
              <t.Column>Name</t.Column>
            </t.Header>
            <t.Body>
              <t.Row>
                <t.Cell>Content</t.Cell>
              </t.Row>
            </t.Body>
          </SimpleTable>
        </template>
      );

      // The table should render successfully with loading state
      assert.dom('[data-test-id="table"]').exists();
      assert.dom('[data-test-id="table"][data-loading="true"]').exists();
      assert.dom('[data-test-id="table-cell"]').exists();
    });

    test('it supports loading state with color variants', async function (assert) {
      const colors = ['default', 'primary', 'success', 'warning', 'danger'];

      for (const color of colors) {
        // Re-render with each color variant
        await render(
          <template>
            <SimpleTable @isLoading={{true}} @loadingColor={{color}} as |t|>
              <t.Header>
                <t.Column>Name</t.Column>
              </t.Header>
              <t.Body>
                <t.Row>
                  <t.Cell>Content for {{color}}</t.Cell>
                </t.Row>
              </t.Body>
            </SimpleTable>
          </template>
        );

        // The table should render successfully with loading color variant
        assert.dom('[data-test-id="table"]').exists();
        assert.dom('[data-test-id="table"][data-loading="true"]').exists();
        assert
          .dom('[data-test-id="table-cell"]')
          .containsText(`Content for ${color}`);
      }
    });
  }
);
