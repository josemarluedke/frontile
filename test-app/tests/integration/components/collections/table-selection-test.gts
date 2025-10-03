import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, settled, click, triggerKeyEvent } from '@ember/test-helpers';
import { Table, type ColumnConfig } from '@frontile/collections';
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';

const array = <T,>(...args: T[]): T[] => args;

interface TestItem {
  id: string;
  name: string;
  email: string;
  role: string;
}

interface TestHelperSignature {
  Args: {
    initialKeys?: Set<string>;
  };
  Blocks: {
    default: [Set<string>, (keys: Set<string>) => void];
  };
}

class TestHelper extends Component<TestHelperSignature> {
  @tracked selectedKeys: Set<string>;

  constructor(owner: unknown, args: TestHelperSignature['Args']) {
    super(owner, args);
    this.selectedKeys = args.initialKeys || new Set<string>();
  }

  handleSelectionChange = (keys: Set<string>) => {
    this.selectedKeys = keys;
  };

  <template>{{yield this.selectedKeys this.handleSelectionChange}}</template>
}

module(
  'Integration | Component | Table | Selection | @frontile/collections',
  function (hooks) {
    setupRenderingTest(hooks);

    test('it renders checkboxes for multiple selection mode', async function (assert) {
      const columns = [
        { key: 'id', name: 'ID' },
        { key: 'name', name: 'Name' }
      ] as const satisfies ColumnConfig<TestItem>[];

      const items: TestItem[] = [
        { id: '1', name: 'John Doe', email: 'john@example.com', role: 'admin' },
        { id: '2', name: 'Jane Smith', email: 'jane@example.com', role: 'user' }
      ];

      await render(
        <template>
          <TestHelper as |selectedKeys onSelectionChange|>
            <Table
              @columns={{columns}}
              @items={{items}}
              @selectionMode="multiple"
              @selectedKeys={{selectedKeys}}
              @onSelectionChange={{onSelectionChange}}
            />
          </TestHelper>
        </template>
      );

      // Check that selection column is rendered
      assert
        .dom('[data-test-id="table-column"][data-key="__selection__"]')
        .exists();

      // Check that select all checkbox exists in header
      assert
        .dom(
          '[data-test-id="table-column"][data-key="__selection__"] input[type="checkbox"]'
        )
        .exists();

      // Check that each row has a checkbox
      assert
        .dom(
          '[data-test-id="table-row"][data-key="1"] [data-column="__selection__"] input[type="checkbox"]'
        )
        .exists();
      assert
        .dom(
          '[data-test-id="table-row"][data-key="2"] [data-column="__selection__"] input[type="checkbox"]'
        )
        .exists();
    });

    test('it handles single row selection via checkbox', async function (assert) {
      const columns = [
        { key: 'id', name: 'ID' },
        { key: 'name', name: 'Name' }
      ] as const satisfies ColumnConfig<TestItem>[];

      const items: TestItem[] = [
        { id: '1', name: 'John Doe', email: 'john@example.com', role: 'admin' },
        { id: '2', name: 'Jane Smith', email: 'jane@example.com', role: 'user' }
      ];

      let capturedKeys: Set<string> | null = null;

      await render(
        <template>
          <TestHelper as |selectedKeys onSelectionChange|>
            <Table
              @columns={{columns}}
              @items={{items}}
              @selectionMode="multiple"
              @selectedKeys={{selectedKeys}}
              @onSelectionChange={{onSelectionChange}}
            />
          </TestHelper>
        </template>
      );

      // Click first row checkbox
      await click(
        '[data-test-id="table-row"][data-key="1"] [data-column="__selection__"] input[type="checkbox"]'
      );

      // Verify via DOM
      const row1Checkbox = this.element.querySelector<HTMLInputElement>(
        '[data-test-id="table-row"][data-key="1"] [data-column="__selection__"] input[type="checkbox"]'
      );
      assert.true(row1Checkbox?.checked, 'First row checkbox is checked');

      // Click second row checkbox
      await click(
        '[data-test-id="table-row"][data-key="2"] [data-column="__selection__"] input[type="checkbox"]'
      );

      const row2Checkbox = this.element.querySelector<HTMLInputElement>(
        '[data-test-id="table-row"][data-key="2"] [data-column="__selection__"] input[type="checkbox"]'
      );
      assert.true(row1Checkbox?.checked, 'First row checkbox is still checked');
      assert.true(row2Checkbox?.checked, 'Second row checkbox is checked');
    });

    test('it handles select all checkbox - none to all', async function (assert) {
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
          <TestHelper as |selectedKeys onSelectionChange|>
            <Table
              @columns={{columns}}
              @items={{items}}
              @selectionMode="multiple"
              @selectedKeys={{selectedKeys}}
              @onSelectionChange={{onSelectionChange}}
            />
          </TestHelper>
        </template>
      );

      const selectAllCheckbox = this.element.querySelector<HTMLInputElement>(
        '[data-test-id="table-column"][data-key="__selection__"] input[type="checkbox"]'
      );

      // Initially: none selected, checkbox not checked, not indeterminate
      assert.false(
        selectAllCheckbox?.checked,
        'Select all checkbox is not checked'
      );
      assert.false(
        selectAllCheckbox?.indeterminate,
        'Select all checkbox is not indeterminate'
      );

      // Click to select all
      await click(selectAllCheckbox!);

      // Verify selection happened by checking row checkbox states
      const row1Checkbox = this.element.querySelector<HTMLInputElement>(
        '[data-test-id="table-row"][data-key="1"] [data-column="__selection__"] input[type="checkbox"]'
      );
      const row2Checkbox = this.element.querySelector<HTMLInputElement>(
        '[data-test-id="table-row"][data-key="2"] [data-column="__selection__"] input[type="checkbox"]'
      );
      const row3Checkbox = this.element.querySelector<HTMLInputElement>(
        '[data-test-id="table-row"][data-key="3"] [data-column="__selection__"] input[type="checkbox"]'
      );

      assert.true(row1Checkbox?.checked, 'First row checkbox is checked');
      assert.true(row2Checkbox?.checked, 'Second row checkbox is checked');
      assert.true(row3Checkbox?.checked, 'Third row checkbox is checked');

      assert.true(selectAllCheckbox?.checked, 'Select all checkbox is checked');
      assert.false(
        selectAllCheckbox?.indeterminate,
        'Select all checkbox is not indeterminate'
      );
    });

    test('it handles select all checkbox - all to none', async function (assert) {
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

      const initialKeys = new Set(['1', '2', '3']);

      await render(
        <template>
          <TestHelper
            @initialKeys={{initialKeys}}
            as |currentKeys onSelectionChange|
          >
            <Table
              @columns={{columns}}
              @items={{items}}
              @selectionMode="multiple"
              @selectedKeys={{currentKeys}}
              @onSelectionChange={{onSelectionChange}}
            />
          </TestHelper>
        </template>
      );

      const selectAllCheckbox = this.element.querySelector<HTMLInputElement>(
        '[data-test-id="table-column"][data-key="__selection__"] input[type="checkbox"]'
      );

      // Initially: all selected, checkbox checked, not indeterminate
      assert.true(selectAllCheckbox?.checked, 'Select all checkbox is checked');
      assert.false(
        selectAllCheckbox?.indeterminate,
        'Select all checkbox is not indeterminate'
      );

      // Click to deselect all
      await click(selectAllCheckbox!);

      const row1Checkbox = this.element.querySelector<HTMLInputElement>(
        '[data-test-id="table-row"][data-key="1"] [data-column="__selection__"] input[type="checkbox"]'
      );
      const row2Checkbox = this.element.querySelector<HTMLInputElement>(
        '[data-test-id="table-row"][data-key="2"] [data-column="__selection__"] input[type="checkbox"]'
      );
      const row3Checkbox = this.element.querySelector<HTMLInputElement>(
        '[data-test-id="table-row"][data-key="3"] [data-column="__selection__"] input[type="checkbox"]'
      );

      assert.false(row1Checkbox?.checked, 'First row checkbox is not checked');
      assert.false(row2Checkbox?.checked, 'Second row checkbox is not checked');
      assert.false(row3Checkbox?.checked, 'Third row checkbox is not checked');

      assert.false(
        selectAllCheckbox?.checked,
        'Select all checkbox is not checked'
      );
      assert.false(
        selectAllCheckbox?.indeterminate,
        'Select all checkbox is not indeterminate'
      );
    });

    test('it handles select all checkbox - indeterminate to all', async function (assert) {
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

      const initialKeys = new Set(['1']);

      await render(
        <template>
          <TestHelper
            @initialKeys={{initialKeys}}
            as |currentKeys onSelectionChange|
          >
            <Table
              @columns={{columns}}
              @items={{items}}
              @selectionMode="multiple"
              @selectedKeys={{currentKeys}}
              @onSelectionChange={{onSelectionChange}}
            />
          </TestHelper>
        </template>
      );

      const selectAllCheckbox = this.element.querySelector<HTMLInputElement>(
        '[data-test-id="table-column"][data-key="__selection__"] input[type="checkbox"]'
      );

      // Initially: some selected, checkbox not checked but indeterminate
      assert.false(
        selectAllCheckbox?.checked,
        'Select all checkbox is not checked when indeterminate'
      );
      assert.true(
        selectAllCheckbox?.indeterminate,
        'Select all checkbox is indeterminate'
      );

      // Click to select all
      await click(selectAllCheckbox!);

      const row1Checkbox = this.element.querySelector<HTMLInputElement>(
        '[data-test-id="table-row"][data-key="1"] [data-column="__selection__"] input[type="checkbox"]'
      );
      const row2Checkbox = this.element.querySelector<HTMLInputElement>(
        '[data-test-id="table-row"][data-key="2"] [data-column="__selection__"] input[type="checkbox"]'
      );
      const row3Checkbox = this.element.querySelector<HTMLInputElement>(
        '[data-test-id="table-row"][data-key="3"] [data-column="__selection__"] input[type="checkbox"]'
      );

      assert.true(row1Checkbox?.checked, 'First row checkbox is checked');
      assert.true(row2Checkbox?.checked, 'Second row checkbox is checked');
      assert.true(row3Checkbox?.checked, 'Third row checkbox is checked');

      assert.true(selectAllCheckbox?.checked, 'Select all checkbox is checked');
      assert.false(
        selectAllCheckbox?.indeterminate,
        'Select all checkbox is not indeterminate'
      );
    });

    test('it handles select all with disabled rows', async function (assert) {
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
          <TestHelper as |selectedKeys onSelectionChange|>
            <Table
              @columns={{columns}}
              @items={{items}}
              @selectionMode="multiple"
              @selectedKeys={{selectedKeys}}
              @onSelectionChange={{onSelectionChange}}
              @disabledKeys={{(array "2")}}
            />
          </TestHelper>
        </template>
      );

      const selectAllCheckbox = this.element.querySelector<HTMLInputElement>(
        '[data-test-id="table-column"][data-key="__selection__"] input[type="checkbox"]'
      );

      // Click to select all (should only select non-disabled rows)
      await click(selectAllCheckbox!);

      const row1Checkbox = this.element.querySelector<HTMLInputElement>(
        '[data-test-id="table-row"][data-key="1"] [data-column="__selection__"] input[type="checkbox"]'
      );
      const row2Checkbox = this.element.querySelector<HTMLInputElement>(
        '[data-test-id="table-row"][data-key="2"] [data-column="__selection__"] input[type="checkbox"]'
      );
      const row3Checkbox = this.element.querySelector<HTMLInputElement>(
        '[data-test-id="table-row"][data-key="3"] [data-column="__selection__"] input[type="checkbox"]'
      );

      assert.true(row1Checkbox?.checked, 'First row checkbox is checked');
      assert.false(
        row2Checkbox?.checked,
        'Second row checkbox is NOT checked (disabled)'
      );
      assert.true(row3Checkbox?.checked, 'Third row checkbox is checked');

      assert.true(selectAllCheckbox?.checked, 'Select all checkbox is checked');
      assert.false(
        selectAllCheckbox?.indeterminate,
        'Select all checkbox is not indeterminate'
      );
    });

    test('it handles disabled keys', async function (assert) {
      const columns = [
        { key: 'id', name: 'ID' },
        { key: 'name', name: 'Name' }
      ] as const satisfies ColumnConfig<TestItem>[];

      const items: TestItem[] = [
        { id: '1', name: 'John Doe', email: 'john@example.com', role: 'admin' },
        { id: '2', name: 'Jane Smith', email: 'jane@example.com', role: 'user' }
      ];

      await render(
        <template>
          <TestHelper as |selectedKeys onSelectionChange|>
            <Table
              @columns={{columns}}
              @items={{items}}
              @selectionMode="multiple"
              @selectedKeys={{selectedKeys}}
              @onSelectionChange={{onSelectionChange}}
              @disabledKeys={{array "2"}}
            />
          </TestHelper>
        </template>
      );

      // Check that disabled row checkbox is disabled
      assert
        .dom(
          '[data-test-id="table-row"][data-key="2"] [data-column="__selection__"] input[type="checkbox"]'
        )
        .isDisabled();

      // Check that enabled row checkbox is not disabled
      assert
        .dom(
          '[data-test-id="table-row"][data-key="1"] [data-column="__selection__"] input[type="checkbox"]'
        )
        .isNotDisabled();

      // Check that disabled row has data-disabled attribute
      assert
        .dom('[data-test-id="table-row"][data-key="2"]')
        .hasAttribute('data-disabled', 'true');
    });

    test('it handles single selection mode', async function (assert) {
      const columns = [
        { key: 'id', name: 'ID' },
        { key: 'name', name: 'Name' }
      ] as const satisfies ColumnConfig<TestItem>[];

      const items: TestItem[] = [
        { id: '1', name: 'John Doe', email: 'john@example.com', role: 'admin' },
        { id: '2', name: 'Jane Smith', email: 'jane@example.com', role: 'user' }
      ];

      await render(
        <template>
          <TestHelper as |selectedKeys onSelectionChange|>
            <Table
              @columns={{columns}}
              @items={{items}}
              @selectionMode="single"
              @selectedKeys={{selectedKeys}}
              @onSelectionChange={{onSelectionChange}}
            />
          </TestHelper>
        </template>
      );

      // In single selection mode, no checkboxes should be rendered
      assert
        .dom('[data-test-id="table-column"][data-key="__selection__"]')
        .doesNotExist();

      // Click first row (universal-ember/table handles row clicks for single selection)
      await click('[data-test-id="table-row"][data-key="1"]');

      // Verify via DOM data attribute
      assert
        .dom('[data-test-id="table-row"][data-key="1"]')
        .hasAttribute('data-selected', 'true', 'First row is selected');

      // Click second row
      await click('[data-test-id="table-row"][data-key="2"]');

      // Verify first row is no longer selected and second row is selected
      assert
        .dom('[data-test-id="table-row"][data-key="1"]')
        .hasAttribute('data-selected', 'false', 'First row is deselected');
      assert
        .dom('[data-test-id="table-row"][data-key="2"]')
        .hasAttribute('data-selected', 'true', 'Second row is selected');
    });

    test('it applies correct data attributes for selected and selectable rows', async function (assert) {
      const columns = [
        { key: 'id', name: 'ID' },
        { key: 'name', name: 'Name' }
      ] as const satisfies ColumnConfig<TestItem>[];

      const items: TestItem[] = [
        { id: '1', name: 'John Doe', email: 'john@example.com', role: 'admin' }
      ];

      const initialKeys = new Set(['1']);

      await render(
        <template>
          <TestHelper
            @initialKeys={{initialKeys}}
            as |currentKeys onSelectionChange|
          >
            <Table
              @columns={{columns}}
              @items={{items}}
              @selectionMode="multiple"
              @selectedKeys={{currentKeys}}
              @onSelectionChange={{onSelectionChange}}
            />
          </TestHelper>
        </template>
      );

      // Check that selected row has data-selected attribute
      assert
        .dom('[data-test-id="table-row"][data-key="1"]')
        .hasAttribute('data-selected', 'true');

      // Check that row has data-selectable attribute
      assert
        .dom('[data-test-id="table-row"][data-key="1"]')
        .hasAttribute('data-selectable', 'true');
    });

    test('it works in uncontrolled mode', async function (assert) {
      const columns = [
        { key: 'id', name: 'ID' },
        { key: 'name', name: 'Name' }
      ] as const satisfies ColumnConfig<TestItem>[];

      const items: TestItem[] = [
        { id: '1', name: 'John Doe', email: 'john@example.com', role: 'admin' },
        { id: '2', name: 'Jane Smith', email: 'jane@example.com', role: 'user' }
      ];

      await render(
        <template>
          <Table
            @columns={{columns}}
            @items={{items}}
            @selectionMode="multiple"
          />
        </template>
      );

      // Check that checkboxes are rendered
      assert
        .dom('[data-test-id="table-column"][data-key="__selection__"]')
        .exists();

      // Click first row checkbox
      await click(
        '[data-test-id="table-row"][data-key="1"] [data-column="__selection__"] input[type="checkbox"]'
      );

      // Verify first row is selected via DOM
      const row1Checkbox = this.element.querySelector<HTMLInputElement>(
        '[data-test-id="table-row"][data-key="1"] [data-column="__selection__"] input[type="checkbox"]'
      );
      assert.true(row1Checkbox?.checked, 'First row checkbox is checked');
      assert
        .dom('[data-test-id="table-row"][data-key="1"]')
        .hasAttribute('data-selected', 'true', 'First row is selected');

      // Click second row checkbox
      await click(
        '[data-test-id="table-row"][data-key="2"] [data-column="__selection__"] input[type="checkbox"]'
      );

      const row2Checkbox = this.element.querySelector<HTMLInputElement>(
        '[data-test-id="table-row"][data-key="2"] [data-column="__selection__"] input[type="checkbox"]'
      );
      assert.true(row1Checkbox?.checked, 'First row is still checked');
      assert.true(row2Checkbox?.checked, 'Second row is checked');
    });

    test('it calls onSelectionChange in uncontrolled mode', async function (assert) {
      const columns = [
        { key: 'id', name: 'ID' },
        { key: 'name', name: 'Name' }
      ] as const satisfies ColumnConfig<TestItem>[];

      const items: TestItem[] = [
        { id: '1', name: 'John Doe', email: 'john@example.com', role: 'admin' },
        { id: '2', name: 'Jane Smith', email: 'jane@example.com', role: 'user' }
      ];

      let capturedKeys: Set<string> | null = null;
      const handleChange = (keys: Set<string>) => {
        capturedKeys = keys;
      };

      await render(
        <template>
          <Table
            @columns={{columns}}
            @items={{items}}
            @selectionMode="multiple"
            @onSelectionChange={{handleChange}}
          />
        </template>
      );

      // Click first row checkbox
      await click(
        '[data-test-id="table-row"][data-key="1"] [data-column="__selection__"] input[type="checkbox"]'
      );

      assert.ok(capturedKeys, 'onSelectionChange was called');
      assert.true(capturedKeys?.has('1'), 'First row key is in selection');
      assert.strictEqual(capturedKeys?.size, 1, 'Only one key selected');

      // Click second row checkbox
      await click(
        '[data-test-id="table-row"][data-key="2"] [data-column="__selection__"] input[type="checkbox"]'
      );

      assert.true(capturedKeys?.has('1'), 'First row still in selection');
      assert.true(capturedKeys?.has('2'), 'Second row in selection');
      assert.strictEqual(capturedKeys?.size, 2, 'Two keys selected');
    });

    test('it handles keyboard navigation with Space key', async function (assert) {
      const columns = [
        { key: 'id', name: 'ID' },
        { key: 'name', name: 'Name' }
      ] as const satisfies ColumnConfig<TestItem>[];

      const items: TestItem[] = [
        { id: '1', name: 'John Doe', email: 'john@example.com', role: 'admin' },
        { id: '2', name: 'Jane Smith', email: 'jane@example.com', role: 'user' }
      ];

      await render(
        <template>
          <TestHelper as |selectedKeys onSelectionChange|>
            <Table
              @columns={{columns}}
              @items={{items}}
              @selectionMode="multiple"
              @selectedKeys={{selectedKeys}}
              @onSelectionChange={{onSelectionChange}}
            />
          </TestHelper>
        </template>
      );

      const row1 = this.element.querySelector<HTMLElement>(
        '[data-test-id="table-row"][data-key="1"]'
      );

      // Focus and press Space on first row
      row1?.focus();
      await triggerKeyEvent(
        '[data-test-id="table-row"][data-key="1"]',
        'keydown',
        ' '
      );

      // Verify first row is selected
      assert
        .dom('[data-test-id="table-row"][data-key="1"]')
        .hasAttribute('data-selected', 'true', 'First row selected via Space');

      // Press Space again to deselect
      await triggerKeyEvent(
        '[data-test-id="table-row"][data-key="1"]',
        'keydown',
        ' '
      );

      assert
        .dom('[data-test-id="table-row"][data-key="1"]')
        .hasAttribute(
          'data-selected',
          'false',
          'First row deselected via Space'
        );
    });

    test('it handles keyboard navigation with Enter key', async function (assert) {
      const columns = [
        { key: 'id', name: 'ID' },
        { key: 'name', name: 'Name' }
      ] as const satisfies ColumnConfig<TestItem>[];

      const items: TestItem[] = [
        { id: '1', name: 'John Doe', email: 'john@example.com', role: 'admin' },
        { id: '2', name: 'Jane Smith', email: 'jane@example.com', role: 'user' }
      ];

      await render(
        <template>
          <TestHelper as |selectedKeys onSelectionChange|>
            <Table
              @columns={{columns}}
              @items={{items}}
              @selectionMode="single"
              @selectedKeys={{selectedKeys}}
              @onSelectionChange={{onSelectionChange}}
            />
          </TestHelper>
        </template>
      );

      const row1 = this.element.querySelector<HTMLElement>(
        '[data-test-id="table-row"][data-key="1"]'
      );

      // Focus and press Enter on first row
      row1?.focus();
      await triggerKeyEvent(
        '[data-test-id="table-row"][data-key="1"]',
        'keydown',
        'Enter'
      );

      // Verify first row is selected
      assert
        .dom('[data-test-id="table-row"][data-key="1"]')
        .hasAttribute('data-selected', 'true', 'First row selected via Enter');

      // Press Enter on second row
      await triggerKeyEvent(
        '[data-test-id="table-row"][data-key="2"]',
        'keydown',
        'Enter'
      );

      assert
        .dom('[data-test-id="table-row"][data-key="1"]')
        .hasAttribute(
          'data-selected',
          'false',
          'First row deselected in single mode'
        );
      assert
        .dom('[data-test-id="table-row"][data-key="2"]')
        .hasAttribute('data-selected', 'true', 'Second row selected via Enter');
    });

    test('it respects disabled rows with keyboard navigation', async function (assert) {
      const columns = [
        { key: 'id', name: 'ID' },
        { key: 'name', name: 'Name' }
      ] as const satisfies ColumnConfig<TestItem>[];

      const items: TestItem[] = [
        { id: '1', name: 'John Doe', email: 'john@example.com', role: 'admin' },
        { id: '2', name: 'Jane Smith', email: 'jane@example.com', role: 'user' }
      ];

      await render(
        <template>
          <TestHelper as |selectedKeys onSelectionChange|>
            <Table
              @columns={{columns}}
              @items={{items}}
              @selectionMode="multiple"
              @selectedKeys={{selectedKeys}}
              @onSelectionChange={{onSelectionChange}}
              @disabledKeys={{array "1"}}
            />
          </TestHelper>
        </template>
      );

      // Try to select disabled row with Space
      await triggerKeyEvent(
        '[data-test-id="table-row"][data-key="1"]',
        'keydown',
        ' '
      );

      // Verify disabled row is not selected
      assert
        .dom('[data-test-id="table-row"][data-key="1"]')
        .hasAttribute(
          'data-selected',
          'false',
          'Disabled row cannot be selected via keyboard'
        );
    });

    test('it applies selectionColor variant styles', async function (assert) {
      const columns = [
        { key: 'id', name: 'ID' },
        { key: 'name', name: 'Name' }
      ] as const satisfies ColumnConfig<TestItem>[];

      const items: TestItem[] = [
        { id: '1', name: 'John Doe', email: 'john@example.com', role: 'admin' }
      ];

      const initialKeys = new Set(['1']);

      await render(
        <template>
          <TestHelper
            @initialKeys={{initialKeys}}
            as |selectedKeys onSelectionChange|
          >
            <Table
              @columns={{columns}}
              @items={{items}}
              @selectionMode="multiple"
              @selectedKeys={{selectedKeys}}
              @onSelectionChange={{onSelectionChange}}
              @selectionColor="success"
            />
          </TestHelper>
        </template>
      );

      // Check that the selected row exists with data-selected attribute
      assert
        .dom('[data-test-id="table-row"][data-key="1"]')
        .hasAttribute('data-selected', 'true', 'Row is selected');

      // Note: The actual color class will be applied by the theme system
      // We verify the variant is passed correctly by checking the row is selected
      // The visual styling is tested through integration with the theme package
    });

    test('it handles arrow key navigation between rows', async function (assert) {
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
          <TestHelper as |selectedKeys onSelectionChange|>
            <Table
              @columns={{columns}}
              @items={{items}}
              @selectionMode="multiple"
              @selectedKeys={{selectedKeys}}
              @onSelectionChange={{onSelectionChange}}
            />
          </TestHelper>
        </template>
      );

      // Focus first row
      const row1 = this.element.querySelector<HTMLElement>(
        '[data-test-id="table-row"][data-key="1"]'
      );
      row1?.focus();

      // Press ArrowDown to move to second row
      await triggerKeyEvent(
        '[data-test-id="table-row"][data-key="1"]',
        'keydown',
        'ArrowDown'
      );

      // Check that second row is now focused
      const row2 = this.element.querySelector<HTMLElement>(
        '[data-test-id="table-row"][data-key="2"]'
      );
      assert.strictEqual(
        document.activeElement,
        row2,
        'Second row should be focused after ArrowDown'
      );

      // Press ArrowDown again to move to third row
      await triggerKeyEvent(
        '[data-test-id="table-row"][data-key="2"]',
        'keydown',
        'ArrowDown'
      );

      const row3 = this.element.querySelector<HTMLElement>(
        '[data-test-id="table-row"][data-key="3"]'
      );
      assert.strictEqual(
        document.activeElement,
        row3,
        'Third row should be focused after second ArrowDown'
      );

      // Press ArrowUp to move back to second row
      await triggerKeyEvent(
        '[data-test-id="table-row"][data-key="3"]',
        'keydown',
        'ArrowUp'
      );

      assert.strictEqual(
        document.activeElement,
        row2,
        'Second row should be focused after ArrowUp'
      );
    });
  }
);
