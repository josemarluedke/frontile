import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { click, render, triggerKeyEvent, fillIn } from '@ember/test-helpers';
import { registerCustomStyles } from '@frontile/theme';
import { tv } from 'tailwind-variants';
import { modifier } from 'ember-modifier';
import { Listbox, type ListboxSignature } from 'frontile';
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

      assert.dom('[data-key="item-3"]').hasAttribute('aria-disabled', 'true');
      assert.dom('[data-key="item-4"]').hasAttribute('aria-disabled', 'true');

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

    test('keyboard navigation follows DOM order after items are inserted before a persisting item', async function (assert) {
      // Mimics an async (e.g. address) search: the previous match is still in
      // the new results, but closer matches are inserted before it. The
      // persisting item keeps its object identity, so Glimmer moves its
      // existing element instead of re-creating it.
      const later = { key: 'later', label: 'Later' };
      const first = { key: 'first', label: 'First' };
      const second = { key: 'second', label: 'Second' };

      const items = cell<{ key: string; label: string }[]>([later]);

      await render(
        <template>
          <Listbox
            @isKeyboardEventsEnabled={{true}}
            @selectionMode="single"
            @items={{items.current}}
            @autoActivateMode="none"
          />
        </template>
      );

      assert.dom('[data-key="later"]').exists();

      items.current = [first, second, later];
      await settled();

      const domOrder = [
        ...document.querySelectorAll('[data-component="listbox-item"]')
      ].map((el) => (el as HTMLElement).dataset['key']);
      assert.deepEqual(
        domOrder,
        ['first', 'second', 'later'],
        'DOM renders the new items before the persisting one'
      );

      const visited: (string | undefined)[] = [];
      for (let i = 0; i < 3; i++) {
        await triggerKeyEvent(
          '[data-test-id="listbox"]',
          'keydown',
          'ArrowDown'
        );
        visited.push(
          (
            document.querySelector(
              '[data-component="listbox-item"][data-active="true"]'
            ) as HTMLElement | null
          )?.dataset['key']
        );
      }

      assert.deepEqual(
        visited,
        ['first', 'second', 'later'],
        'ArrowDown visits items in DOM order'
      );
    });

    test('keyboard navigation follows DOM order when results are replaced around a persisting item', async function (assert) {
      // Same scenario, but the previous results are also dropped — the shape of
      // a real search where typing narrows the list.
      const match = { key: 'match', label: 'Match' };
      const oldA = { key: 'old-a', label: 'Old A' };
      const oldB = { key: 'old-b', label: 'Old B' };
      const newA = { key: 'new-a', label: 'New A' };
      const newB = { key: 'new-b', label: 'New B' };

      const items = cell<{ key: string; label: string }[]>([oldA, oldB, match]);

      await render(
        <template>
          <Listbox
            @isKeyboardEventsEnabled={{true}}
            @selectionMode="single"
            @items={{items.current}}
            @autoActivateMode="none"
          />
        </template>
      );

      items.current = [newA, newB, match];
      await settled();

      const domOrder = [
        ...document.querySelectorAll('[data-component="listbox-item"]')
      ].map((el) => (el as HTMLElement).dataset['key']);
      assert.deepEqual(domOrder, ['new-a', 'new-b', 'match'], 'DOM order');

      const visited: (string | undefined)[] = [];
      for (let i = 0; i < 3; i++) {
        await triggerKeyEvent(
          '[data-test-id="listbox"]',
          'keydown',
          'ArrowDown'
        );
        visited.push(
          (
            document.querySelector(
              '[data-component="listbox-item"][data-active="true"]'
            ) as HTMLElement | null
          )?.dataset['key']
        );
      }

      assert.deepEqual(
        visited,
        ['new-a', 'new-b', 'match'],
        'ArrowDown visits items in DOM order'
      );
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
                tertiary: { base: 'intent-tertiary' },
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
              <l.Item @key="item-7" @intent="tertiary">Item 7</l.Item>
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

        // tertiary intent overwritten at item
        assert.dom('[data-key="item-7"]').hasClass('intent-tertiary');

        // Divider
        assert.dom('[data-key="item-4"]').hasClass('with-divider');

        // selected
        assert.dom('[data-key="item-5"]').hasClass('is-selected');

        // disabled
        assert.dom('[data-key="item-6"]').hasClass('is-disabled');
      });
    });

    module('aria selection state', function () {
      test('options expose aria-selected reflecting selection', async function (assert) {
        const animals = ['cheetah', 'crocodile', 'elephant'];
        const selectedKeys = cell<string[]>(['crocodile']);

        const onSelectionChange = (keys: string[]) => {
          selectedKeys.current = keys;
        };

        await render(
          <template>
            <Listbox
              @selectionMode="single"
              @items={{animals}}
              @selectedKeys={{selectedKeys.current}}
              @onSelectionChange={{onSelectionChange}}
            />
          </template>
        );

        assert.dom('[data-key="crocodile"]').hasAttribute('role', 'option');
        assert
          .dom('[data-key="crocodile"]')
          .hasAttribute('aria-selected', 'true', 'the selected option says so');
        assert
          .dom('[data-key="cheetah"]')
          .hasAttribute(
            'aria-selected',
            'false',
            'unselected options are present but not selected'
          );

        await click('[data-key="elephant"]');

        assert
          .dom('[data-key="elephant"]')
          .hasAttribute('aria-selected', 'true', 'updates on selection');
        assert
          .dom('[data-key="crocodile"]')
          .hasAttribute('aria-selected', 'false', 'and clears the previous');
      });

      test('a multiple-selection listbox is marked aria-multiselectable', async function (assert) {
        const animals = ['cheetah', 'crocodile'];
        const selectionMode = cell<'single' | 'multiple'>('single');
        const selectedKeys = cell<string[]>([]);

        const onSelectionChange = (keys: string[]) => {
          selectedKeys.current = keys;
        };

        await render(
          <template>
            <Listbox
              @selectionMode={{selectionMode.current}}
              @items={{animals}}
              @selectedKeys={{selectedKeys.current}}
              @onSelectionChange={{onSelectionChange}}
            />
          </template>
        );

        assert
          .dom('[data-test-id="listbox"]')
          .doesNotHaveAttribute(
            'aria-multiselectable',
            'absent for single selection'
          );

        selectionMode.current = 'multiple';
        await settled();

        assert
          .dom('[data-test-id="listbox"]')
          .hasAttribute('aria-multiselectable', 'true');
      });

      test('menu items do not carry aria-selected', async function (assert) {
        // `aria-selected` on a plain menuitem is invalid ARIA - menus convey
        // state via aria-checked, and only as menuitemcheckbox/menuitemradio.
        const animals = ['cheetah', 'crocodile'];
        const selectedKeys = cell<string[]>(['cheetah']);

        const onSelectionChange = (keys: string[]) => {
          selectedKeys.current = keys;
        };

        await render(
          <template>
            <Listbox
              @type="menu"
              @selectionMode="single"
              @items={{animals}}
              @selectedKeys={{selectedKeys.current}}
              @onSelectionChange={{onSelectionChange}}
            />
          </template>
        );

        assert.dom('[data-key="cheetah"]').hasAttribute('role', 'menuitem');
        assert
          .dom('[data-key="cheetah"]')
          .doesNotHaveAttribute(
            'aria-selected',
            'selected menu item has no aria-selected'
          );
        assert
          .dom('[data-test-id="listbox"]')
          .doesNotHaveAttribute('aria-multiselectable');
      });
    });

    /**
     * Regression coverage for a pre-existing ListManager bug: the new
     * selection was rebuilt purely from the *rendered* items, so any selected
     * key whose item was not currently in the list — filtered out, paginated
     * away, or simply never passed in @items — was silently dropped on the
     * next toggle.
     *
     * Driven by plain clicks: the defect is in selection, not in key handling.
     */
    module('selections outside the rendered item set', function () {
      test('toggling keeps selected keys whose items are not rendered', async function (assert) {
        const animals = ['crocodile', 'elephant'];
        // 'cheetah' is selected but deliberately absent from @items.
        const selectedKeys = cell<string[]>(['cheetah', 'crocodile']);
        const onSelectionChange = (keys: string[]) => {
          selectedKeys.current = keys;
        };

        await render(
          <template>
            <Listbox
              @selectionMode="multiple"
              @items={{animals}}
              @selectedKeys={{selectedKeys.current}}
              @onSelectionChange={{onSelectionChange}}
            />
          </template>
        );

        assert
          .dom('[data-key="cheetah"]')
          .doesNotExist('the selected item is not in the rendered list');

        await click('[data-key="elephant"]');

        assert.deepEqual(
          [...selectedKeys.current].sort(),
          ['cheetah', 'crocodile', 'elephant'],
          'selecting a rendered item does not drop the unrendered selection'
        );
      });

      test('deselecting a rendered item keeps unrendered selections', async function (assert) {
        const animals = ['crocodile', 'elephant'];
        const selectedKeys = cell<string[]>(['cheetah', 'crocodile']);
        const onSelectionChange = (keys: string[]) => {
          selectedKeys.current = keys;
        };

        await render(
          <template>
            <Listbox
              @selectionMode="multiple"
              @items={{animals}}
              @selectedKeys={{selectedKeys.current}}
              @onSelectionChange={{onSelectionChange}}
            />
          </template>
        );

        await click('[data-key="crocodile"]');

        assert.deepEqual(
          [...selectedKeys.current].sort(),
          ['cheetah'],
          'deselecting removes only the clicked key'
        );
      });

      /**
       * The no-op guarantee. With every selected item rendered there is
       * nothing to union back in, so the emitted array must be byte-for-byte
       * what the unfixed code produced — including its quirk of appending a
       * newly selected key last rather than in DOM order.
       *
       * Unlike its three neighbours this test is green BEFORE the fix as well
       * as after: staying green across the change is precisely what it
       * asserts. It was written against the unfixed code's real output.
       */
      test('is a no-op when every selected item is rendered', async function (assert) {
        const animals = ['cheetah', 'crocodile', 'elephant'];
        const selectedKeys = cell<string[]>(['crocodile']);
        const onSelectionChange = (keys: string[]) => {
          selectedKeys.current = keys;
        };

        await render(
          <template>
            <Listbox
              @selectionMode="multiple"
              @items={{animals}}
              @selectedKeys={{selectedKeys.current}}
              @onSelectionChange={{onSelectionChange}}
            />
          </template>
        );

        await click('[data-key="elephant"]');
        assert.deepEqual(
          selectedKeys.current,
          ['crocodile', 'elephant'],
          'DOM order preserved, no duplicates'
        );

        await click('[data-key="cheetah"]');
        assert.deepEqual(
          selectedKeys.current,
          ['crocodile', 'elephant', 'cheetah'],
          'a newly selected key is appended last, exactly as before the fix'
        );

        await click('[data-key="crocodile"]');
        assert.deepEqual(
          selectedKeys.current,
          ['cheetah', 'elephant'],
          'the array is re-derived in DOM order on each toggle, as before the fix'
        );
      });

      test('single mode is unaffected by unrendered selections', async function (assert) {
        const animals = ['crocodile', 'elephant'];
        const selectedKeys = cell<string[]>(['cheetah']);
        const onSelectionChange = (keys: string[]) => {
          selectedKeys.current = keys;
        };

        await render(
          <template>
            <Listbox
              @selectionMode="single"
              @items={{animals}}
              @selectedKeys={{selectedKeys.current}}
              @onSelectionChange={{onSelectionChange}}
            />
          </template>
        );

        await click('[data-key="elephant"]');

        assert.deepEqual(
          selectedKeys.current,
          ['elephant'],
          'single selection still replaces, it does not accumulate'
        );
      });
    });
  }
);
