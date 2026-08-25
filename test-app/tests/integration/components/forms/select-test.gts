import { module, test } from 'qunit';
import type { Assert } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import {
  click,
  render,
  triggerKeyEvent,
  fillIn,
  settled
} from '@ember/test-helpers';
import { cell } from 'ember-resources';
import { Select } from 'frontile';
import { array, hash } from '@ember/helper';
import { selectOptionByKey } from 'frontile/test-support';

// Simple equality helper
const eq = (a: unknown, b: unknown) => a === b;

module('Integration | Component | Select | @frontile/forms', function (hooks) {
  setupRenderingTest(hooks);

  const getNativeSelect = () => {
    const select = document.querySelector('[data-component="native-select"]');
    if (!select) throw new Error('native-select not found');
    return select;
  };

  const checkSelected = (
    assert: { ok: (val: boolean, mes: string) => void },
    queryString: string,
    shouldBeSelected: boolean
  ): void => {
    const option = getNativeSelect().querySelector(queryString);
    const isSelected = option && (option as HTMLOptionElement).selected;
    const msg = shouldBeSelected
      ? `Expected ${queryString} to be selected`
      : `Expected ${queryString} to not be selected`;
    assert.ok(shouldBeSelected ? !!isSelected : !isSelected, msg);
  };

  const isSelected = (
    assert: { ok: (val: boolean, mes: string) => void },
    queryString: string
  ) => checkSelected(assert, queryString, true);

  const isNotSelected = (
    assert: { ok: (val: boolean, mes: string) => void },
    queryString: string
  ) => checkSelected(assert, queryString, false);

  const assertListboxSelection = (
    assert: Assert,
    key: string,
    expected: boolean,
    message?: string
  ) => {
    assert
      .dom(`[data-component="listbox"] [data-key="${key}"]`)
      .hasAttribute(
        'data-selected',
        String(expected),
        message || `${key} should ${expected ? '' : 'not '}be selected`
      );
  };

  test('it renders static items in NativeSelect and Listbox', async function (assert) {
    const selectedKey = cell<string | null>(null);
    const onSelectionChange = (key: string | null) =>
      (selectedKey.current = key);

    await render(
      <template>
        <Select
          @onSelectionChange={{onSelectionChange}}
          @selectedKey={{selectedKey.current}}
          @disabledKeys={{array "item-3" "item-4"}}
          @allowEmpty={{true}}
          as |l|
        >
          <l.Item @key="item-1">Item 1</l.Item>
          <l.Item @key="item-2">Item 2</l.Item>
          <l.Item @key="item-3">Item 3</l.Item>
          <l.Item @key="item-4">Item 4</l.Item>
          <l.Item @key="item-5">Item 5</l.Item>
        </Select>
      </template>
    );

    assert.dom('[data-component="native-select"]').exists();
    assert.dom('[data-component="native-select"] [data-key="item-1"]').exists();
    assert.dom('[data-component="native-select"] [data-key="item-2"]').exists();
    assert.dom('[data-component="native-select"] [data-key="item-3"]').exists();
    assert.dom('[data-component="native-select"] [data-key="item-4"]').exists();
    assert.dom('[data-component="native-select"] [data-key="item-5"]').exists();

    assert
      .dom('[data-component="native-select"] [data-key="item-3"]')
      .hasAttribute('disabled');
    assert
      .dom('[data-component="native-select"] [data-key="item-4"]')
      .hasAttribute('disabled');

    assert
      .dom('[data-component="native-select"] [data-key="item-1"]')
      .containsText('Item 1');
    assert
      .dom('[data-component="native-select"] [data-key="item-2"]')
      .containsText('Item 2');
    assert
      .dom('[data-component="native-select"] [data-key="item-3"]')
      .containsText('Item 3');
    assert
      .dom('[data-component="native-select"] [data-key="item-4"]')
      .containsText('Item 4');
    assert
      .dom('[data-component="native-select"] [data-key="item-5"]')
      .containsText('Item 5');

    isNotSelected(
      assert,
      '[data-component="native-select"] [data-key="item-2"]'
    );

    await selectOptionByKey('[data-component="native-select"]', 'item-2');

    assert.equal(selectedKey.current, 'item-2');
    isSelected(assert, '[data-key="item-2"]');

    // Check Listbox
    await click('[data-component="select-trigger"]');

    assert.dom('[data-component="listbox"]').exists();
    assert.dom('[data-component="listbox"] [data-key="item-1"]').exists();
    assert.dom('[data-component="listbox"] [data-key="item-2"]').exists();
    assert.dom('[data-component="listbox"] [data-key="item-3"]').exists();
    assert.dom('[data-component="listbox"] [data-key="item-4"]').exists();
    assert.dom('[data-component="listbox"] [data-key="item-5"]').exists();

    assert
      .dom('[data-component="listbox"] [data-key="item-3"]')
      .hasAttribute('aria-disabled', 'true');
    assert
      .dom('[data-component="listbox"] [data-key="item-4"]')
      .hasAttribute('aria-disabled', 'true');

    assert
      .dom('[data-component="listbox"] [data-key="item-1"]')
      .containsText('Item 1');
    assert
      .dom('[data-component="listbox"] [data-key="item-2"]')
      .containsText('Item 2');
    assert
      .dom('[data-component="listbox"] [data-key="item-3"]')
      .containsText('Item 3');
    assert
      .dom('[data-component="listbox"] [data-key="item-4"]')
      .containsText('Item 4');
    assert
      .dom('[data-component="listbox"] [data-key="item-5"]')
      .containsText('Item 5');

    assert
      .dom('[data-component="listbox"] [data-key="item-2"]')
      .hasAttribute('data-selected', 'true');
  });

  test('it render dynamic items without yield of item selectionMode = single / multiple, closes on item click', async function (assert) {
    const selectionMode = cell<'single' | 'multiple'>('single');
    const animals = ['cheetah', 'crocodile', 'elephant'];
    const selectedKey = cell<string | null>(null);
    const selectedKeys = cell<string[]>([]);
    const onSingleSelectionChange = (key: string | null) =>
      (selectedKey.current = key);
    const onMultipleSelectionChange = (keys: string[]) =>
      (selectedKeys.current = keys);

    await render(
      <template>
        {{#if (eq selectionMode.current "single")}}
          <Select
            @allowEmpty={{true}}
            @selectionMode={{selectionMode.current}}
            @items={{animals}}
            @selectedKey={{selectedKey.current}}
            @onSelectionChange={{onSingleSelectionChange}}
          />
        {{else}}
          <Select
            @allowEmpty={{true}}
            @selectionMode={{selectionMode.current}}
            @items={{animals}}
            @selectedKeys={{selectedKeys.current}}
            @onSelectionChange={{onMultipleSelectionChange}}
          />
        {{/if}}
      </template>
    );

    await click('[data-component="select-trigger"]');
    assert.dom('[data-component="listbox"]').exists();

    assert.dom('[data-component="listbox"] [data-key="cheetah"]').exists();
    assert.dom('[data-component="listbox"] [data-key="crocodile"]').exists();
    assert.dom('[data-component="listbox"] [data-key="elephant"]').exists();

    // Selection Mode single
    await click('[data-component="listbox"] [data-key="cheetah"]');
    assert.equal(selectedKey.current, 'cheetah');
    assert.dom('[data-component="listbox"]').doesNotExist('should have closed');

    await click('[data-component="select-trigger"]');
    await click('[data-component="listbox"] [data-key="crocodile"]');
    assert.equal(selectedKey.current, 'crocodile');
    assert.dom('[data-component="listbox"]').doesNotExist('should have closed');

    // Selection Mode multiple
    selectionMode.current = 'multiple';
    selectedKeys.current = [];

    await click('[data-component="select-trigger"]');
    await click('[data-component="listbox"] [data-key="elephant"]');
    assert.dom('[data-component="listbox"]').exists('should not have closed');

    assert.equal(selectedKeys.current.length, 1);
    assert.equal(selectedKeys.current[0], 'elephant');

    await click('[data-component="listbox"] [data-key="crocodile"]');
    assert.equal(selectedKeys.current.length, 2);

    assert.ok(selectedKeys.current.includes('elephant'));
    assert.ok(selectedKeys.current.includes('crocodile'));

    // toggle
    await click('[data-component="listbox"] [data-key="crocodile"]');

    assert.equal(selectedKeys.current.length, 1);
    assert.equal(selectedKeys.current[0], 'elephant');

    await click('[data-component="listbox"] [data-key="elephant"]');

    assert.equal(selectedKeys.current.length, 0);
  });

  test('it render dynamic items yielding of item', async function (assert) {
    const animals = [
      { key: 'cheetah-key', value: 'cheetah-value' },
      { key: 'crocodile-key', value: 'crocodile-value' },
      { key: 'elephant-key', value: 'elephant-value' }
    ];
    const selectedKey = cell<string | null>(null);
    const onSelectionChange = (key: string | null) =>
      (selectedKey.current = key);

    await render(
      <template>
        <Select
          @allowEmpty={{false}}
          @selectionMode="single"
          @items={{animals}}
          @selectedKey={{selectedKey.current}}
          @onSelectionChange={{onSelectionChange}}
        >
          <:item as |o|>
            <o.Item @key={{o.item.key}}>
              {{o.item.value}}
            </o.Item>
          </:item>
        </Select>
      </template>
    );

    assert.dom('[data-component="native-select"]').exists();

    assert.dom('[data-key="cheetah-key"]').exists();
    assert.dom('[data-key="crocodile-key"]').exists();
    assert.dom('[data-key="elephant-key"]').exists();

    assert.dom('[data-key="cheetah-key"]').containsText('cheetah-value');
    assert.dom('[data-key="crocodile-key"]').containsText('crocodile-value');
    assert.dom('[data-key="elephant-key"]').containsText('elephant-value');

    // Check Listbox
    await click('[data-component="select-trigger"]');

    assert.dom('[data-component="listbox"]').exists();
    assert.dom('[data-component="listbox"] [data-key="cheetah-key"]').exists();
    assert
      .dom('[data-component="listbox"] [data-key="crocodile-key"]')
      .exists();
    assert.dom('[data-component="listbox"] [data-key="elephant-key"]').exists();

    assert
      .dom('[data-component="listbox"] [data-key="cheetah-key"]')
      .containsText('cheetah-value');
    assert
      .dom('[data-component="listbox"] [data-key="crocodile-key"]')
      .containsText('crocodile-value');
    assert
      .dom('[data-component="listbox"] [data-key="elephant-key"]')
      .containsText('elephant-value');
  });

  test('keyboard navigation work (roving focus))', async function (assert) {
    const selectedKey = cell<string | null>(null);
    const onSelectionChange = (key: string | null) =>
      (selectedKey.current = key);

    await render(
      <template>
        <Select
          @onSelectionChange={{onSelectionChange}}
          @selectedKey={{selectedKey.current}}
          @disabledKeys={{array "item-3" "item-4"}}
          @allowEmpty={{true}}
          as |l|
        >
          <l.Item @key="item-1">Item 1</l.Item>
          <l.Item @key="item-2">Item 2</l.Item>
          <l.Item @key="item-3">Item 3</l.Item>
          <l.Item @key="item-4">Item 4</l.Item>
          <l.Item @key="item-5">Item 5</l.Item>
        </Select>
      </template>
    );

    // Check Listbox
    await click('[data-component="select-trigger"]');

    assert.dom('[data-component="listbox"]').exists();
    assert.dom('[data-component="listbox"] [data-key="item-1"]').exists();
    assert.dom('[data-component="listbox"] [data-key="item-2"]').exists();
    assert.dom('[data-component="listbox"] [data-key="item-3"]').exists();
    assert.dom('[data-component="listbox"] [data-key="item-4"]').exists();
    assert.dom('[data-component="listbox"] [data-key="item-5"]').exists();

    assert
      .dom('[data-component="listbox"] [data-key="item-1"]')
      .hasAttribute('data-active', 'true');

    await triggerKeyEvent('[data-component="listbox"]', 'keydown', 'ArrowDown');
    assert
      .dom('[data-component="listbox"] [data-key="item-1"]')
      .hasAttribute('data-active', 'false');
    assert
      .dom('[data-component="listbox"] [data-key="item-2"]')
      .hasAttribute('data-active', 'true');

    await triggerKeyEvent('[data-component="listbox"]', 'keydown', 'ArrowUp');
    assert
      .dom('[data-component="listbox"] [data-key="item-1"]')
      .hasAttribute('data-active', 'true');
    assert
      .dom('[data-component="listbox"] [data-key="item-2"]')
      .hasAttribute('data-active', 'false');

    await triggerKeyEvent('[data-component="listbox"]', 'keydown', 'ArrowDown');
    await triggerKeyEvent('[data-component="listbox"]', 'keypress', 'Enter');
    assert.dom('[data-component="listbox"]').doesNotExist();

    assert.equal(selectedKey.current, 'item-2');
  });

  test('it renders disabled select', async function (assert) {
    const animals = ['tiger'];
    await render(
      <template><Select @items={{animals}} @isDisabled={{true}} /></template>
    );
    assert.dom('[data-component="native-select"]').exists();
    assert.dom('[data-component="native-select"]').isDisabled;
    assert.dom('[data-component="select-trigger"]').isDisabled;
  });

  test('it renders select with placeholder', async function (assert) {
    const animals = ['tiger'];
    await render(
      <template>
        <Select
          @items={{animals}}
          @placeholder="Select an animal"
          @isDisabled={{true}}
        />
      </template>
    );
    assert.dom('[data-component="select-trigger"]').hasText('Select an animal');
  });

  test('it renders named blocks startContent and endContent', async function (assert) {
    const classes = { innerContainer: 'input-container' };
    const animals = ['tiger'];
    await render(
      <template>
        <Select
          @items={{animals}}
          @placeholder="Select an animal"
          @classes={{classes}}
        >
          <:startContent>Start</:startContent>
          <:endContent>End</:endContent>
        </Select>
      </template>
    );

    assert.dom('.input-container div:first-child').exists();
    assert.dom('.input-container div:first-child').hasTextContaining('Start');

    assert.dom('.input-container div:last-child').exists();
    assert.dom('.input-container div:last-child').hasTextContaining('End');
  });

  test('it clears selectedKey when isClearable is set and clear button clicked', async function (assert) {
    const selectedKey = cell<string | null>(null);
    const onSelectionChange = (key: string | null) =>
      (selectedKey.current = key);

    await render(
      <template>
        <Select
          @onSelectionChange={{onSelectionChange}}
          @selectedKey={{selectedKey.current}}
          @isClearable={{true}}
          as |l|
        >
          <l.Item @key="item-1">Item 1</l.Item>
          <l.Item @key="item-2">Item 2</l.Item>
          <l.Item @key="item-3">Item 3</l.Item>
        </Select>
      </template>
    );

    await click('[data-component="select-trigger"]');
    await click('[data-component="listbox"] [data-key="item-1"]');
    assert.equal(selectedKey.current, 'item-1');

    await click('[data-test-id="input-clear-button"]');
    assert.equal(selectedKey.current, null);
  });

  test('it filters options when isFilterable is enabled', async function (assert) {
    const items = ['Apple', 'Banana', 'Cherry'];
    const selectedKey = cell<string | null>(null);
    const onSelectionChange = (key: string | null) =>
      (selectedKey.current = key);

    await render(
      <template>
        <Select
          @items={{items}}
          @isFilterable={{true}}
          @selectedKey={{selectedKey.current}}
          @onSelectionChange={{onSelectionChange}}
        />
      </template>
    );

    await click('[data-component="select-trigger"]');
    assert.dom('[data-component="listbox"]').exists();

    await fillIn('[data-test-id="trigger"]', 'App');
    assert.dom('[data-key="Apple"]').exists();
    assert.dom('[data-key="Banana"]').doesNotExist();
    assert.dom('[data-key="Cherry"]').doesNotExist();

    await fillIn('[data-test-id="trigger"]', 'a');
    assert.dom('[data-key="Apple"]').exists();
    assert.dom('[data-key="Banana"]').exists();
    assert.dom('[data-key="Cherry"]').doesNotExist();
  });

  test('it shows empty content when no options match the filter', async function (assert) {
    const items = ['Apple', 'Banana', 'Cherry'];

    const selectedKey = cell<string | null>(null);
    const onSelectionChange = (key: string | null) =>
      (selectedKey.current = key);

    await render(
      <template>
        <Select
          @items={{items}}
          @isFilterable={{true}}
          @selectedKey={{selectedKey.current}}
          @onSelectionChange={{onSelectionChange}}
        />
      </template>
    );

    await click('[data-component="select-trigger"]');
    await fillIn('[data-test-id="trigger"]', 'XYZ');

    assert.dom('[data-test-id="empty-content"]').exists();
    assert.dom('[data-test-id="empty-content"]').hasText('No results found.');

    await render(
      <template>
        <Select
          @items={{items}}
          @isFilterable={{true}}
          @selectedKey={{selectedKey.current}}
          @onSelectionChange={{onSelectionChange}}
        >
          <:emptyContent>No results found from blocks.</:emptyContent>
        </Select>
      </template>
    );

    await click('[data-component="select-trigger"]');
    await fillIn('[data-test-id="trigger"]', 'XYZ');

    assert.dom('[data-test-id="empty-content"]').exists();
    assert
      .dom('[data-test-id="empty-content"]')
      .hasText('No results found from blocks.');
  });

  test('it does not show empty content when hideEmptyContent is true', async function (assert) {
    const items = ['Apple', 'Banana', 'Cherry'];

    await render(
      <template>
        <Select
          @items={{items}}
          @isFilterable={{true}}
          @hideEmptyContent={{true}}
        />
      </template>
    );

    await click('[data-component="select-trigger"]');
    await fillIn('[data-test-id="trigger"]', 'XYZ');

    assert.dom('[data-test-id="empty-content"]').doesNotExist();
  });

  test('it shows loading spinner when isLoading is true', async function (assert) {
    const items = ['Apple', 'Banana'];

    await render(
      <template><Select @items={{items}} @isLoading={{true}} /></template>
    );

    assert.dom('[data-test-id="loading-spinner"]').exists();
  });

  test('it hides loading spinner when isLoading is false', async function (assert) {
    const items = ['Apple', 'Banana'];

    await render(
      <template><Select @items={{items}} @isLoading={{false}} /></template>
    );

    assert.dom('[data-test-id="loading-spinner"]').doesNotExist();
  });

  test('TypeScript discriminated union works correctly for explicit single mode', async function (assert) {
    // Test for issue #387 - TypeScript should properly infer SingleSelectArgs
    // when selectionMode is explicitly set to "single"
    const selectedKey = cell<string | null>(null);
    const onSelectionChange = (key: string | null) => {
      selectedKey.current = key;
    };
    const items = ['item1', 'item2', 'item3'];

    // This should compile without TypeScript errors
    await render(
      <template>
        <Select
          @selectionMode="single"
          @selectedKey={{selectedKey.current}}
          @onSelectionChange={{onSelectionChange}}
          @items={{items}}
        />
      </template>
    );

    assert.dom('[data-component="select-trigger"]').exists();
    assert.dom('[data-component="native-select"]').exists();

    // Test that single selection works as expected
    await click('[data-component="select-trigger"]');
    await click('[data-component="listbox"] [data-key="item2"]');

    assert.equal(selectedKey.current, 'item2');
    assert
      .dom('[data-component="listbox"]')
      .doesNotExist('should close after selection in single mode');
  });

  test('TypeScript discriminated union works correctly for multiple mode', async function (assert) {
    // Test for issue #387 - TypeScript should properly infer MultipleSelectArgs
    // when selectionMode is explicitly set to "multiple"
    const selectedKeys = cell<string[]>([]);
    const onSelectionChange = (keys: string[]) => {
      selectedKeys.current = keys;
    };
    const items = ['item1', 'item2', 'item3'];

    // This should compile without TypeScript errors
    await render(
      <template>
        <Select
          @selectionMode="multiple"
          @selectedKeys={{selectedKeys.current}}
          @onSelectionChange={{onSelectionChange}}
          @items={{items}}
        />
      </template>
    );

    assert.dom('[data-component="select-trigger"]').exists();
    assert.dom('[data-component="native-select"]').exists();

    // Test that multiple selection works as expected
    await click('[data-component="select-trigger"]');
    await click('[data-component="listbox"] [data-key="item1"]');

    assert.equal(selectedKeys.current.length, 1);
    assert.equal(selectedKeys.current[0], 'item1');
    assert
      .dom('[data-component="listbox"]')
      .exists('should remain open after selection in multiple mode');

    await click('[data-component="listbox"] [data-key="item2"]');

    assert.equal(selectedKeys.current.length, 2);
    assert.ok(selectedKeys.current.includes('item1'));
    assert.ok(selectedKeys.current.includes('item2'));
  });

  test('TypeScript discriminated union works correctly for default mode (no selectionMode specified)', async function (assert) {
    // Test for issue #387 - TypeScript should properly infer SingleSelectArgs
    // when selectionMode is omitted (defaults to single)
    const selectedKey = cell<string | null>(null);
    const onSelectionChange = (key: string | null) => {
      selectedKey.current = key;
    };
    const items = ['item1', 'item2', 'item3'];

    // This should compile without TypeScript errors and behave as single mode
    await render(
      <template>
        <Select
          @selectedKey={{selectedKey.current}}
          @onSelectionChange={{onSelectionChange}}
          @items={{items}}
        />
      </template>
    );

    assert.dom('[data-component="select-trigger"]').exists();
    assert.dom('[data-component="native-select"]').exists();

    // Test that single selection works as expected (default behavior)
    await click('[data-component="select-trigger"]');
    await click('[data-component="listbox"] [data-key="item3"]');

    assert.equal(selectedKey.current, 'item3');
    assert
      .dom('[data-component="listbox"]')
      .doesNotExist('should close after selection in default single mode');
  });

  test('selectOptionByKey works correctly when key is already selected', async function (assert) {
    const selectedKey = cell<string | null>(null);
    const onSelectionChange = (key: string | null) => {
      selectedKey.current = key;
    };

    await render(
      <template>
        <Select
          @onSelectionChange={{onSelectionChange}}
          @selectedKey={{selectedKey.current}}
          @allowEmpty={{true}}
          as |l|
        >
          <l.Item @key="item-1">Item 1</l.Item>
          <l.Item @key="item-2">Item 2</l.Item>
          <l.Item @key="item-3">Item 3</l.Item>
        </Select>
      </template>
    );

    // First select an option
    await selectOptionByKey('[data-component="native-select"]', 'item-2');
    assert.equal(selectedKey.current, 'item-2');
    isSelected(assert, '[data-key="item-2"]');

    // Call selectOptionByKey on the already selected option - should not change anything
    await selectOptionByKey('[data-component="native-select"]', 'item-2');

    // Verify the selection remains the same
    assert.equal(selectedKey.current, 'item-2');
    isSelected(assert, '[data-key="item-2"]');

    // Verify other options are still not selected
    isNotSelected(assert, '[data-key="item-1"]');
    isNotSelected(assert, '[data-key="item-3"]');
  });

  test('selectOptionByKey works correctly when key is already selected (by default)', async function (assert) {
    const selectedKey = cell<string | null>(null);
    const onSelectionChange = (key: string | null) => {
      selectedKey.current = key;
    };

    await render(
      <template>
        <Select
          @onSelectionChange={{onSelectionChange}}
          @selectedKey={{selectedKey.current}}
          @allowEmpty={{true}}
          as |l|
        >
          <l.Item @key="item-1">Item 1</l.Item>
        </Select>
      </template>
    );

    // First select an option
    await selectOptionByKey('[data-component="native-select"]', 'item-1');
    assert.equal(selectedKey.current, 'item-1');
    isSelected(assert, '[data-key="item-1"]');

    // Call selectOptionByKey on the already selected option - should not change anything
    await selectOptionByKey('[data-component="native-select"]', 'item-1');

    // Verify the selection remains the same
    assert.equal(selectedKey.current, 'item-1');
    isSelected(assert, '[data-key="item-1"]');
  });

  test('Single mode: external @selectedKey changes update trigger button text', async function (assert) {
    const selectedKey = cell<string | null>(null);
    const onSelectionChange = (key: string | null) => {
      selectedKey.current = key;
    };
    const items = ['Apple', 'Banana', 'Cherry'];

    await render(
      <template>
        <Select
          @items={{items}}
          @selectedKey={{selectedKey.current}}
          @onSelectionChange={{onSelectionChange}}
          @placeholder="Select a fruit"
        />
      </template>
    );

    assert
      .dom('[data-component="select-trigger"]')
      .hasText('Select a fruit', 'trigger should show placeholder initially');

    selectedKey.current = 'Apple';
    await settled();
    assert
      .dom('[data-component="select-trigger"]')
      .hasText('Apple', 'trigger should display Apple');
    isSelected(assert, '[data-key="Apple"]');

    selectedKey.current = 'Banana';
    await settled();
    assert
      .dom('[data-component="select-trigger"]')
      .hasText('Banana', 'trigger should display Banana');
    isSelected(assert, '[data-key="Banana"]');
    isNotSelected(assert, '[data-key="Apple"]');
  });

  test('Single mode: external @selectedKey changes update both native select and listbox', async function (assert) {
    const selectedKey = cell<string | null>('item-1');
    const onSelectionChange = (key: string | null) => {
      selectedKey.current = key;
    };

    await render(
      <template>
        <Select
          @selectedKey={{selectedKey.current}}
          @onSelectionChange={{onSelectionChange}}
          as |l|
        >
          <l.Item @key="item-1">Item 1</l.Item>
          <l.Item @key="item-2">Item 2</l.Item>
          <l.Item @key="item-3">Item 3</l.Item>
        </Select>
      </template>
    );

    isSelected(assert, '[data-key="item-1"]');
    assert.dom('[data-component="select-trigger"]').hasText('Item 1');

    await click('[data-component="select-trigger"]');
    assertListboxSelection(assert, 'item-1', true);
    assertListboxSelection(assert, 'item-2', false);
    await click('[data-component="select-trigger"]');

    selectedKey.current = 'item-2';
    await settled();
    isSelected(assert, '[data-key="item-2"]');
    isNotSelected(assert, '[data-key="item-1"]');
    assert.dom('[data-component="select-trigger"]').hasText('Item 2');

    await click('[data-component="select-trigger"]');
    assertListboxSelection(assert, 'item-2', true);
    assertListboxSelection(assert, 'item-1', false);
    await click('[data-component="select-trigger"]');

    selectedKey.current = 'item-3';
    await settled();
    isSelected(assert, '[data-key="item-3"]');
    assert.dom('[data-component="select-trigger"]').hasText('Item 3');

    await click('[data-component="select-trigger"]');
    assertListboxSelection(assert, 'item-3', true);
  });

  test('Multiple mode: external @selectedKeys changes update trigger display', async function (assert) {
    const selectedKeys = cell<string[]>([]);
    const onSelectionChange = (keys: string[]) => {
      selectedKeys.current = keys;
    };
    const items = ['Apple', 'Banana', 'Cherry', 'Date'];

    await render(
      <template>
        <Select
          @selectionMode="multiple"
          @selectedItemsDisplay="text"
          @items={{items}}
          @selectedKeys={{selectedKeys.current}}
          @onSelectionChange={{onSelectionChange}}
          @placeholder="Select fruits"
        />
      </template>
    );

    const trigger = '[data-component="select-trigger"]';
    assert.dom(trigger).hasText('Select fruits');

    selectedKeys.current = ['Apple'];
    await settled();
    assert.dom(trigger).hasText('Apple');

    selectedKeys.current = ['Apple', 'Banana'];
    await settled();
    assert.dom(trigger).hasText('Apple, Banana');

    selectedKeys.current = ['Cherry', 'Date', 'Apple'];
    await settled();
    assert.dom(trigger).hasText('Apple, Cherry, Date');

    selectedKeys.current = [];
    await settled();
    assert.dom(trigger).hasText('Select fruits');
  });

  test('Multiple mode: external @selectedKeys changes update listbox selections', async function (assert) {
    const selectedKeys = cell<string[]>([]);
    const onSelectionChange = (keys: string[]) => {
      selectedKeys.current = keys;
    };

    await render(
      <template>
        <Select
          @selectionMode="multiple"
          @selectedKeys={{selectedKeys.current}}
          @onSelectionChange={{onSelectionChange}}
          as |l|
        >
          <l.Item @key="item-1">Item 1</l.Item>
          <l.Item @key="item-2">Item 2</l.Item>
          <l.Item @key="item-3">Item 3</l.Item>
          <l.Item @key="item-4">Item 4</l.Item>
        </Select>
      </template>
    );

    await click('[data-component="select-trigger"]');
    assertListboxSelection(assert, 'item-1', false);
    assertListboxSelection(assert, 'item-2', false);
    await click('[data-component="select-trigger"]');

    selectedKeys.current = ['item-1', 'item-3'];
    await settled();
    await click('[data-component="select-trigger"]');
    assertListboxSelection(assert, 'item-1', true);
    assertListboxSelection(assert, 'item-2', false);
    assertListboxSelection(assert, 'item-3', true);
    assertListboxSelection(assert, 'item-4', false);
    await click('[data-component="select-trigger"]');

    selectedKeys.current = ['item-2', 'item-3'];
    await settled();
    await click('[data-component="select-trigger"]');
    assertListboxSelection(assert, 'item-1', false);
    assertListboxSelection(assert, 'item-2', true);
    assertListboxSelection(assert, 'item-3', true);
    await click('[data-component="select-trigger"]');

    selectedKeys.current = [];
    await settled();
    await click('[data-component="select-trigger"]');
    assertListboxSelection(assert, 'item-1', false);
    assertListboxSelection(assert, 'item-2', false);
    assertListboxSelection(assert, 'item-3', false);
  });

  test('Single mode: initializes correctly with pre-set @selectedKey', async function (assert) {
    const selectedKey = cell<string | null>('item-2');
    let callCount = 0;

    const onSelectionChange = (key: string | null) => {
      callCount++;
      selectedKey.current = key;
    };

    await render(
      <template>
        <Select
          @selectedKey={{selectedKey.current}}
          @onSelectionChange={{onSelectionChange}}
          as |l|
        >
          <l.Item @key="item-1">Item 1</l.Item>
          <l.Item @key="item-2">Item 2</l.Item>
          <l.Item @key="item-3">Item 3</l.Item>
        </Select>
      </template>
    );

    assert.equal(callCount, 0, 'callback should not be called during init');
    assert.dom('[data-component="select-trigger"]').hasText('Item 2');
    isSelected(assert, '[data-key="item-2"]');
    isNotSelected(assert, '[data-key="item-1"]');
    isNotSelected(assert, '[data-key="item-3"]');

    await click('[data-component="select-trigger"]');
    assertListboxSelection(assert, 'item-2', true);
    assertListboxSelection(assert, 'item-1', false);
    assertListboxSelection(assert, 'item-3', false);
    assert.equal(callCount, 0, 'callback should not be called after opening');

    await click('[data-component="listbox"] [data-key="item-3"]');
    assert.equal(callCount, 1, 'callback should be called after user click');
    assert.equal(selectedKey.current, 'item-3');
  });

  test('Multiple mode: initializes correctly with pre-set @selectedKeys', async function (assert) {
    const selectedKeys = cell<string[]>(['Apple', 'Cherry']);
    let callCount = 0;

    const onSelectionChange = (keys: string[]) => {
      callCount++;
      selectedKeys.current = keys;
    };

    const items = ['Apple', 'Banana', 'Cherry', 'Date'];

    await render(
      <template>
        <Select
          @selectionMode="multiple"
          @selectedItemsDisplay="text"
          @items={{items}}
          @selectedKeys={{selectedKeys.current}}
          @onSelectionChange={{onSelectionChange}}
        />
      </template>
    );

    assert.equal(callCount, 0, 'callback should not be called during init');
    assert.dom('[data-component="select-trigger"]').hasText('Apple, Cherry');

    await click('[data-component="select-trigger"]');
    assertListboxSelection(assert, 'Apple', true);
    assertListboxSelection(assert, 'Banana', false);
    assertListboxSelection(assert, 'Cherry', true);
    assertListboxSelection(assert, 'Date', false);
    assert.equal(callCount, 0, 'callback should not be called after opening');

    await click('[data-component="listbox"] [data-key="Banana"]');
    assert.equal(callCount, 1, 'callback should be called after user click');
    assert.deepEqual(selectedKeys.current, ['Apple', 'Cherry', 'Banana']);
  });

  test('Single mode: initializes with null (no selection)', async function (assert) {
    const selectedKey = cell<string | null>(null);
    let callCount = 0;

    const onSelectionChange = (key: string | null) => {
      callCount++;
      selectedKey.current = key;
    };

    await render(
      <template>
        <Select
          @selectedKey={{selectedKey.current}}
          @onSelectionChange={{onSelectionChange}}
          @placeholder="Select an item"
          @allowEmpty={{true}}
          as |l|
        >
          <l.Item @key="item-1">Item 1</l.Item>
          <l.Item @key="item-2">Item 2</l.Item>
          <l.Item @key="item-3">Item 3</l.Item>
        </Select>
      </template>
    );

    assert.equal(callCount, 0, 'callback should not be called during init');
    assert.dom('[data-component="select-trigger"]').hasText('Select an item');
    isNotSelected(assert, '[data-key="item-1"]');
    isNotSelected(assert, '[data-key="item-2"]');
    isNotSelected(assert, '[data-key="item-3"]');

    await click('[data-component="select-trigger"]');
    assertListboxSelection(assert, 'item-1', false);
    assertListboxSelection(assert, 'item-2', false);
    assertListboxSelection(assert, 'item-3', false);
    assert.equal(callCount, 0, 'callback should not be called after opening');
  });

  test('Multiple mode: initializes with empty array (no selections)', async function (assert) {
    const selectedKeys = cell<string[]>([]);
    let callCount = 0;

    const onSelectionChange = (keys: string[]) => {
      callCount++;
      selectedKeys.current = keys;
    };

    const items = ['Apple', 'Banana', 'Cherry'];

    await render(
      <template>
        <Select
          @selectionMode="multiple"
          @selectedItemsDisplay="text"
          @items={{items}}
          @selectedKeys={{selectedKeys.current}}
          @onSelectionChange={{onSelectionChange}}
          @placeholder="Select fruits"
        />
      </template>
    );

    assert.equal(callCount, 0, 'callback should not be called during init');
    assert.dom('[data-component="select-trigger"]').hasText('Select fruits');

    await click('[data-component="select-trigger"]');
    assertListboxSelection(assert, 'Apple', false);
    assertListboxSelection(assert, 'Banana', false);
    assertListboxSelection(assert, 'Cherry', false);
    assert.equal(callCount, 0, 'callback should not be called after opening');
  });

  test('Edge case: initializes with undefined @selectedKey (not passed)', async function (assert) {
    let callCount = 0;
    let lastSelectedKey: string | null = null;

    const onSelectionChange = (key: string | null) => {
      callCount++;
      lastSelectedKey = key;
    };

    await render(
      <template>
        <Select
          @onSelectionChange={{onSelectionChange}}
          @placeholder="Select an item"
          @allowEmpty={{true}}
          as |l|
        >
          <l.Item @key="item-1">Item 1</l.Item>
          <l.Item @key="item-2">Item 2</l.Item>
          <l.Item @key="item-3">Item 3</l.Item>
        </Select>
      </template>
    );

    assert.dom('[data-component="select-trigger"]').exists();
    assert.equal(callCount, 0, 'callback should not be called during init');
    assert.dom('[data-component="select-trigger"]').hasText('Select an item');
    isNotSelected(assert, '[data-key="item-1"]');
    isNotSelected(assert, '[data-key="item-2"]');
    isNotSelected(assert, '[data-key="item-3"]');

    await click('[data-component="select-trigger"]');
    assertListboxSelection(assert, 'item-1', false);
    assertListboxSelection(assert, 'item-2', false);
    assertListboxSelection(assert, 'item-3', false);

    await click('[data-component="listbox"] [data-key="item-2"]');
    assert.equal(callCount, 1, 'callback should be called after user click');
    assert.equal(lastSelectedKey, 'item-2');
    assert.dom('[data-component="select-trigger"]').hasText('Item 2');
  });

  test('Multiple mode: external state + user interactions work together via onSelectionChange', async function (assert) {
    const selectedKeys = cell<string[]>([]);
    let callCount = 0;
    let lastCallbackValue: string[] | null = null;

    const onSelectionChange = (keys: string[]) => {
      callCount++;
      lastCallbackValue = keys;
      selectedKeys.current = keys;
    };

    const items = ['Apple', 'Banana', 'Cherry', 'Date'];
    const trigger = '[data-component="select-trigger"]';

    await render(
      <template>
        <Select
          @selectionMode="multiple"
          @selectedItemsDisplay="text"
          @items={{items}}
          @selectedKeys={{selectedKeys.current}}
          @onSelectionChange={{onSelectionChange}}
          @placeholder="Select fruits"
        />
      </template>
    );

    assert.equal(callCount, 0, 'callback should not be called initially');
    assert.equal(selectedKeys.current.length, 0);
    assert.dom(trigger).hasText('Select fruits');

    selectedKeys.current = ['Apple', 'Cherry'];
    await settled();
    assert.equal(
      callCount,
      0,
      'callback should not be called on external change'
    );
    assert.dom(trigger).hasText('Apple, Cherry');

    await click(trigger);
    assertListboxSelection(assert, 'Apple', true);
    assertListboxSelection(assert, 'Banana', false);
    assertListboxSelection(assert, 'Cherry', true);
    assertListboxSelection(assert, 'Date', false);

    await click('[data-component="listbox"] [data-key="Banana"]');
    assert.equal(callCount, 1);
    assert.deepEqual(lastCallbackValue, ['Apple', 'Cherry', 'Banana']);
    assert.deepEqual(selectedKeys.current, ['Apple', 'Cherry', 'Banana']);
    assertListboxSelection(assert, 'Banana', true);
    assert.dom(trigger).hasText('Apple, Banana, Cherry');

    await click('[data-component="listbox"] [data-key="Cherry"]');
    assert.equal(callCount, 2);
    assert.deepEqual(lastCallbackValue, ['Apple', 'Banana']);
    assert.deepEqual(selectedKeys.current, ['Apple', 'Banana']);
    assertListboxSelection(assert, 'Cherry', false);
    assert.dom(trigger).hasText('Apple, Banana');

    await click('[data-component="listbox"] [data-key="Date"]');
    assert.equal(callCount, 3);
    assert.deepEqual(lastCallbackValue, ['Apple', 'Banana', 'Date']);
    assert.dom(trigger).hasText('Apple, Banana, Date');

    await click(trigger);
    assert.dom('[data-component="listbox"]').doesNotExist();

    await click(trigger);
    assertListboxSelection(assert, 'Apple', true);
    assertListboxSelection(assert, 'Banana', true);
    assertListboxSelection(assert, 'Cherry', false);
    assertListboxSelection(assert, 'Date', true);

    assert.equal(
      callCount,
      3,
      'callback should only be called for user clicks'
    );
  });
  test('Multiple mode: renders a chip per selected option by default', async function (assert) {
    const selectedKeys = cell<string[]>(['apple', 'cherry']);
    const onChange = (keys: string[]) => (selectedKeys.current = keys);

    await render(
      <template>
        <Select
          @items={{array "apple" "banana" "cherry"}}
          @selectionMode="multiple"
          @selectedKeys={{selectedKeys.current}}
          @onSelectionChange={{onChange}}
          @placeholder="Select fruits"
        />
      </template>
    );

    assert.dom('[data-test-id="chips-field"]').exists('chips wrapper renders');
    assert.dom('[data-test-id="selected-chip"]').exists({ count: 2 });
    assert
      .dom('[data-test-id="selected-chip"][data-key="apple"]')
      .hasTextContaining('apple');
    assert
      .dom('[data-test-id="selected-chip"][data-key="cherry"]')
      .hasTextContaining('cherry');
    assert
      .dom('[data-component="select-trigger"]')
      .doesNotIncludeText('apple, cherry', 'joined text is not rendered');
    assert
      .dom('[data-component="select-trigger"] [data-test-id="selected-chip"]')
      .doesNotExist('chips must not be nested inside the trigger');
    assert
      .dom('[data-component="select-trigger"]')
      .hasAttribute('data-component', 'select-trigger');
  });

  test('Multiple mode: the chips-mode trigger keeps a hittable box beside the chips', async function (assert) {
    const selectedKeys = cell<string[]>(['apple', 'cherry']);
    const onChange = (keys: string[]) => (selectedKeys.current = keys);

    await render(
      <template>
        <Select
          @items={{array "apple" "banana" "cherry"}}
          @selectionMode="multiple"
          @selectedKeys={{selectedKeys.current}}
          @onSelectionChange={{onChange}}
          @placeholder="Select fruits"
        />
      </template>
    );

    const trigger = document.querySelector(
      '[data-component="select-trigger"]'
    ) as HTMLElement;
    const chip = document.querySelector(
      '[data-test-id="selected-chip"]'
    ) as HTMLElement;

    const triggerRect = trigger.getBoundingClientRect();
    const chipRect = chip.getBoundingClientRect();

    assert.ok(
      triggerRect.height > 0,
      `the trigger must have a box to click, height was ${triggerRect.height}`
    );
    assert.ok(
      triggerRect.width > 0,
      `the trigger must have a box to click, width was ${triggerRect.width}`
    );
    assert.ok(
      triggerRect.height >= chipRect.height,
      `trigger height (${triggerRect.height}) should be at least the chip height (${chipRect.height})`
    );

    // Hit test rather than `click(trigger)`: `@ember/test-helpers` dispatches at
    // the element whether or not it occupies any space, which is exactly how a
    // zero-height trigger passed the suite while being unusable in a browser.
    const x = triggerRect.left + triggerRect.width / 2;
    const y = triggerRect.top + triggerRect.height / 2;
    const hit = document.elementFromPoint(x, y);

    assert.ok(
      !!hit && (hit === trigger || trigger.contains(hit)),
      `the empty area of the field must hit the trigger, got ${
        hit
          ? (hit as HTMLElement).tagName + '.' + (hit as HTMLElement).className
          : 'null'
      }`
    );

    hit?.dispatchEvent(
      new MouseEvent('click', {
        bubbles: true,
        cancelable: true,
        clientX: x,
        clientY: y
      })
    );
    await settled();

    assert
      .dom('[data-component="listbox"]')
      .exists('clicking the empty area of the field opens the listbox');
    assert.dom(trigger).hasAttribute('aria-expanded', 'true');
  });

  test('Multiple mode: chips replace the placeholder only once something is selected', async function (assert) {
    const selectedKeys = cell<string[]>([]);
    const onChange = (keys: string[]) => (selectedKeys.current = keys);

    await render(
      <template>
        <Select
          @items={{array "apple" "banana"}}
          @selectionMode="multiple"
          @selectedKeys={{selectedKeys.current}}
          @onSelectionChange={{onChange}}
          @placeholder="Select fruits"
        />
      </template>
    );

    assert.dom('[data-component="select-trigger"]').hasText('Select fruits');
    assert.dom('[data-test-id="selected-chip"]').doesNotExist();

    await click('[data-component="select-trigger"]');
    await click('[data-component="listbox"] [data-key="apple"]');

    assert.dom('[data-test-id="selected-chip"]').exists({ count: 1 });
    assert
      .dom('[data-component="select-trigger"]')
      .doesNotIncludeText('Select fruits', 'placeholder hides once chips show');
  });

  test('Multiple mode: @selectedItemsDisplay="text" keeps the joined text', async function (assert) {
    const selectedKeys = cell<string[]>(['apple', 'cherry']);
    const onChange = (keys: string[]) => (selectedKeys.current = keys);

    await render(
      <template>
        <Select
          @items={{array "apple" "banana" "cherry"}}
          @selectionMode="multiple"
          @selectedItemsDisplay="text"
          @selectedKeys={{selectedKeys.current}}
          @onSelectionChange={{onChange}}
          @placeholder="Select fruits"
        />
      </template>
    );

    assert.dom('[data-test-id="selected-chip"]').doesNotExist();
    assert.dom('[data-test-id="chips-field"]').doesNotExist();
    assert.dom('[data-component="select-trigger"]').hasText('apple, cherry');
  });

  test('Single mode: is unaffected and renders no chips', async function (assert) {
    const selectedKey = cell<string | null>('apple');
    const onChange = (key: string | null) => (selectedKey.current = key);

    await render(
      <template>
        <Select
          @items={{array "apple" "banana"}}
          @selectedKey={{selectedKey.current}}
          @onSelectionChange={{onChange}}
        />
      </template>
    );

    assert.dom('[data-test-id="selected-chip"]').doesNotExist();
    assert.dom('[data-test-id="chips-field"]').doesNotExist();
    assert.dom('[data-component="select-trigger"]').hasText('apple');
  });
  test('Multiple mode: a selected chip survives a filter that excludes its item', async function (assert) {
    const selectedKeys = cell<string[]>(['apple']);
    const onChange = (keys: string[]) => (selectedKeys.current = keys);

    await render(
      <template>
        <Select
          @items={{array "apple" "banana" "cherry"}}
          @selectionMode="multiple"
          @isFilterable={{true}}
          @selectedKeys={{selectedKeys.current}}
          @onSelectionChange={{onChange}}
          @placeholder="Select fruits"
        />
      </template>
    );

    assert
      .dom('[data-test-id="selected-chip"][data-key="apple"]')
      .exists('the chip renders before filtering');

    await fillIn('[data-component="select-trigger"]', 'ban');

    assert
      .dom('[data-component="listbox"] [data-key="apple"]')
      .doesNotExist('apple is filtered out of the listbox');
    assert
      .dom('[data-test-id="selected-chip"][data-key="apple"]')
      .exists('the chip for the filtered-out selection is still rendered');
    assert
      .dom('[data-test-id="selected-chip"][data-key="apple"]')
      .hasTextContaining('apple', 'and it keeps its label');
  });

  test('Multiple mode: the trigger has an accessible name while chips are shown', async function (assert) {
    const selectedKeys = cell<string[]>(['apple']);
    const onChange = (keys: string[]) => (selectedKeys.current = keys);

    await render(
      <template>
        <Select
          @items={{array "apple" "banana"}}
          @selectionMode="multiple"
          @label="Fruits"
          @selectedKeys={{selectedKeys.current}}
          @onSelectionChange={{onChange}}
        />
      </template>
    );

    assert.dom('[data-component="select-trigger"]').hasText('');
    assert
      .dom('[data-component="select-trigger"]')
      .hasAttribute('aria-label', 'Fruits');
  });

  test('Single mode: the trigger is named by its own text, not an aria-label', async function (assert) {
    const selectedKey = cell<string | null>('apple');
    const onChange = (key: string | null) => (selectedKey.current = key);

    await render(
      <template>
        <Select
          @items={{array "apple" "banana"}}
          @label="Fruit"
          @selectedKey={{selectedKey.current}}
          @onSelectionChange={{onChange}}
        />
      </template>
    );

    assert.dom('[data-component="select-trigger"]').hasText('apple');
    assert
      .dom('[data-component="select-trigger"]')
      .doesNotHaveAttribute('aria-label');
  });

  test('Multiple mode: a chip close button removes just that selection', async function (assert) {
    const selectedKeys = cell<string[]>(['apple', 'banana', 'cherry']);
    const onSelectionChange = (keys: string[]) => (selectedKeys.current = keys);

    await render(
      <template>
        <Select
          @items={{array "apple" "banana" "cherry"}}
          @selectionMode="multiple"
          @selectedKeys={{selectedKeys.current}}
          @onSelectionChange={{onSelectionChange}}
        />
      </template>
    );

    assert.dom('[data-test-id="selected-chip"]').exists({ count: 3 });

    await click('[data-test-id="selected-chip"][data-key="banana"] button');

    assert.deepEqual(selectedKeys.current, ['apple', 'cherry']);
    assert.dom('[data-test-id="selected-chip"]').exists({ count: 2 });
    assert
      .dom('[data-test-id="selected-chip"][data-key="banana"]')
      .doesNotExist();
    isNotSelected(assert, '[value="banana"]');
    isSelected(assert, '[value="apple"]');
  });

  test('Multiple mode: chip close buttons are individually labelled', async function (assert) {
    const selectedKeys = cell<string[]>(['apple', 'banana']);
    const onSelectionChange = (keys: string[]) => (selectedKeys.current = keys);

    await render(
      <template>
        <Select
          @items={{array "apple" "banana"}}
          @selectionMode="multiple"
          @selectedKeys={{selectedKeys.current}}
          @onSelectionChange={{onSelectionChange}}
        />
      </template>
    );

    // @closeButtonTitle feeds CloseButton's visually-hidden text, which is
    // the button's accessible name — not a `title` attribute (CloseButton
    // deliberately has none, to avoid a duplicate accessible description
    // and an unwanted native tooltip).
    assert
      .dom('[data-test-id="selected-chip"][data-key="apple"] button')
      .hasText('Remove apple');
    assert
      .dom('[data-test-id="selected-chip"][data-key="banana"] button')
      .hasText('Remove banana');
  });

  test('Multiple mode: the last chip has no close button unless @allowEmpty', async function (assert) {
    const selectedKeys = cell<string[]>(['apple']);
    const onSelectionChange = (keys: string[]) => (selectedKeys.current = keys);

    await render(
      <template>
        <Select
          @items={{array "apple" "banana"}}
          @selectionMode="multiple"
          @selectedKeys={{selectedKeys.current}}
          @onSelectionChange={{onSelectionChange}}
        />
      </template>
    );

    assert
      .dom('[data-test-id="selected-chip"][data-key="apple"] button')
      .doesNotExist('no dead close button on the last required selection');
  });

  test('Multiple mode: @allowEmpty lets the last chip be removed', async function (assert) {
    const selectedKeys = cell<string[]>(['apple']);
    const onSelectionChange = (keys: string[]) => (selectedKeys.current = keys);

    await render(
      <template>
        <Select
          @items={{array "apple" "banana"}}
          @selectionMode="multiple"
          @allowEmpty={{true}}
          @selectedKeys={{selectedKeys.current}}
          @onSelectionChange={{onSelectionChange}}
        />
      </template>
    );

    await click('[data-test-id="selected-chip"][data-key="apple"] button');

    assert.deepEqual(selectedKeys.current, []);
    assert.dom('[data-test-id="selected-chip"]').doesNotExist();
  });

  test('Multiple mode: chips are disabled when the select is disabled', async function (assert) {
    const selectedKeys = cell<string[]>(['apple', 'banana']);
    const onSelectionChange = (keys: string[]) => (selectedKeys.current = keys);

    await render(
      <template>
        <Select
          @items={{array "apple" "banana"}}
          @selectionMode="multiple"
          @isDisabled={{true}}
          @selectedKeys={{selectedKeys.current}}
          @onSelectionChange={{onSelectionChange}}
        />
      </template>
    );

    // A chip's close button carries a real `disabled` attribute when the
    // select is disabled, so a user has no way to activate it — browsers
    // do not deliver pointer/keyboard events to a natively disabled
    // button, and `@ember/test-helpers`' `click()` itself refuses to
    // simulate a click on one. That native semantics is the actual
    // guarantee here, so it is what this test asserts.
    //
    // `removeSelectedKey`'s own `@isDisabled` check is defense-in-depth
    // with no reachable UI path to exercise it from a test — there is no
    // way to fire a "real" click on a disabled button, so that branch is
    // intentionally left uncovered rather than faked with a synthetic
    // event dispatch that would never occur from user interaction.
    assert
      .dom('[data-test-id="selected-chip"][data-key="apple"] button')
      .isDisabled();
    assert
      .dom('[data-test-id="chips-field"]')
      .hasAttribute('data-disabled', 'true');
  });

  test('Filterable multiple mode: the filter input stays empty so it can be typed in', async function (assert) {
    const selectedKeys = cell<string[]>(['apple', 'cherry']);
    const onSelectionChange = (keys: string[]) => (selectedKeys.current = keys);

    await render(
      <template>
        <Select
          @items={{array "apple" "banana" "cherry"}}
          @selectionMode="multiple"
          @isFilterable={{true}}
          @selectedKeys={{selectedKeys.current}}
          @onSelectionChange={{onSelectionChange}}
        />
      </template>
    );

    assert.dom('[data-test-id="selected-chip"]').exists({ count: 2 });
    assert
      .dom('[data-component="select-trigger"]')
      .hasValue('', 'the joined selection does not fill the filter input');

    await click('[data-component="select-trigger"]');
    await fillIn('[data-component="select-trigger"]', 'ban');
    assert.dom('[data-component="listbox"] [data-key="banana"]').exists();
    assert
      .dom('[data-component="listbox"] [data-key="apple"]')
      .doesNotExist('filtering still works with chips present');
  });

  test('Filterable multiple mode: Backspace on an empty filter removes the last chip', async function (assert) {
    const selectedKeys = cell<string[]>(['apple', 'banana', 'cherry']);
    const onSelectionChange = (keys: string[]) => (selectedKeys.current = keys);

    await render(
      <template>
        <Select
          @items={{array "apple" "banana" "cherry"}}
          @selectionMode="multiple"
          @isFilterable={{true}}
          @selectedKeys={{selectedKeys.current}}
          @onSelectionChange={{onSelectionChange}}
        />
      </template>
    );

    await triggerKeyEvent(
      '[data-component="select-trigger"]',
      'keydown',
      'Backspace'
    );

    assert.deepEqual(selectedKeys.current, ['apple', 'banana']);

    // Backspace with text in the filter edits the text, it does not remove a chip
    await fillIn('[data-component="select-trigger"]', 'ap');
    await triggerKeyEvent(
      '[data-component="select-trigger"]',
      'keydown',
      'Backspace'
    );

    assert.deepEqual(
      selectedKeys.current,
      ['apple', 'banana'],
      'Backspace while filtering leaves the selection alone'
    );
  });

  test('Filterable multiple mode: Backspace does not remove the final chip unless @allowEmpty', async function (assert) {
    const selectedKeys = cell<string[]>(['apple']);
    const onSelectionChange = (keys: string[]) => (selectedKeys.current = keys);

    await render(
      <template>
        <Select
          @items={{array "apple" "banana"}}
          @selectionMode="multiple"
          @isFilterable={{true}}
          @selectedKeys={{selectedKeys.current}}
          @onSelectionChange={{onSelectionChange}}
        />
      </template>
    );

    await triggerKeyEvent(
      '[data-component="select-trigger"]',
      'keydown',
      'Backspace'
    );

    assert.deepEqual(
      selectedKeys.current,
      ['apple'],
      'the last required selection is not removed by Backspace, matching the chip close-button rule'
    );
    assert.dom('[data-test-id="selected-chip"]').exists({ count: 1 });
  });

  test('Multiple mode: chips default to the faded appearance and inherit @intent', async function (assert) {
    const selectedKeys = cell<string[]>(['apple', 'banana']);
    const onSelectionChange = (keys: string[]) => (selectedKeys.current = keys);

    await render(
      <template>
        <Select
          @items={{array "apple" "banana"}}
          @selectionMode="multiple"
          @intent="primary"
          @selectedKeys={{selectedKeys.current}}
          @onSelectionChange={{onSelectionChange}}
        />
      </template>
    );

    // The chip theme's real 'faded' + 'primary' compound variant resolves to
    // `bg-primary-subtle` (see packages/theme/src/components/chip.ts), but the
    // test suite globally overrides the `chip` theme via `registerCustomStyles`
    // in chip-test.gts with stub classnames per variant (no compound
    // resolution), so `hasClass('bg-primary-subtle')` can never pass here.
    // Assert against the variant stubs instead, matching the convention used
    // by chip-test.gts / buttons-test.gts elsewhere in this suite.
    const chip = '[data-test-id="selected-chip"][data-key="apple"]';
    assert.dom(chip).hasClass('chip-faded', 'defaults to appearance faded');
    assert.dom(chip).hasClass('intent-primary', 'inherits @intent="primary"');
  });

  test('Multiple mode: @chip overrides appearance, intent, size and dot', async function (assert) {
    const selectedKeys = cell<string[]>(['apple']);
    const onSelectionChange = (keys: string[]) => (selectedKeys.current = keys);

    await render(
      <template>
        <Select
          @items={{array "apple" "banana"}}
          @selectionMode="multiple"
          @allowEmpty={{true}}
          @intent="primary"
          @chip={{hash
            appearance="outlined"
            intent="danger"
            size="lg"
            radius="full"
            withDot=true
          }}
          @selectedKeys={{selectedKeys.current}}
          @onSelectionChange={{onSelectionChange}}
        />
      </template>
    );

    const chip = '[data-test-id="selected-chip"][data-key="apple"]';
    assert.dom(chip).hasClass('radius-full', '@chip.radius applies');
    assert
      .dom(chip)
      .doesNotHaveClass(
        'intent-primary',
        '@chip.intent overrides the inherited @intent'
      );
    assert.dom(chip).hasClass('intent-danger', '@chip.intent applies');
    assert.dom(chip).hasClass('chip-outlined', '@chip.appearance applies');
    assert
      .dom(chip)
      .doesNotHaveClass(
        'chip-faded',
        '@chip.appearance overrides the faded default'
      );
    assert.dom(chip).hasClass('chip-lg', '@chip.size applies');
    assert
      .dom(chip)
      .doesNotHaveClass('chip-sm', '@chip.size overrides the sm default');
    // `span:first-child` would pass regardless of @withDot, because
    // chip.gts renders the content span as the first child when there is no
    // dot. Target the dot's own stub class instead (chip-test.gts registers
    // `dot: ['chip-dot']` on the mocked chip theme).
    assert.dom(`${chip} .chip-dot`).exists('@chip.withDot renders the dot');
  });

  test('Multiple mode: @classes.chip is merged onto every chip', async function (assert) {
    const selectedKeys = cell<string[]>(['apple', 'banana']);
    const onSelectionChange = (keys: string[]) => (selectedKeys.current = keys);

    await render(
      <template>
        <Select
          @items={{array "apple" "banana"}}
          @selectionMode="multiple"
          @classes={{hash chip="test-chip-class" chipsField="test-field-class"}}
          @selectedKeys={{selectedKeys.current}}
          @onSelectionChange={{onSelectionChange}}
        />
      </template>
    );

    assert.dom('[data-test-id="selected-chip"]').exists({ count: 2 });
    assert
      .dom('[data-test-id="selected-chip"][data-key="apple"]')
      .hasClass('test-chip-class');
    assert.dom('[data-test-id="chips-field"]').hasClass('test-field-class');
  });
});
