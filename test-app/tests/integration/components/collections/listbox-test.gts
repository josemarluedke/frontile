import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { click, render, triggerKeyEvent, fillIn } from '@ember/test-helpers';
import { registerCustomStyles } from '@frontile/theme';
import { tv } from 'tailwind-variants';
import { modifier } from 'ember-modifier';
import { Listbox, type ListboxSignature } from '@frontile/collections';
import { array } from '@ember/helper';
import { cell } from 'ember-resources';
import { settled } from '@ember/test-helpers';

module(
  'Integration | Component | Listbox | @frontile/collections',
  function (hooks) {
    setupRenderingTest(hooks);

    test('it render static items', async function (assert) {
      const clickedOn: string[] = [];
      const onAction = (key: string) => {
        clickedOn.push(key);
      };

      await render(
        <template>
          <Listbox
            @selectionMode="none"
            @onAction={{onAction}}
            @disabledKeys={{array "item-3" "item-4"}}
            as |l|
          >
            <l.Item
              @key="item-1"
              @shortcut="⌘⇧E"
              @description="The description of the item"
              @intent="warning"
              @appearance="faded"
            >
              <:default>
                Item 1
              </:default>
            </l.Item>
            <l.Item @key="item-2" @shortcut="⌘⇧C">Item 2</l.Item>
            <l.Item @key="item-3">Item 3</l.Item>
            <l.Item @key="item-4" @withDivider={{true}}>Item 4</l.Item>
            <l.Item
              @key="item-5"
              @shortcut="⌘⇧B"
              @intent="danger"
              @appearance="faded"
              @class="text-danger"
            >
              Item 5
            </l.Item>
          </Listbox>
        </template>
      );

      assert.dom('[data-test-id="listbox"]').exists();
      assert.dom('[data-key="item-1"]').exists();
      assert
        .dom('[data-key="item-1"] [data-test-id="listbox-item-description"]')
        .exists();

      assert.dom('[data-key="item-2"]').exists();
      assert
        .dom('[data-key="item-2"] [data-test-id="listbox-item-shortcut"]')
        .exists();
      assert.dom('[data-key="item-3"]').exists();
      assert.dom('[data-key="item-4"]').exists();
      assert
        .dom('[data-key="item-4"] + [data-test-id="divider"]')
        .exists('divider should be sibling of item 4');
      assert.dom('[data-key="item-5"]').exists();

      assert.dom('[data-key="item-3"]').hasAttribute('disabled');
      assert.dom('[data-key="item-4"]').hasAttribute('disabled');

      assert.dom('[data-key="item-1"]').containsText('Item 1');
      assert.dom('[data-key="item-2"]').containsText('Item 2');
      assert.dom('[data-key="item-3"]').containsText('Item 3');
      assert.dom('[data-key="item-4"]').containsText('Item 4');
      assert.dom('[data-key="item-5"]').containsText('Item 5');

      assert.dom('[data-key="item-1"]').hasAttribute('data-selected', 'false');
      assert.dom('[data-key="item-2"]').hasAttribute('data-selected', 'false');

      await click('[data-key="item-2"]');
      await click('[data-key="item-1"]');
      await click('[data-key="item-3"]');

      assert.deepEqual(clickedOn, ['item-2', 'item-1']);

      // should be not selected because selectionMode is none
      assert.dom('[data-key="item-1"]').hasAttribute('data-selected', 'false');
      assert.dom('[data-key="item-2"]').hasAttribute('data-selected', 'false');
    });

    test('it render dynamic items without yield of item selectionMode = single / multiple', async function (assert) {
      const selectionMode = cell<'single' | 'multiple' | 'none'>('single');
      const allowEmpty = cell(false);
      const animals = ['cheetah', 'crocodile', 'elephant'];
      const selectedKeys = cell<string[]>([]);

      const onSelectionChange = (keys: string[]) => {
        selectedKeys.current = keys;
      };

      await render(
        <template>
          <Listbox
            @allowEmpty={{allowEmpty.current}}
            @selectionMode={{selectionMode.current}}
            @items={{animals}}
            @selectedKeys={{selectedKeys.current}}
            @onSelectionChange={{onSelectionChange}}
          />
        </template>
      );

      assert.dom('[data-test-id="listbox"]').exists();

      assert.dom('[data-key="cheetah"]').exists();
      assert.dom('[data-key="crocodile"]').exists();
      assert.dom('[data-key="elephant"]').exists();

      // Selection Mode single
      await click('[data-key="cheetah"]');

      assert.equal(selectedKeys.current.length, 1);
      assert.equal(selectedKeys.current[0], 'cheetah');
      assert.dom('[data-key="cheetah"]').hasAttribute('data-selected', 'true');
      assert
        .dom('[data-key="cheetah"] [data-test-id="listbox-item-selected-icon"]')
        .exists('should render icon on selected item');

      await click('[data-key="crocodile"]');
      assert.equal(selectedKeys.current.length, 1);
      assert.equal(selectedKeys.current[0], 'crocodile');
      assert
        .dom('[data-key="crocodile"]')
        .hasAttribute('data-selected', 'true');
      assert.dom('[data-key="cheetah"]').hasAttribute('data-selected', 'false');

      // Toggle when allowEmpty = false
      await click('[data-key="crocodile"]');
      assert.equal(selectedKeys.current.length, 1);
      assert.equal(selectedKeys.current[0], 'crocodile');

      // Toggle when allowEmpty = true
      allowEmpty.current = true;
      await settled();
      await click('[data-key="crocodile"]');
      assert.equal(selectedKeys.current.length, 0);

      // Selection Mode multiple
      selectionMode.current = 'multiple';
      selectedKeys.current = [];
      selectedKeys.current = [];
      await settled();

      await click('[data-key="elephant"]');

      assert.equal(selectedKeys.current.length, 1);
      assert.equal(selectedKeys.current[0], 'elephant');
      assert.dom('[data-key="elephant"]').hasAttribute('data-selected', 'true');

      await click('[data-key="crocodile"]');
      assert.equal(selectedKeys.current.length, 2);
      assert.equal(selectedKeys.current[1], 'crocodile');
      assert.dom('[data-key="elephant"]').hasAttribute('data-selected', 'true');
      assert
        .dom('[data-key="crocodile"]')
        .hasAttribute('data-selected', 'true');

      // Toggle when allowEmpty = false
      allowEmpty.current = false;
      await settled();
      await click('[data-key="crocodile"]');
      assert.equal(selectedKeys.current.length, 1);
      assert.equal(selectedKeys.current[0], 'elephant');
      assert.dom('[data-key="elephant"]').hasAttribute('data-selected', 'true');
      assert
        .dom('[data-key="crocodile"]')
        .hasAttribute('data-selected', 'false');

      await click('[data-key="elephant"]');
      assert.equal(selectedKeys.current.length, 1);
      assert.equal(selectedKeys.current[0], 'elephant');
      assert.dom('[data-key="elephant"]').hasAttribute('data-selected', 'true');

      // Toggle when allowEmpty = true
      allowEmpty.current = true;
      await settled();
      await click('[data-key="elephant"]');
      assert.equal(selectedKeys.current.length, 0);
    });

    test('it render dynamic items yielding of item', async function (assert) {
      const animals = [
        { key: 'cheetah-key', value: 'cheetah-value' },
        { key: 'crocodile-key', value: 'crocodile-value' },
        { key: 'elephant-key', value: 'elephant-value' }
      ];

      const selectionMode = cell<'single' | 'multiple' | 'none'>('single');
      const allowEmpty = cell(false);
      const selectedKeys = cell<string[]>([]);

      const onSelectionChange = (keys: string[]) => {
        selectedKeys.current = keys;
      };

      await render(
        <template>
          <Listbox
            @allowEmpty={{allowEmpty.current}}
            @selectionMode={{selectionMode.current}}
            @items={{animals}}
            @selectedKeys={{selectedKeys.current}}
            @onSelectionChange={{onSelectionChange}}
          >
            <:item as |o|>
              <o.Item @key={{o.item.key}}>
                {{o.item.value}}
              </o.Item>
            </:item>
          </Listbox>
        </template>
      );

      assert.dom('[data-test-id="listbox"]').exists();

      assert.dom('[data-key="cheetah-key"]').exists();
      assert.dom('[data-key="crocodile-key"]').exists();
      assert.dom('[data-key="elephant-key"]').exists();

      assert.dom('[data-key="cheetah-key"]').containsText('cheetah-value');
      assert.dom('[data-key="crocodile-key"]').containsText('crocodile-value');
      assert.dom('[data-key="elephant-key"]').containsText('elephant-value');
    });

    test('keyboard navigation works', async function (assert) {
      const animals = ['cheetah', 'crocodile', 'elephant'];

      const selectionMode = cell<'single' | 'multiple' | 'none'>('single');
      const allowEmpty = cell(false);
      const selectedKeys = cell<string[]>([]);

      const onSelectionChange = (keys: string[]) => {
        selectedKeys.current = keys;
      };

      await render(
        <template>
          <Listbox
            @isKeyboardEventsEnabled={{true}}
            @allowEmpty={{allowEmpty.current}}
            @selectionMode={{selectionMode.current}}
            @items={{animals}}
            @selectedKeys={{selectedKeys.current}}
            @onSelectionChange={{onSelectionChange}}
            @autoActivateMode="none"
          />
        </template>
      );

      assert.dom('[data-test-id="listbox"]').exists();

      assert.dom('[data-key="cheetah"]').exists();
      assert.dom('[data-key="crocodile"]').exists();
      assert.dom('[data-key="elephant"]').exists();

      // ArrowDown & ArrowUp navigation
      assert.dom('[data-key="cheetah"]').hasAttribute('data-active', 'false');
      await triggerKeyEvent('[data-test-id="listbox"]', 'keydown', 'ArrowDown');
      assert.dom('[data-key="cheetah"]').hasAttribute('data-active', 'true');

      await triggerKeyEvent('[data-test-id="listbox"]', 'keydown', 'ArrowDown');
      assert.dom('[data-key="cheetah"]').hasAttribute('data-active', 'false');
      assert.dom('[data-key="crocodile"]').hasAttribute('data-active', 'true');

      await triggerKeyEvent('[data-test-id="listbox"]', 'keydown', 'ArrowUp');
      assert.dom('[data-key="cheetah"]').hasAttribute('data-active', 'true');
      assert.dom('[data-key="crocodile"]').hasAttribute('data-active', 'false');

      // PageDown & PageUp
      await triggerKeyEvent('[data-test-id="listbox"]', 'keydown', 'PageDown');
      assert.dom('[data-key="cheetah"]').hasAttribute('data-active', 'false');
      assert.dom('[data-key="crocodile"]').hasAttribute('data-active', 'false');
      assert.dom('[data-key="elephant"]').hasAttribute('data-active', 'true');

      await triggerKeyEvent('[data-test-id="listbox"]', 'keydown', 'PageUp');
      assert.dom('[data-key="cheetah"]').hasAttribute('data-active', 'true');
      assert.dom('[data-key="crocodile"]').hasAttribute('data-active', 'false');
      assert.dom('[data-key="elephant"]').hasAttribute('data-active', 'false');

      // select active item
      await triggerKeyEvent('[data-test-id="listbox"]', 'keypress', 'Enter');
      assert.equal(selectedKeys.current.length, 1);
      assert.equal(selectedKeys.current[0], 'cheetah');

      // search
      await triggerKeyEvent('[data-test-id="listbox"]', 'keypress', 'E');
      assert.dom('[data-key="cheetah"]').hasAttribute('data-active', 'false');
      assert.dom('[data-key="crocodile"]').hasAttribute('data-active', 'false');
      assert.dom('[data-key="elephant"]').hasAttribute('data-active', 'true');

      await triggerKeyEvent('[data-test-id="listbox"]', 'keypress', 'C');
      assert.dom('[data-key="cheetah"]').hasAttribute('data-active', 'true');
      assert.dom('[data-key="crocodile"]').hasAttribute('data-active', 'false');
      assert.dom('[data-key="elephant"]').hasAttribute('data-active', 'false');

      triggerKeyEvent('[data-test-id="listbox"]', 'keypress', 'C');
      await triggerKeyEvent('[data-test-id="listbox"]', 'keypress', 'R');

      assert.dom('[data-key="cheetah"]').hasAttribute('data-active', 'false');
      assert
        .dom('[data-key="crocodile"]')
        .hasAttribute(
          'data-active',
          'true',
          'should have selected crocodile due to two keypress'
        );
      assert.dom('[data-key="elephant"]').hasAttribute('data-active', 'false');
    });

    test('it render item with blocks', async function (assert) {
      const clickedOn: string[] = [];
      const onAction = (key: string) => {
        clickedOn.push(key);
      };

      await render(
        <template>
          <Listbox
            @selectionMode="none"
            @onAction={{onAction}}
            @disabledKeys={{array "item-3" "item-4"}}
            as |l|
          >
            <l.Item
              @key="item-1"
              @shortcut="⌘⇧E"
              @description="The description of the item"
              @intent="warning"
              @appearance="faded"
            >
              <:start>
                <div data-test-id="start">Start content</div>
              </:start>
              <:default>
                Item 1
              </:default>
              <:end>
                <div data-test-id="end">End content</div>
              </:end>
            </l.Item>
          </Listbox>
        </template>
      );

      assert.dom('[data-test-id="listbox"]').exists();
      assert.dom('[data-key="item-1"]').exists();
      assert
        .dom('[data-key="item-1"] [data-test-id="listbox-item-label"]')
        .exists();
      assert
        .dom('[data-key="item-1"] [data-test-id="listbox-item-label"]')
        .hasText('Item 1');

      assert.dom('[data-key="item-1"] [data-test-id="start"]').exists();
      assert
        .dom('[data-key="item-1"] [data-test-id="start"]')
        .hasText('Start content');
      assert.dom('[data-key="item-1"] [data-test-id="end"]').exists();
      assert
        .dom('[data-key="item-1"] [data-test-id="end"]')
        .hasText('End content');
    });

    test('automatically activate first item', async function (assert) {
      const animals = cell<string[]>(['cheetah', 'crocodile', 'elephant']);

      await render(
        <template>
          <Listbox @items={{animals.current}} @autoActivateMode="first" />
        </template>
      );
      assert.dom('[data-key="cheetah"]').hasAttribute('data-active', 'true');
      animals.current = ['crocodile', 'elephant'];
      await settled();

      assert.dom('[data-key="crocodile"]').hasAttribute('data-active', 'true');
    });

    test('it calls onActiveItemChange when a new item is activated', async function (assert) {
      const activeItems: string[] = [];
      const onActiveItemChange = (key?: string) => {
        activeItems.push(key || '');
      };
      const animals = ['cheetah', 'crocodile', 'elephant'];

      await render(
        <template>
          <Listbox
            @items={{animals}}
            @autoActivateMode="first"
            @isKeyboardEventsEnabled={{true}}
            @onActiveItemChange={{onActiveItemChange}}
          />
        </template>
      );

      assert.dom('[data-key="cheetah"]').hasAttribute('data-active', 'true');
      await triggerKeyEvent('[data-test-id="listbox"]', 'keydown', 'ArrowDown');
      await triggerKeyEvent('[data-test-id="listbox"]', 'keydown', 'ArrowDown');

      assert.deepEqual(activeItems, ['cheetah', 'crocodile', 'elephant']);
    });

    test('it adds keyboard events to element passed in args', async function (assert) {
      const elementToAddKeyboardEvents = cell<HTMLElement>(undefined);

      const myModifier = modifier((element: HTMLElement) => {
        elementToAddKeyboardEvents.current = element;
      });

      const animals = ['cheetah', 'crocodile', 'elephant'];

      await render(
        <template>
          <input type="text" data-test-input {{myModifier}} />
          <Listbox
            @items={{animals}}
            @autoActivateMode="none"
            @isKeyboardEventsEnabled={{true}}
            @elementToAddKeyboardEvents={{elementToAddKeyboardEvents.current}}
          />
        </template>
      );

      assert.dom('[data-key="cheetah"]').hasAttribute('data-active', 'false');
      await triggerKeyEvent('[data-test-input]', 'keydown', 'ArrowDown');
      assert.dom('[data-key="cheetah"]').hasAttribute('data-active', 'true');
      await triggerKeyEvent('[data-test-input]', 'keypress', 'E');
      assert.dom('[data-key="cheetah"]').hasAttribute('data-active', 'true');
      await fillIn('[data-test-input]', 'e');
      assert.dom('[data-key="cheetah"]').hasAttribute('data-active', 'true');

      await triggerKeyEvent('[data-test-input]', 'keydown', 'ArrowDown');
      assert.dom('[data-key="crocodile"]').hasAttribute('data-active', 'true');
    });

    module('style classes', () => {
      test('it adds class for default appearance', async function (assert) {
        registerCustomStyles({
          listboxItem: tv({
            slots: {
              base: ['listboxItem'],
              descriptionWrapper: 'descriptionWrapper',
              label: 'label',
              description: ['description'],
              selectedIcon: ['selectedIcon'],
              shortcut: ['shortcut']
            },
            variants: {
              appearance: {
                default: {
                  base: 'appearance-default'
                },
                outlined: {
                  base: 'appearance-outlined'
                },
                faded: {
                  base: ['appearance-faded']
                }
              },
              intent: {
                default: { base: 'intent-default' },
                primary: { base: 'intent-primary' },
                secondary: { base: 'intent-secondary' },
                success: { base: 'intent-success' },
                warning: { base: 'intent-warning' },
                danger: { base: 'intent-danger' }
              },
              isActive: { true: { base: ['is-active'] } },
              withDivider: {
                true: {
                  base: ['with-divider']
                }
              },

              isDisabled: {
                true: {
                  base: 'is-disabled'
                }
              },
              isSelected: {
                true: {
                  base: 'is-selected'
                }
              }
            },
            defaultVariants: {
              appearance: 'default',
              intent: 'default'
            }
          }) as never
        });

        const appearance =
          cell<ListboxSignature<unknown>['Args']['appearance']>();
        const intent = cell<ListboxSignature<unknown>['Args']['intent']>();
        const selectedKeys = ['item-5'];
        const disabledKeys = ['item-6'];
        await render(
          <template>
            <Listbox
              @selectedKeys={{selectedKeys}}
              @disabledKeys={{disabledKeys}}
              @appearance={{appearance.current}}
              @intent={{intent.current}}
              as |l|
            >
              <l.Item @key="item-1">Item 1</l.Item>
              <l.Item @key="item-2" @appearance="outlined">Item 2</l.Item>
              <l.Item @key="item-3" @intent="danger">Item 3</l.Item>
              <l.Item @key="item-4" @withDivider={{true}}>Item 4</l.Item>
              <l.Item @key="item-5">Item 5</l.Item>
              <l.Item @key="item-6">Item 6</l.Item>
            </Listbox>
          </template>
        );

        // no appearance or intent set
        assert.dom('[data-key="item-1"]').hasClass('appearance-default');
        assert.dom('[data-key="item-1"]').hasClass('intent-default');

        // appearance and intent set
        appearance.current = 'faded';
        intent.current = 'warning';
        await settled();
        assert.dom('[data-key="item-1"]').hasClass('appearance-faded');
        assert.dom('[data-key="item-1"]').hasClass('intent-warning');

        // appearance overwritten at item
        assert.dom('[data-key="item-2"]').hasClass('appearance-outlined');

        // intent overwritten at item
        assert.dom('[data-key="item-3"]').hasClass('intent-danger');

        // Divider
        assert.dom('[data-key="item-4"]').hasClass('with-divider');

        // selected
        assert.dom('[data-key="item-5"]').hasClass('is-selected');

        // disabled
        assert.dom('[data-key="item-6"]').hasClass('is-disabled');
      });
    });
  }
);
