import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import {
  click,
  fillIn,
  render,
  triggerKeyEvent,
  settled
} from '@ember/test-helpers';
import { Command, CommandDialog } from 'frontile';
import { cell } from 'ember-resources';
import { array } from '@ember/helper';

interface Doc {
  key: string;
  label: string;
  category: string;
}

const DOCS: Doc[] = [
  { key: 'button-group', label: 'ButtonGroup', category: 'Buttons' },
  { key: 'toggle-button', label: 'ToggleButton', category: 'Buttons' },
  { key: 'button', label: 'Button', category: 'Buttons' },
  { key: 'calendar', label: 'Calendar', category: 'Suggestions' },
  { key: 'emoji', label: 'Search Emoji', category: 'Suggestions' },
  { key: 'profile', label: 'Profile', category: 'Settings' },
  { key: 'billing', label: 'Billing', category: 'Settings' }
];

function renderedKeys(): (string | undefined)[] {
  return [...document.querySelectorAll('[data-component="listbox-item"]')].map(
    (el) => (el as HTMLElement).dataset['key']
  );
}

function groupTitles(): string[] {
  return [
    ...document.querySelectorAll('[data-test-id="listbox-group-title"]')
  ].map((el) => (el as HTMLElement).textContent?.trim() ?? '');
}

