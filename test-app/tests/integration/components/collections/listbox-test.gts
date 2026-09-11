import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { click, render, triggerKeyEvent, fillIn } from '@ember/test-helpers';
import { registerCustomStyles } from '@frontile/theme';
import { tv } from 'tailwind-variants';
import { modifier } from 'ember-modifier';
import { Listbox, setKbdPlatform, type ListboxSignature } from 'frontile';
import { array, get } from '@ember/helper';
import { cell } from 'ember-resources';
import { settled } from '@ember/test-helpers';

/**
 * Press a key the way a browser does.
 *
 * A browser dispatches `keydown` and only follows it with `keypress` when the
 * keydown was not canceled. Tests that dispatch `keypress` directly therefore
 * describe an event sequence that cannot happen when any handler calls
 * `preventDefault()`, which is exactly the fragility this models.
 */
function pressKey(el: HTMLElement, key: string) {
  const notCanceled = el.dispatchEvent(
    new KeyboardEvent('keydown', { key, bubbles: true, cancelable: true })
  );

  if (notCanceled) {
    el.dispatchEvent(
      new KeyboardEvent('keydown', { key, bubbles: true, cancelable: true })
    );
  }
}

module(
  'Integration | Component | Listbox | @frontile/collections',
  function (hooks) {
    setupRenderingTest(hooks);

    hooks.afterEach(function () {
      setKbdPlatform('auto');
    });

    module('shortcuts', function () {
      test('@shortcut accepts named keys and resolves them per platform', async function (assert) {
        setKbdPlatform('apple');

        await render(
          <template>
            <Listbox @selectionMode="none" as |l|>
              <l.Item @key="save" @shortcut="mod+shift+s">Save as</l.Item>
            </Listbox>
          </template>
        );

        assert
          .dom('[data-test-id="listbox-item-shortcut"]')
          .hasText(
            '⌘ Command ⇧ Shift S',
            'glyphs render with their spoken names alongside'
          );

        setKbdPlatform('other');

        await render(
          <template>
            <Listbox @selectionMode="none" as |l|>
              <l.Item @key="save" @shortcut="mod+shift+s">Save as</l.Item>
            </Listbox>
          </template>
        );

        assert
          .dom('[data-test-id="listbox-item-shortcut"]')
          .includesText(
            'Ctrl',
            'mod follows the platform, so it is not ⌘ here'
          );
      });

      test('@shortcutAppearance threads down to the rendered Kbd', async function (assert) {
        await render(
          <template>
            <Listbox @selectionMode="none" @shortcutAppearance="plain" as |l|>
              <l.Item @key="save" @shortcut="mod+s">Save</l.Item>
              <l.Group @title="More" as |g|>
                <g.Item @key="print" @shortcut="mod+p">Print</g.Item>
              </l.Group>
            </Listbox>
          </template>
        );

        const caps = document.querySelectorAll(
          '[data-test-id="listbox-item-shortcut"] [data-part="key"]'
        );

        assert.true(caps.length > 0, 'shortcuts render through Kbd');
        // `plain` is what Command asks for; without threading these would be
        // `inherit` and keep their hairline box.
        for (const cap of caps) {
          assert.dom(cap).hasClass('border-0');
        }
      });

      test('a shortcut with no separator still renders verbatim', async function (assert) {
        // Existing consumers pass display strings like this; adopting Kbd must
        // not reinterpret them.
        await render(
          <template>
            <Listbox @selectionMode="none" as |l|>
              <l.Item @key="save" @shortcut="⌘⇧S">Save as</l.Item>
            </Listbox>
          </template>
        );

        assert.dom('[data-test-id="listbox-item-shortcut"]').hasText('⌘⇧S');
      });
    });

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

      assert.dom('[data-component="listbox"]').exists();
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

      assert.dom('[data-component="listbox"]').exists();

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

      assert.dom('[data-component="listbox"]').exists();

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

      assert.dom('[data-component="listbox"]').exists();

      assert.dom('[data-key="cheetah"]').exists();
      assert.dom('[data-key="crocodile"]').exists();
      assert.dom('[data-key="elephant"]').exists();

      // ArrowDown & ArrowUp navigation
      assert.dom('[data-key="cheetah"]').hasAttribute('data-active', 'false');
      await triggerKeyEvent(
        '[data-component="listbox"]',
        'keydown',
        'ArrowDown'
      );
      assert.dom('[data-key="cheetah"]').hasAttribute('data-active', 'true');

      await triggerKeyEvent(
        '[data-component="listbox"]',
        'keydown',
        'ArrowDown'
      );
      assert.dom('[data-key="cheetah"]').hasAttribute('data-active', 'false');
      assert.dom('[data-key="crocodile"]').hasAttribute('data-active', 'true');

      await triggerKeyEvent('[data-component="listbox"]', 'keydown', 'ArrowUp');
      assert.dom('[data-key="cheetah"]').hasAttribute('data-active', 'true');
      assert.dom('[data-key="crocodile"]').hasAttribute('data-active', 'false');

      // PageDown & PageUp
      await triggerKeyEvent(
        '[data-component="listbox"]',
        'keydown',
        'PageDown'
      );
      assert.dom('[data-key="cheetah"]').hasAttribute('data-active', 'false');
      assert.dom('[data-key="crocodile"]').hasAttribute('data-active', 'false');
      assert.dom('[data-key="elephant"]').hasAttribute('data-active', 'true');

      await triggerKeyEvent('[data-component="listbox"]', 'keydown', 'PageUp');
      assert.dom('[data-key="cheetah"]').hasAttribute('data-active', 'true');
      assert.dom('[data-key="crocodile"]').hasAttribute('data-active', 'false');
      assert.dom('[data-key="elephant"]').hasAttribute('data-active', 'false');

      // select active item
      await triggerKeyEvent('[data-component="listbox"]', 'keydown', 'Enter');
      assert.equal(selectedKeys.current.length, 1);
      assert.equal(selectedKeys.current[0], 'cheetah');

      // search
      await triggerKeyEvent('[data-component="listbox"]', 'keydown', 'E');
      assert.dom('[data-key="cheetah"]').hasAttribute('data-active', 'false');
      assert.dom('[data-key="crocodile"]').hasAttribute('data-active', 'false');
      assert.dom('[data-key="elephant"]').hasAttribute('data-active', 'true');

      await triggerKeyEvent('[data-component="listbox"]', 'keydown', 'C');
      assert.dom('[data-key="cheetah"]').hasAttribute('data-active', 'true');
      assert.dom('[data-key="crocodile"]').hasAttribute('data-active', 'false');
      assert.dom('[data-key="elephant"]').hasAttribute('data-active', 'false');

      triggerKeyEvent('[data-component="listbox"]', 'keydown', 'C');
      await triggerKeyEvent('[data-component="listbox"]', 'keydown', 'R');

      assert.dom('[data-key="cheetah"]').hasAttribute('data-active', 'false');
      assert
        .dom('[data-key="crocodile"]')
        .hasAttribute(
          'data-active',
          'true',
          'should have selected crocodile due to two keydown'
        );
      assert.dom('[data-key="elephant"]').hasAttribute('data-active', 'false');
    });

    test('an immediate Enter after type-ahead selects the matched item', async function (assert) {
      // Regression test for: type a few letters of type-ahead, then press
      // Enter right away -- nothing happened. Root cause: `handleKeyPress`
      // guarded Enter on `searchKeys == ''`, but the search buffer is only
      // cleared by a 500ms debounce, so any Enter within that window was
      // silently dropped.
      //
      // Both keys are dispatched natively and synchronously, with no
      // `await` in between. Awaiting `triggerKeyEvent` chains `settled()`,
      // which waits out the pending `debounce(this, this.#clearSearch, 500)`
      // scheduled by the first keystroke's `search()` call -- that would
      // clear `searchKeys` before Enter ever arrives and make this test
      // vacuously pass against the broken code. See the same technique in
      // dropdown-test.gts's submenu pointer-travel test.
      const animals = ['cheetah', 'crocodile', 'elephant'];
      const selected: string[] = [];
      const onAction = (key: string) => selected.push(key);

      await render(
        <template>
          <Listbox
            @isKeyboardEventsEnabled={{true}}
            @selectionMode="none"
            @items={{animals}}
            @onAction={{onAction}}
          />
        </template>
      );

      const listbox = document.querySelector(
        '[data-component="listbox"]'
      ) as HTMLElement;

      listbox.dispatchEvent(
        new KeyboardEvent('keydown', { key: 'c', bubbles: true })
      );
      listbox.dispatchEvent(
        new KeyboardEvent('keydown', { key: 'r', bubbles: true })
      );
      listbox.dispatchEvent(
        new KeyboardEvent('keydown', { key: 'Enter', bubbles: true })
      );
      await settled();

      assert.deepEqual(
        selected,
        ['crocodile'],
        'type-ahead matched crocodile and the immediate Enter selected it'
      );
    });

    test('Space is still a search character while a search is active', async function (assert) {
      // The half of the guard that must NOT change: Space is a legitimate
      // type-ahead character per the WAI-ARIA APG while a search buffer is
      // already non-empty, and must only *select* when no search is active.
      //
      // Each keystroke is dispatched natively and synchronously, with no
      // `await` in between -- an awaited `triggerKeyEvent` between letters
      // would chain `settled()`, which waits out the pending 500ms
      // `#clearSearch` debounce and clears the buffer before the next
      // letter arrives, collapsing "big d" down to a single leftover
      // character. See the file-level note on the type-ahead-then-Enter
      // test above for the same hazard.
      await render(
        <template>
          <Listbox
            @isKeyboardEventsEnabled={{true}}
            @selectionMode="none"
            as |l|
          >
            <l.Item @key="big-cat">Big Cat</l.Item>
            <l.Item @key="big-dog">Big Dog</l.Item>
          </Listbox>
        </template>
      );

      const listbox = document.querySelector(
        '[data-component="listbox"]'
      ) as HTMLElement;

      for (const key of ['b', 'i', 'g', ' ', 'd']) {
        listbox.dispatchEvent(
          new KeyboardEvent('keydown', { key, bubbles: true })
        );
      }
      await settled();

      assert
        .dom('[data-key="big-dog"]')
        .hasAttribute(
          'data-active',
          'true',
          'Space extended the search buffer to "big d", matching Big Dog'
        );
      assert.dom('[data-key="big-cat"]').hasAttribute('data-active', 'false');
    });

    test('Enter still selects when another keydown handler calls preventDefault', async function (assert) {
      // The whole justification for handling keys on `keydown` instead of the
      // deprecated `keypress`. A browser only fires `keypress` when the
      // preceding `keydown` was NOT canceled, so any co-located handler that
      // calls `preventDefault()` on keydown -- Dropdown's submenu keys, a
      // consuming app's own shortcut handler, Autocomplete's form-submission
      // guard -- silently deletes the `keypress` event Listbox used to rely
      // on, and Enter selection just stops working with no error.
      //
      // `pressKey` reproduces that browser behaviour faithfully rather than
      // dispatching a `keypress` that a real browser would never have
      // delivered. Dispatch stays synchronous and native: no `await` between
      // keystrokes, so a pending type-ahead debounce cannot make this
      // vacuously pass. See the regression test above for the full rationale.
      const animals = ['cheetah', 'crocodile', 'elephant'];
      const selected: string[] = [];
      const onAction = (key: string) => selected.push(key);

      // Stands in for any sibling keydown listener on the same <ul>, the way
      // Dropdown's Menu attaches its submenu keys through `...attributes`.
      const cancelKeydown = modifier((el: HTMLElement) => {
        const handler = (event: KeyboardEvent) => event.preventDefault();
        el.addEventListener('keydown', handler);
        return () => el.removeEventListener('keydown', handler);
      });

      await render(
        <template>
          <Listbox
            @isKeyboardEventsEnabled={{true}}
            @selectionMode="none"
            @items={{animals}}
            @onAction={{onAction}}
            {{cancelKeydown}}
          />
        </template>
      );

      const listbox = document.querySelector(
        '[data-component="listbox"]'
      ) as HTMLElement;

      pressKey(listbox, 'Enter');
      await settled();

      assert.deepEqual(
        selected,
        ['cheetah'],
        'Enter selected the active item even though keydown was canceled'
      );
    });

    test('modifier-combo shortcuts do not leak into the type-ahead buffer', async function (assert) {
      // `keypress` largely did not fire for modifier combinations; `keydown`
      // does, and it reports a printable `key`: Cmd+K arrives as
      // `key === 'k'`. A bare `key.length === 1` check would type that into
      // the search buffer and steal the user's shortcut. Shift is exempt --
      // a capital letter is legitimate type-ahead, asserted below.
      const animals = ['cheetah', 'crocodile', 'elephant'];

      await render(
        <template>
          <Listbox
            @isKeyboardEventsEnabled={{true}}
            @selectionMode="none"
            @items={{animals}}
          />
        </template>
      );

      const listbox = document.querySelector(
        '[data-component="listbox"]'
      ) as HTMLElement;

      for (const modifier of ['metaKey', 'ctrlKey', 'altKey']) {
        listbox.dispatchEvent(
          new KeyboardEvent('keydown', {
            key: 'e',
            code: 'KeyE',
            bubbles: true,
            [modifier]: true
          })
        );
      }
      await settled();

      assert
        .dom('[data-key="elephant"]')
        .hasAttribute(
          'data-active',
          'false',
          'Cmd+E / Ctrl+E / Alt+E did not type-ahead to elephant'
        );
      assert
        .dom('[data-key="cheetah"]')
        .hasAttribute('data-active', 'true', 'the active item never moved');

      // Shift must still reach type-ahead, or capital letters stop working.
      listbox.dispatchEvent(
        new KeyboardEvent('keydown', {
          key: 'E',
          code: 'KeyE',
          bubbles: true,
          shiftKey: true
        })
      );
      await settled();

      assert
        .dom('[data-key="elephant"]')
        .hasAttribute(
          'data-active',
          'true',
          'Shift+E is a legitimate type-ahead character'
        );
    });

    test('modifier combos do not trigger Enter or Space selection', async function (assert) {
      // The same leak as type-ahead, on the selection paths. `keypress`
      // filtered modifier combos out for free; `keydown` delivers Cmd+Enter,
      // Ctrl+Space and Cmd+Space (Spotlight) with an unchanged `key`, and
      // acting on those both steals an OS/app shortcut and selects something
      // the user never asked for.
      const animals = ['cheetah', 'crocodile'];
      const selected: string[] = [];
      const onAction = (key: string) => selected.push(key);

      await render(
        <template>
          <Listbox
            @isKeyboardEventsEnabled={{true}}
            @selectionMode="none"
            @items={{animals}}
            @onAction={{onAction}}
          />
        </template>
      );

      const listbox = document.querySelector(
        '[data-component="listbox"]'
      ) as HTMLElement;

      for (const key of ['Enter', ' ']) {
        for (const modifier of ['metaKey', 'ctrlKey', 'altKey']) {
          listbox.dispatchEvent(
            new KeyboardEvent('keydown', {
              key,
              bubbles: true,
              [modifier]: true
            })
          );
        }
      }
      await settled();

      assert.deepEqual(selected, [], 'no modifier combo selected anything');

      // Unmodified Enter still selects, so the guard is not simply inert.
      listbox.dispatchEvent(
        new KeyboardEvent('keydown', { key: 'Enter', bubbles: true })
      );
      await settled();

      assert.deepEqual(selected, ['cheetah'], 'plain Enter still selects');
    });

    test('autorepeat from a held key does not extend the search buffer', async function (assert) {
      // A held key autorepeats under `keydown`, which `keypress` never
      // exposed here. `search()` accumulates a prefix rather than cycling
      // between same-initial items, so honouring repeats would turn a
      // leaned-on 'a' into the buffer "aa" and jump the user elsewhere.
      //
      // The item labels make that jump observable: "a" matches Apple (first
      // in DOM order) while "aa" matches Aardvark. Asserting only that Apple
      // stays active would pass vacuously, because a buffer matching nothing
      // leaves the active item exactly where it already was.
      const items = ['Apple', 'Aardvark'];

      await render(
        <template>
          <Listbox
            @isKeyboardEventsEnabled={{true}}
            @selectionMode="none"
            @items={{items}}
          />
        </template>
      );

      const listbox = document.querySelector(
        '[data-component="listbox"]'
      ) as HTMLElement;

      // Synchronous and native: an `await` here would let the 500ms
      // type-ahead debounce clear the buffer between keystrokes and hide a
      // regression. See the Enter-after-type-ahead test above.
      listbox.dispatchEvent(
        new KeyboardEvent('keydown', { key: 'a', bubbles: true })
      );
      for (let i = 0; i < 2; i++) {
        listbox.dispatchEvent(
          new KeyboardEvent('keydown', {
            key: 'a',
            bubbles: true,
            repeat: true
          })
        );
      }
      await settled();

      assert
        .dom('[data-key="Apple"]')
        .hasAttribute(
          'data-active',
          'true',
          'the buffer stayed "a" and kept matching Apple'
        );
      assert
        .dom('[data-key="Aardvark"]')
        .hasAttribute(
          'data-active',
          'false',
          'autorepeat did not extend the buffer to "aa"'
        );
    });

    test('IME composition keystrokes are left to the input method', async function (assert) {
      // A mid-composition `keydown` still reports a printable `key`, but the
      // keystroke belongs to the IME, not to type-ahead. Same observable
      // labels as the autorepeat test above, for the same reason.
      const items = ['Apple', 'Aardvark'];

      await render(
        <template>
          <Listbox
            @isKeyboardEventsEnabled={{true}}
            @selectionMode="none"
            @items={{items}}
          />
        </template>
      );

      const listbox = document.querySelector(
        '[data-component="listbox"]'
      ) as HTMLElement;

      listbox.dispatchEvent(
        new KeyboardEvent('keydown', { key: 'a', bubbles: true })
      );
      listbox.dispatchEvent(
        new KeyboardEvent('keydown', {
          key: 'a',
          bubbles: true,
          isComposing: true
        })
      );
      await settled();

      assert
        .dom('[data-key="Apple"]')
        .hasAttribute(
          'data-active',
          'true',
          'the composing keystroke did not extend the buffer to "aa"'
        );
      assert.dom('[data-key="Aardvark"]').hasAttribute('data-active', 'false');
    });

    test('Space selects the active item when no search is active', async function (assert) {
      const onAction: string[] = [];
      const handleAction = (key: string) => onAction.push(key);

      await render(
        <template>
          <Listbox
            @isKeyboardEventsEnabled={{true}}
            @selectionMode="none"
            @onAction={{handleAction}}
            as |l|
          >
            <l.Item @key="item-1">Item 1</l.Item>
            <l.Item @key="item-2">Item 2</l.Item>
          </Listbox>
        </template>
      );

      // `@autoActivateMode` defaults to "first", so item-1 is already active
      // without any navigation.
      await triggerKeyEvent('[data-component="listbox"]', 'keydown', ' ');

      assert.deepEqual(
        onAction,
        ['item-1'],
        'Space with no search active selected the active item'
      );
    });

    test('it derives textValue from a document-scoped aria-labelledby', async function (assert) {
      // `aria-labelledby` points at ids anywhere in the document and holds a
      // space-separated *list* of them — neither of which a scoped
      // `#id` selector can express.
      await render(
        <template>
          <span id="external.label">Zebra</span>
          <span id="external-second">Yak</span>

          <Listbox
            @selectionMode="none"
            @isKeyboardEventsEnabled={{true}}
            @autoActivateMode="none"
            as |l|
          >
            <l.Item @key="item-1" aria-labelledby="external.label">
              Ignored one
            </l.Item>
            <l.Item @key="item-2" aria-labelledby="external-second another-id">
              Ignored two
            </l.Item>
          </Listbox>
        </template>
      );

      await triggerKeyEvent('[data-component="listbox"]', 'keydown', 'Z');
      assert
        .dom('[data-key="item-1"]')
        .hasAttribute(
          'data-active',
          'true',
          'should have matched the external label text'
        );

      await triggerKeyEvent('[data-component="listbox"]', 'keydown', 'Y');
      assert
        .dom('[data-key="item-2"]')
        .hasAttribute(
          'data-active',
          'true',
          'should have matched the first id of a multi-id aria-labelledby'
        );
    });

    test('it falls back to the item text when aria-labelledby cannot be resolved', async function (assert) {
      await render(
        <template>
          <Listbox
            @selectionMode="none"
            @isKeyboardEventsEnabled={{true}}
            @autoActivateMode="none"
            as |l|
          >
            <l.Item @key="item-1" aria-labelledby="does-not-exist">
              Zebra
            </l.Item>
            <l.Item @key="item-2">Yak</l.Item>
          </Listbox>
        </template>
      );

      // A search that matches nothing leaves the previously active item
      // active, so match the other item first to make this discriminating.
      await triggerKeyEvent('[data-component="listbox"]', 'keydown', 'Y');
      assert.dom('[data-key="item-2"]').hasAttribute('data-active', 'true');

      await triggerKeyEvent('[data-component="listbox"]', 'keydown', 'Z');
      assert
        .dom('[data-key="item-1"]')
        .hasAttribute('data-active', 'true', 'should have used its own text');
      assert.dom('[data-key="item-2"]').hasAttribute('data-active', 'false');
    });

    test('an explicit @textValue wins over aria-labelledby', async function (assert) {
      await render(
        <template>
          <span id="external.label">Yak</span>

          <Listbox
            @selectionMode="none"
            @isKeyboardEventsEnabled={{true}}
            @autoActivateMode="none"
            as |l|
          >
            <l.Item
              @key="item-1"
              @textValue="Zebra"
              aria-labelledby="external.label"
            >
              Ignored
            </l.Item>
            <l.Item @key="item-2">Yak</l.Item>
          </Listbox>
        </template>
      );

      await triggerKeyEvent('[data-component="listbox"]', 'keydown', 'Z');
      assert
        .dom('[data-key="item-1"]')
        .hasAttribute('data-active', 'true', 'should have used @textValue');

      await triggerKeyEvent('[data-component="listbox"]', 'keydown', 'Y');
      assert
        .dom('[data-key="item-2"]')
        .hasAttribute(
          'data-active',
          'true',
          'the labelled text must not have won over @textValue'
        );
      assert.dom('[data-key="item-1"]').hasAttribute('data-active', 'false');
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
          '[data-component="listbox"]',
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
          '[data-component="listbox"]',
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

      assert.dom('[data-component="listbox"]').exists();
      assert.dom('[data-key="item-1"]').exists();
      assert.dom('[data-key="item-1"] [data-part="label"]').exists();
      assert.dom('[data-key="item-1"] [data-part="label"]').hasText('Item 1');

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
      await triggerKeyEvent(
        '[data-component="listbox"]',
        'keydown',
        'ArrowDown'
      );
      await triggerKeyEvent(
        '[data-component="listbox"]',
        'keydown',
        'ArrowDown'
      );

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
      await triggerKeyEvent('[data-test-input]', 'keydown', 'E');
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
              shortcut: ['shortcut'],
              submenuIndicator: ['submenu-indicator']
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
          .dom('[data-component="listbox"]')
          .doesNotHaveAttribute(
            'aria-multiselectable',
            'absent for single selection'
          );

        selectionMode.current = 'multiple';
        await settled();

        assert
          .dom('[data-component="listbox"]')
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
          .dom('[data-component="listbox"]')
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
    /**
     * `Listbox` builds its `ListManager` in a field initializer, so every
     * callback it hands over is captured once, at construction. The `setup`
     * modifier is the only thing that runs again when arguments change, so
     * unless the callbacks travel through it too, a `Listbox` whose
     * `@onAction` is rebuilt each render -- `{{fn this.pick group.id}}` inside
     * an `{{#each}}`, the shape that makes this visible -- keeps calling the
     * closure from the very first render, with the very first `group.id`.
     */
    module('callbacks replaced between renders', function () {
      test('a replaced @onAction is the one invoked', async function (assert) {
        const calls: string[] = [];
        const handlers = {
          first: (key: string) => calls.push(`first:${key}`),
          second: (key: string) => calls.push(`second:${key}`)
        };
        const which = cell<'first' | 'second'>('first');

        await render(
          <template>
            <Listbox
              @selectionMode="none"
              @autoActivateMode="none"
              @items={{array "cheetah"}}
              @onAction={{get handlers which.current}}
            />
          </template>
        );

        await click('[data-key="cheetah"]');
        assert.deepEqual(calls, ['first:cheetah'], 'the first closure ran');

        which.current = 'second';
        await settled();

        await click('[data-key="cheetah"]');
        assert.deepEqual(
          calls,
          ['first:cheetah', 'second:cheetah'],
          'the replacement closure ran, not the captured original'
        );
      });

      test('a replaced @onSelectionChange is the one invoked', async function (assert) {
        const calls: string[] = [];
        const handlers = {
          first: (keys: string[]) => calls.push(`first:${keys.join()}`),
          second: (keys: string[]) => calls.push(`second:${keys.join()}`)
        };
        const which = cell<'first' | 'second'>('first');

        await render(
          <template>
            <Listbox
              @selectionMode="multiple"
              @autoActivateMode="none"
              @items={{array "cheetah"}}
              @onSelectionChange={{get handlers which.current}}
            />
          </template>
        );

        await click('[data-key="cheetah"]');
        assert.deepEqual(calls, ['first:cheetah'], 'the first closure ran');

        which.current = 'second';
        await settled();

        await click('[data-key="cheetah"]');
        assert.deepEqual(
          calls,
          ['first:cheetah', 'second:cheetah'],
          'the replacement closure ran, not the captured original'
        );
      });

      test('a replaced @onActiveItemChange is the one invoked', async function (assert) {
        const calls: string[] = [];
        const handlers = {
          first: (key?: string) => calls.push(`first:${key}`),
          second: (key?: string) => calls.push(`second:${key}`)
        };
        const which = cell<'first' | 'second'>('first');

        await render(
          <template>
            <Listbox
              @selectionMode="none"
              @autoActivateMode="none"
              @isKeyboardEventsEnabled={{true}}
              @items={{array "cheetah" "crocodile"}}
              @onActiveItemChange={{get handlers which.current}}
            />
          </template>
        );

        await triggerKeyEvent(
          '[data-component="listbox"]',
          'keydown',
          'ArrowDown'
        );
        assert.deepEqual(calls, ['first:cheetah'], 'the first closure ran');

        which.current = 'second';
        await settled();

        await triggerKeyEvent(
          '[data-component="listbox"]',
          'keydown',
          'ArrowDown'
        );
        assert.deepEqual(
          calls,
          ['first:cheetah', 'second:crocodile'],
          'the replacement closure ran, not the captured original'
        );
      });
    });

    /**
     * The WAI-ARIA listbox pattern allows exactly one tabbable option: the
     * options form a composite the user steps *into* once and then navigates
     * with the arrow keys. Handing `tabindex="0"` to every selected option
     * turned an eight-selection multi-select into eight tab stops.
     */
    module('roving tabindex', function () {
      const tabbableKeys = () =>
        [
          ...document.querySelectorAll(
            '[data-component="listbox-item"][tabindex="0"]'
          )
        ].map((el) => (el as HTMLElement).dataset['key']);

      test('several selected options still make a single tab stop', async function (assert) {
        const animals = ['cheetah', 'crocodile', 'elephant', 'flamingo'];

        await render(
          <template>
            <Listbox
              @selectionMode="multiple"
              @autoActivateMode="none"
              @items={{animals}}
              @selectedKeys={{array "crocodile" "elephant" "flamingo"}}
            />
          </template>
        );

        assert
          .dom('[data-key="crocodile"]')
          .hasAttribute('data-selected', 'true');
        assert
          .dom('[data-key="elephant"]')
          .hasAttribute('data-selected', 'true');
        assert
          .dom('[data-key="flamingo"]')
          .hasAttribute('data-selected', 'true');

        assert.deepEqual(
          tabbableKeys(),
          ['crocodile'],
          'only the first selected option is tabbable'
        );
      });

      test('the tab stop follows the active option', async function (assert) {
        const animals = ['cheetah', 'crocodile', 'elephant'];

        await render(
          <template>
            <Listbox
              @selectionMode="multiple"
              @autoActivateMode="none"
              @isKeyboardEventsEnabled={{true}}
              @items={{animals}}
              @selectedKeys={{array "crocodile"}}
            />
          </template>
        );

        assert.deepEqual(
          tabbableKeys(),
          ['crocodile'],
          'the selection owns the tab stop while nothing is active, ahead of the first option'
        );

        // Navigation starts from the selection when nothing is active yet, so
        // this steps onto the option after it.
        await triggerKeyEvent(
          '[data-component="listbox"]',
          'keydown',
          'ArrowDown'
        );
        assert.dom('[data-key="elephant"]').hasAttribute('data-active', 'true');
        assert.deepEqual(
          tabbableKeys(),
          ['elephant'],
          'the active option takes the tab stop over from the selection'
        );

        await triggerKeyEvent(
          '[data-component="listbox"]',
          'keydown',
          'ArrowUp'
        );
        assert
          .dom('[data-key="crocodile"]')
          .hasAttribute('data-active', 'true');
        assert.deepEqual(
          tabbableKeys(),
          ['crocodile'],
          'the tab stop moves with the active option'
        );
      });

      test('the first option owns the tab stop when nothing is active or selected', async function (assert) {
        const animals = ['cheetah', 'crocodile', 'elephant'];

        await render(
          <template>
            <Listbox
              @selectionMode="none"
              @autoActivateMode="none"
              @items={{animals}}
            />
          </template>
        );

        assert.deepEqual(
          tabbableKeys(),
          ['cheetah'],
          'a list nobody has touched yet is still reachable by Tab'
        );
      });

      test('a disabled option is skipped by the tab stop fallback', async function (assert) {
        const animals = ['cheetah', 'crocodile', 'elephant'];

        await render(
          <template>
            <Listbox
              @selectionMode="none"
              @autoActivateMode="none"
              @disabledKeys={{array "cheetah"}}
              @items={{animals}}
            />
          </template>
        );

        assert.deepEqual(
          tabbableKeys(),
          ['crocodile'],
          'the tab stop lands on the first option a user can actually act on'
        );
      });
    });

    test('a sub-trigger item carries submenu aria attributes and never selects', async function (assert) {
      const actions: string[] = [];
      const onAction = (key: string) => {
        actions.push(key);
      };

      await render(
        <template>
          <Listbox @type="menu" @onAction={{onAction}} as |l|>
            <l.Item @key="plain">Plain</l.Item>
            <l.Item
              @key="parent"
              @hasSubmenu={{true}}
              @isSubmenuOpen={{false}}
              @submenuId="my-submenu"
            >More</l.Item>
          </Listbox>
        </template>
      );

      assert.dom('[data-key="parent"]').hasAria('haspopup', 'menu');
      assert.dom('[data-key="parent"]').hasAria('expanded', 'false');
      assert.dom('[data-key="parent"]').hasAria('controls', 'my-submenu');
      assert
        .dom('[data-key="parent"]')
        .hasAttribute('data-submenu-open', 'false');
      assert
        .dom(
          '[data-key="parent"] [data-test-id="listbox-item-submenu-indicator"]'
        )
        .exists('renders the chevron');

      // A plain item is untouched by the new args.
      assert.dom('[data-key="plain"]').doesNotHaveAria('haspopup');
      assert
        .dom(
          '[data-key="plain"] [data-test-id="listbox-item-submenu-indicator"]'
        )
        .doesNotExist();

      // Clicking a sub-trigger must not fire onAction -- opening is not choosing.
      await click('[data-key="parent"]');
      assert.deepEqual(actions, [], 'sub-trigger fired no action');

      await click('[data-key="plain"]');
      assert.deepEqual(actions, ['plain'], 'a plain item still fires');
    });

    test('an open sub-trigger reports aria-expanded and data-submenu-open', async function (assert) {
      await render(
        <template>
          <Listbox @type="menu" as |l|>
            <l.Item @key="parent" @hasSubmenu={{true}} @isSubmenuOpen={{true}}>
              More
            </l.Item>
          </Listbox>
        </template>
      );

      assert.dom('[data-key="parent"]').hasAria('expanded', 'true');
      assert
        .dom('[data-key="parent"]')
        .hasAttribute('data-submenu-open', 'true');
    });

    test('an explicit :end block wins over the submenu chevron', async function (assert) {
      await render(
        <template>
          <Listbox @type="menu" as |l|>
            <l.Item @key="parent" @hasSubmenu={{true}}>
              <:default>More</:default>
              <:end><span data-test-id="custom-end">custom</span></:end>
            </l.Item>
          </Listbox>
        </template>
      );

      assert.dom('[data-test-id="custom-end"]').exists();
      assert
        .dom('[data-test-id="listbox-item-submenu-indicator"]')
        .doesNotExist('the default chevron steps aside');
    });

    module('anatomy', function () {
      test('listbox item and group are components, not parts', async function (assert) {
        await render(
          <template>
            <Listbox as |l|>
              <l.Group @title="G">
                <l.Item @key="a" @description="desc">A</l.Item>
              </l.Group>
            </Listbox>
          </template>
        );

        assert
          .dom('[data-component="listbox-group"]')
          .hasAttribute('data-part', 'base');
        assert
          .dom('[data-component="listbox-item"]')
          .hasAttribute('data-part', 'base');
        assert
          .dom('[data-component="listbox-group"] [data-part="title"]')
          .exists();
        assert
          .dom('[data-component="listbox-group"] [data-part="list"]')
          .exists();
        assert
          .dom('[data-component="listbox-item"] [data-part="label"]')
          .exists();
        assert
          .dom(
            '[data-component="listbox-item"] [data-part="description-wrapper"]'
          )
          .exists();
        assert
          .dom('[data-component="listbox-item"] [data-part="description"]')
          .exists();
        assert.strictEqual(
          document.querySelectorAll('[data-component="listbox-group"]').length,
          1,
          'data-component="listbox-group" marks the root only, never a part'
        );
        assert.strictEqual(
          document.querySelectorAll('[data-component="listbox-item"]').length,
          1,
          'data-component="listbox-item" marks the root only, never a part'
        );
      });

      test('listbox group renders a data-part="divider" when @withDivider is set', async function (assert) {
        await render(
          <template>
            <Listbox as |l|>
              <l.Group @title="G" @withDivider={{true}}>
                <l.Item @key="a">A</l.Item>
              </l.Group>
            </Listbox>
          </template>
        );

        assert.dom('[data-part="divider"]').exists();
      });

      test('a selected item renders data-part="selected-icon"', async function (assert) {
        await render(
          <template>
            <Listbox @selectedKeys={{array "a"}} as |l|>
              <l.Item @key="a">A</l.Item>
            </Listbox>
          </template>
        );

        assert
          .dom('[data-component="listbox-item"] [data-part="selected-icon"]')
          .exists();
      });

      test('a submenu trigger renders data-part="submenu-indicator"', async function (assert) {
        await render(
          <template>
            <Listbox @type="menu" as |l|>
              <l.Item @key="parent" @hasSubmenu={{true}}>More</l.Item>
            </Listbox>
          </template>
        );

        assert
          .dom(
            '[data-component="listbox-item"] [data-part="submenu-indicator"]'
          )
          .exists();
      });
    });
  }
);
