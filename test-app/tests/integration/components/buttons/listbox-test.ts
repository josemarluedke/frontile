import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { click, render, triggerKeyEvent } from '@ember/test-helpers';
import hbs from 'htmlbars-inline-precompile';
import { registerCustomStyles } from '@frontile/theme';
import { tv } from 'tailwind-variants';

module(
  'Integration | Component | Listbox | @frontile/buttons',
  function (hooks) {
    setupRenderingTest(hooks);

    test('it render static items', async function (assert) {
      const clickedOn: string[] = [];
      this.set('onAction', function (key: string) {
        clickedOn.push(key);
      });

      await render(
        hbs`
          <Listbox
            @selectionMode="none"
            @onAction={{this.onAction}}
            @disabledKeys={{(array "item-3" "item-4")}}
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
          </Listbox>`
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
        <Listbox
          @allowEmpty={{this.allowEmpty}}
          @selectionMode={{this.selectionMode}}
          @items={{this.animals}}
          @selectedKeys={{this.selectedKeys}}
          @onSelectionChange={{this.onSelectionChange}}
        />`
      );

      assert.dom('[data-test-id="listbox"]').exists();

      assert.dom('[data-key="cheetah"]').exists();
      assert.dom('[data-key="crocodile"]').exists();
      assert.dom('[data-key="elephant"]').exists();

      // Selection Mode single
      await click('[data-key="cheetah"]');

      assert.equal(selectedKeys.length, 1);
      assert.equal(selectedKeys[0], 'cheetah');
      assert.dom('[data-key="cheetah"]').hasAttribute('data-selected', 'true');
      assert
        .dom('[data-key="cheetah"] [data-test-id="listbox-item-selected-icon"]')
        .exists('should render icon on selected item');

      await click('[data-key="crocodile"]');
      assert.equal(selectedKeys.length, 1);
      assert.equal(selectedKeys[0], 'crocodile');
      assert
        .dom('[data-key="crocodile"]')
        .hasAttribute('data-selected', 'true');
      assert.dom('[data-key="cheetah"]').hasAttribute('data-selected', 'false');

      // Toggle when allowEmpty = false
      await click('[data-key="crocodile"]');
      assert.equal(selectedKeys.length, 1);
      assert.equal(selectedKeys[0], 'crocodile');

      // Toggle when allowEmpty = true
      this.set('allowEmpty', true);
      await click('[data-key="crocodile"]');
      assert.equal(selectedKeys.length, 0);

      // Selection Mode multiple
      this.set('selectionMode', 'multiple');
      this.set('selectedKeys', []);
      selectedKeys = [];

      await click('[data-key="elephant"]');

      assert.equal(selectedKeys.length, 1);
      assert.equal(selectedKeys[0], 'elephant');
      assert.dom('[data-key="elephant"]').hasAttribute('data-selected', 'true');

      await click('[data-key="crocodile"]');
      assert.equal(selectedKeys.length, 2);
      assert.equal(selectedKeys[1], 'crocodile');
      assert.dom('[data-key="elephant"]').hasAttribute('data-selected', 'true');
      assert
        .dom('[data-key="crocodile"]')
        .hasAttribute('data-selected', 'true');

      // Toggle when allowEmpty = false
      this.set('allowEmpty', false);
      await click('[data-key="crocodile"]');
      assert.equal(selectedKeys.length, 1);
      assert.equal(selectedKeys[0], 'elephant');
      assert.dom('[data-key="elephant"]').hasAttribute('data-selected', 'true');
      assert
        .dom('[data-key="crocodile"]')
        .hasAttribute('data-selected', 'false');

      await click('[data-key="elephant"]');
      assert.equal(selectedKeys.length, 1);
      assert.equal(selectedKeys[0], 'elephant');
      assert.dom('[data-key="elephant"]').hasAttribute('data-selected', 'true');

      // Toggle when allowEmpty = true
      this.set('allowEmpty', true);
      await click('[data-key="elephant"]');
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
        <Listbox
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
        </Listbox>`
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
        <Listbox
          @isKeyboardEventsEnabled={{true}}
          @allowEmpty={{this.allowEmpty}}
          @selectionMode={{this.selectionMode}}
          @items={{this.animals}}
          @selectedKeys={{this.selectedKeys}}
          @onSelectionChange={{this.onSelectionChange}}
        />`
      );

      assert.dom('[data-test-id="listbox"]').exists();

      assert.dom('[data-key="cheetah"]').exists();
      assert.dom('[data-key="crocodile"]').exists();
      assert.dom('[data-key="elephant"]').exists();

      // ArrowDown & ArrowUp navigation
      assert.dom('[data-key="cheetah"]').hasAttribute('data-active', 'false');
      await triggerKeyEvent('[data-test-id="listbox"]', 'keyup', 'ArrowDown');
      assert.dom('[data-key="cheetah"]').hasAttribute('data-active', 'true');

      await triggerKeyEvent('[data-test-id="listbox"]', 'keyup', 'ArrowDown');
      assert.dom('[data-key="cheetah"]').hasAttribute('data-active', 'false');
      assert.dom('[data-key="crocodile"]').hasAttribute('data-active', 'true');

      await triggerKeyEvent('[data-test-id="listbox"]', 'keyup', 'ArrowUp');
      assert.dom('[data-key="cheetah"]').hasAttribute('data-active', 'true');
      assert.dom('[data-key="crocodile"]').hasAttribute('data-active', 'false');

      // PageDown & PageUp
      await triggerKeyEvent('[data-test-id="listbox"]', 'keyup', 'PageDown');
      assert.dom('[data-key="cheetah"]').hasAttribute('data-active', 'false');
      assert.dom('[data-key="crocodile"]').hasAttribute('data-active', 'false');
      assert.dom('[data-key="elephant"]').hasAttribute('data-active', 'true');

      await triggerKeyEvent('[data-test-id="listbox"]', 'keyup', 'PageUp');
      assert.dom('[data-key="cheetah"]').hasAttribute('data-active', 'true');
      assert.dom('[data-key="crocodile"]').hasAttribute('data-active', 'false');
      assert.dom('[data-key="elephant"]').hasAttribute('data-active', 'false');

      // select active item
      await triggerKeyEvent('[data-test-id="listbox"]', 'keypress', 'Enter');
      assert.equal(selectedKeys.length, 1);
      assert.equal(selectedKeys[0], 'cheetah');

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
      this.set('onAction', function (key: string) {
        clickedOn.push(key);
      });

      await render(
        hbs`
          <Listbox
            @selectionMode="none"
            @onAction={{this.onAction}}
            @disabledKeys={{(array "item-3" "item-4")}}
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
          </Listbox>`
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
              appearence: {
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
              appearence: 'default',
              intent: 'default'
            }
          }) as never
        });

        this.set('appearance', '');
        this.set('intent', '');
        this.set('selectedKeys', ['item-5']);
        this.set('disabledKeys', ['item-6']);
        await render(
          hbs`
            <Listbox
              @selectedKeys={{this.selectedKeys}}
              @disabledKeys={{this.disabledKeys}}
              @appearance={{this.appearance}}
              @intent={{this.intent}}
              as |l|
            >
              <l.Item @key="item-1">Item 1</l.Item>
              <l.Item @key="item-2" @appearance="outlined">Item 2</l.Item>
              <l.Item @key="item-3" @intent="danger">Item 3</l.Item>
              <l.Item @key="item-4" @withDivider={{true}}>Item 4</l.Item>
              <l.Item @key="item-5">Item 5</l.Item>
              <l.Item @key="item-6">Item 6</l.Item>
            </Listbox>`
        );

        // no appearance or intent set
        assert.dom('[data-key="item-1"]').hasClass('appearance-default');
        assert.dom('[data-key="item-1"]').hasClass('intent-default');

        // appearance and intent set
        this.set('appearance', 'faded');
        this.set('intent', 'warning');
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