module(
  'Integration | Component | Command | @frontile/collections',
  function (hooks) {
    setupRenderingTest(hooks);

    test('it renders every item before a query is typed', async function (assert) {
      await render(
        <template>
          <Command @items={{DOCS}} as |c|>
            <c.Input @placeholder="Type a command or search…" />
            <c.List>
              <:item as |ctx|>
                <ctx.Item @key={{ctx.key}}>{{ctx.label}}</ctx.Item>
              </:item>
            </c.List>
          </Command>
        </template>
      );

      assert.dom('[data-test-id="command-input"]').exists();
      assert
        .dom('[data-test-id="command-input"]')
        .hasAttribute('placeholder', 'Type a command or search…');
      assert.strictEqual(
        renderedKeys().length,
        DOCS.length,
        'a blank query shows everything'
      );
    });

    test('results are ranked, so an exact match is not buried', async function (assert) {
      // The bug this component was built for: `Button` must come first even
      // though `ButtonGroup` is earlier in the source array.
      await render(
        <template>
          <Command @items={{DOCS}} as |c|>
            <c.Input />
            <c.List>
              <:item as |ctx|>
                <ctx.Item @key={{ctx.key}}>{{ctx.label}}</ctx.Item>
              </:item>
            </c.List>
          </Command>
        </template>
      );

      await fillIn('[data-test-id="command-input"]', 'button');

      assert.strictEqual(
        renderedKeys()[0],
        'button',
        `Button ranks first (got ${renderedKeys().join(', ')})`
      );
    });

    test('a group whose items all filter out disappears entirely', async function (assert) {
      await render(
        <template>
          <Command @items={{DOCS}} @groupBy="category" as |c|>
            <c.Input />
            <c.List>
              <:item as |ctx|>
                <ctx.Item @key={{ctx.key}}>{{ctx.label}}</ctx.Item>
              </:item>
            </c.List>
          </Command>
        </template>
      );

      assert.deepEqual(
        groupTitles().sort(),
        ['Buttons', 'Settings', 'Suggestions'],
        'all three groups render initially'
      );
      assert.strictEqual(
        document.querySelectorAll('[data-test-id="divider"]').length,
        2,
        'separators render between the 3 groups, never after the last'
      );

      await fillIn('[data-test-id="command-input"]', 'calen');

      assert.deepEqual(
        groupTitles(),
        ['Suggestions'],
        'the empty groups are gone, heading and all'
      );
      assert.deepEqual(renderedKeys(), ['calendar']);
      assert.strictEqual(
        document.querySelectorAll('[data-test-id="divider"]').length,
        0,
        'and the separators go with them'
      );
    });

    test('arrow keys navigate from the input and Enter selects', async function (assert) {
      const selected: string[] = [];
      const onSelect = (key: string) => selected.push(key);

      await render(
        <template>
          <Command
            @items={{DOCS}}
            @groupBy="category"
            @onSelect={{onSelect}}
            as |c|
          >
            <c.Input />
            <c.List>
              <:item as |ctx|>
                <ctx.Item @key={{ctx.key}}>{{ctx.label}}</ctx.Item>
              </:item>
            </c.List>
          </Command>
        </template>
      );

      const input = '[data-test-id="command-input"]';

      // Down twice, crossing from one group into the next where relevant.
      await triggerKeyEvent(input, 'keydown', 'ArrowDown');
      await triggerKeyEvent(input, 'keydown', 'ArrowDown');
      await triggerKeyEvent(input, 'keypress', 'Enter');

      assert.strictEqual(selected.length, 1, 'Enter selected exactly one item');
      assert.notStrictEqual(selected[0], undefined, 'and reported which one');
    });

    test('it selects the item that was clicked', async function (assert) {
      const selected: string[] = [];
      const items: Doc[] = [];
      const onSelect = (key: string, item?: Doc) => {
        selected.push(key);
        if (item) items.push(item);
      };

      await render(
        <template>
          <Command @items={{DOCS}} @onSelect={{onSelect}} as |c|>
            <c.Input />
            <c.List>
              <:item as |ctx|>
                <ctx.Item @key={{ctx.key}}>{{ctx.label}}</ctx.Item>
              </:item>
            </c.List>
          </Command>
        </template>
      );

      await click('[data-key="profile"]');

      assert.deepEqual(selected, ['profile']);
      assert.strictEqual(
        items[0]?.label,
        'Profile',
        'the original item is handed back, not just its key'
      );
    });

    test('the input carries the combobox semantics', async function (assert) {
      await render(
        <template>
          <Command @items={{DOCS}} @label="Search documentation" as |c|>
            <c.Input />
            <c.List>
              <:item as |ctx|>
                <ctx.Item @key={{ctx.key}}>{{ctx.label}}</ctx.Item>
              </:item>
            </c.List>
          </Command>
        </template>
      );

      const input = document.querySelector(
        '[data-test-id="command-input"]'
      ) as HTMLInputElement;

      assert.dom(input).hasAttribute('role', 'combobox');
      assert.dom(input).hasAttribute('aria-autocomplete', 'list');

      // aria-controls must point at the list that actually rendered.
      const list = document.querySelector('[data-test-id="command-list"]');
      assert.strictEqual(
        input.getAttribute('aria-controls'),
        list?.id,
        'aria-controls points at the listbox'
      );
      assert.dom(list).hasAttribute('role', 'listbox');

      // The label is on the input, not on a wrapper.
      assert.strictEqual(
        input.labels?.[0]?.textContent?.trim(),
        'Search documentation'
      );

      await triggerKeyEvent(input, 'keydown', 'ArrowDown');

      const activeId = input.getAttribute('aria-activedescendant');
      assert.ok(
        activeId,
        'aria-activedescendant is set once an item is active'
      );
      assert.dom(`#${activeId}`).hasAttribute('role', 'option');
      assert
        .dom(`#${activeId}`)
        .hasAttribute('data-active', 'true', 'and points at the active option');
    });

    test('it renders the empty block when nothing matches', async function (assert) {
      await render(
        <template>
          <Command @items={{DOCS}} as |c|>
            <c.Input />
            <c.List>
              <:item as |ctx|>
                <ctx.Item @key={{ctx.key}}>{{ctx.label}}</ctx.Item>
              </:item>
              <:empty>Nothing for "{{c.query}}"</:empty>
            </c.List>
          </Command>
        </template>
      );

      await fillIn('[data-test-id="command-input"]', 'zzzzzz');

      assert
        .dom('[data-test-id="command-empty"]')
        .hasText('Nothing for "zzzzzz"');
      assert.strictEqual(renderedKeys().length, 0);
    });

    test('disabled items are marked and are not selectable', async function (assert) {
      const selected: string[] = [];
      const onSelect = (key: string) => selected.push(key);

      await render(
        <template>
          <Command
            @items={{DOCS}}
            @onSelect={{onSelect}}
            @disabledKeys={{array "billing"}}
            as |c|
          >
            <c.Input />
            <c.List>
              <:item as |ctx|>
                <ctx.Item @key={{ctx.key}}>{{ctx.label}}</ctx.Item>
              </:item>
            </c.List>
          </Command>
        </template>
      );

      assert.dom('[data-key="billing"]').hasAttribute('aria-disabled', 'true');

      await click('[data-key="billing"]');
      assert.deepEqual(selected, [], 'a disabled item does not select');
    });

    module('dialog', function () {
      test('it opens on its shortcut and closes on Escape', async function (assert) {
        const isOpen = cell(false);
        const open = () => (isOpen.current = true);
        const close = () => (isOpen.current = false);

        await render(
          <template>
            <CommandDialog
              @isOpen={{isOpen.current}}
              @onOpen={{open}}
              @onClose={{close}}
              @shortcut="mod+k"
              @items={{DOCS}}
              @disableTransitions={{true}}
              as |c|
            >
              <c.Input />
              <c.List>
                <:item as |ctx|>
                  <ctx.Item @key={{ctx.key}}>{{ctx.label}}</ctx.Item>
                </:item>
              </c.List>
            </CommandDialog>
          </template>
        );

        assert
          .dom('[data-test-id="command-input"]')
          .doesNotExist('closed initially');

        // The shortcut is global, so it fires on the document, not on the palette.
        const isApple = /Mac|iPhone|iPad|iPod/i.test(navigator.platform);
        document.dispatchEvent(
          new KeyboardEvent('keydown', {
            key: 'k',
            metaKey: isApple,
            ctrlKey: !isApple,
            bubbles: true
          })
        );
        await settled();

        assert
          .dom('[data-test-id="command-input"]')
          .exists('the shortcut opened it');
        assert.strictEqual(renderedKeys().length, DOCS.length);

        await triggerKeyEvent(
          '[data-component="overlay"]',
          'keydown',
          'Escape'
        );

        assert.strictEqual(isOpen.current, false, 'Escape closed it');
      });

      test('an unmodified shortcut does not steal keystrokes from a field', async function (assert) {
        const isOpen = cell(false);
        const open = () => (isOpen.current = true);

        await render(
          <template>
            {{! template-lint-disable require-input-label }}
            <input type="text" data-test-other-input />
            <CommandDialog
              @isOpen={{isOpen.current}}
              @onOpen={{open}}
              @shortcut="/"
              @items={{DOCS}}
              @disableTransitions={{true}}
              as |c|
            >
              <c.Input />
              <c.List>
                <:item as |ctx|>
                  <ctx.Item @key={{ctx.key}}>{{ctx.label}}</ctx.Item>
                </:item>
              </c.List>
            </CommandDialog>
          </template>
        );

        const other = document.querySelector(
          '[data-test-other-input]'
        ) as HTMLInputElement;
        other.focus();
        other.dispatchEvent(
          new KeyboardEvent('keydown', { key: '/', bubbles: true })
        );
        await settled();

        assert.strictEqual(
          isOpen.current,
          false,
          'typing "/" in a field does not open the palette'
        );

        // But it still opens from outside a field.
        document.body.dispatchEvent(
          new KeyboardEvent('keydown', { key: '/', bubbles: true })
        );
        await settled();

        assert.strictEqual(isOpen.current, true, 'and it does from the page');
      });
    });

    module('async', function () {
      test('it renders resolved results and shows loading while pending', async function (assert) {
        let resolveSearch: (items: Doc[]) => void = () => {};
        const onSearch = (query: string) =>
          new Promise<Doc[]>((resolve) => {
            resolveSearch = resolve;
            assert.step(`search:${query}`);
          });

        await render(
          <template>
            <Command @onSearch={{onSearch}} @searchDebounce={{0}} as |c|>
              <c.Input />
              <c.List>
                <:item as |ctx|>
                  <ctx.Item @key={{ctx.key}}>{{ctx.label}}</ctx.Item>
                </:item>
                <:loading>Searching…</:loading>
              </c.List>
            </Command>
          </template>
        );

        fillIn('[data-test-id="command-input"]', 'but');
        await new Promise((r) => setTimeout(r, 20));

        assert.dom('[data-test-id="command-loading"]').exists('shows loading');

        resolveSearch([DOCS[2]!]);
        await settled();

        assert.dom('[data-test-id="command-loading"]').doesNotExist();
        assert.deepEqual(renderedKeys(), ['button']);
        assert.verifySteps(['search:but']);
      });

      test('a stale response cannot overwrite a newer one', async function (assert) {
        const resolvers: ((items: Doc[]) => void)[] = [];
        const onSearch = () =>
          new Promise<Doc[]>((resolve) => resolvers.push(resolve));

        await render(
          <template>
            <Command @onSearch={{onSearch}} @searchDebounce={{0}} as |c|>
              <c.Input />
              <c.List>
                <:item as |ctx|>
                  <ctx.Item @key={{ctx.key}}>{{ctx.label}}</ctx.Item>
                </:item>
              </c.List>
            </Command>
          </template>
        );

        fillIn('[data-test-id="command-input"]', 'a');
        await new Promise((r) => setTimeout(r, 20));
        fillIn('[data-test-id="command-input"]', 'ab');
        await new Promise((r) => setTimeout(r, 20));

        assert.strictEqual(resolvers.length, 2, 'both searches were issued');

        // Resolve the NEWER one first, then the older, out of order.
        resolvers[1]!([DOCS[2]!]);
        await settled();
        resolvers[0]!([DOCS[0]!]);
        await settled();

        assert.deepEqual(
          renderedKeys(),
          ['button'],
          'the latest query wins, not the last response to arrive'
        );
      });
    });
  }
);
