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
    assert.dom('[data-component="native-select"]').isDisabled();
    assert.dom('[data-component="select-trigger"]').isDisabled();
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
    // Scoped to the listbox: the hidden native <select> deliberately keeps
    // every option so the submitted value is never truncated by the filter.
    assert.dom('[data-component="listbox"] [data-key="Apple"]').exists();
    assert.dom('[data-component="listbox"] [data-key="Banana"]').doesNotExist();
    assert.dom('[data-component="listbox"] [data-key="Cherry"]').doesNotExist();

    await fillIn('[data-test-id="trigger"]', 'a');
    assert.dom('[data-component="listbox"] [data-key="Apple"]').exists();
    assert.dom('[data-component="listbox"] [data-key="Banana"]').exists();
    assert.dom('[data-component="listbox"] [data-key="Cherry"]').doesNotExist();
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
      .dom('[data-test-id="chips-field"] [data-component="select-trigger"]')
      .exists('the trigger is a sibling of the chips inside the chips field');
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

  test('Multiple mode: the hidden native select keeps the whole selection while a filter is active', async function (assert) {
    const selectedKeys = cell<string[]>(['apple', 'cherry']);
    const onChange = (keys: string[]) => (selectedKeys.current = keys);

    await render(
      <template>
        <Select
          @items={{array "apple" "banana" "cherry"}}
          @selectionMode="multiple"
          @isFilterable={{true}}
          @name="fruits"
          @selectedKeys={{selectedKeys.current}}
          @onSelectionChange={{onChange}}
          @placeholder="Select fruits"
        />
      </template>
    );

    // The hidden native <select> is what a form submit reads, so its
    // selectedOptions are the submitted value.
    const submittedValues = () =>
      Array.from((getNativeSelect() as HTMLSelectElement).selectedOptions).map(
        (option) => option.value
      );

    assert.deepEqual(
      submittedValues(),
      ['apple', 'cherry'],
      'both selections submit before filtering'
    );

    await fillIn('[data-component="select-trigger"]', 'ban');

    assert
      .dom('[data-component="listbox"] [data-key="apple"]')
      .doesNotExist('the filter really is narrowing the listbox');
    assert.deepEqual(
      submittedValues(),
      ['apple', 'cherry'],
      'an active filter must not truncate the submitted value'
    );
  });

  test('Single mode: the filterable trigger keeps its placeholder once the filter is cleared', async function (assert) {
    const selectedKey = cell<string | null>('apple');
    const onChange = (key: string | null) => (selectedKey.current = key);

    await render(
      <template>
        <Select
          @items={{array "apple" "banana"}}
          @isFilterable={{true}}
          @selectedKey={{selectedKey.current}}
          @onSelectionChange={{onChange}}
          @placeholder="Search fruits"
        />
      </template>
    );

    assert
      .dom('[data-component="select-trigger"]')
      .hasAttribute(
        'placeholder',
        'Search fruits',
        'single mode keeps its placeholder with a selection'
      );

    await fillIn('[data-component="select-trigger"]', '');

    assert
      .dom('[data-component="select-trigger"]')
      .hasValue('', 'the filter box is empty');
    assert
      .dom('[data-component="select-trigger"]')
      .hasAttribute(
        'placeholder',
        'Search fruits',
        'so the placeholder is what the user sees'
      );
  });

  test('Multiple mode: @selectedItemsDisplay="text" keeps the filterable placeholder', async function (assert) {
    const selectedKeys = cell<string[]>(['apple']);
    const onChange = (keys: string[]) => (selectedKeys.current = keys);

    await render(
      <template>
        <Select
          @items={{array "apple" "banana"}}
          @selectionMode="multiple"
          @selectedItemsDisplay="text"
          @isFilterable={{true}}
          @selectedKeys={{selectedKeys.current}}
          @onSelectionChange={{onChange}}
          @placeholder="Search fruits"
        />
      </template>
    );

    await fillIn('[data-component="select-trigger"]', '');

    assert
      .dom('[data-component="select-trigger"]')
      .hasAttribute(
        'placeholder',
        'Search fruits',
        'text mode is not chips mode, so the placeholder stays'
      );
  });

  test('Multiple mode: chips mode drops the filterable placeholder once something is selected', async function (assert) {
    const selectedKeys = cell<string[]>([]);
    const onChange = (keys: string[]) => (selectedKeys.current = keys);

    await render(
      <template>
        <Select
          @items={{array "apple" "banana"}}
          @selectionMode="multiple"
          @isFilterable={{true}}
          @selectedKeys={{selectedKeys.current}}
          @onSelectionChange={{onChange}}
          @placeholder="Search fruits"
        />
      </template>
    );

    assert
      .dom('[data-component="select-trigger"]')
      .hasAttribute(
        'placeholder',
        'Search fruits',
        'with nothing selected the placeholder is the only prompt'
      );

    await click('[data-component="select-trigger"]');
    await click('[data-component="listbox"] [data-key="apple"]');

    assert
      .dom('[data-test-id="selected-chip"][data-key="apple"]')
      .exists('a chip now occupies the field');
    assert
      .dom('[data-component="select-trigger"]')
      .doesNotHaveAttribute(
        'placeholder',
        'so the placeholder is suppressed beside it'
      );
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

  test("Multiple mode: clicking a chip's body opens the dropdown", async function (assert) {
    // A narrow single-chip trigger is hard to hit directly, so
    // `handleFieldClick` forwards a click landing on a chip's body to the
    // trigger -- the same way it already forwards clicks on the field's
    // empty area. Only the chip's own close button is excluded from this
    // (covered separately below).
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

    assert.dom('[data-component="listbox"]').doesNotExist();

    await click('[data-test-id="selected-chip"][data-key="apple"]');

    assert
      .dom('[data-component="listbox"]')
      .exists("clicking a chip's body opens the dropdown");
    assert
      .dom('[data-test-id="trigger"]')
      .hasAttribute('aria-expanded', 'true');
    assert.deepEqual(
      selectedKeys.current,
      ['apple'],
      'the selection is unchanged by the click'
    );
  });

  test('Multiple mode: a chip close button works with no runtime dependency on data-test-id', async function (assert) {
    // `handleFieldClick` must tell a chip's close button apart from the
    // rest of the chip (and the field) without keying off
    // `data-test-id="selected-chip"` -- that attribute is only a test
    // hook, and tools like ember-test-selectors strip `data-test-*` from
    // production builds. If the click forwarder ever regresses to a
    // selector-based check, this simulates a stripped build by removing
    // the attributes from the rendered chips before clicking, which would
    // make a selector-based `closest(...)` return null and the click fall
    // through to `trigger.click()` -- popping the dropdown open even
    // though a chip was removed. The real detection (an ancestor `<button>`
    // inside the chips container) does not depend on the attribute at all.
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

    const closeButton = document.querySelector(
      '[data-test-id="selected-chip"][data-key="banana"] button'
    ) as HTMLButtonElement;
    if (!closeButton) {
      throw new Error('banana chip close button not found');
    }

    document
      .querySelectorAll('[data-test-id="selected-chip"]')
      .forEach((chip) => chip.removeAttribute('data-test-id'));

    // `@ember/test-helpers`' `click()` awaits `settled()` between the
    // simulated `mousedown`/`mouseup`/`click` events. `onPress` fires
    // synchronously off `mouseup` here and removes the chip, so that
    // `settled()` lets Ember's render runloop flush and detach the chip
    // from the DOM *before* the simulated `click` event is dispatched --
    // a detached node cannot bubble its click to the field, so the click
    // forwarder never runs regardless of what it checks, and the test
    // would pass for the wrong reason. A real physical click fires
    // mousedown/mouseup/click back-to-back with no render flush in
    // between, so this dispatches all three synchronously (no `await`
    // between them) to match that and actually exercise the forwarder.
    const mouseEventOptions = { bubbles: true, cancelable: true, button: 0 };
    closeButton.dispatchEvent(new MouseEvent('mousedown', mouseEventOptions));
    closeButton.dispatchEvent(new MouseEvent('mouseup', mouseEventOptions));
    closeButton.dispatchEvent(new MouseEvent('click', mouseEventOptions));
    await settled();

    assert.deepEqual(
      selectedKeys.current,
      ['apple', 'cherry'],
      'the chip was still removed'
    );
    assert
      .dom('[data-component="listbox"]')
      .doesNotExist('the dropdown did not open');
    assert.notEqual(
      document
        .querySelector('[data-test-id="trigger"]')
        ?.getAttribute('aria-expanded'),
      'true',
      'the trigger does not report itself expanded'
    );
  });

  test('Multiple mode: clicking the field empty area still opens the dropdown', async function (assert) {
    const selectedKeys = cell<string[]>(['apple', 'banana']);
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

    assert.dom('[data-component="listbox"]').doesNotExist();

    await click('[data-test-id="chips-field"]');

    assert
      .dom('[data-component="listbox"]')
      .exists('clicking the empty field area opens the dropdown');
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

  /**
   * Tab order, not merely "is there a button". A keyboard user reaching a
   * chips field expects the combobox first; per-chip close buttons are pointer
   * affordances and must not each cost a Tab stop on the way in.
   */
  test('Multiple mode: the trigger is reached before any chip close button', async function (assert) {
    const selectedKeys = cell<string[]>(['apple', 'banana', 'cherry']);
    const onSelectionChange = (keys: string[]) => (selectedKeys.current = keys);

    await render(
      <template>
        <Select
          @items={{array "apple" "banana" "cherry"}}
          @selectionMode="multiple"
          @allowEmpty={{true}}
          @selectedKeys={{selectedKeys.current}}
          @onSelectionChange={{onSelectionChange}}
        />
      </template>
    );

    const field = document.querySelector(
      '[data-test-id="chips-field"]'
    ) as HTMLElement;
    assert.ok(field, 'the chips field renders');

    const isTabbable = (el: Element) => {
      const tabindex = el.getAttribute('tabindex');
      if (tabindex !== null && Number(tabindex) < 0) return false;
      return !(el as HTMLButtonElement).disabled;
    };

    const tabbable = [
      ...field.querySelectorAll('button, input, [tabindex]')
    ].filter(isTabbable);

    assert.deepEqual(
      tabbable.map((el) => el.getAttribute('data-component')),
      ['select-trigger'],
      'the trigger is the only tab stop inside the chips field'
    );

    assert
      .dom('[data-test-id="selected-chip"] button')
      .exists({ count: 3 }, 'chips still have pointer-reachable close buttons');

    document
      .querySelectorAll('[data-test-id="selected-chip"] button')
      .forEach((button) => {
        assert.strictEqual(
          button.getAttribute('tabindex'),
          '-1',
          'each chip close button is out of the tab order'
        );
      });
  });

  /**
   * Taking the close buttons out of the tab order is only acceptable because
   * Backspace removes the last chip. That has to hold for the non-filterable
   * trigger too, otherwise keyboard users lose chip removal entirely.
   */
  test('Multiple mode: Backspace on the non-filterable trigger removes the last chip', async function (assert) {
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

    assert
      .dom('button[data-component="select-trigger"]')
      .exists('this select uses the button trigger, not a filter input');

    await triggerKeyEvent(
      '[data-component="select-trigger"]',
      'keydown',
      'Backspace'
    );

    assert.deepEqual(
      selectedKeys.current,
      ['apple', 'banana'],
      'Backspace removes the last chip from a non-filterable chips field'
    );
    assert.dom('[data-test-id="selected-chip"]').exists({ count: 2 });
    checkSelected(assert, '[data-key="cherry"]', false);

    await triggerKeyEvent(
      '[data-component="select-trigger"]',
      'keydown',
      'Delete'
    );

    assert.deepEqual(
      selectedKeys.current,
      ['apple'],
      'Delete removes the last chip too'
    );
  });

  test('Multiple mode: Backspace does not remove the final chip unless @allowEmpty', async function (assert) {
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

    await triggerKeyEvent(
      '[data-component="select-trigger"]',
      'keydown',
      'Backspace'
    );

    assert.deepEqual(
      selectedKeys.current,
      ['apple'],
      'the final required selection survives Backspace on the button trigger'
    );
  });

  /**
   * Bug B. Driven through a real keypress on the trigger — the event the
   * Listbox actually listens to for Enter — rather than by calling internals.
   */
  test('Filterable multiple mode: Enter on a filtered option adds to the selection', async function (assert) {
    const selectedKeys = cell<string[]>(['apple', 'banana']);
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

    await click('[data-component="select-trigger"]');
    await fillIn('[data-component="select-trigger"]', 'cherry');

    assert
      .dom('[data-component="listbox"] [data-key="cherry"]')
      .exists('only the filtered option is listed');
    assert
      .dom('[data-component="listbox"] [data-key="apple"]')
      .doesNotExist('the already-selected option is filtered out of the list');

    await triggerKeyEvent(
      '[data-component="select-trigger"]',
      'keypress',
      'Enter'
    );

    assert.deepEqual(
      selectedKeys.current,
      ['apple', 'banana', 'cherry'],
      'Enter adds the active option without dropping the filtered-out selections'
    );

    checkSelected(assert, '[data-key="apple"]', true);
    checkSelected(assert, '[data-key="banana"]', true);
    checkSelected(assert, '[data-key="cherry"]', true);
  });

  /**
   * Bug B, mouse path — proof the data loss is not Enter-specific.
   */
  test('Filterable multiple mode: clicking a filtered option keeps the filtered-out selections', async function (assert) {
    const selectedKeys = cell<string[]>(['apple', 'banana']);
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

    await click('[data-component="select-trigger"]');
    await fillIn('[data-component="select-trigger"]', 'cherry');
    await click('[data-component="listbox"] [data-key="cherry"]');

    assert.deepEqual(
      selectedKeys.current,
      ['apple', 'banana', 'cherry'],
      'clicking a filtered option adds to the selection'
    );
    assert.dom('[data-test-id="selected-chip"]').exists({ count: 3 });
  });

  /**
   * The second of the two layout bugs the user reported: "larger spacing below
   * the chip to the input bottom when in one line".
   *
   * The `min-w-16` floor the chips-mode trigger used to carry pushed it onto a
   * second flex line whenever the room left beside the chips was tighter than
   * the floor. That line was zero-height, but the field's `gap` still paid for
   * it, so a single row of chips sat with dead space underneath.
   *
   * `triggerRect.height >= chipRect.height` — asserted by the hittable-box test
   * above — does NOT catch this: a wrapped trigger that has since gained a
   * `min-h` satisfies it while the dead space is back, and worse than before,
   * because the wrapped line is now tall rather than empty. What has to be
   * pinned is that the trigger *shares the chips' line*.
   *
   * The fixture has to leave less room beside the chips than that 64px floor,
   * or it does not reproduce the case at all. How much room it actually leaves
   * cannot be reasoned about from the production chip theme: `chip-test.gts`
   * calls `registerCustomStyles` at module scope, which replaces the `chip`
   * theme for the whole suite with padding-free stub classnames, so the chips
   * here are narrower than production chips by their entire horizontal
   * padding. The tightness is therefore measured at runtime and asserted below
   * ("premise"), rather than assumed — if the chip theme (real or stubbed) ever
   * changes enough that the row stops being tight, this test fails loudly
   * instead of quietly guarding nothing.
   */
  test('Multiple mode: the trigger shares the chips line instead of wrapping below them', async function (assert) {
    const selectedKeys = cell<string[]>([
      'strawberry',
      'blackberry',
      'raspberry'
    ]);
    const onChange = (keys: string[]) => (selectedKeys.current = keys);

    // Explicit widths: the assertion is about how much room is left beside the
    // chips, so it must not depend on the harness viewport.
    await render(
      <template>
        <div style="width: 320px">
          <Select
            @items={{array "strawberry" "blackberry" "raspberry"}}
            @selectionMode="multiple"
            @selectedKeys={{selectedKeys.current}}
            @onSelectionChange={{onChange}}
          />
        </div>
        <div style="width: 320px">
          <Select
            @items={{array "strawberry" "blackberry" "raspberry"}}
            @placeholder="Pick one"
          />
        </div>
      </template>
    );

    const field = document.querySelector(
      '[data-test-id="chips-field"]'
    ) as HTMLElement;
    const trigger = field.querySelector(
      '[data-component="select-trigger"]'
    ) as HTMLElement;
    const chips = [
      ...field.querySelectorAll('[data-test-id="selected-chip"]')
    ] as HTMLElement[];

    assert.strictEqual(chips.length, 3, 'all three chips render');

    const fieldRect = field.getBoundingClientRect();
    const triggerRect = trigger.getBoundingClientRect();

    // Every chip is on one row: this is the "in one line" case, not a field
    // that is legitimately wrapping.
    const firstChipRect = (chips[0] as HTMLElement).getBoundingClientRect();
    chips.forEach((chip, i) => {
      const rect = chip.getBoundingClientRect();
      assert.ok(
        Math.abs(rect.top - firstChipRect.top) < 1,
        `chip ${i} shares the first chip's row (top ${rect.top} vs ${firstChipRect.top})`
      );
    });

    const lastChipRect = (
      chips[chips.length - 1] as HTMLElement
    ).getBoundingClientRect();

    // Premise check. The QUnit container is `transform: scale(.5)`, so
    // getBoundingClientRect returns halved values while getComputedStyle does
    // not; normalise back to CSS pixels before comparing against the 64px
    // (`min-w-16`) floor this fix removed.
    const scale = fieldRect.width / field.offsetWidth;
    const roomBesideChips =
      (fieldRect.right - lastChipRect.right) / scale -
      parseFloat(getComputedStyle(field).paddingRight);

    assert.ok(
      roomBesideChips < 64,
      `premise: the fixture must leave less room beside the chips than the ` +
        `removed 64px min-width floor, or it is not reproducing the wrapping ` +
        `case at all (measured ${roomBesideChips}px)`
    );

    assert.ok(
      triggerRect.top < lastChipRect.bottom &&
        triggerRect.bottom > lastChipRect.top,
      `the trigger must share the chips' line, not wrap below them: trigger ` +
        `[${triggerRect.top}, ${triggerRect.bottom}] vs last chip ` +
        `[${lastChipRect.top}, ${lastChipRect.bottom}]`
    );

    assert.ok(
      triggerRect.left >= lastChipRect.right - 1,
      `the trigger sits after the last chip on that line (trigger left ` +
        `${triggerRect.left}, last chip right ${lastChipRect.right})`
    );

    // ...and the field is no taller than a single-select field of the same
    // @inputSize. That equivalence is what the geometry fix established, and it
    // is what "extra spacing below the chip" violates: unexplained height in
    // the field beyond one row of chips.
    const singleTrigger = document.querySelectorAll(
      '[data-component="select-trigger"]'
    )[1] as HTMLElement;
    const singleRect = singleTrigger.getBoundingClientRect();

    assert.ok(
      Math.abs(fieldRect.height - singleRect.height) <= 1,
      `a chips field must be the same height as a same-size single select: ` +
        `chips ${fieldRect.height} vs single ${singleRect.height}`
    );

    // The chips must be centred in that height rather than pinned to the top
    // with the slack underneath, which is what the user actually saw.
    const spaceAbove = firstChipRect.top - fieldRect.top;
    const spaceBelow = fieldRect.bottom - firstChipRect.bottom;
    assert.ok(
      Math.abs(spaceAbove - spaceBelow) <= 1,
      `the row of chips must sit centred in the field, not with the slack ` +
        `below it: ${spaceAbove} above vs ${spaceBelow} below`
    );
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
  test('the chips wrapper reflects the invalid state as data-invalid', async function (assert) {
    // `data-invalid` is load-bearing, not decorative: the theme keys
    // `data-[invalid=true]:border-danger-soft` off it, because an `aria-invalid:`
    // variant cannot match this plain `div`.
    const isInvalid = cell<boolean>(false);

    await render(
      <template>
        <Select
          @items={{array "apple" "banana"}}
          @selectionMode="multiple"
          @selectedKeys={{array "apple"}}
          @isInvalid={{isInvalid.current}}
        />
      </template>
    );

    assert
      .dom('[data-test-id="chips-field"]')
      .hasAttribute('data-invalid', 'false', 'valid by default');
    assert
      .dom('[data-test-id="chips-field"]')
      .hasAttribute('data-has-chips', 'true', 'chips mode is reported');

    isInvalid.current = true;
    await settled();

    assert
      .dom('[data-test-id="chips-field"]')
      .hasAttribute('data-invalid', 'true', '@isInvalid marks the wrapper');

    isInvalid.current = false;
    await settled();

    assert
      .dom('[data-test-id="chips-field"]')
      .hasAttribute('data-invalid', 'false', 'and it goes back');
  });

  test('@errors mark the chips wrapper as data-invalid', async function (assert) {
    await render(
      <template>
        <Select
          @items={{array "apple" "banana"}}
          @selectionMode="multiple"
          @selectedKeys={{array "apple"}}
          @errors={{array "Pick something else"}}
        />
      </template>
    );

    assert
      .dom('[data-test-id="chips-field"]')
      .hasAttribute('data-invalid', 'true');
  });

  // --- `:selectedItem` block -------------------------------------------------

  interface DemoUser {
    key: string;
    label: string;
    email: string;
  }

  const demoUsers: DemoUser[] = [
    { key: 'ana', label: 'Ana', email: 'ana@example.com' },
    { key: 'bruno', label: 'Bruno', email: 'bruno@example.com' },
    { key: 'cleo', label: 'Cleo', email: 'cleo@example.com' }
  ];

  const noop = (_key: string | null): void => {};
  const noopKeys = (_keys: string[]): void => {};

  // `selected.item` is `unknown` at the block boundary and is genuinely absent
  // for block-form options, so the test reads it the way a consumer has to.
  const emailOf = (item: unknown): string =>
    (item as DemoUser | undefined)?.email ?? 'no-item';

  test('`:selectedItem` renders custom content inside the single-mode trigger', async function (assert) {
    await render(
      <template>
        <Select
          @items={{demoUsers}}
          @label="Owner"
          @selectedKey="bruno"
          @onSelectionChange={{noop}}
        >
          <:selectedItem as |selected|>
            <span data-test-id="custom-selected" data-key={{selected.key}}>
              {{selected.label}}
            </span>
          </:selectedItem>
        </Select>
      </template>
    );

    assert
      .dom('[data-component="select-trigger"] [data-test-id="custom-selected"]')
      .exists('the block renders inside the trigger');
    assert
      .dom('[data-component="select-trigger"] [data-test-id="custom-selected"]')
      .hasAttribute('data-key', 'bruno', 'the block is handed the option key');
    assert
      .dom('[data-component="select-trigger"] [data-test-id="custom-selected"]')
      .hasText('Bruno', '`label` is the option text');
  });

  test('`:selectedItem` renders inside each chip, keeping the chip chrome', async function (assert) {
    const selectedKeys = cell<string[]>(['ana', 'cleo']);
    const onChange = (keys: string[]) => (selectedKeys.current = keys);

    await render(
      <template>
        <Select
          @items={{demoUsers}}
          @label="Owners"
          @selectionMode="multiple"
          @allowEmpty={{true}}
          @selectedKeys={{selectedKeys.current}}
          @onSelectionChange={{onChange}}
        >
          <:selectedItem as |selected|>
            <span data-test-id="custom-selected">{{selected.label}}</span>
          </:selectedItem>
        </Select>
      </template>
    );

    assert.dom('[data-test-id="selected-chip"]').exists({ count: 2 });
    assert
      .dom(
        '[data-test-id="selected-chip"][data-key="ana"] [data-test-id="custom-selected"]'
      )
      .hasText('Ana', 'the block renders inside the chip');
    assert
      .dom(
        '[data-test-id="selected-chip"][data-key="cleo"] [data-test-id="custom-selected"]'
      )
      .hasText('Cleo');
    assert
      .dom('[data-test-id="selected-chip"][data-key="ana"] button')
      .exists('the chip keeps its close button');
    // CloseButton renders its @title as visually hidden *text*, not a `title`
    // attribute -- so this reads the accessible text, which is what a screen
    // reader announces.
    assert
      .dom('[data-test-id="selected-chip"][data-key="ana"] button')
      .hasText(
        'Remove Ana',
        'the close button is still labelled from the option text'
      );
  });

  test('`:selectedItem` renders once per selection in @selectedItemsDisplay="text"', async function (assert) {
    await render(
      <template>
        <Select
          @items={{demoUsers}}
          @label="Owners"
          @selectionMode="multiple"
          @selectedItemsDisplay="text"
          @selectedKeys={{array "ana" "cleo"}}
          @onSelectionChange={{noopKeys}}
        >
          <:selectedItem as |selected|>
            <span data-test-id="custom-selected">{{selected.label}}</span>
          </:selectedItem>
        </Select>
      </template>
    );

    assert.dom('[data-test-id="selected-chip"]').doesNotExist();
    assert
      .dom('[data-component="select-trigger"] [data-test-id="custom-selected"]')
      .exists({ count: 2 }, 'the block renders once per selection');
    // The plain presentation deliberately keeps one text node; the block
    // branch renders many, so assert on the text, not the node shape. The
    // separator is matched loosely because the whitespace around it belongs to
    // the consumer's own block markup, not to the Select.
    assert
      .dom('[data-component="select-trigger"]')
      .hasText(/Ana\s*,\s*Cleo/, 'the selections stay comma-separated');
  });

  test('without `:selectedItem`, every presentation is unchanged', async function (assert) {
    await render(
      <template>
        <Select
          @items={{demoUsers}}
          @label="Owner"
          @selectedKey="bruno"
          @onSelectionChange={{noop}}
        />
        <Select
          @items={{demoUsers}}
          @label="Owners"
          @selectionMode="multiple"
          @selectedItemsDisplay="text"
          @selectedKeys={{array "ana" "cleo"}}
          @onSelectionChange={{noopKeys}}
        />
        <Select
          @items={{demoUsers}}
          @label="Reviewers"
          @selectionMode="multiple"
          @allowEmpty={{true}}
          @selectedKeys={{array "ana" "cleo"}}
          @onSelectionChange={{noopKeys}}
        />
        <Select
          @items={{demoUsers}}
          @label="Filterable owner"
          @isFilterable={{true}}
          @selectedKey="bruno"
          @onSelectionChange={{noop}}
        />
      </template>
    );

    const triggers = document.querySelectorAll(
      '[data-component="select-trigger"]'
    );

    assert.dom(triggers[0]).hasText('Bruno', 'single mode renders the label');
    assert
      .dom(triggers[0])
      .doesNotHaveAttribute(
        'aria-label',
        'the trigger is still named by its own text'
      );
    assert
      .dom(triggers[1])
      .hasText('Ana, Cleo', 'text mode still renders the joined string');
    assert
      .dom(triggers[1])
      .doesNotHaveAttribute('aria-label', 'and is still named by that text');

    // The chip body is the markup this feature actually replaced
    // (`{{item.textValue}}` became a yielded block with a fallback), so it is
    // the presentation most worth pinning. Matched from the start of the chip
    // so the close button's visually hidden `Remove Ana` cannot stand in for
    // the body, and case-sensitively so the key (`ana`) cannot either.
    assert
      .dom('[data-test-id="selected-chip"][data-key="ana"]')
      .hasText(/^\s*Ana\b/, 'the chip body is still the option label');
    assert
      .dom('[data-test-id="selected-chip"][data-key="cleo"]')
      .hasText(/^\s*Cleo\b/);
    assert
      .dom('[data-test-id="selected-chip"][data-key="ana"] button')
      .hasText(
        'Remove Ana',
        'and the close button is still named from the option'
      );

    assert
      .dom(triggers[3])
      .hasTagName('input', 'a filterable trigger is an input');
    assert
      .dom(triggers[3])
      .hasValue('Bruno', 'which still shows the selection as its own value');
    assert
      .dom(triggers[3])
      .doesNotHaveAttribute(
        'aria-label',
        'and is still named by that value alone'
      );
  });

  test('a filterable trigger is not given an `aria-label` by `:selectedItem`', async function (assert) {
    await render(
      <template>
        <Select
          @items={{demoUsers}}
          @label="Owner"
          @isFilterable={{true}}
          @selectedKey="bruno"
          @onSelectionChange={{noop}}
        >
          <:selectedItem as |selected|>
            <span data-test-id="custom-selected">{{selected.label}}</span>
          </:selectedItem>
        </Select>
        <Select
          @items={{demoUsers}}
          @label="Owner"
          @selectedKey="bruno"
          @onSelectionChange={{noop}}
        >
          <:selectedItem as |selected|>
            <span data-test-id="custom-selected">{{selected.label}}</span>
          </:selectedItem>
        </Select>
      </template>
    );

    const triggers = document.querySelectorAll(
      '[data-component="select-trigger"]'
    );

    // The block cannot render into an `<input>`, so the input is never left
    // unnamed: its own value is its accessible text. An `aria-label` here
    // would both duplicate that value and change as the user types.
    assert.dom(triggers[0]).hasTagName('input');
    assert
      .dom(triggers[0])
      .hasValue('Bruno', 'the input still shows the selection as text');
    assert
      .dom(triggers[0])
      .doesNotHaveAttribute(
        'aria-label',
        'the filterable trigger keeps its value as its only name'
      );

    // The `<button>` trigger does hand its content to the block, so it still
    // needs the explicit name.
    assert.dom(triggers[1]).hasTagName('button');
    assert
      .dom(triggers[1])
      .hasAttribute(
        'aria-label',
        'Owner, Bruno',
        'the non-filterable trigger is still named explicitly'
      );
  });

  test('a filterable trigger in chips mode keeps its `aria-label`', async function (assert) {
    await render(
      <template>
        <Select
          @items={{demoUsers}}
          @label="Owners"
          @isFilterable={{true}}
          @selectionMode="multiple"
          @allowEmpty={{true}}
          @selectedKeys={{array "ana"}}
          @onSelectionChange={{noopKeys}}
        >
          <:selectedItem as |selected|>
            <span data-test-id="custom-selected">{{selected.label}}</span>
          </:selectedItem>
        </Select>
        <Select
          @items={{demoUsers}}
          @label="Reviewers"
          @isFilterable={{true}}
          @selectionMode="multiple"
          @allowEmpty={{true}}
          @selectedKeys={{array "ana"}}
          @onSelectionChange={{noopKeys}}
        />
      </template>
    );

    const triggers = document.querySelectorAll(
      '[data-component="select-trigger"]'
    );

    // In chips mode the input shows nothing of the selection, so it has no
    // text of its own -- the control name is still required there, block or
    // no block.
    assert.dom(triggers[0]).hasAttribute('aria-label', 'Owners');
    assert.dom(triggers[1]).hasAttribute('aria-label', 'Reviewers');
  });

  test('the composed name never ends in a dangling separator', async function (assert) {
    await render(
      <template>
        <Select
          @items={{demoUsers}}
          @label="Owner"
          @selectedKey="nobody"
          @onSelectionChange={{noop}}
        >
          <:selectedItem as |selected|>
            <span data-test-id="custom-selected">{{selected.label}}</span>
          </:selectedItem>
        </Select>
      </template>
    );

    // A key with no registered option behind it counts as a selection but
    // resolves to no text, and `Owner, ` is announced as "Owner comma".
    assert
      .dom('[data-component="select-trigger"] [data-test-id="custom-selected"]')
      .doesNotExist('there is no option behind the key, so nothing renders');
    assert
      .dom('[data-component="select-trigger"]')
      .hasAttribute(
        'aria-label',
        'Owner',
        'the separator only appears between two non-empty halves'
      );
  });

  test('with no label or placeholder the name is the selected text alone', async function (assert) {
    await render(
      <template>
        <Select
          @items={{demoUsers}}
          @selectedKey="ana"
          @onSelectionChange={{noop}}
        >
          <:selectedItem as |selected|>
            <span data-test-id="custom-selected">{{selected.label}}</span>
          </:selectedItem>
        </Select>
        <Select
          @items={{demoUsers}}
          @selectionMode="multiple"
          @allowEmpty={{true}}
          @selectedKeys={{array "ana"}}
          @onSelectionChange={{noopKeys}}
        >
          <:selectedItem as |selected|>
            <span data-test-id="custom-selected">{{selected.label}}</span>
          </:selectedItem>
        </Select>
      </template>
    );

    const triggers = document.querySelectorAll(
      '[data-component="select-trigger"]'
    );

    // `Select options` is a hardcoded English literal; prefixing the selected
    // text with it names the control no better and localizes worse.
    assert
      .dom(triggers[0])
      .hasAttribute(
        'aria-label',
        'Ana',
        'the selection names the control on its own'
      );

    // Chips mode has no selected text inside the trigger to fall back to, so
    // the literal is still the only answer there -- unchanged.
    assert
      .dom(triggers[1])
      .hasAttribute(
        'aria-label',
        'Select options',
        'chips mode is untouched by that fallback'
      );
  });

  test('an `aria-label` on the Select does not reach the trigger', async function (assert) {
    await render(
      <template>
        <Select
          @items={{demoUsers}}
          @label="Owner"
          @selectedKey="ana"
          @onSelectionChange={{noop}}
          aria-label="Pick an owner"
        >
          <:selectedItem as |selected|>
            <span data-test-id="custom-selected">{{selected.label}}</span>
          </:selectedItem>
        </Select>
      </template>
    );

    // `...attributes` on `<Select>` land on the wrapper element, not on the
    // combobox, so a consumer cannot override the composed name this way.
    // The docs say so rather than promising an override that does not exist.
    assert
      .dom('[data-component="select-trigger"]')
      .hasAttribute(
        'aria-label',
        'Owner, Ana',
        'the composed name still wins on the trigger'
      );
  });

  test('`selected.item` is the `@items` entry the selection came from', async function (assert) {
    await render(
      <template>
        <Select
          @items={{demoUsers}}
          @label="Owner"
          @selectedKey="cleo"
          @onSelectionChange={{noop}}
        >
          <:selectedItem as |selected|>
            <span data-test-id="custom-email">{{emailOf selected.item}}</span>
          </:selectedItem>
        </Select>
      </template>
    );

    assert
      .dom('[data-test-id="custom-email"]')
      .hasText(
        'cleo@example.com',
        'the block can reach the consumer’s own object'
      );
  });

  test('`selected.item` is undefined for options written in block form', async function (assert) {
    await render(
      <template>
        <Select @label="Owner" @selectedKey="ana" @onSelectionChange={{noop}}>
          <:default as |l|>
            <l.Item @key="ana">Ana</l.Item>
            <l.Item @key="bruno">Bruno</l.Item>
          </:default>
          <:selectedItem as |selected|>
            <span data-test-id="custom-email">{{emailOf selected.item}}</span>
            <span data-test-id="custom-label">{{selected.label}}</span>
          </:selectedItem>
        </Select>
      </template>
    );

    assert
      .dom('[data-test-id="custom-email"]')
      .hasText('no-item', 'there is no collection entry behind a block option');
    assert
      .dom('[data-test-id="custom-label"]')
      .hasText('Ana', 'the label is still available');
  });

  test('a `:selectedItem` block rendering no text still leaves the trigger named', async function (assert) {
    await render(
      <template>
        <Select
          @items={{demoUsers}}
          @label="Owner"
          @selectedKey="bruno"
          @onSelectionChange={{noop}}
        >
          <:selectedItem as |selected|>
            <span
              data-test-id="graphic-only"
              data-key={{selected.key}}
              aria-hidden="true"
            ></span>
          </:selectedItem>
        </Select>
      </template>
    );

    assert
      .dom('[data-component="select-trigger"] [data-test-id="graphic-only"]')
      .exists('the block rendered, and rendered nothing readable');
    assert
      .dom('[data-component="select-trigger"]')
      .hasText('', 'the trigger has no text of its own to be named by');

    const trigger = document.querySelector(
      '[data-component="select-trigger"]'
    ) as HTMLElement;
    const ariaLabel = trigger.getAttribute('aria-label');

    assert.ok(
      ariaLabel && ariaLabel.trim() !== '',
      `the trigger carries a non-empty aria-label (got ${JSON.stringify(ariaLabel)})`
    );
    assert.strictEqual(
      ariaLabel,
      'Owner, Bruno',
      'built from the field label and the selected option text'
    );
  });

  test('chips carrying custom content are still removable, tabbable-past and Backspace-able', async function (assert) {
    const selectedKeys = cell<string[]>(['ana', 'bruno', 'cleo']);
    const onChange = (keys: string[]) => (selectedKeys.current = keys);

    await render(
      <template>
        <Select
          @items={{demoUsers}}
          @label="Owners"
          @selectionMode="multiple"
          @allowEmpty={{true}}
          @selectedKeys={{selectedKeys.current}}
          @onSelectionChange={{onChange}}
        >
          <:selectedItem as |selected|>
            <span data-test-id="custom-selected">{{selected.label}}</span>
          </:selectedItem>
        </Select>
      </template>
    );

    assert
      .dom('[data-test-id="selected-chip"][data-key="bruno"] button')
      .hasAttribute(
        'tabindex',
        '-1',
        'close buttons stay out of the tab order'
      );

    await click('[data-test-id="selected-chip"][data-key="bruno"] button');

    assert.deepEqual(
      selectedKeys.current,
      ['ana', 'cleo'],
      'the close button removed just that selection'
    );
    assert
      .dom('[data-test-id="selected-chip"][data-key="bruno"]')
      .doesNotExist();

    await triggerKeyEvent(
      '[data-component="select-trigger"]',
      'keydown',
      'Backspace'
    );

    assert.deepEqual(
      selectedKeys.current,
      ['ana'],
      'Backspace on the trigger still removes the last chip'
    );
  });

  test('@allowEmpty still governs chips carrying custom content', async function (assert) {
    const selectedKeys = cell<string[]>(['ana']);
    const onChange = (keys: string[]) => (selectedKeys.current = keys);

    await render(
      <template>
        <Select
          @items={{demoUsers}}
          @label="Owners"
          @selectionMode="multiple"
          @selectedKeys={{selectedKeys.current}}
          @onSelectionChange={{onChange}}
        >
          <:selectedItem as |selected|>
            <span data-test-id="custom-selected">{{selected.label}}</span>
          </:selectedItem>
        </Select>
      </template>
    );

    assert
      .dom(
        '[data-test-id="selected-chip"][data-key="ana"] [data-test-id="custom-selected"]'
      )
      .exists('the chip carries the custom content');
    assert
      .dom('[data-test-id="selected-chip"][data-key="ana"] button')
      .doesNotExist(
        'the last selection cannot be removed without @allowEmpty, so no dead close button'
      );

    await triggerKeyEvent(
      '[data-component="select-trigger"]',
      'keydown',
      'Backspace'
    );

    assert.deepEqual(
      selectedKeys.current,
      ['ana'],
      'and Backspace cannot remove it either'
    );
  });
  const blurAnimals = ['cheetah', 'crocodile', 'elephant'];

  // ---------------------------------------------------------------------------
  // @onBlur
  //
  // `@onBlur` means "focus left this control", which is not the same thing as
  // "an option was clicked": the trigger blurs on the way *into* the dropdown,
  // and in multiple mode the dropdown stays open across several clicks.
  // ---------------------------------------------------------------------------

  test('@onBlur is not called while selecting in multiple mode with the dropdown open', async function (assert) {
    const selectedKeys = cell<string[]>([]);
    const onSelectionChange = (keys: string[]) => (selectedKeys.current = keys);
    let blurCount = 0;
    const onBlur = () => blurCount++;

    await render(
      <template>
        <Select
          @selectionMode="multiple"
          @items={{blurAnimals}}
          @selectedKeys={{selectedKeys.current}}
          @onSelectionChange={{onSelectionChange}}
          @onBlur={{onBlur}}
        />
      </template>
    );

    await click('[data-component="select-trigger"]');
    await click('[data-component="listbox"] [data-key="cheetah"]');
    await click('[data-component="listbox"] [data-key="crocodile"]');

    assert
      .dom('[data-component="listbox"]')
      .exists('the dropdown is still open');
    assert.deepEqual(selectedKeys.current, ['cheetah', 'crocodile']);
    assert.strictEqual(
      blurCount,
      0,
      'focus never left the control, so no blur was reported'
    );
  });

  test('@onBlur is not called when selecting in single mode', async function (assert) {
    const selectedKey = cell<string | null>(null);
    const onSelectionChange = (key: string | null) =>
      (selectedKey.current = key);
    let blurCount = 0;
    const onBlur = () => blurCount++;

    await render(
      <template>
        <Select
          @items={{blurAnimals}}
          @selectedKey={{selectedKey.current}}
          @onSelectionChange={{onSelectionChange}}
          @onBlur={{onBlur}}
        />
      </template>
    );

    await click('[data-component="select-trigger"]');
    await click('[data-component="listbox"] [data-key="cheetah"]');

    assert.strictEqual(selectedKey.current, 'cheetah');
    assert.strictEqual(
      blurCount,
      0,
      'the dropdown closed and focus went back to the trigger, so no blur'
    );
  });

  test('@onBlur is called exactly once when focus leaves the control', async function (assert) {
    const selectedKey = cell<string | null>(null);
    const onSelectionChange = (key: string | null) =>
      (selectedKey.current = key);
    let blurCount = 0;
    const onBlur = () => blurCount++;

    await render(
      <template>
        <Select
          @items={{blurAnimals}}
          @selectedKey={{selectedKey.current}}
          @onSelectionChange={{onSelectionChange}}
          @onBlur={{onBlur}}
        />
        <button type="button" data-test-id="outside">Outside</button>
      </template>
    );

    await click('[data-component="select-trigger"]');
    await click('[data-component="listbox"] [data-key="cheetah"]');
    assert.strictEqual(blurCount, 0, 'selecting is not blurring');

    await click('[data-test-id="outside"]');

    assert.strictEqual(blurCount, 1, 'leaving the control reported one blur');
  });

  test('@onBlur is not called while filtering, and once on leaving the filterable control', async function (assert) {
    const selectedKey = cell<string | null>(null);
    const onSelectionChange = (key: string | null) =>
      (selectedKey.current = key);
    let blurCount = 0;
    const onBlur = () => blurCount++;

    await render(
      <template>
        <Select
          @isFilterable={{true}}
          @items={{blurAnimals}}
          @selectedKey={{selectedKey.current}}
          @onSelectionChange={{onSelectionChange}}
          @onBlur={{onBlur}}
        />
        <button type="button" data-test-id="outside">Outside</button>
      </template>
    );

    await click('[data-component="select-trigger"]');
    await fillIn('[data-component="select-trigger"]', 'cro');
    await click('[data-component="listbox"] [data-key="crocodile"]');

    assert.strictEqual(selectedKey.current, 'crocodile');
    assert.strictEqual(blurCount, 0, 'typing and selecting is not blurring');

    await click('[data-test-id="outside"]');

    assert.strictEqual(blurCount, 1, 'leaving the control reported one blur');
  });

  test('tearing the Select down right after a selection neither calls @onBlur nor asserts', async function (assert) {
    const isRendered = cell<boolean>(true);
    let blurCount = 0;
    const onBlur = () => blurCount++;
    const onSelectionChange = (_key: string | null) => {
      // Destroys the Select in the middle of the selection it is reacting to.
      isRendered.current = false;
    };

    await render(
      <template>
        {{#if isRendered.current}}
          <Select
            @items={{blurAnimals}}
            @onSelectionChange={{onSelectionChange}}
            @onBlur={{onBlur}}
          />
        {{/if}}
      </template>
    );

    await click('[data-component="select-trigger"]');
    await click('[data-component="listbox"] [data-key="cheetah"]');

    assert.dom('[data-component="select-trigger"]').doesNotExist('torn down');
    assert.strictEqual(
      blurCount,
      0,
      'no callback fires after the component is gone'
    );
  });

  test('@isClearable clears the selection even with @allowEmpty false', async function (assert) {
    const selectedKey = cell<string | null>('cheetah');
    const onSelectionChange = (key: string | null) =>
      (selectedKey.current = key);

    await render(
      <template>
        <Select
          @items={{blurAnimals}}
          @allowEmpty={{false}}
          @isClearable={{true}}
          @selectedKey={{selectedKey.current}}
          @onSelectionChange={{onSelectionChange}}
        />
      </template>
    );

    assert
      .dom('[data-test-id="input-clear-button"]')
      .exists('the clear button is an explicit opt-in, so it renders');

    await click('[data-test-id="input-clear-button"]');

    assert.strictEqual(
      selectedKey.current,
      null,
      '@isClearable is documented to override @allowEmpty'
    );
  });

  test('@isClearable renders no clear button on a disabled Select', async function (assert) {
    const selectedKey = cell<string | null>('cheetah');
    const onSelectionChange = (key: string | null) =>
      (selectedKey.current = key);

    await render(
      <template>
        <Select
          @items={{blurAnimals}}
          @isClearable={{true}}
          @isDisabled={{true}}
          @selectedKey={{selectedKey.current}}
          @onSelectionChange={{onSelectionChange}}
        />
      </template>
    );

    assert
      .dom('[data-test-id="input-clear-button"]')
      .doesNotExist('a disabled control cannot be cleared, so no dead button');
  });
});
