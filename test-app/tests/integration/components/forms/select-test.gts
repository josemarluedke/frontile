import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { click, render, triggerKeyEvent, fillIn } from '@ember/test-helpers';
import { cell } from 'ember-resources';
import { Select } from '@frontile/forms';
import { array } from '@ember/helper';
import { selectOptionByKey } from '@frontile/forms/test-support';

// Simple equality helper
const eq = (a: unknown, b: unknown) => a === b;

module('Integration | Component | Select | @frontile/forms', function (hooks) {
  setupRenderingTest(hooks);

  const isSelected = (
    assert: { ok: (val: boolean, mes: string) => void },
    queryString: string
  ): void => {
    const select = document.querySelector('[data-component="native-select"]');
    if (!select) {
      throw new Error(
        'did not find native-select to check if options is selected'
      );
    }
    const option = select.querySelector(queryString);
    const isSelected = option && (option as HTMLOptionElement).selected;
    assert.ok(!!isSelected, `Expected ${queryString} to be selected`);
  };

  const isNotSelected = (
    assert: { ok: (val: boolean, mes: string) => void },
    queryString: string
  ): void => {
    const select = document.querySelector('[data-component="native-select"]');
    if (!select) {
      throw new Error(
        'did not find native-select to check if options is selected'
      );
    }
    const option = select.querySelector(queryString);
    const isSelected = option && (option as HTMLOptionElement).selected;
    assert.ok(!isSelected, `Expected ${queryString} to not be selected`);
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
      .hasAttribute('disabled');
    assert
      .dom('[data-component="listbox"] [data-key="item-4"]')
      .hasAttribute('disabled');

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

    // Initially no selection - should show placeholder
    assert
      .dom('[data-component="select-trigger"]')
      .hasText('Select a fruit', 'trigger should show placeholder initially');

    // Set selectedKey externally to 'Apple'
    selectedKey.current = 'Apple';
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

    // Verify trigger button text updates
    assert
      .dom('[data-component="select-trigger"]')
      .hasText('Apple', 'trigger should display Apple');

    // Verify native select reflects the selection
    isSelected(assert, '[data-key="Apple"]');

    // Change selectedKey externally to 'Banana'
    selectedKey.current = 'Banana';
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

    // Verify trigger button text updates to Banana
    assert
      .dom('[data-component="select-trigger"]')
      .hasText('Banana', 'trigger should display Banana');

    // Verify native select reflects the new selection
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

    // Verify initial selection in native select
    isSelected(assert, '[data-key="item-1"]');
    assert.dom('[data-component="select-trigger"]').hasText('Item 1');

    // Open listbox and verify selection
    await click('[data-component="select-trigger"]');
    assert
      .dom('[data-component="listbox"] [data-key="item-1"]')
      .hasAttribute('data-selected', 'true');
    assert
      .dom('[data-component="listbox"] [data-key="item-2"]')
      .hasAttribute('data-selected', 'false');

    // Close listbox
    await click('[data-component="select-trigger"]');

    // Change selectedKey externally from item-1 to item-2
    selectedKey.current = 'item-2';
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

    // Verify native select updated
    isSelected(assert, '[data-key="item-2"]');
    isNotSelected(assert, '[data-key="item-1"]');
    assert
      .dom('[data-component="select-trigger"]')
      .hasText('Item 2', 'trigger should show Item 2');

    // Open listbox and verify selection updated
    await click('[data-component="select-trigger"]');
    assert
      .dom('[data-component="listbox"] [data-key="item-2"]')
      .hasAttribute('data-selected', 'true', 'item-2 should be selected');
    assert
      .dom('[data-component="listbox"] [data-key="item-1"]')
      .hasAttribute('data-selected', 'false', 'item-1 should not be selected');

    // Close and change to item-3
    await click('[data-component="select-trigger"]');
    selectedKey.current = 'item-3';
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

    // Verify final state
    isSelected(assert, '[data-key="item-3"]');
    assert.dom('[data-component="select-trigger"]').hasText('Item 3');

    await click('[data-component="select-trigger"]');
    assert
      .dom('[data-component="listbox"] [data-key="item-3"]')
      .hasAttribute('data-selected', 'true');
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
          @items={{items}}
          @selectedKeys={{selectedKeys.current}}
          @onSelectionChange={{onSelectionChange}}
          @placeholder="Select fruits"
        />
      </template>
    );

    // Initially no selection - should show placeholder
    assert
      .dom('[data-component="select-trigger"]')
      .hasText('Select fruits', 'trigger should show placeholder initially');

    // Set selectedKeys externally to ['Apple']
    selectedKeys.current = ['Apple'];
    await render(
      <template>
        <Select
          @selectionMode="multiple"
          @items={{items}}
          @selectedKeys={{selectedKeys.current}}
          @onSelectionChange={{onSelectionChange}}
          @placeholder="Select fruits"
        />
      </template>
    );

    // Verify trigger displays single selection
    assert
      .dom('[data-component="select-trigger"]')
      .hasText('Apple', 'trigger should display Apple');

    // Set selectedKeys externally to ['Apple', 'Banana']
    selectedKeys.current = ['Apple', 'Banana'];
    await render(
      <template>
        <Select
          @selectionMode="multiple"
          @items={{items}}
          @selectedKeys={{selectedKeys.current}}
          @onSelectionChange={{onSelectionChange}}
          @placeholder="Select fruits"
        />
      </template>
    );

    // Verify trigger displays comma-separated values
    assert
      .dom('[data-component="select-trigger"]')
      .hasText(
        'Apple, Banana',
        'trigger should display comma-separated values'
      );

    // Set selectedKeys externally to ['Cherry', 'Date', 'Apple']
    selectedKeys.current = ['Cherry', 'Date', 'Apple'];
    await render(
      <template>
        <Select
          @selectionMode="multiple"
          @items={{items}}
          @selectedKeys={{selectedKeys.current}}
          @onSelectionChange={{onSelectionChange}}
          @placeholder="Select fruits"
        />
      </template>
    );

    // Verify trigger displays all three comma-separated (in items array order)
    assert
      .dom('[data-component="select-trigger"]')
      .hasText(
        'Apple, Cherry, Date',
        'trigger should display three comma-separated values in items array order'
      );

    // Clear selection externally
    selectedKeys.current = [];
    await render(
      <template>
        <Select
          @selectionMode="multiple"
          @items={{items}}
          @selectedKeys={{selectedKeys.current}}
          @onSelectionChange={{onSelectionChange}}
          @placeholder="Select fruits"
        />
      </template>
    );

    // Verify trigger shows placeholder again when selection cleared
    assert
      .dom('[data-component="select-trigger"]')
      .hasText(
        'Select fruits',
        'trigger should show placeholder when selection cleared'
      );
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

    // Open listbox - nothing should be selected
    await click('[data-component="select-trigger"]');
    assert
      .dom('[data-component="listbox"] [data-key="item-1"]')
      .hasAttribute('data-selected', 'false');
    assert
      .dom('[data-component="listbox"] [data-key="item-2"]')
      .hasAttribute('data-selected', 'false');

    // Close listbox
    await click('[data-component="select-trigger"]');

    // Set selectedKeys externally to ['item-1', 'item-3']
    selectedKeys.current = ['item-1', 'item-3'];
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

    // Open listbox and verify selections
    await click('[data-component="select-trigger"]');
    assert
      .dom('[data-component="listbox"] [data-key="item-1"]')
      .hasAttribute('data-selected', 'true', 'item-1 should be selected');
    assert
      .dom('[data-component="listbox"] [data-key="item-2"]')
      .hasAttribute('data-selected', 'false', 'item-2 should not be selected');
    assert
      .dom('[data-component="listbox"] [data-key="item-3"]')
      .hasAttribute('data-selected', 'true', 'item-3 should be selected');
    assert
      .dom('[data-component="listbox"] [data-key="item-4"]')
      .hasAttribute('data-selected', 'false', 'item-4 should not be selected');

    // Close listbox
    await click('[data-component="select-trigger"]');

    // Add item-2 to selection, remove item-1
    selectedKeys.current = ['item-2', 'item-3'];
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

    // Open listbox and verify updated selections
    await click('[data-component="select-trigger"]');
    assert
      .dom('[data-component="listbox"] [data-key="item-1"]')
      .hasAttribute(
        'data-selected',
        'false',
        'item-1 should no longer be selected'
      );
    assert
      .dom('[data-component="listbox"] [data-key="item-2"]')
      .hasAttribute('data-selected', 'true', 'item-2 should now be selected');
    assert
      .dom('[data-component="listbox"] [data-key="item-3"]')
      .hasAttribute('data-selected', 'true', 'item-3 should still be selected');

    // Close and clear all selections
    await click('[data-component="select-trigger"]');
    selectedKeys.current = [];
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

    // Verify nothing is selected
    await click('[data-component="select-trigger"]');
    assert
      .dom('[data-component="listbox"] [data-key="item-1"]')
      .hasAttribute('data-selected', 'false');
    assert
      .dom('[data-component="listbox"] [data-key="item-2"]')
      .hasAttribute('data-selected', 'false');
    assert
      .dom('[data-component="listbox"] [data-key="item-3"]')
      .hasAttribute('data-selected', 'false');
  });

  test('Single mode: initializes correctly with pre-set @selectedKey', async function (assert) {
    // Initialize with a pre-set value BEFORE first render
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

    // Verify onSelectionChange was NOT called during initialization
    assert.equal(
      callCount,
      0,
      'onSelectionChange should not be called during component initialization'
    );

    // Verify trigger button shows the pre-set selection
    assert
      .dom('[data-component="select-trigger"]')
      .hasText('Item 2', 'trigger should display the initialized selection');

    // Verify native select has the correct option selected
    isSelected(assert, '[data-key="item-2"]');
    isNotSelected(assert, '[data-key="item-1"]');
    isNotSelected(assert, '[data-key="item-3"]');

    // Open listbox and verify the pre-set selection is shown
    await click('[data-component="select-trigger"]');
    assert
      .dom('[data-component="listbox"] [data-key="item-2"]')
      .hasAttribute(
        'data-selected',
        'true',
        'item-2 should be selected in listbox'
      );
    assert
      .dom('[data-component="listbox"] [data-key="item-1"]')
      .hasAttribute('data-selected', 'false', 'item-1 should not be selected');
    assert
      .dom('[data-component="listbox"] [data-key="item-3"]')
      .hasAttribute('data-selected', 'false', 'item-3 should not be selected');

    // Verify callback still not called after opening listbox
    assert.equal(
      callCount,
      0,
      'onSelectionChange should still not be called after opening listbox'
    );

    // Now test that user interaction DOES trigger callback
    await click('[data-component="listbox"] [data-key="item-3"]');
    assert.equal(
      callCount,
      1,
      'onSelectionChange should be called once after user clicks'
    );
    assert.equal(selectedKey.current, 'item-3', 'selection should update');
  });

  test('Multiple mode: initializes correctly with pre-set @selectedKeys', async function (assert) {
    // Initialize with pre-set values BEFORE first render
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
          @items={{items}}
          @selectedKeys={{selectedKeys.current}}
          @onSelectionChange={{onSelectionChange}}
        />
      </template>
    );

    // Verify onSelectionChange was NOT called during initialization
    assert.equal(
      callCount,
      0,
      'onSelectionChange should not be called during component initialization'
    );

    // Verify trigger shows the pre-set selections (in items array order)
    assert
      .dom('[data-component="select-trigger"]')
      .hasText(
        'Apple, Cherry',
        'trigger should display the initialized selections'
      );

    // Open listbox and verify the pre-set selections are shown
    await click('[data-component="select-trigger"]');
    assert
      .dom('[data-component="listbox"] [data-key="Apple"]')
      .hasAttribute('data-selected', 'true', 'Apple should be selected');
    assert
      .dom('[data-component="listbox"] [data-key="Banana"]')
      .hasAttribute('data-selected', 'false', 'Banana should not be selected');
    assert
      .dom('[data-component="listbox"] [data-key="Cherry"]')
      .hasAttribute('data-selected', 'true', 'Cherry should be selected');
    assert
      .dom('[data-component="listbox"] [data-key="Date"]')
      .hasAttribute('data-selected', 'false', 'Date should not be selected');

    // Verify callback still not called after opening listbox
    assert.equal(
      callCount,
      0,
      'onSelectionChange should still not be called after opening listbox'
    );

    // Now test that user interaction DOES trigger callback
    await click('[data-component="listbox"] [data-key="Banana"]');
    assert.equal(
      callCount,
      1,
      'onSelectionChange should be called once after user clicks'
    );
    assert.deepEqual(
      selectedKeys.current,
      ['Apple', 'Cherry', 'Banana'],
      'selection should include Banana'
    );
  });

  test('Single mode: initializes with null (no selection)', async function (assert) {
    // Initialize with null BEFORE first render
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

    // Verify onSelectionChange was NOT called during initialization
    assert.equal(
      callCount,
      0,
      'onSelectionChange should not be called during initialization with null'
    );

    // Verify trigger shows placeholder
    assert
      .dom('[data-component="select-trigger"]')
      .hasText(
        'Select an item',
        'trigger should display placeholder when null'
      );

    // Verify native select has no selection
    isNotSelected(assert, '[data-key="item-1"]');
    isNotSelected(assert, '[data-key="item-2"]');
    isNotSelected(assert, '[data-key="item-3"]');

    // Open listbox and verify no items are selected
    await click('[data-component="select-trigger"]');
    assert
      .dom('[data-component="listbox"] [data-key="item-1"]')
      .hasAttribute('data-selected', 'false', 'item-1 should not be selected');
    assert
      .dom('[data-component="listbox"] [data-key="item-2"]')
      .hasAttribute('data-selected', 'false', 'item-2 should not be selected');
    assert
      .dom('[data-component="listbox"] [data-key="item-3"]')
      .hasAttribute('data-selected', 'false', 'item-3 should not be selected');

    // Verify callback still not called
    assert.equal(
      callCount,
      0,
      'onSelectionChange should still not be called after opening listbox'
    );
  });

  test('Multiple mode: initializes with empty array (no selections)', async function (assert) {
    // Initialize with empty array BEFORE first render
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
          @items={{items}}
          @selectedKeys={{selectedKeys.current}}
          @onSelectionChange={{onSelectionChange}}
          @placeholder="Select fruits"
        />
      </template>
    );

    // Verify onSelectionChange was NOT called during initialization
    assert.equal(
      callCount,
      0,
      'onSelectionChange should not be called during initialization with empty array'
    );

    // Verify trigger shows placeholder
    assert
      .dom('[data-component="select-trigger"]')
      .hasText(
        'Select fruits',
        'trigger should display placeholder when empty'
      );

    // Open listbox and verify no items are selected
    await click('[data-component="select-trigger"]');
    assert
      .dom('[data-component="listbox"] [data-key="Apple"]')
      .hasAttribute('data-selected', 'false', 'Apple should not be selected');
    assert
      .dom('[data-component="listbox"] [data-key="Banana"]')
      .hasAttribute('data-selected', 'false', 'Banana should not be selected');
    assert
      .dom('[data-component="listbox"] [data-key="Cherry"]')
      .hasAttribute('data-selected', 'false', 'Cherry should not be selected');

    // Verify callback still not called
    assert.equal(
      callCount,
      0,
      'onSelectionChange should still not be called after opening listbox'
    );
  });

  test('Edge case: initializes with undefined @selectedKey (not passed)', async function (assert) {
    // Don't pass @selectedKey at all (simulates uncontrolled component)
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

    // Verify component renders without errors
    assert
      .dom('[data-component="select-trigger"]')
      .exists('component should render without @selectedKey');

    // Verify onSelectionChange was NOT called during initialization
    assert.equal(
      callCount,
      0,
      'onSelectionChange should not be called during initialization without @selectedKey'
    );

    // Verify trigger shows placeholder
    assert
      .dom('[data-component="select-trigger"]')
      .hasText(
        'Select an item',
        'trigger should show placeholder when @selectedKey undefined'
      );

    // Verify native select has no selection
    isNotSelected(assert, '[data-key="item-1"]');
    isNotSelected(assert, '[data-key="item-2"]');
    isNotSelected(assert, '[data-key="item-3"]');

    // Open listbox and verify no items are selected
    await click('[data-component="select-trigger"]');
    assert
      .dom('[data-component="listbox"] [data-key="item-1"]')
      .hasAttribute('data-selected', 'false', 'item-1 should not be selected');
    assert
      .dom('[data-component="listbox"] [data-key="item-2"]')
      .hasAttribute('data-selected', 'false', 'item-2 should not be selected');
    assert
      .dom('[data-component="listbox"] [data-key="item-3"]')
      .hasAttribute('data-selected', 'false', 'item-3 should not be selected');

    // Verify component works - user can select an item
    await click('[data-component="listbox"] [data-key="item-2"]');
    assert.equal(
      callCount,
      1,
      'callback should be called after user selection'
    );
    assert.equal(
      lastSelectedKey,
      'item-2',
      'callback should receive correct key'
    );

    // Verify UI updates (component manages its own internal state)
    assert
      .dom('[data-component="select-trigger"]')
      .hasText('Item 2', 'trigger should show selected item');
  });

  test('Multiple mode: external state + user interactions work together via onSelectionChange', async function (assert) {
    const selectedKeys = cell<string[]>([]);
    let callCount = 0;
    let lastCallbackValue: string[] | null = null;

    const onSelectionChange = (keys: string[]) => {
      callCount++;
      lastCallbackValue = keys;
      selectedKeys.current = keys; // Update parent state
    };

    const items = ['Apple', 'Banana', 'Cherry', 'Date'];

    await render(
      <template>
        <Select
          @selectionMode="multiple"
          @items={{items}}
          @selectedKeys={{selectedKeys.current}}
          @onSelectionChange={{onSelectionChange}}
          @placeholder="Select fruits"
        />
      </template>
    );

    // Initial state - no selections, callback not called yet
    assert.equal(
      callCount,
      0,
      'onSelectionChange should not be called initially'
    );
    assert.equal(
      selectedKeys.current.length,
      0,
      'should start with no selections'
    );
    assert
      .dom('[data-component="select-trigger"]')
      .hasText('Select fruits', 'should show placeholder');

    // Set external state to ['Apple', 'Cherry']
    selectedKeys.current = ['Apple', 'Cherry'];
    await render(
      <template>
        <Select
          @selectionMode="multiple"
          @items={{items}}
          @selectedKeys={{selectedKeys.current}}
          @onSelectionChange={{onSelectionChange}}
          @placeholder="Select fruits"
        />
      </template>
    );

    // Verify external state update did NOT trigger callback
    assert.equal(
      callCount,
      0,
      'onSelectionChange should NOT be called when @selectedKeys changes externally'
    );
    assert
      .dom('[data-component="select-trigger"]')
      .hasText('Apple, Cherry', 'should show externally set selections');

    // Open listbox and verify external selections are shown
    await click('[data-component="select-trigger"]');
    assert
      .dom('[data-component="listbox"] [data-key="Apple"]')
      .hasAttribute('data-selected', 'true', 'Apple should be selected');
    assert
      .dom('[data-component="listbox"] [data-key="Banana"]')
      .hasAttribute('data-selected', 'false', 'Banana should not be selected');
    assert
      .dom('[data-component="listbox"] [data-key="Cherry"]')
      .hasAttribute('data-selected', 'true', 'Cherry should be selected');
    assert
      .dom('[data-component="listbox"] [data-key="Date"]')
      .hasAttribute('data-selected', 'false', 'Date should not be selected');

    // User clicks Banana (adding to selection)
    await click('[data-component="listbox"] [data-key="Banana"]');

    // Verify callback WAS called with correct value
    assert.equal(
      callCount,
      1,
      'onSelectionChange should be called once after user clicks'
    );
    assert.deepEqual(
      lastCallbackValue,
      ['Apple', 'Cherry', 'Banana'],
      'callback should receive updated array with Banana added'
    );
    assert.deepEqual(
      selectedKeys.current,
      ['Apple', 'Cherry', 'Banana'],
      'parent state should be updated'
    );

    // Verify UI updated
    assert
      .dom('[data-component="listbox"] [data-key="Banana"]')
      .hasAttribute('data-selected', 'true', 'Banana should now be selected');
    assert
      .dom('[data-component="select-trigger"]')
      .hasText('Apple, Banana, Cherry', 'trigger should show all selections');

    // User clicks Cherry (removing from selection)
    await click('[data-component="listbox"] [data-key="Cherry"]');

    // Verify callback called again with correct value
    assert.equal(
      callCount,
      2,
      'onSelectionChange should be called again after second click'
    );
    assert.deepEqual(
      lastCallbackValue,
      ['Apple', 'Banana'],
      'callback should receive array with Cherry removed'
    );
    assert.deepEqual(
      selectedKeys.current,
      ['Apple', 'Banana'],
      'parent state should reflect removal'
    );

    // Verify UI updated
    assert
      .dom('[data-component="listbox"] [data-key="Cherry"]')
      .hasAttribute(
        'data-selected',
        'false',
        'Cherry should now be unselected'
      );
    assert
      .dom('[data-component="select-trigger"]')
      .hasText('Apple, Banana', 'trigger should show remaining selections');

    // User clicks Date (adding to selection)
    await click('[data-component="listbox"] [data-key="Date"]');

    assert.equal(callCount, 3, 'onSelectionChange should be called third time');
    assert.deepEqual(
      lastCallbackValue,
      ['Apple', 'Banana', 'Date'],
      'callback should receive array with Date added'
    );
    assert
      .dom('[data-component="select-trigger"]')
      .hasText(
        'Apple, Banana, Date',
        'trigger should show all three selections'
      );

    // Close and verify listbox can be reopened with correct state
    await click('[data-component="select-trigger"]');
    assert
      .dom('[data-component="listbox"]')
      .doesNotExist('listbox should close');

    await click('[data-component="select-trigger"]');
    assert
      .dom('[data-component="listbox"] [data-key="Apple"]')
      .hasAttribute(
        'data-selected',
        'true',
        'Apple still selected after reopen'
      );
    assert
      .dom('[data-component="listbox"] [data-key="Banana"]')
      .hasAttribute(
        'data-selected',
        'true',
        'Banana still selected after reopen'
      );
    assert
      .dom('[data-component="listbox"] [data-key="Cherry"]')
      .hasAttribute(
        'data-selected',
        'false',
        'Cherry still unselected after reopen'
      );
    assert
      .dom('[data-component="listbox"] [data-key="Date"]')
      .hasAttribute(
        'data-selected',
        'true',
        'Date still selected after reopen'
      );

    // Final verification: callback was only called for user interactions, not external updates
    assert.equal(
      callCount,
      3,
      'onSelectionChange should only have been called 3 times (once per user click)'
    );
  });
});
