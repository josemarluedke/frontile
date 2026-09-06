import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { click, render, triggerKeyEvent } from '@ember/test-helpers';
import { Listbox } from 'frontile';
import { array } from '@ember/helper';
import { cell } from 'ember-resources';

module(
  'Integration | Component | Listbox::Group | @frontile/collections',
  function (hooks) {
    setupRenderingTest(hooks);

    test('it renders a titled group wrapping its options', async function (assert) {
      await render(
        <template>
          <Listbox @selectionMode="none" as |l|>
            <l.Group @title="Suggestions" as |g|>
              <g.Item @key="calendar">Calendar</g.Item>
              <g.Item @key="emoji">Search Emoji</g.Item>
            </l.Group>
          </Listbox>
        </template>
      );

      assert.dom('[data-test-id="listbox-group"]').exists();
      assert
        .dom('[data-test-id="listbox-group"]')
        .hasAttribute('role', 'group');
      assert.dom('[data-test-id="listbox-group-title"]').hasText('Suggestions');

      // The group must be labelled by its own heading, so a screen reader
      // announces "Suggestions" when entering the group.
      const group = document.querySelector(
        '[data-test-id="listbox-group"]'
      ) as HTMLElement;
      const title = document.querySelector(
        '[data-test-id="listbox-group-title"]'
      ) as HTMLElement;
      assert.strictEqual(
        group.getAttribute('aria-labelledby'),
        title.id,
        'aria-labelledby points at the group title'
      );
      assert.ok(title.id, 'the title has an id to be referenced by');

      // Intervening markup between listbox and option must be presentational,
      // otherwise the listbox -> option ownership chain is broken.
      const innerList = group.querySelector('ul') as HTMLElement;
      assert.dom(innerList).hasAttribute('role', 'none');

      assert.dom('[data-key="calendar"]').hasAttribute('role', 'option');
      assert.strictEqual(
        document.querySelectorAll('[data-component="listbox-item"]').length,
        2,
        'both options render inside the group'
      );
    });

    test('a group without a title renders no heading and no aria-labelledby', async function (assert) {
      await render(
        <template>
          <Listbox @selectionMode="none" as |l|>
            <l.Group as |g|>
              <g.Item @key="only">Only</g.Item>
            </l.Group>
          </Listbox>
        </template>
      );

      assert.dom('[data-test-id="listbox-group-title"]').doesNotExist();
      assert
        .dom('[data-test-id="listbox-group"]')
        .doesNotHaveAttribute(
          'aria-labelledby',
          'no dangling reference when there is no heading'
        );
    });

    test('keyboard navigation traverses across group boundaries in DOM order', async function (assert) {
      // The point of the whole grouping design: ListManager derives order from
      // the live DOM via compareDocumentPosition, so nesting options inside a
      // group wrapper must not change traversal.
      await render(
        <template>
          <Listbox
            @selectionMode="none"
            @isKeyboardEventsEnabled={{true}}
            @autoActivateMode="none"
            as |l|
          >
            <l.Group @title="Suggestions" as |g|>
              <g.Item @key="calendar">Calendar</g.Item>
              <g.Item @key="emoji">Search Emoji</g.Item>
            </l.Group>
            <l.Group @title="Settings" as |g|>
              <g.Item @key="profile">Profile</g.Item>
              <g.Item @key="billing">Billing</g.Item>
            </l.Group>
          </Listbox>
        </template>
      );

      const visited: (string | undefined)[] = [];
      for (let i = 0; i < 4; i++) {
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
        ['calendar', 'emoji', 'profile', 'billing'],
        'ArrowDown crosses from the last item of one group into the next'
      );
    });

    test('the roving tab stop is a single option, and moves across groups', async function (assert) {
      // main replaced the old per-item tabindex with a roving tab stop keyed
      // off ListManager's `tabStopKey`. It is keyed by key rather than DOM
      // position, so grouping should not affect it — asserted here because no
      // other group test covers tabindex.
      await render(
        <template>
          <Listbox
            @selectionMode="none"
            @isKeyboardEventsEnabled={{true}}
            @autoActivateMode="none"
            as |l|
          >
            <l.Group @title="Suggestions" as |g|>
              <g.Item @key="calendar">Calendar</g.Item>
              <g.Item @key="emoji">Search Emoji</g.Item>
            </l.Group>
            <l.Group @title="Settings" as |g|>
              <g.Item @key="profile">Profile</g.Item>
              <g.Item @key="billing">Billing</g.Item>
            </l.Group>
          </Listbox>
        </template>
      );

      const tabStops = () =>
        [...document.querySelectorAll('[data-component="listbox-item"]')]
          .filter((el) => el.getAttribute('tabindex') === '0')
          .map((el) => (el as HTMLElement).dataset['key']);

      assert.deepEqual(
        tabStops(),
        ['calendar'],
        'exactly one tab stop, the first option, even though it is nested in a group'
      );

      // Walk to the last item of the first group, then across the boundary.
      for (const expected of ['calendar', 'emoji', 'profile', 'billing']) {
        await triggerKeyEvent(
          '[data-test-id="listbox"]',
          'keydown',
          'ArrowDown'
        );

        assert.deepEqual(
          tabStops(),
          [expected],
          `the tab stop follows the active option to ${expected}`
        );
      }

      // The group wrapper itself must never become focusable.
      assert.strictEqual(
        document.querySelectorAll('[data-test-id="listbox-group"][tabindex]')
          .length,
        0,
        'the group element carries no tabindex'
      );
    });

    test('options inside a group participate in selection and actions', async function (assert) {
      const clickedOn: string[] = [];
      const onAction = (key: string) => clickedOn.push(key);
      const selected: string[][] = [];
      // Listbox is controlled: aria-selected only reflects what is passed back
      // in via @selectedKeys, so the test has to close that loop.
      const selectedKeys = cell<string[]>([]);
      const onSelectionChange = (keys: string[]) => {
        selected.push(keys);
        selectedKeys.current = keys;
      };

      await render(
        <template>
          <Listbox
            @selectionMode="single"
            @onAction={{onAction}}
            @selectedKeys={{selectedKeys.current}}
            @onSelectionChange={{onSelectionChange}}
            @disabledKeys={{array "billing"}}
            as |l|
          >
            <l.Group @title="Settings" as |g|>
              <g.Item @key="profile">Profile</g.Item>
              <g.Item @key="billing">Billing</g.Item>
            </l.Group>
          </Listbox>
        </template>
      );

      await click('[data-key="profile"]');

      assert.deepEqual(clickedOn, ['profile'], 'onAction fires from a group');
      assert.deepEqual(
        selected,
        [['profile']],
        'selection changes from within a group'
      );
      assert.dom('[data-key="profile"]').hasAttribute('aria-selected', 'true');

      // disabledKeys must still reach items nested inside a group.
      assert.dom('[data-key="billing"]').hasAttribute('aria-disabled', 'true');
    });
  }
);
