import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import {
  click,
  render,
  triggerKeyEvent,
  triggerEvent
} from '@ember/test-helpers';
import { registerCustomStyles } from '@frontile/theme';
import { tv } from 'tailwind-variants';
import { Dropdown } from 'frontile';
import { cell } from 'ember-resources';
import { settled } from '@ember/test-helpers';

module(
  'Integration | Component | Dropdown | @frontile/collections',
  function (hooks) {
    setupRenderingTest(hooks);

    registerCustomStyles({
      backdrop: tv({ base: 'overlay__backdrop' }) as never,
      overlay: tv({
        base: 'overlay__content',
        variants: {
          inPlace: {
            true: 'overlay--in-place'
          }
        }
      }) as never
    });

    test('it renders the trigger and menu when opened', async function (assert) {
      const clickedOn: string[] = [];
      const onAction = (key: string) => {
        clickedOn.push(key);
      };

      await render(
        <template>
          <Dropdown as |d|>
            <d.Trigger @intent="primary" @size="sm">Dropdown</d.Trigger>

            <d.Menu
              @onAction={{onAction}}
              @intent="primary"
              @disableTransitions={{true}}
              as |Item|
            >
              <Item @key="profile">My Profile</Item>
              <Item @key="settings">Settings</Item>
            </d.Menu>
          </Dropdown>
        </template>
      );

      assert.dom('[data-component="listbox"]').doesNotExist();
      await click('[data-test-id="dropdown-trigger"]');

      assert.dom('[data-component="listbox"]').exists();

      assert.dom('[data-key="profile"]').exists();
      assert.dom('[data-key="settings"]').exists();

      await click('[data-key="profile"]');

      assert.deepEqual(clickedOn, ['profile']);
    });

    test('it renders accessibility attributes', async function (assert) {
      await render(
        <template>
          <Dropdown as |d|>
            <d.Trigger @intent="primary" @size="sm">Dropdown</d.Trigger>

            <d.Menu @disableTransitions={{true}} as |Item|>
              <Item @key="profile">My Profile</Item>
              <Item @key="settings">Settings</Item>
            </d.Menu>
          </Dropdown>
        </template>
      );

      assert
        .dom('[data-test-id="dropdown-trigger"]')
        .hasAria('haspopup', 'true');
      assert
        .dom('[data-test-id="dropdown-trigger"]')
        .hasAria('expanded', 'false');
      assert
        .dom('[data-test-id="dropdown-trigger"]')
        .hasAttribute('aria-controls');

      await click('[data-test-id="dropdown-trigger"]');

      assert
        .dom('[data-test-id="dropdown-trigger"]')
        .hasAria('expanded', 'true');
    });

    test('it shows backdrop when @backdrop=none', async function (assert) {
      const backdrop = cell<'none' | 'faded'>('none');

      await render(
        <template>
          <Dropdown as |d|>
            <d.Trigger @intent="primary" @size="sm">Dropdown</d.Trigger>

            <d.Menu
              @backdrop={{backdrop.current}}
              @disableTransitions={{true}}
              as |Item|
            >
              <Item @key="profile">My Profile</Item>
              <Item @key="settings">Settings</Item>
            </d.Menu>
          </Dropdown>
        </template>
      );

      await click('[data-test-id="dropdown-trigger"]');

      assert.dom('.overlay__backdrop').doesNotExist();

      backdrop.current = 'faded';
      await settled();

      assert.dom('.overlay__backdrop').exists();
    });

    test('on item click, closes menu, calls @didClose', async function (assert) {
      let calledClosed = false;
      const didClose = () => {
        calledClosed = true;
      };

      await render(
        <template>
          <Dropdown @didClose={{didClose}} as |d|>
            <d.Trigger @intent="primary" @size="sm">Dropdown</d.Trigger>

            <d.Menu @disableTransitions={{true}} as |Item|>
              <Item @key="profile">My Profile</Item>
              <Item @key="settings">Settings</Item>
            </d.Menu>
          </Dropdown>
        </template>
      );

      assert.dom('[data-component="listbox"]').doesNotExist();
      await click('[data-test-id="dropdown-trigger"]');
      assert.dom('[data-component="listbox"]').exists();

      await click('[data-key="profile"]');
      assert.dom('[data-component="listbox"]').doesNotExist();
      assert.equal(calledClosed, true, 'should called didClose argument');
    });

    test('on item click, does not close menu when @closeOnItemSelect=false', async function (assert) {
      await render(
        <template>
          <Dropdown @closeOnItemSelect={{false}} as |d|>
            <d.Trigger @intent="primary" @size="sm">Dropdown</d.Trigger>

            <d.Menu @disableTransitions={{true}} as |Item|>
              <Item @key="profile">My Profile</Item>
              <Item @key="settings">Settings</Item>
            </d.Menu>
          </Dropdown>
        </template>
      );

      assert.dom('[data-component="listbox"]').doesNotExist();
      await click('[data-test-id="dropdown-trigger"]');
      assert.dom('[data-component="listbox"]').exists();

      await click('[data-key="profile"]');
      assert.dom('[data-component="listbox"]').exists();
    });

    test('clicking outside closes menu', async function (assert) {
      let calledClosed = false;
      const didClose = () => {
        calledClosed = true;
      };

      await render(
        <template>
          <div id="outside" tabindex="0"></div>
          <Dropdown @didClose={{didClose}} as |d|>
            <d.Trigger @intent="primary" @size="sm">Dropdown</d.Trigger>

            <d.Menu @disableTransitions={{true}} as |Item|>
              <Item @key="profile">My Profile</Item>
              <Item @key="settings">Settings</Item>
            </d.Menu>
          </Dropdown>
        </template>
      );

      assert.dom('[data-component="listbox"]').doesNotExist();
      await click('[data-test-id="dropdown-trigger"]');
      assert.dom('[data-component="listbox"]').exists();

      await click('#outside');
      assert.dom('[data-component="listbox"]').doesNotExist();
      assert.equal(calledClosed, true, 'should called didClose argument');
    });

    test('clicking outside closes the whole chain while a submenu is open', async function (assert) {
      await render(
        <template>
          <div id="outside" tabindex="0"></div>
          <Dropdown as |d|>
            <d.Trigger>Options</d.Trigger>
            <d.Menu @disableTransitions={{true}} as |Item Sub|>
              <Item @key="edit">Edit</Item>
              <Sub as |s|>
                <s.Trigger>More</s.Trigger>
                <s.Menu as |Item|>
                  <Item @key="nested">Nested</Item>
                </s.Menu>
              </Sub>
            </d.Menu>
          </Dropdown>
        </template>
      );

      await click('[data-test-id="dropdown-trigger"]');
      await click('[data-test-id="dropdown-submenu-trigger"]');

      assert.dom('[data-key="nested"]').exists('submenu is open');
      assert.dom('[data-key="edit"]').exists('root menu is open');

      await click('#outside');

      assert.dom('[data-key="nested"]').doesNotExist('submenu item is gone');
      assert.dom('[data-key="edit"]').doesNotExist('root item is gone');
    });

    test('on pressing arrow up/down key, opens the menu', async function (assert) {
      await render(
        <template>
          <Dropdown as |d|>
            <d.Trigger @intent="primary" @size="sm">Dropdown</d.Trigger>

            <d.Menu @disableTransitions={{true}} as |Item|>
              <Item @key="profile">My Profile</Item>
              <Item @key="settings">Settings</Item>
            </d.Menu>
          </Dropdown>
        </template>
      );

      assert.dom('[data-component="listbox"]').doesNotExist();
      await triggerKeyEvent(
        '[data-test-id="dropdown-trigger"]',
        'keyup',
        'ArrowDown'
      );

      assert.dom('[data-component="listbox"]').exists();
    });

    test('it opens with Enter on the trigger', async function (assert) {
      await render(
        <template>
          <Dropdown as |d|>
            <d.Trigger>Dropdown</d.Trigger>

            <d.Menu @disableTransitions={{true}} as |Item|>
              <Item @key="profile">My Profile</Item>
            </d.Menu>
          </Dropdown>
        </template>
      );

      assert.dom('[data-component="listbox"]').doesNotExist();

      await triggerKeyEvent(
        '[data-test-id="dropdown-trigger"]',
        'keydown',
        'Enter'
      );
      await triggerKeyEvent(
        '[data-test-id="dropdown-trigger"]',
        'keyup',
        'Enter'
      );

      assert
        .dom('[data-component="listbox"]')
        .exists('Enter on a focused trigger opens the menu');
    });

    test('it opens with Space on the trigger', async function (assert) {
      await render(
        <template>
          <Dropdown as |d|>
            <d.Trigger>Dropdown</d.Trigger>

            <d.Menu @disableTransitions={{true}} as |Item|>
              <Item @key="profile">My Profile</Item>
            </d.Menu>
          </Dropdown>
        </template>
      );

      assert.dom('[data-component="listbox"]').doesNotExist();

      await triggerKeyEvent(
        '[data-test-id="dropdown-trigger"]',
        'keydown',
        ' '
      );
      await triggerKeyEvent('[data-test-id="dropdown-trigger"]', 'keyup', ' ');

      assert
        .dom('[data-component="listbox"]')
        .exists('Space on a focused trigger opens the menu');
    });

    test('it opens a submenu on click and fires the root onAction for a nested item', async function (assert) {
      const actions: string[] = [];
      const onAction = (key: string) => {
        actions.push(key);
      };

      await render(
        <template>
          <Dropdown as |d|>
            <d.Trigger>Options</d.Trigger>

            <d.Menu
              @onAction={{onAction}}
              @disableTransitions={{true}}
              as |Item Sub|
            >
              <Item @key="edit">Edit</Item>

              <Sub as |s|>
                <s.Trigger>More</s.Trigger>
                <s.Menu as |Item|>
                  <Item @key="move-project">Move to project</Item>
                  <Item @key="move-folder">Move to folder</Item>
                </s.Menu>
              </Sub>
            </d.Menu>
          </Dropdown>
        </template>
      );

      await click('[data-test-id="dropdown-trigger"]');
      assert.dom('[data-key="edit"]').exists('the root menu is open');
      assert.dom('[data-key="move-project"]').doesNotExist('submenu is closed');

      await click('[data-test-id="dropdown-submenu-trigger"]');

      assert.dom('[data-key="move-project"]').exists('the submenu opened');
      assert.dom('[data-key="edit"]').exists('the parent menu stayed open');
      assert.deepEqual(actions, [], 'opening a submenu fired no action');

      await click('[data-key="move-folder"]');

      assert.deepEqual(
        actions,
        ['move-folder'],
        'the root onAction saw the key'
      );
      assert.dom('[data-key="edit"]').doesNotExist('the whole chain closed');
    });

    test('a submenu trigger carries the submenu aria attributes', async function (assert) {
      await render(
        <template>
          <Dropdown as |d|>
            <d.Trigger>Options</d.Trigger>
            <d.Menu @disableTransitions={{true}} as |Item Sub|>
              <Item @key="edit">Edit</Item>
              <Sub as |s|>
                <s.Trigger>More</s.Trigger>
                <s.Menu as |Item|>
                  <Item @key="nested">Nested</Item>
                </s.Menu>
              </Sub>
            </d.Menu>
          </Dropdown>
        </template>
      );

      await click('[data-test-id="dropdown-trigger"]');

      const trigger = '[data-test-id="dropdown-submenu-trigger"]';
      assert.dom(trigger).hasAttribute('role', 'menuitem');
      assert.dom(trigger).hasAria('haspopup', 'menu');
      assert.dom(trigger).hasAria('expanded', 'false');

      await click(trigger);

      assert.dom(trigger).hasAria('expanded', 'true');

      const submenuId = document
        .querySelector(trigger)
        ?.getAttribute('aria-controls');
      assert.ok(submenuId, 'aria-controls points somewhere');
      assert
        .dom(`#${submenuId}`)
        .hasAttribute('role', 'menu', 'and it points at the submenu');
    });

    test('selection settings declared on the root menu reach submenu items', async function (assert) {
      let selected: string[] = [];
      const onSelectionChange = (keys: string[]) => {
        selected = keys;
      };

      await render(
        <template>
          <Dropdown as |d|>
            <d.Trigger>Options</d.Trigger>
            <d.Menu
              @selectionMode="single"
              @onSelectionChange={{onSelectionChange}}
              @closeOnItemSelect={{false}}
              @disableTransitions={{true}}
              as |Item Sub|
            >
              <Item @key="edit">Edit</Item>
              <Sub as |s|>
                <s.Trigger>More</s.Trigger>
                <s.Menu as |Item|>
                  <Item @key="nested">Nested</Item>
                </s.Menu>
              </Sub>
            </d.Menu>
          </Dropdown>
        </template>
      );

      await click('[data-test-id="dropdown-trigger"]');
      await click('[data-test-id="dropdown-submenu-trigger"]');
      await click('[data-key="nested"]');

      assert.deepEqual(
        selected,
        ['nested'],
        'the root selection handler fired'
      );
    });

    test('the existing single-block-param form still works', async function (assert) {
      const actions: string[] = [];
      const onAction = (key: string) => {
        actions.push(key);
      };

      await render(
        <template>
          <Dropdown as |d|>
            <d.Trigger>Options</d.Trigger>
            <d.Menu
              @onAction={{onAction}}
              @disableTransitions={{true}}
              as |Item|
            >
              <Item @key="only">Only</Item>
            </d.Menu>
          </Dropdown>
        </template>
      );

      await click('[data-test-id="dropdown-trigger"]');
      await click('[data-key="only"]');

      assert.deepEqual(actions, ['only'], 'no regression for as |Item|');
    });

    test('ArrowRight opens the submenu of the active item and highlights its first row', async function (assert) {
      await render(
        <template>
          <Dropdown as |d|>
            <d.Trigger>Options</d.Trigger>
            <d.Menu @disableTransitions={{true}} as |Item Sub|>
              <Item @key="edit">Edit</Item>
              <Sub as |s|>
                <s.Trigger>More</s.Trigger>
                <s.Menu as |Item|>
                  <Item @key="first-nested">First nested</Item>
                  <Item @key="second-nested">Second nested</Item>
                </s.Menu>
              </Sub>
            </d.Menu>
          </Dropdown>
        </template>
      );

      await click('[data-test-id="dropdown-trigger"]');

      // Walk down onto the sub-trigger: Edit, then More.
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
      assert
        .dom('[data-test-id="dropdown-submenu-trigger"]')
        .hasAttribute('data-active', 'true', 'the sub-trigger is active');

      await triggerKeyEvent(
        '[data-component="listbox"]',
        'keydown',
        'ArrowRight'
      );

      assert.dom('[data-key="first-nested"]').exists('ArrowRight opened it');
      assert
        .dom('[data-key="first-nested"]')
        .hasAttribute(
          'data-active',
          'true',
          'keyboard open highlights the first row'
        );
    });

    test('ArrowLeft closes the submenu and leaves the parent open', async function (assert) {
      await render(
        <template>
          <Dropdown as |d|>
            <d.Trigger>Options</d.Trigger>
            <d.Menu @disableTransitions={{true}} as |Item Sub|>
              <Item @key="edit">Edit</Item>
              <Sub as |s|>
                <s.Trigger>More</s.Trigger>
                <s.Menu as |Item|>
                  <Item @key="nested">Nested</Item>
                </s.Menu>
              </Sub>
            </d.Menu>
          </Dropdown>
        </template>
      );

      await click('[data-test-id="dropdown-trigger"]');
      await click('[data-test-id="dropdown-submenu-trigger"]');

      assert.dom('[data-key="nested"]').exists('open to begin with');

      const submenuId = document
        .querySelector('[data-test-id="dropdown-submenu-trigger"]')
        ?.getAttribute('aria-controls') as string;

      await triggerKeyEvent(`#${submenuId}`, 'keydown', 'ArrowLeft');

      assert.dom('[data-key="nested"]').doesNotExist('the submenu closed');
      assert.dom('[data-key="edit"]').exists('the parent stayed open');

      // The sub-trigger was made active when ArrowRight navigated onto it
      // (before the submenu even opened), and nothing on the submenu's own,
      // separate ListManager ever deactivates it — so it should still be
      // the parent level's active row, keeping the roving tabindex and the
      // highlight in agreement with where focus actually returns to.
      assert
        .dom('[data-test-id="dropdown-submenu-trigger"]')
        .hasAttribute(
          'data-active',
          'true',
          'the sub-trigger is still active after ArrowLeft'
        );
      assert
        .dom('[data-test-id="dropdown-submenu-trigger"]')
        .isFocused('and focus returned to it');
    });

    test('Escape closes only the innermost level', async function (assert) {
      await render(
        <template>
          <Dropdown as |d|>
            <d.Trigger>Options</d.Trigger>
            <d.Menu @disableTransitions={{true}} as |Item Sub|>
              <Item @key="edit">Edit</Item>
              <Sub as |s|>
                <s.Trigger>More</s.Trigger>
                <s.Menu as |Item|>
                  <Item @key="nested">Nested</Item>
                </s.Menu>
              </Sub>
            </d.Menu>
          </Dropdown>
        </template>
      );

      await click('[data-test-id="dropdown-trigger"]');
      await click('[data-test-id="dropdown-submenu-trigger"]');

      const submenuId = document
        .querySelector('[data-test-id="dropdown-submenu-trigger"]')
        ?.getAttribute('aria-controls') as string;

      await triggerKeyEvent(`#${submenuId}`, 'keydown', 'Escape');

      assert.dom('[data-key="nested"]').doesNotExist('the submenu closed');
      assert.dom('[data-key="edit"]').exists('the parent survived Escape');
    });

    test('Enter on a sub-trigger opens the submenu', async function (assert) {
      await render(
        <template>
          <Dropdown as |d|>
            <d.Trigger>Options</d.Trigger>
            <d.Menu @disableTransitions={{true}} as |Item Sub|>
              <Sub as |s|>
                <s.Trigger>More</s.Trigger>
                <s.Menu as |Item|>
                  <Item @key="nested">Nested</Item>
                </s.Menu>
              </Sub>
            </d.Menu>
          </Dropdown>
        </template>
      );

      await click('[data-test-id="dropdown-trigger"]');
      await triggerKeyEvent(
        '[data-component="listbox"]',
        'keydown',
        'ArrowDown'
      );
      await triggerKeyEvent('[data-component="listbox"]', 'keydown', 'Enter');

      assert.dom('[data-key="nested"]').exists('Enter opened the submenu');
    });

    test('a hover-opened submenu highlights nothing', async function (assert) {
      await render(
        <template>
          <Dropdown as |d|>
            <d.Trigger>Options</d.Trigger>
            <d.Menu @disableTransitions={{true}} as |Item Sub|>
              <Sub as |s|>
                <s.Trigger>More</s.Trigger>
                <s.Menu as |Item|>
                  <Item @key="nested">Nested</Item>
                </s.Menu>
              </Sub>
            </d.Menu>
          </Dropdown>
        </template>
      );

      await click('[data-test-id="dropdown-trigger"]');
      // A click is a pointer open, like a hover.
      await click('[data-test-id="dropdown-submenu-trigger"]');

      assert
        .dom('[data-key="nested"]')
        .hasAttribute(
          'data-active',
          'false',
          'pointer open highlights nothing'
        );
    });

    test('hovering a sub-trigger opens the submenu, and leaving closes it', async function (assert) {
      await render(
        <template>
          <Dropdown as |d|>
            <d.Trigger>Options</d.Trigger>
            <d.Menu @disableTransitions={{true}} as |Item Sub|>
              <Item @key="edit">Edit</Item>
              <Sub as |s|>
                <s.Trigger>More</s.Trigger>
                <s.Menu as |Item|>
                  <Item @key="nested">Nested</Item>
                </s.Menu>
              </Sub>
            </d.Menu>
          </Dropdown>
        </template>
      );

      await click('[data-test-id="dropdown-trigger"]');
      assert.dom('[data-key="nested"]').doesNotExist('closed at rest');

      await triggerEvent(
        '[data-test-id="dropdown-submenu-trigger"]',
        'pointerenter'
      );

      assert.dom('[data-key="nested"]').exists('hover opened it');

      // Leaving toward a sibling row -- straight out of the safe area.
      await triggerEvent(
        '[data-test-id="dropdown-submenu-trigger"]',
        'pointerleave'
      );

      assert.dom('[data-key="nested"]').doesNotExist('leaving closed it');
    });

    test('an immediate Enter after type-ahead onto a sub-trigger opens the submenu', async function (assert) {
      // Regression test for: type-ahead onto a submenu trigger, then press
      // Enter right away -- nothing happened until a second Enter, because
      // `handleKeyPress` guarded Enter on an empty search buffer, which the
      // 500ms `debounce`d clear had not yet emptied. This is the path the
      // bug was originally found on.
      //
      // Both keys are dispatched natively and synchronously, with no
      // `await` in between -- an awaited `triggerKeyEvent` chains
      // `settled()`, which would wait out the pending debounce and clear
      // the search buffer before Enter arrived, making this pass
      // vacuously against the broken code. Same technique as the
      // pointer-travel test above.
      await render(
        <template>
          <Dropdown as |d|>
            <d.Trigger>Options</d.Trigger>
            <d.Menu @disableTransitions={{true}} as |Item Sub|>
              <Item @key="edit">Edit</Item>
              <Sub as |s|>
                <s.Trigger>More</s.Trigger>
                <s.Menu as |Item|>
                  <Item @key="nested">Nested</Item>
                </s.Menu>
              </Sub>
            </d.Menu>
          </Dropdown>
        </template>
      );

      await click('[data-test-id="dropdown-trigger"]');
      assert.dom('[data-key="nested"]').doesNotExist('closed at rest');

      const listbox = document.querySelector(
        '[data-component="listbox"]'
      ) as HTMLElement;

      listbox.dispatchEvent(
        new KeyboardEvent('keydown', { key: 'm', bubbles: true })
      );
      listbox.dispatchEvent(
        new KeyboardEvent('keydown', { key: 'Enter', bubbles: true })
      );
      await settled();

      assert
        .dom('[data-key="nested"]')
        .exists(
          'type-ahead onto "More", then an immediate Enter, opened the submenu'
        );
    });

    test('the pointer may travel through the gap into the submenu', async function (assert) {
      await render(
        <template>
          <Dropdown as |d|>
            <d.Trigger>Options</d.Trigger>
            <d.Menu @disableTransitions={{true}} as |Item Sub|>
              <Item @key="edit">Edit</Item>
              <Sub as |s|>
                <s.Trigger>More</s.Trigger>
                <s.Menu as |Item|>
                  <Item @key="nested">Nested</Item>
                </s.Menu>
              </Sub>
            </d.Menu>
          </Dropdown>
        </template>
      );

      await click('[data-test-id="dropdown-trigger"]');
      await triggerEvent(
        '[data-test-id="dropdown-submenu-trigger"]',
        'pointerenter'
      );
      assert.dom('[data-key="nested"]').exists('open to begin with');

      const submenuId = document
        .querySelector('[data-test-id="dropdown-submenu-trigger"]')
        ?.getAttribute('aria-controls') as string;
      const submenu = document.querySelector(`#${submenuId}`) as HTMLElement;
      const box = submenu.getBoundingClientRect();

      // Leave the trigger, then move onto a point inside the submenu itself.
      //
      // The `pointerleave` is dispatched natively and synchronously, not via
      // an awaited `triggerEvent`: `triggerEvent` chains `settled()`, which
      // would not resolve until the pending `SUBMENU_CLOSE_DELAY` timer has
      // actually fired — defeating the point of this test, which is to move
      // the pointer into the submenu *before* that timer elapses. A native
      // dispatch reaches the same listener synchronously, with no floating
      // promise and no dependence on the relative timing of test-helper hooks.
      const trigger = document.querySelector(
        '[data-test-id="dropdown-submenu-trigger"]'
      ) as HTMLElement;
      trigger.dispatchEvent(
        new PointerEvent('pointerleave', { bubbles: true })
      );
      await triggerEvent(document, 'pointermove', {
        clientX: box.left + box.width / 2,
        clientY: box.top + box.height / 2
      });

      assert
        .dom('[data-key="nested"]')
        .exists('moving into the submenu kept it open');
    });

    test('closing a submenu returns focus to the parent level', async function (assert) {
      await render(
        <template>
          <Dropdown as |d|>
            <d.Trigger>Options</d.Trigger>
            <d.Menu @disableTransitions={{true}} as |Item Sub|>
              <Item @key="edit">Edit</Item>
              <Sub as |s|>
                <s.Trigger>More</s.Trigger>
                <s.Menu as |Item|>
                  <Item @key="nested">Nested</Item>
                </s.Menu>
              </Sub>
            </d.Menu>
          </Dropdown>
        </template>
      );

      await click('[data-test-id="dropdown-trigger"]');
      const parentListbox = document.querySelector(
        '[data-component="listbox"]'
      ) as HTMLElement;

      await click('[data-test-id="dropdown-submenu-trigger"]');

      const submenuId = document
        .querySelector('[data-test-id="dropdown-submenu-trigger"]')
        ?.getAttribute('aria-controls') as string;

      await triggerKeyEvent(`#${submenuId}`, 'keydown', 'ArrowLeft');

      assert.ok(
        parentListbox.contains(document.activeElement),
        'focus returned to the parent level after ArrowLeft'
      );

      await click('[data-test-id="dropdown-submenu-trigger"]');

      const submenuId2 = document
        .querySelector('[data-test-id="dropdown-submenu-trigger"]')
        ?.getAttribute('aria-controls') as string;

      await triggerKeyEvent(`#${submenuId2}`, 'keydown', 'Escape');

      assert.ok(
        parentListbox.contains(document.activeElement),
        'focus returned to the parent level after Escape'
      );
    });

    test('ArrowLeft at the root level does nothing', async function (assert) {
      await render(
        <template>
          <Dropdown as |d|>
            <d.Trigger>Options</d.Trigger>
            <d.Menu @disableTransitions={{true}} as |Item Sub|>
              <Item @key="edit">Edit</Item>
              <Sub as |s|>
                <s.Trigger>More</s.Trigger>
                <s.Menu as |Item|>
                  <Item @key="nested">Nested</Item>
                </s.Menu>
              </Sub>
            </d.Menu>
          </Dropdown>
        </template>
      );

      await click('[data-test-id="dropdown-trigger"]');
      assert.dom('[data-key="edit"]').exists('root menu is open');
      assert.dom('[data-key="nested"]').doesNotExist('submenu is closed');

      await triggerKeyEvent(
        '[data-component="listbox"]',
        'keydown',
        'ArrowLeft'
      );

      assert.dom('[data-key="edit"]').exists('root menu stayed open');
      assert.dom('[data-key="nested"]').doesNotExist('submenu did not open');
    });

    test('submenus nest to arbitrary depth', async function (assert) {
      const actions: string[] = [];
      const onAction = (key: string) => {
        actions.push(key);
      };

      await render(
        <template>
          <Dropdown as |d|>
            <d.Trigger>Share</d.Trigger>
            <d.Menu
              @onAction={{onAction}}
              @disableTransitions={{true}}
              as |Item Sub|
            >
              <Item @key="copy-link">Copy Link</Item>

              <Sub as |s1|>
                <s1.Trigger data-test-id="sub-1">Other</s1.Trigger>
                <s1.Menu as |Item Sub|>
                  <Item @key="whatsapp">WhatsApp</Item>

                  <Sub as |s2|>
                    <s2.Trigger data-test-id="sub-2">Email</s2.Trigger>
                    <s2.Menu as |Item|>
                      <Item @key="work-email">Work email</Item>
                      <Item @key="personal-email">Personal email</Item>
                    </s2.Menu>
                  </Sub>
                </s1.Menu>
              </Sub>
            </d.Menu>
          </Dropdown>
        </template>
      );

      await click('[data-test-id="dropdown-trigger"]');
      await click('[data-test-id="sub-1"]');

      assert.dom('[data-key="whatsapp"]').exists('level 1 opened');

      await click('[data-test-id="sub-2"]');

      assert.dom('[data-key="work-email"]').exists('level 2 opened');
      assert.dom('[data-key="whatsapp"]').exists('level 1 stayed open');
      assert.dom('[data-key="copy-link"]').exists('the root stayed open');

      await click('[data-key="work-email"]');

      assert.deepEqual(
        actions,
        ['work-email'],
        'the root onAction saw depth 2'
      );
      assert
        .dom('[data-key="copy-link"]')
        .doesNotExist('all three levels closed');
    });

    test('Escape at depth 2 closes one level at a time', async function (assert) {
      await render(
        <template>
          <Dropdown as |d|>
            <d.Trigger>Share</d.Trigger>
            <d.Menu @disableTransitions={{true}} as |Item Sub|>
              <Item @key="copy-link">Copy Link</Item>
              <Sub as |s1|>
                <s1.Trigger data-test-id="sub-1">Other</s1.Trigger>
                <s1.Menu as |Item Sub|>
                  <Item @key="whatsapp">WhatsApp</Item>
                  <Sub as |s2|>
                    <s2.Trigger data-test-id="sub-2">Email</s2.Trigger>
                    <s2.Menu as |Item|>
                      <Item @key="work-email">Work email</Item>
                    </s2.Menu>
                  </Sub>
                </s1.Menu>
              </Sub>
            </d.Menu>
          </Dropdown>
        </template>
      );

      await click('[data-test-id="dropdown-trigger"]');
      await click('[data-test-id="sub-1"]');

      await click('[data-test-id="sub-2"]');

      const deepestId = document
        .querySelector('[data-test-id="sub-2"]')
        ?.getAttribute('aria-controls') as string;

      await triggerKeyEvent(`#${deepestId}`, 'keydown', 'Escape');

      assert.dom('[data-key="work-email"]').doesNotExist('depth 2 closed');
      assert.dom('[data-key="whatsapp"]').exists('depth 1 survived');
      assert.dom('[data-key="copy-link"]').exists('the root survived');
    });
  }
);
