import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render } from '@ember/test-helpers';
import { selectOptionByKey, toggleOptionByKey } from 'frontile/test-support';
import { cell } from 'ember-resources';
import { NativeSelect } from 'frontile';
import { array } from '@ember/helper';
import { settled } from '@ember/test-helpers';

const eq = (a: unknown, b: unknown) => a === b;

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
      const selectedKey = cell<string | null>(null);
      const onSelectionChange = (key: string | null) => {
        selectedKey.current = key;
      };

      await render(
        <template>
          <NativeSelect
            @onSelectionChange={{onSelectionChange}}
            @selectedKey={{selectedKey.current}}
            @disabledKeys={{(array "item-3" "item-4")}}
            @allowEmpty={{true}}
            as |l|
          >
            <l.Item @key="item-1">
              Item 1
            </l.Item>
            <l.Item @key="item-2">Item 2</l.Item>
            <l.Item @key="item-3">Item 3</l.Item>
            <l.Item @key="item-4">Item 4</l.Item>
            <l.Item @key="item-5">
              Item 5
            </l.Item>
          </NativeSelect>
        </template>
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

      await selectOptionByKey('[data-test-id="native-select"]', 'item-2');

      assert.equal(selectedKey.current, 'item-2');
      isSelected(assert, '[data-key="item-2"]');
    });

    test('it render dynamic items without yield of item selectionMode = single / multiple', async function (assert) {
      const selectionMode = cell<'single' | 'multiple'>('single');
      const allowEmpty = cell(false);
      const animals = ['cheetah', 'crocodile', 'elephant'];
      const selectedKey = cell<string | null>(null);
      const selectedKeys = cell<string[]>([]);
      const onSingleSelectionChange = (key: string | null) => {
        selectedKey.current = key;
      };
      const onMultipleSelectionChange = (keys: string[]) => {
        selectedKeys.current = keys;
      };

      await render(
        <template>
          {{#if (eq selectionMode.current "single")}}
            <NativeSelect
              @allowEmpty={{allowEmpty.current}}
              @selectionMode="single"
              @items={{animals}}
              @selectedKey={{selectedKey.current}}
              @onSelectionChange={{onSingleSelectionChange}}
            />
          {{else}}
            <NativeSelect
              @allowEmpty={{allowEmpty.current}}
              @selectionMode="multiple"
              @items={{animals}}
              @selectedKeys={{selectedKeys.current}}
              @onSelectionChange={{onMultipleSelectionChange}}
            />
          {{/if}}
        </template>
      );

      assert.dom('[data-test-id="native-select"]').exists();

      assert.dom('[data-key="cheetah"]').exists();
      assert.dom('[data-key="crocodile"]').exists();
      assert.dom('[data-key="elephant"]').exists();

      // Selection Mode single
      await selectOptionByKey('[data-test-id="native-select"]', 'cheetah');

      assert.equal(selectedKey.current, 'cheetah');

      await selectOptionByKey('[data-test-id="native-select"]', 'crocodile');
      assert.equal(selectedKey.current, 'crocodile');

      // Slect empty option when allowEmpty = true
      allowEmpty.current = true;
      await settled();
      await selectOptionByKey('[data-test-id="native-select"]', '');
      assert.equal(selectedKey.current, null);

      // Selection Mode multiple
      selectionMode.current = 'multiple';
      selectedKeys.current = [];
      selectedKey.current = null;
      await settled();

      await selectOptionByKey('[data-test-id="native-select"]', 'elephant');

      assert.equal(selectedKeys.current.length, 1);
      assert.equal(selectedKeys.current[0], 'elephant');

      await selectOptionByKey('[data-test-id="native-select"]', 'crocodile');
      assert.equal(selectedKeys.current.length, 2);

      assert.ok(selectedKeys.current.includes('elephant'));
      assert.ok(selectedKeys.current.includes('crocodile'));

      await toggleOptionByKey('[data-test-id="native-select"]', 'crocodile');

      assert.equal(selectedKeys.current.length, 1);
      assert.equal(selectedKeys.current[0], 'elephant');

      await toggleOptionByKey('[data-test-id="native-select"]', 'elephant');

      assert.equal(selectedKeys.current.length, 0);
    });

    test('it render dynamic items yielding of item', async function (assert) {
      const animals = [
        { key: 'cheetah-key', value: 'cheetah-value' },
        { key: 'crocodile-key', value: 'crocodile-value' },
        { key: 'elephant-key', value: 'elephant-value' }
      ];

      const selectionMode = cell<'single' | 'multiple'>('single');
      const allowEmpty = cell(false);
      const selectedKey = cell<string | null>(null);

      const onSelectionChange = (key: string | null) => {
        selectedKey.current = key;
      };

      await render(
        <template>
          <NativeSelect
            @allowEmpty={{allowEmpty.current}}
            @selectionMode={{selectionMode.current}}
            @items={{animals}}
            @selectedKey={{selectedKey.current}}
            @onSelectionChange={{onSelectionChange}}
          >
            <:item as |o|>
              <o.Item @key={{o.item.key}}>
                {{o.item.value}}
              </o.Item>
            </:item>
          </NativeSelect>
        </template>
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
      const animals = ['tiger'];
      await render(
        <template>
          <NativeSelect
            @items={{animals}}
            @placeholder="Select an animal"
            @classes={{classes}}
          >
            <:startContent>Start</:startContent>
            <:endContent>End</:endContent>
          </NativeSelect>
        </template>
      );

      assert.dom('.input-container div:first-child').exists();
      assert.dom('.input-container div:first-child').hasTextContaining('Start');

      assert.dom('.input-container div:last-child').exists();
      assert.dom('.input-container div:last-child').hasTextContaining('End');
    });
  }
);
