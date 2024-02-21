import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import {
  click,
  render,
  triggerEvent,
  triggerKeyEvent
} from '@ember/test-helpers';
import hbs from 'htmlbars-inline-precompile';

function selectNativeOptionByKey(
  selectSelector: string,
  key: string
): Promise<void> {
  return changeOption('selectNativeOptionByKey', selectSelector, key, false);
}

function changeOption(
  functionName: string,
  selectSelector: string,
  key: string,
  toggle: boolean
): Promise<void> {
  const select = document.querySelector(selectSelector);
  if (!select) {
    throw new Error(
      `You called "${functionName}('${selectSelector}', '${key}')" but no select was found using selector "${selectSelector}"`
    );
  }
  const option = select.querySelector(`[data-key="${key}"]`) as
    | HTMLOptionElement
    | undefined;
  if (!option) {
    throw new Error(
      `You called "${functionName}('${selectSelector}', '${key}')" but no option with key "${key}" was found`
    );
  }
  if (option.selected && toggle) {
    option.selected = false;
  } else {
    option.selected = true;
  }
  return triggerEvent(select, 'change');
}

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

  test('it render static items in NativeSelect and Listbox', async function (assert) {
    let selectedKeys: string[] = [];
    this.set('selectedKeys', []);
    this.set('onSelectionChange', (keys: string[]) => {
      selectedKeys = keys;
      this.set('selectedKeys', keys);
    });

    await render(
      hbs`
          <div id="my-destination"></div>
          <Select
            @destinationElementId="my-destination"
            @onSelectionChange={{this.onSelectionChange}}
            @selectedKeys={{this.selectedKeys}}
            @disabledKeys={{(array "item-3" "item-4")}}
            @allowEmpty={{true}}
            as |l|
          >
            <l.Item
              @key="item-1"
            >
              Item 1
            </l.Item>
            <l.Item @key="item-2">Item 2</l.Item>
            <l.Item @key="item-3">Item 3</l.Item>
            <l.Item @key="item-4">Item 4</l.Item>
            <l.Item @key="item-5">
              Item 5
            </l.Item>
          </Select>`
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

    await selectNativeOptionByKey('[data-component="native-select"]', 'item-2');

    assert.deepEqual(selectedKeys, ['item-2']);
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
    this.set('selectionMode', 'single');
    this.set('animals', ['cheetah', 'crocodile', 'elephant']);
    let selectedKeys: string[] = [];

    this.set('selectedKeys', []);
    this.set('onSelectionChange', (keys: string[]) => {
      this.set('selectedKeys', keys);
      selectedKeys = keys;
    });

    await render(
      hbs`
        <div id="my-destination"></div>
        <Select
          @destinationElementId="my-destination"
          @allowEmpty={{true}}
          @selectionMode={{this.selectionMode}}
          @items={{this.animals}}
          @selectedKeys={{this.selectedKeys}}
          @onSelectionChange={{this.onSelectionChange}}
        />`
    );

    await click('[data-component="select-trigger"]');
    assert.dom('[data-component="listbox"]').exists();

    assert.dom('[data-component="listbox"] [data-key="cheetah"]').exists();
    assert.dom('[data-component="listbox"] [data-key="crocodile"]').exists();
    assert.dom('[data-component="listbox"] [data-key="elephant"]').exists();

    // Selection Mode single
    await click('[data-component="listbox"] [data-key="cheetah"]');
    assert.equal(selectedKeys.length, 1);
    assert.equal(selectedKeys[0], 'cheetah');
    assert.dom('[data-component="listbox"]').doesNotExist('should have closed');

    await click('[data-component="select-trigger"]');
    await click('[data-component="listbox"] [data-key="crocodile"]');
    assert.equal(selectedKeys.length, 1);
    assert.equal(selectedKeys[0], 'crocodile');
    assert.dom('[data-component="listbox"]').doesNotExist('should have closed');

    // Selection Mode multiple
    this.set('selectionMode', 'multiple');
    this.set('selectedKeys', []);
    selectedKeys = [];

    await click('[data-component="select-trigger"]');
    await click('[data-component="listbox"] [data-key="elephant"]');
    assert.dom('[data-component="listbox"]').exists('should not have closed');

    assert.equal(selectedKeys.length, 1);
    assert.equal(selectedKeys[0], 'elephant');

    await click('[data-component="listbox"] [data-key="crocodile"]');
    assert.equal(selectedKeys.length, 2);

    assert.ok(selectedKeys.includes('elephant'));
    assert.ok(selectedKeys.includes('crocodile'));

    // toggle
    await click('[data-component="listbox"] [data-key="crocodile"]');

    assert.equal(selectedKeys.length, 1);
    assert.equal(selectedKeys[0], 'elephant');

    await click('[data-component="listbox"] [data-key="elephant"]');

    assert.equal(selectedKeys.length, 0);
  });

  test('it render dynamic items yielding of item', async function (assert) {
    this.set('selectionMode', 'single');
    this.set('allowEmpty', false);
    this.set('animals', [
      { key: 'cheetah-key', value: 'cheetah-value' },
      { key: 'crocodile-key', value: 'crocodile-value' },
      { key: 'elephant-key', value: 'elephant-value' }
    ]);

    this.set('selectedKeys', []);
    this.set('onSelectionChange', (keys: string[]) => {
      this.set('selectedKeys', keys);
    });

    await render(
      hbs`
        <div id="my-destination"></div>
        <Select
          @destinationElementId="my-destination"
          @allowEmpty={{this.allowEmpty}}
          @selectionMode={{this.selectionMode}}
          @items={{this.animals}}
          @selectedKeys={{this.selectedKeys}}
          @onSelectionChange={{this.onSelectionChange}}
        >
          <:item as |o|>
            <o.Item @key={{o.item.key}}>
              {{o.item.value}}
            </o.Item>
          </:item>
        </Select>`
    );

    assert.dom('[data-test-id="native-select"]').exists();

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
    let selectedKeys: string[] = [];
    this.set('selectedKeys', []);
    this.set('onSelectionChange', (keys: string[]) => {
      selectedKeys = keys;
      this.set('selectedKeys', keys);
    });

    await render(
      hbs`
          <div id="my-destination"></div>
          <Select
            @destinationElementId="my-destination"
            @onSelectionChange={{this.onSelectionChange}}
            @selectedKeys={{this.selectedKeys}}
            @disabledKeys={{(array "item-3" "item-4")}}
            @allowEmpty={{true}}
            as |l|
          >
            <l.Item
              @key="item-1"
            >
              Item 1
            </l.Item>
            <l.Item @key="item-2">Item 2</l.Item>
            <l.Item @key="item-3">Item 3</l.Item>
            <l.Item @key="item-4">Item 4</l.Item>
            <l.Item @key="item-5">
              Item 5
            </l.Item>
          </Select>`
    );

    // Check Listbox
    await click('[data-component="select-trigger"]');

    assert.dom('[data-component="listbox"]').exists();
    assert.dom('[data-component="listbox"] [data-key="item-1"]').exists();
    assert.dom('[data-component="listbox"] [data-key="item-2"]').exists();
    assert.dom('[data-component="listbox"] [data-key="item-3"]').exists();
    assert.dom('[data-component="listbox"] [data-key="item-4"]').exists();
    assert.dom('[data-component="listbox"] [data-key="item-5"]').exists();

    await triggerKeyEvent('[data-component="listbox"]', 'keyup', 'ArrowDown');
    assert.dom('[data-key="item-1"]').hasAttribute('data-active', 'true');

    await triggerKeyEvent('[data-component="listbox"]', 'keyup', 'ArrowDown');
    assert.dom('[data-key="item-1"]').hasAttribute('data-active', 'false');
    assert.dom('[data-key="item-2"]').hasAttribute('data-active', 'true');

    await triggerKeyEvent('[data-component="listbox"]', 'keyup', 'ArrowUp');
    assert.dom('[data-key="item-1"]').hasAttribute('data-active', 'true');
    assert.dom('[data-key="item-2"]').hasAttribute('data-active', 'false');

    await triggerKeyEvent('[data-component="listbox"]', 'keyup', 'ArrowDown');
    await triggerKeyEvent('[data-component="listbox"]', 'keypress', 'Enter');
    assert.dom('[data-component="listbox"]').doesNotExist();

    assert.equal(selectedKeys.length, 1);
    assert.equal(selectedKeys[0], 'item-2');
  });
});
