import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, triggerEvent } from '@ember/test-helpers';
import hbs from 'htmlbars-inline-precompile';

function selectNativeOptionByKey(
  selectSelector: string,
  key: string
): Promise<void> {
  return changeOption('selectNativeOptionByKey', selectSelector, key, false);
}

function toggleNativeOptionByKey(
  selectSelector: string,
  key: string
): Promise<void> {
  return changeOption('toggleNativeOptionByKey', selectSelector, key, true);
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

module(
  'Integration | Component | NativeSelect | @frontile/forms',
  function (hooks) {
    setupRenderingTest(hooks);

    const isSelected = (
      assert: { ok: (val: boolean, mes: string) => void },
      queryString: string
    ): void => {
      const option = document.querySelector(queryString);
      const isSelected = option && (option as HTMLOptionElement).selected;
      assert.ok(!!isSelected, `Expected ${queryString} to be selected`);
    };

    const isNotSelected = (
      assert: { ok: (val: boolean, mes: string) => void },
      queryString: string
    ): void => {
      const option = document.querySelector(queryString);
      const isSelected = option && (option as HTMLOptionElement).selected;
      assert.ok(!isSelected, `Expected ${queryString} to not be selected`);
    };

    test('it render static items', async function (assert) {
      let selectedKeys: string[] = [];
      this.set('onSelectionChange', function (keys: string[]) {
        selectedKeys = keys;
      });

      await render(
        hbs`
          <NativeSelect
            @onSelectionChange={{this.onSelectionChange}}
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
          </NativeSelect>`
      );

      assert.dom('[data-test-id="native-select"]').exists();
      assert.dom('[data-key="item-1"]').exists();
      assert.dom('[data-key="item-2"]').exists();
      assert.dom('[data-key="item-3"]').exists();
      assert.dom('[data-key="item-4"]').exists();
      assert.dom('[data-key="item-5"]').exists();

      assert.dom('[data-key="item-3"]').hasAttribute('disabled');
      assert.dom('[data-key="item-4"]').hasAttribute('disabled');

      assert.dom('[data-key="item-1"]').containsText('Item 1');
      assert.dom('[data-key="item-2"]').containsText('Item 2');
      assert.dom('[data-key="item-3"]').containsText('Item 3');
      assert.dom('[data-key="item-4"]').containsText('Item 4');
      assert.dom('[data-key="item-5"]').containsText('Item 5');

      isNotSelected(assert, '[data-key="item-2"]');

      await selectNativeOptionByKey('[data-test-id="native-select"]', 'item-2');

      assert.deepEqual(selectedKeys, ['item-2']);
      isSelected(assert, '[data-key="item-2"]');
    });

    test('it render dynamic items without yield of item selectionMode = single / multiple', async function (assert) {
      this.set('selectionMode', 'single');
      this.set('allowEmpty', false);
      this.set('animals', ['cheetah', 'crocodile', 'elephant']);
      let selectedKeys: string[] = [];

      this.set('selectedKeys', []);
      this.set('onSelectionChange', (keys: string[]) => {
        this.set('selectedKeys', keys);
        selectedKeys = keys;
      });

      await render(
        hbs`
        <NativeSelect
          @allowEmpty={{this.allowEmpty}}
          @selectionMode={{this.selectionMode}}
          @items={{this.animals}}
          @selectedKeys={{this.selectedKeys}}
          @onSelectionChange={{this.onSelectionChange}}
        />`
      );

      assert.dom('[data-test-id="native-select"]').exists();

      assert.dom('[data-key="cheetah"]').exists();
      assert.dom('[data-key="crocodile"]').exists();
      assert.dom('[data-key="elephant"]').exists();

      // Selection Mode single
      await selectNativeOptionByKey(
        '[data-test-id="native-select"]',
        'cheetah'
      );

      assert.equal(selectedKeys.length, 1);
      assert.equal(selectedKeys[0], 'cheetah');

      await selectNativeOptionByKey(
        '[data-test-id="native-select"]',
        'crocodile'
      );
      assert.equal(selectedKeys.length, 1);
      assert.equal(selectedKeys[0], 'crocodile');

      // Slect empty option when  allowEmpty = true
      this.set('allowEmpty', true);
      await selectNativeOptionByKey('[data-test-id="native-select"]', '');
      assert.equal(selectedKeys.length, 0);

      // Selection Mode multiple
      this.set('selectionMode', 'multiple');
      this.set('selectedKeys', []);
      selectedKeys = [];

      await selectNativeOptionByKey(
        '[data-test-id="native-select"]',
        'elephant'
      );

      assert.equal(selectedKeys.length, 1);
      assert.equal(selectedKeys[0], 'elephant');

      await selectNativeOptionByKey(
        '[data-test-id="native-select"]',
        'crocodile'
      );
      assert.equal(selectedKeys.length, 2);

      assert.ok(selectedKeys.includes('elephant'));
      assert.ok(selectedKeys.includes('crocodile'));

      await toggleNativeOptionByKey(
        '[data-test-id="native-select"]',
        'crocodile'
      );

      assert.equal(selectedKeys.length, 1);
      assert.equal(selectedKeys[0], 'elephant');

      await toggleNativeOptionByKey(
        '[data-test-id="native-select"]',
        'elephant'
      );

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
        <NativeSelect
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
        </NativeSelect>`
      );

      assert.dom('[data-test-id="native-select"]').exists();

      assert.dom('[data-key="cheetah-key"]').exists();
      assert.dom('[data-key="crocodile-key"]').exists();
      assert.dom('[data-key="elephant-key"]').exists();

      assert.dom('[data-key="cheetah-key"]').containsText('cheetah-value');
      assert.dom('[data-key="crocodile-key"]').containsText('crocodile-value');
      assert.dom('[data-key="elephant-key"]').containsText('elephant-value');
    });

    test('it renders named blocks startContent and endContent', async function (assert) {
      const classes = { innerContainer: 'input-container' };
      this.set('animals', ['tiger']);
      this.set('classes', classes);
      await render(
        hbs`
        <NativeSelect
          @items={{this.animals}}
          @placeholder="Select an animal"
          @classes={{this.classes}}
        >
          <:startContent>Start</:startContent>
          <:endContent>End</:endContent>
      </NativeSelect>`
      );

      assert.dom('.input-container div:first-child').exists();
      assert.dom('.input-container div:first-child').hasTextContaining('Start');

      assert.dom('.input-container div:last-child').exists();
      assert.dom('.input-container div:last-child').hasTextContaining('End');
    });
  }
);
