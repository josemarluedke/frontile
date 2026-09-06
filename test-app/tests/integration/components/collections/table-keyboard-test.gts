import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import {
  render,
  settled,
  focus,
  triggerKeyEvent,
  findAll
} from '@ember/test-helpers';
import { tracked } from '@glimmer/tracking';
import { Table, type ColumnConfig } from 'frontile';

const array = <T,>(...args: T[]): T[] => args;

interface TestItem {
  id: string;
  name: string;
}

const columns = [
  { key: 'id', name: 'ID' },
  { key: 'name', name: 'Name' }
] as const satisfies ColumnConfig<TestItem>[];

const rowFor = (key: string): HTMLElement =>
  document.querySelector<HTMLElement>(
    `[data-test-id="table-row"][data-key="${key}"]`
  ) as HTMLElement;

const rowKeys = (): (string | undefined)[] =>
  findAll('[data-test-id="table-row"]').map(
    (row) => (row as HTMLElement).dataset['key']
  );

const tabbableKeys = (): (string | undefined)[] =>
  findAll('[data-test-id="table-row"][tabindex="0"]').map(
    (row) => (row as HTMLElement).dataset['key']
  );

class State {
  @tracked items: TestItem[];

  constructor(items: TestItem[]) {
    this.items = items;
  }
}

const threeItems = (): TestItem[] => [
  { id: '1', name: 'John Doe' },
  { id: '2', name: 'Jane Smith' },
  { id: '3', name: 'Bob Wilson' }
];

module(
  'Integration | Component | Table | Keyboard | @frontile/collections',
  function (hooks) {
    setupRenderingTest(hooks);

    test('Home and End jump to the first and last row', async function (assert) {
      const items = threeItems();

      await render(
        <template>
          <Table
            @columns={{columns}}
            @items={{items}}
            @selectionMode="multiple"
          />
        </template>
      );

      await focus(rowFor('2'));

      await triggerKeyEvent(rowFor('2'), 'keydown', 'End');
      assert.strictEqual(
        document.activeElement,
        rowFor('3'),
        'End moves to the last row'
      );

      await triggerKeyEvent(rowFor('3'), 'keydown', 'Home');
      assert.strictEqual(
        document.activeElement,
        rowFor('1'),
        'Home moves to the first row'
      );
    });

    test('arrow navigation wraps at both ends', async function (assert) {
      const items = threeItems();

      await render(
        <template>
          <Table
            @columns={{columns}}
            @items={{items}}
            @selectionMode="multiple"
          />
        </template>
      );

      await focus(rowFor('3'));
      await triggerKeyEvent(rowFor('3'), 'keydown', 'ArrowDown');
      assert.strictEqual(
        document.activeElement,
        rowFor('1'),
        'ArrowDown past the last row wraps to the first'
      );

      await triggerKeyEvent(rowFor('1'), 'keydown', 'ArrowUp');
      assert.strictEqual(
        document.activeElement,
        rowFor('3'),
        'ArrowUp past the first row wraps to the last'
      );
    });

    test('arrow navigation skips disabled rows', async function (assert) {
      const items = threeItems();

      await render(
        <template>
          <Table
            @columns={{columns}}
            @items={{items}}
            @selectionMode="multiple"
            @disabledKeys={{array "2"}}
          />
        </template>
      );

      await focus(rowFor('1'));
      await triggerKeyEvent(rowFor('1'), 'keydown', 'ArrowDown');
      assert.strictEqual(
        document.activeElement,
        rowFor('3'),
        'the disabled middle row is stepped over'
      );

      await triggerKeyEvent(rowFor('3'), 'keydown', 'ArrowUp');
      assert.strictEqual(
        document.activeElement,
        rowFor('1'),
        'and stepped over on the way back'
      );
    });

    test('a disabled first row does not own the tab stop', async function (assert) {
      const items = threeItems();

      await render(
        <template>
          <Table
            @columns={{columns}}
            @items={{items}}
            @selectionMode="multiple"
            @disabledKeys={{array "1"}}
          />
        </template>
      );

      assert.deepEqual(
        tabbableKeys(),
        ['2'],
        'the tab stop falls through to the first enabled row'
      );
    });

    test('the tab stop survives the row holding it being removed', async function (assert) {
      const state = new State(threeItems());

      await render(
        <template>
          <Table
            @columns={{columns}}
            @items={{state.items}}
            @selectionMode="multiple"
          />
        </template>
      );

      assert.deepEqual(tabbableKeys(), ['1'], 'the first row starts tabbable');

      await focus(rowFor('2'));
      await triggerKeyEvent(rowFor('2'), 'keydown', 'ArrowDown');
      assert.deepEqual(tabbableKeys(), ['3'], 'the tab stop follows focus');

      state.items = state.items.filter((item) => item.id !== '3');
      await settled();

      assert.deepEqual(
        tabbableKeys(),
        ['1'],
        'removing the row that held the tab stop leaves exactly one behind'
      );
    });

    test('a newly added row joins the navigation order', async function (assert) {
      const state = new State(threeItems());

      await render(
        <template>
          <Table
            @columns={{columns}}
            @items={{state.items}}
            @selectionMode="multiple"
          />
        </template>
      );

      state.items = [...state.items, { id: '4', name: 'Ada Lovelace' }];
      await settled();

      await focus(rowFor('3'));
      await triggerKeyEvent(rowFor('3'), 'keydown', 'ArrowDown');
      assert.strictEqual(
        document.activeElement,
        rowFor('4'),
        'ArrowDown reaches the row added after render'
      );

      await triggerKeyEvent(rowFor('4'), 'keydown', 'ArrowDown');
      assert.strictEqual(
        document.activeElement,
        rowFor('1'),
        'and wrapping accounts for it'
      );
    });

    test('reordered rows are navigated in the order they are rendered', async function (assert) {
      const state = new State(threeItems());

      await render(
        <template>
          <Table
            @columns={{columns}}
            @items={{state.items}}
            @selectionMode="multiple"
          />
        </template>
      );

      state.items = [state.items[2]!, state.items[0]!, state.items[1]!];
      await settled();

      assert.deepEqual(rowKeys(), ['3', '1', '2'], 'the rows moved');

      await focus(rowFor('3'));
      await triggerKeyEvent(rowFor('3'), 'keydown', 'ArrowDown');
      assert.strictEqual(
        document.activeElement,
        rowFor('1'),
        'ArrowDown follows document order, not registration order'
      );
    });
  }
);
