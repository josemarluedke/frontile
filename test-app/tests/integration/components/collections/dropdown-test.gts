import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import {
  click,
  render,
  rerender,
  triggerKeyEvent,
  triggerEvent
} from '@ember/test-helpers';
import { tv } from 'tailwind-variants';
import { Dropdown } from 'frontile';
import { tracked } from '@glimmer/tracking';
import { cell } from 'ember-resources';
import { array } from '@ember/helper';
import { settled } from '@ember/test-helpers';
import { trackDeprecations } from '../../../helpers/deprecations';
import { useCustomStyles } from '../../../helpers/scoped-styles';

module(
  'Integration | Component | Dropdown | @frontile/collections',
  function (hooks) {
    setupRenderingTest(hooks);

    useCustomStyles(hooks, {
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

    test('Trigger accepts @variant without deprecating', async function (assert) {
      const { ids } = trackDeprecations();

      await render(
        <template>
          <Dropdown as |d|>
            <d.Trigger
              @variant="outline"
              data-test-id="trigger"
            >Open</d.Trigger>
            <d.Menu as |Item|><Item @key="a">A</Item></d.Menu>
          </Dropdown>
        </template>
      );

      // The trigger is a Button, so @variant must reach it directly; before this
      // was wired, TriggerArgs picked only `appearance` and @variant was a type
      // error, leaving consumers unable to migrate the trigger off the old name.
      assert.dom('[data-test-id="trigger"]').exists('trigger renders');
      assert.deepEqual(ids, [], 'no deprecation for the new arg');
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

    test('opening with the keyboard lands on the first item', async function (assert) {
      await render(
        <template>
          <Dropdown as |d|>
            <d.Trigger>Options</d.Trigger>
            <d.Menu @disableTransitions={{true}} as |Item|>
              <Item @key="profile">My Profile</Item>
              <Item @key="settings">Settings</Item>
            </d.Menu>
          </Dropdown>
        </template>
      );

      await triggerKeyEvent(
        '[data-test-id="dropdown-trigger"]',
        'keyup',
        'ArrowDown'
      );

      assert
        .dom('[data-key="profile"]')
        .hasAttribute(
          'data-active',
          'true',
          'a keyboard open highlights the first row, per the menu button pattern'
        );
    });

    test('opening with a pointer highlights nothing', async function (assert) {
      await render(
        <template>
          <Dropdown as |d|>
            <d.Trigger>Options</d.Trigger>
            <d.Menu @disableTransitions={{true}} as |Item|>
              <Item @key="profile">My Profile</Item>
              <Item @key="settings">Settings</Item>
            </d.Menu>
          </Dropdown>
        </template>
      );

      await click('[data-test-id="dropdown-trigger"]');

      assert
        .dom('[data-key="profile"]')
        .hasAttribute(
          'data-active',
          'false',
          'a pointer open moves the highlight nowhere the user did not point'
        );
    });

    test('an explicit @autoActivateMode outranks the open source', async function (assert) {
      // The open source is translated into an activation mode in one place,
      // and a consumer that states the mode outright wins over it -- in both
      // directions.
      await render(
        <template>
          <Dropdown as |d|>
            <d.Trigger>Options</d.Trigger>
            <d.Menu
              @autoActivateMode="none"
              @disableTransitions={{true}}
              as |Item|
            >
              <Item @key="profile">My Profile</Item>
              <Item @key="settings">Settings</Item>
            </d.Menu>
          </Dropdown>
        </template>
      );

      await triggerKeyEvent(
        '[data-test-id="dropdown-trigger"]',
        'keyup',
        'ArrowDown'
      );

      assert
        .dom('[data-key="profile"]')
        .hasAttribute(
          'data-active',
          'false',
          'a keyboard open still highlights nothing when the consumer said none'
        );
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

    test('a selectable menu item exposes its state as menuitemcheckbox/aria-checked', async function (assert) {
      await render(
        <template>
          <Dropdown as |d|>
            <d.Trigger>Options</d.Trigger>
            <d.Menu
              @selectionMode="multiple"
              @selectedKeys={{array "edit"}}
              @closeOnItemSelect={{false}}
              @disableTransitions={{true}}
              as |Item|
            >
              <Item @key="edit">Edit</Item>
              <Item @key="delete">Delete</Item>
            </d.Menu>
          </Dropdown>
        </template>
      );

      await click('[data-test-id="dropdown-trigger"]');

      assert
        .dom('[data-key="edit"]')
        .hasAttribute(
          'role',
          'menuitemcheckbox',
          'a multiple-selection menu row is a checkbox item'
        );
      assert
        .dom('[data-key="edit"]')
        .hasAttribute('aria-checked', 'true', 'the selected row is checked');
      assert
        .dom('[data-key="delete"]')
        .hasAttribute(
          'aria-checked',
          'false',
          'an unselected row reports unchecked rather than omitting the state'
        );
    });

    test('a single-selection menu item is a menuitemradio', async function (assert) {
      await render(
        <template>
          <Dropdown as |d|>
            <d.Trigger>Options</d.Trigger>
            <d.Menu
              @selectionMode="single"
              @selectedKeys={{array "asc"}}
              @closeOnItemSelect={{false}}
              @disableTransitions={{true}}
              as |Item|
            >
              <Item @key="asc">Ascending</Item>
              <Item @key="desc">Descending</Item>
            </d.Menu>
          </Dropdown>
        </template>
      );

      await click('[data-test-id="dropdown-trigger"]');

      assert
        .dom('[data-key="asc"]')
        .hasAttribute('role', 'menuitemradio', 'single selection is a radio');
      assert.dom('[data-key="asc"]').hasAttribute('aria-checked', 'true');
      assert.dom('[data-key="desc"]').hasAttribute('aria-checked', 'false');
    });

    test('a menu without selection keeps plain menuitem rows', async function (assert) {
      await render(
        <template>
          <Dropdown as |d|>
            <d.Trigger>Options</d.Trigger>
            <d.Menu @disableTransitions={{true}} as |Item|>
              <Item @key="edit">Edit</Item>
            </d.Menu>
          </Dropdown>
        </template>
      );

      await click('[data-test-id="dropdown-trigger"]');

      assert.dom('[data-key="edit"]').hasAttribute('role', 'menuitem');
      assert
        .dom('[data-key="edit"]')
        .doesNotHaveAttribute(
          'aria-checked',
          'a row that cannot be checked carries no checked state'
        );
    });

    test('a submenu trigger stays a plain menuitem inside a selection menu', async function (assert) {
      await render(
        <template>
          <Dropdown as |d|>
            <d.Trigger>Options</d.Trigger>
            <d.Menu
              @selectionMode="multiple"
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

      assert
        .dom('[data-test-id="dropdown-submenu-trigger"]')
        .hasAttribute(
          'role',
          'menuitem',
          'a row that opens a submenu is not itself checkable'
        );
      assert
        .dom('[data-test-id="dropdown-submenu-trigger"]')
        .doesNotHaveAttribute('aria-checked');
    });

    test('a submenu may declare its own selection, overriding the inherited one', async function (assert) {
      const submenuSelection = cell<string[]>([]);
      const onSubSelectionChange = (keys: string[]) => {
        submenuSelection.current = keys;
      };

      await render(
        <template>
          <Dropdown as |d|>
            <d.Trigger>Options</d.Trigger>
            <d.Menu
              @closeOnItemSelect={{false}}
              @disableTransitions={{true}}
              as |Item Sub|
            >
              <Item @key="edit">Edit</Item>
              <Sub as |s|>
                <s.Trigger>Scope</s.Trigger>
                <s.Menu
                  @selectionMode="multiple"
                  @selectedKeys={{submenuSelection.current}}
                  @onSelectionChange={{onSubSelectionChange}}
                  as |Item|
                >
                  <Item @key="global">Global</Item>
                  <Item @key="market">Market</Item>
                </s.Menu>
              </Sub>
            </d.Menu>
          </Dropdown>
        </template>
      );

      await click('[data-test-id="dropdown-trigger"]');
      await click('[data-test-id="dropdown-submenu-trigger"]');

      assert
        .dom('[data-key="global"]')
        .hasAttribute(
          'role',
          'menuitemcheckbox',
          "the submenu's own selectionMode drives its rows"
        );
      assert
        .dom('[data-key="edit"]')
        .hasAttribute(
          'role',
          'menuitem',
          'the parent level, which declared no selection, is unaffected'
        );

      await click('[data-key="global"]');
      await click('[data-key="market"]');

      assert.deepEqual(
        submenuSelection.current,
        ['global', 'market'],
        "the submenu's own handler receives its own selection"
      );
      assert
        .dom('[data-key="global"]')
        .hasAttribute(
          'aria-checked',
          'true',
          'and the rows report the checked state back'
        );
    });

    test('a submenu may override the other inherited context settings too', async function (assert) {
      // `@selectionMode` and friends are the headline, but a level owns every
      // setting `#withOwnOverrides` carries -- `@disabledKeys` among them.
      // Documented in dropdown.md, so it is pinned here.
      await render(
        <template>
          <Dropdown as |d|>
            <d.Trigger>Options</d.Trigger>
            <d.Menu
              @disabledKeys={{array "edit"}}
              @disableTransitions={{true}}
              as |Item Sub|
            >
              <Item @key="edit">Edit</Item>
              <Sub as |s|>
                <s.Trigger>Scope</s.Trigger>
                <s.Menu @disabledKeys={{array "market"}} as |Item|>
                  <Item @key="global">Global</Item>
                  <Item @key="market">Market</Item>
                </s.Menu>
              </Sub>
            </d.Menu>
          </Dropdown>
        </template>
      );

      await click('[data-test-id="dropdown-trigger"]');
      await click('[data-test-id="dropdown-submenu-trigger"]');

      assert
        .dom('[data-key="market"]')
        .hasAttribute(
          'aria-disabled',
          'true',
          "the submenu's own disabledKeys apply at its level"
        );
      assert
        .dom('[data-key="global"]')
        .doesNotHaveAttribute(
          'aria-disabled',
          "and the root's disabledKeys no longer reach it"
        );
      assert
        .dom('[data-key="edit"]')
        .hasAttribute('aria-disabled', 'true', 'while the root keeps its own');
    });

    test('a submenu with no selection args of its own still inherits the root', async function (assert) {
      let selected: string[] = [];
      const onSelectionChange = (keys: string[]) => {
        selected = keys;
      };

      await render(
        <template>
          <Dropdown as |d|>
            <d.Trigger>Options</d.Trigger>
            <d.Menu
              @selectionMode="multiple"
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

      assert
        .dom('[data-key="nested"]')
        .hasAttribute(
          'role',
          'menuitemcheckbox',
          'the inherited selectionMode still reaches the submenu'
        );

      await click('[data-key="nested"]');
      assert.deepEqual(selected, ['nested'], 'the root handler still fires');
    });

    test("a submenu's own @onAction takes precedence over the inherited one", async function (assert) {
      const rootActions: string[] = [];
      const subActions: string[] = [];
      const onRootAction = (key: string) => rootActions.push(key);
      const onSubAction = (key: string) => subActions.push(key);

      await render(
        <template>
          <Dropdown as |d|>
            <d.Trigger>Options</d.Trigger>
            <d.Menu
              @onAction={{onRootAction}}
              @closeOnItemSelect={{false}}
              @disableTransitions={{true}}
              as |Item Sub|
            >
              <Item @key="edit">Edit</Item>
              <Sub as |s|>
                <s.Trigger>More</s.Trigger>
                <s.Menu @onAction={{onSubAction}} as |Item|>
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

      assert.deepEqual(subActions, ['nested'], "the submenu's handler fired");
      assert.deepEqual(
        rootActions,
        [],
        'and the inherited one did not fire as well'
      );

      await click('[data-key="edit"]');
      assert.deepEqual(
        rootActions,
        ['edit'],
        'the root level still uses its own handler'
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

    test('opening a sibling submenu closes the one already open', async function (assert) {
      // Two sub-triggers next to each other: moving from one onto the other
      // used to leave both levels on screen at once, because nothing told the
      // first one to go away and the pointer never left the first one's safe
      // area in a way that stuck (see the test below).
      await render(
        <template>
          <Dropdown as |d|>
            <d.Trigger>Options</d.Trigger>
            <d.Menu @disableTransitions={{true}} as |Item Sub|>
              <Item @key="edit">Edit</Item>
              <Sub as |s|>
                <s.Trigger data-test-id="sub-a">Move to</s.Trigger>
                <s.Menu as |Item|>
                  <Item @key="nested-a">Inbox</Item>
                </s.Menu>
              </Sub>
              <Sub as |s|>
                <s.Trigger data-test-id="sub-b">Share with</s.Trigger>
                <s.Menu as |Item|>
                  <Item @key="nested-b">Team</Item>
                </s.Menu>
              </Sub>
            </d.Menu>
          </Dropdown>
        </template>
      );

      await click('[data-test-id="dropdown-trigger"]');
      await triggerEvent('[data-test-id="sub-a"]', 'pointerenter');
      assert.dom('[data-key="nested-a"]').exists('the first submenu opened');

      await triggerEvent('[data-test-id="sub-b"]', 'pointerenter');

      assert.dom('[data-key="nested-b"]').exists('the second submenu opened');
      assert
        .dom('[data-key="nested-a"]')
        .doesNotExist('and the first one is gone');
    });

    test('a pending close is not postponed by further pointer movement', async function (assert) {
      // The close scheduled when the pointer leaves the safe area used to be
      // cancelled and re-scheduled by every subsequent `pointermove` — so a
      // pointer that kept moving anywhere on the page (into a *sibling*
      // submenu, for instance) held the abandoned level open indefinitely.
      //
      // Timed with real waits rather than `settled()`: `settled()` waits for
      // the pending runloop timer to fire, which is precisely the thing under
      // test, and would make this pass against the broken code.
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

      const trigger = document.querySelector(
        '[data-test-id="dropdown-submenu-trigger"]'
      ) as HTMLElement;
      trigger.dispatchEvent(
        new PointerEvent('pointerleave', { bubbles: true })
      );

      // Well clear of both the trigger and the submenu, so every move is
      // outside the safe area.
      const wander = () =>
        document.dispatchEvent(
          new PointerEvent('pointermove', {
            bubbles: true,
            clientX: 5000,
            clientY: 5000
          })
        );
      const wait = (ms: number) =>
        new Promise((resolve) => setTimeout(resolve, ms));

      // SUBMENU_CLOSE_DELAY is 300ms; keep moving well past it.
      for (let i = 0; i < 4; i++) {
        await wait(100);
        wander();
      }
      await wait(100);

      assert
        .dom('[data-key="nested"]')
        .doesNotExist(
          'the close scheduled on leaving the safe area still fired'
        );

      await settled();
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

    test('moving into a grandchild submenu keeps the whole chain open', async function (assert) {
      // Every level runs its own safe-area check, and a third level sits
      // outside the *second* level's area entirely -- so the outer level used
      // to schedule its own close the moment the pointer went deeper, taking
      // the second and third levels down with it. A level has to treat the
      // pointer being anywhere its open descendants consider safe as safe for
      // itself too.
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
      await triggerEvent('[data-test-id="sub-1"]', 'pointerenter');
      await triggerEvent('[data-test-id="sub-2"]', 'pointerenter');

      assert.dom('[data-key="whatsapp"]').exists('level 1 opened');
      assert.dom('[data-key="work-email"]').exists('level 2 opened');

      const level2Id = document
        .querySelector('[data-test-id="sub-2"]')
        ?.getAttribute('aria-controls') as string;
      const level2 = document.querySelector(`#${level2Id}`) as HTMLElement;
      const box = level2.getBoundingClientRect();

      // Leave the level-2 trigger for the level-2 menu itself -- the same
      // native dispatch as the gap test above, so the pending close is not
      // waited out before the move lands.
      (
        document.querySelector('[data-test-id="sub-2"]') as HTMLElement
      ).dispatchEvent(new PointerEvent('pointerleave', { bubbles: true }));
      await triggerEvent(document, 'pointermove', {
        clientX: box.left + box.width / 2,
        clientY: box.top + box.height / 2
      });

      assert
        .dom('[data-key="work-email"]')
        .exists('the level the pointer is in stayed open');
      assert
        .dom('[data-key="whatsapp"]')
        .exists('and so did the level above it');
      assert.dom('[data-key="copy-link"]').exists('and the root');
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

    module('triggerModifier', function () {
      /**
       * Dispatches a cancelable key event and reports whether the element's
       * handlers cancelled the browser's native response to it -- the thing that
       * decides if an `<a href>` navigates or a `<button>` fires a click of its
       * own on top of the toggle the modifier already did.
       */
      const press = (selector: string, type: string, key: string): boolean => {
        const el = document.querySelector(selector) as HTMLElement;
        const event = new KeyboardEvent(type, {
          key,
          bubbles: true,
          cancelable: true
        });
        el.dispatchEvent(event);
        return event.defaultPrevented;
      };

      const menuOpen = () =>
        document.querySelector('[data-component="listbox"]');

      const pressOn = (el: Element | null, type: string, key: string): void => {
        el?.dispatchEvent(
          new KeyboardEvent(type, { key, bubbles: true, cancelable: true })
        );
      };

      const elements = {
        button: async (): Promise<void> => {
          await render(
            <template>
              <Dropdown as |d|>
                <button type="button" data-test-id="t" {{d.triggerModifier}}>
                  Open
                </button>
                <d.Menu @disableTransitions={{true}} as |Item|>
                  <Item @key="a">A</Item>
                  <Item @key="b">B</Item>
                </d.Menu>
              </Dropdown>
            </template>
          );
        },
        anchor: async (): Promise<void> => {
          await render(
            <template>
              <Dropdown as |d|>
                {{! template-lint-disable no-invalid-interactive require-valid-anchor }}
                <a
                  role="button"
                  tabindex="0"
                  data-test-id="t"
                  {{d.triggerModifier}}
                >
                  Open
                </a>
                <d.Menu @disableTransitions={{true}} as |Item|>
                  <Item @key="a">A</Item>
                  <Item @key="b">B</Item>
                </d.Menu>
              </Dropdown>
            </template>
          );
        }
      };

      for (const [name, renderIt] of Object.entries(elements)) {
        module(
          `on a plain <${name === 'button' ? 'button' : 'a'}>`,
          function () {
            for (const key of ['Enter', ' ', 'ArrowDown'] as const) {
              test(`a real ${JSON.stringify(key)} press puts focus in the menu at once, and the next ArrowDown moves within it`, async function (assert) {
                await renderIt();
                (
                  document.querySelector('[data-test-id="t"]') as HTMLElement
                ).focus();

                // Real key presses: keydown, then keyup on whatever has focus
                // by then. Only the render is awaited, not timers, so focus
                // must already be in the menu before the next key event.
                press('[data-test-id="t"]', 'keydown', key);
                await rerender();
                pressOn(document.activeElement, 'keyup', key);
                await rerender();

                assert.ok(menuOpen(), 'open');
                assert.strictEqual(
                  document.activeElement,
                  menuOpen(),
                  'focus is in the menu'
                );
                assert
                  .dom('[data-key="a"]')
                  .hasAttribute('data-active', 'true', 'onto the first item');

                // The list's 1ms bookkeeping flush, far inside any human gap
                // between two keys.
                await settled();
                pressOn(document.activeElement, 'keydown', 'ArrowDown');
                await rerender();
                pressOn(document.activeElement, 'keyup', 'ArrowDown');
                await settled();

                assert.ok(menuOpen(), 'still open');
                assert
                  .dom('[data-key="b"]')
                  .hasAttribute('data-active', 'true');
              });
            }

            test('an ArrowDown keyup that still lands on the element does not close the menu its keydown opened', async function (assert) {
              await renderIt();
              (
                document.querySelector('[data-test-id="t"]') as HTMLElement
              ).focus();
              press('[data-test-id="t"]', 'keydown', 'ArrowDown');
              press('[data-test-id="t"]', 'keyup', 'ArrowDown');
              await settled();

              assert.ok(menuOpen(), 'still open');
              assert.dom('[data-key="a"]').hasAttribute('data-active', 'true');
            });

            test('clicking opens the menu and sets the menu ARIA attributes', async function (assert) {
              await renderIt();
              assert.strictEqual(menuOpen(), null, 'closed to begin with');

              await click('[data-test-id="t"]');

              assert.ok(menuOpen(), 'the click opened the menu');
              assert
                .dom('[data-test-id="t"]')
                .hasAttribute('aria-expanded', 'true');
              assert
                .dom('[data-test-id="t"]')
                .hasAttribute('aria-haspopup', 'true');
            });

            test('a pointer open highlights nothing', async function (assert) {
              await renderIt();
              await triggerEvent('[data-test-id="t"]', 'pointerup');
              await click('[data-test-id="t"]');

              assert.dom('[data-key="a"]').hasAttribute('data-active', 'false');
            });

            test('ArrowDown opens the menu onto the first item', async function (assert) {
              await renderIt();
              // Only the keyup: in a browser Popover's keydown handler has already moved
              // focus into the menu by then, so the trigger never sees it.
              await triggerKeyEvent('[data-test-id="t"]', 'keyup', 'ArrowDown');

              assert.ok(menuOpen(), 'the menu is open');
              assert.dom('[data-key="a"]').hasAttribute('data-active', 'true');
            });

            test('Enter opens the menu', async function (assert) {
              await renderIt();
              await triggerKeyEvent('[data-test-id="t"]', 'keydown', 'Enter');
              await triggerKeyEvent('[data-test-id="t"]', 'keyup', 'Enter');

              assert.ok(menuOpen(), 'Enter opened it');
              assert.dom('[data-key="a"]').hasAttribute('data-active', 'true');
            });

            test('Space opens the menu', async function (assert) {
              await renderIt();
              await triggerKeyEvent('[data-test-id="t"]', 'keydown', ' ');
              await triggerKeyEvent('[data-test-id="t"]', 'keyup', ' ');

              assert.ok(menuOpen(), 'Space opened it');
            });

            test('Escape closes the menu and returns focus to the element', async function (assert) {
              await renderIt();
              (
                document.querySelector('[data-test-id="t"]') as HTMLElement
              ).focus();
              // Only the keyup: in a browser Popover's keydown handler has already moved
              // focus into the menu by then, so the trigger never sees it.
              await triggerKeyEvent('[data-test-id="t"]', 'keyup', 'ArrowDown');
              assert.ok(menuOpen(), 'open');

              await triggerKeyEvent(
                '[data-component="listbox"]',
                'keydown',
                'Escape'
              );

              assert.strictEqual(menuOpen(), null, 'Escape closed it');
              assert.dom('[data-test-id="t"]').isFocused();
            });

            test('Enter and Space keep the browser from also activating the element', async function (assert) {
              await renderIt();

              // Without this a native `<button>` clicks itself on Enter (keydown)
              // and Space (keyup), which Popover's `trigger` would toggle on top
              // of the keyup handler -- opening and immediately closing the menu.
              // An `<a href>` would also navigate on Enter.
              assert.true(
                press('[data-test-id="t"]', 'keydown', 'Enter'),
                'Enter keydown is cancelled'
              );
              assert.true(
                press('[data-test-id="t"]', 'keydown', ' '),
                'Space keydown is cancelled'
              );
              assert.true(
                press('[data-test-id="t"]', 'keyup', ' '),
                'Space keyup is cancelled'
              );
              assert.true(
                press('[data-test-id="t"]', 'keydown', 'ArrowDown'),
                'ArrowDown keydown is cancelled'
              );
              assert.false(
                press('[data-test-id="t"]', 'keydown', 'a'),
                'other keys are left alone'
              );
            });
          }
        );
      }

      for (const name of Object.keys(elements) as (keyof typeof elements)[]) {
        test(`Enter after a click open and close opens it again, not shut, on a ${name}`, async function (assert) {
          await elements[name]();

          await click('[data-test-id="t"]');
          assert.ok(menuOpen(), 'open after one click');
          await click('[data-test-id="t"]');
          assert.strictEqual(menuOpen(), null, 'closed after the second');

          await triggerKeyEvent('[data-test-id="t"]', 'keydown', 'Enter');
          await triggerKeyEvent('[data-test-id="t"]', 'keyup', 'Enter');
          assert.ok(menuOpen(), 'one Enter opens it, without toggling it shut');
        });
      }

      test('Trigger and triggerModifier toggle the same menu', async function (assert) {
        await render(
          <template>
            <Dropdown as |d|>
              <d.Trigger data-test-id="own">Own</d.Trigger>
              <button type="button" data-test-id="mod" {{d.triggerModifier}}>
                Mod
              </button>
              <d.Menu @disableTransitions={{true}} as |Item|>
                <Item @key="a">A</Item>
              </d.Menu>
            </Dropdown>
          </template>
        );
        await click('[data-test-id="own"]');
        assert.ok(menuOpen(), 'Trigger opens the menu');
        await click('[data-test-id="own"]');
        assert.strictEqual(menuOpen(), null, 'Trigger closes it');
        await click('[data-test-id="mod"]');
        assert.ok(menuOpen(), 'the modifier opens the same menu');
      });
    });

    module('link items', function () {
      const openMenu = () => click('[data-test-id="dropdown-trigger"]');

      test('an item with @href renders an anchor with that href', async function (assert) {
        await render(
          <template>
            <Dropdown as |d|>
              <d.Trigger>Open</d.Trigger>
              <d.Menu @disableTransitions={{true}} as |Item|>
                <Item @key="a" @href="/x">Docs</Item>
              </d.Menu>
            </Dropdown>
          </template>
        );
        await openMenu();

        assert
          .dom('[data-key="a"] a')
          .hasAttribute('href', '/x')
          .hasText('Docs');
      });

      test('a link item disabled by @disabledKeys or @isDisabled renders no live href', async function (assert) {
        await render(
          <template>
            <Dropdown as |d|>
              <d.Trigger>Open</d.Trigger>
              <d.Menu
                @disableTransitions={{true}}
                @disabledKeys={{array "a"}}
                as |Item|
              >
                <Item @key="a" @href="/x">Docs</Item>
                <Item @key="b" @href="/y" @isDisabled={{true}}>Blog</Item>
                <Item @key="c" @href="/z">Live</Item>
              </d.Menu>
            </Dropdown>
          </template>
        );
        await openMenu();

        assert.dom('[data-key="a"] a[href]').doesNotExist('disabledKeys');
        assert.dom('[data-key="b"] a[href]').doesNotExist('isDisabled');
        assert.dom('[data-key="a"] a').hasAria('disabled', 'true');
        assert.dom('[data-key="c"] a').hasAttribute('href', '/z');
      });

      test('exactly one element per link item has role="menuitem"', async function (assert) {
        await render(
          <template>
            <Dropdown as |d|>
              <d.Trigger>Open</d.Trigger>
              <d.Menu @disableTransitions={{true}} as |Item|>
                <Item @key="a" @href="/x">Docs</Item>
              </d.Menu>
            </Dropdown>
          </template>
        );
        await openMenu();

        assert.dom('[role="menuitem"]').exists({ count: 1 });
        assert.dom('li[data-key="a"]').hasAttribute('role', 'menuitem');
        assert.dom('li[data-key="a"] a').hasAttribute('tabindex', '-1');
        assert.dom('li[data-key="a"] [role="menuitem"]').doesNotExist();
      });

      test('Enter on the active link item clicks its anchor and closes the menu', async function (assert) {
        const onAction = (_key: string) => assert.step('action');
        await render(
          <template>
            <Dropdown as |d|>
              <d.Trigger>Open</d.Trigger>
              <d.Menu
                @disableTransitions={{true}}
                @onAction={{onAction}}
                as |Item|
              >
                <Item @key="p">Plain</Item>
                <Item @key="a" @href="/x">Docs</Item>
              </d.Menu>
            </Dropdown>
          </template>
        );
        await triggerKeyEvent(
          '[data-test-id="dropdown-trigger"]',
          'keyup',
          'ArrowDown'
        );
        const anchor = document.querySelector(
          '[data-key="a"] a'
        ) as HTMLAnchorElement;
        anchor.addEventListener('click', (e) => {
          e.preventDefault();
          assert.step('anchor click');
        });

        await triggerKeyEvent(
          '[data-component="listbox"]',
          'keydown',
          'ArrowDown'
        );
        assert.dom('[data-key="a"]').hasAttribute('data-active', 'true');
        await triggerKeyEvent('[data-component="listbox"]', 'keydown', 'Enter');

        assert.verifySteps(['anchor click']);
        assert.dom('[data-component="listbox"]').doesNotExist('menu closed');
      });

      test('clicking a link item closes the menu and does not call @onAction', async function (assert) {
        const onAction = (key: string) => assert.step(`action:${key}`);
        await render(
          <template>
            <Dropdown as |d|>
              <d.Trigger>Open</d.Trigger>
              <d.Menu
                @disableTransitions={{true}}
                @onAction={{onAction}}
                as |Item|
              >
                <Item @key="a" @href="/x">Docs</Item>
              </d.Menu>
            </Dropdown>
          </template>
        );
        await openMenu();
        document
          .querySelector('[data-key="a"] a')
          ?.addEventListener('click', (e) => e.preventDefault());

        await click('[data-key="a"] a');

        assert.verifySteps([], 'onAction not called');
        assert.dom('[data-component="listbox"]').doesNotExist('menu closed');
      });

      test('clicking the item padding outside the anchor also follows the link', async function (assert) {
        await render(
          <template>
            <Dropdown as |d|>
              <d.Trigger>Open</d.Trigger>
              <d.Menu @disableTransitions={{true}} as |Item|>
                <Item @key="a" @href="/x">Docs</Item>
              </d.Menu>
            </Dropdown>
          </template>
        );
        await openMenu();
        document
          .querySelector('[data-key="a"] a')
          ?.addEventListener('click', (e) => {
            e.preventDefault();
            assert.step('anchor click');
          });

        await click('li[data-key="a"]');

        assert.verifySteps(['anchor click']);
        assert.dom('[data-component="listbox"]').doesNotExist();
      });

      test('a plain item still calls @onAction and closes', async function (assert) {
        const onAction = (key: string) => assert.step(`action:${key}`);
        await render(
          <template>
            <Dropdown as |d|>
              <d.Trigger>Open</d.Trigger>
              <d.Menu
                @disableTransitions={{true}}
                @onAction={{onAction}}
                as |Item|
              >
                <Item @key="p">Plain</Item>
                <Item @key="a" @href="/x">Docs</Item>
              </d.Menu>
            </Dropdown>
          </template>
        );
        await openMenu();
        await click('[data-key="p"]');

        assert.verifySteps(['action:p']);
        assert.dom('[data-component="listbox"]').doesNotExist();
      });

      test('@closeOnItemSelect={{false}} keeps the menu open after a link click', async function (assert) {
        await render(
          <template>
            <Dropdown as |d|>
              <d.Trigger>Open</d.Trigger>
              <d.Menu
                @disableTransitions={{true}}
                @closeOnItemSelect={{false}}
                as |Item|
              >
                <Item @key="a" @href="/x">Docs</Item>
              </d.Menu>
            </Dropdown>
          </template>
        );
        await openMenu();
        document
          .querySelector('[data-key="a"] a')
          ?.addEventListener('click', (e) => e.preventDefault());
        await click('[data-key="a"] a');

        assert.dom('[data-component="listbox"]').exists();
      });
    });

    module('controlled open state', function () {
      class OpenState {
        @tracked isOpen = false;
        changes: boolean[] = [];

        onOpenChange = (open: boolean): void => {
          this.changes.push(open);
          this.isOpen = open;
        };
      }

      test('@isOpen with @onOpenChange controls the menu', async function (assert) {
        const state = new OpenState();
        await render(
          <template>
            <Dropdown
              @isOpen={{state.isOpen}}
              @onOpenChange={{state.onOpenChange}}
              as |d|
            >
              <d.Trigger>Open</d.Trigger>
              <d.Menu @disableTransitions={{true}} as |Item|>
                <Item @key="a">A</Item>
              </d.Menu>
            </Dropdown>
          </template>
        );

        state.isOpen = true;
        await settled();
        assert.dom('[role="menu"]').exists('opened from outside');
        assert
          .dom('[data-test-id="dropdown-trigger"]')
          .hasAria('expanded', 'true');

        await click('[data-test-id="dropdown-trigger"]');
        assert.deepEqual(state.changes, [false], 'a click asks to close');
        assert.dom('[role="menu"]').doesNotExist();

        await click('[data-test-id="dropdown-trigger"]');
        assert.deepEqual(state.changes, [false, true], 'and to open');
        assert.dom('[role="menu"]').exists();

        state.isOpen = false;
        await settled();
        assert.dom('[role="menu"]').doesNotExist('closed from outside');
      });

      test('a declined request leaves the menu as it was', async function (assert) {
        const changes: boolean[] = [];
        const ignore = (open: boolean): void => {
          changes.push(open);
        };
        await render(
          <template>
            <Dropdown @isOpen={{false}} @onOpenChange={{ignore}} as |d|>
              <d.Trigger>Open</d.Trigger>
              <d.Menu @disableTransitions={{true}} as |Item|>
                <Item @key="a">A</Item>
              </d.Menu>
            </Dropdown>
          </template>
        );

        await click('[data-test-id="dropdown-trigger"]');
        assert.deepEqual(changes, [true]);
        assert.dom('[role="menu"]').doesNotExist();
      });
    });

    module('item @isDisabled', function () {
      test('a disabled item is skipped, marked and cannot be chosen', async function (assert) {
        const actions: string[] = [];
        const onAction = (key: string): void => {
          actions.push(key);
        };
        await render(
          <template>
            <Dropdown as |d|>
              <d.Trigger>Open</d.Trigger>
              <d.Menu
                @disableTransitions={{true}}
                @onAction={{onAction}}
                as |Item|
              >
                <Item @key="a" @isDisabled={{true}}>A</Item>
                <Item @key="b">B</Item>
                <Item @key="c" @isDisabled={{true}}>C</Item>
              </d.Menu>
            </Dropdown>
          </template>
        );

        await triggerKeyEvent(
          '[data-test-id="dropdown-trigger"]',
          'keyup',
          'ArrowDown'
        );
        assert
          .dom('[data-key="b"]')
          .hasAttribute('data-active', 'true', 'a keyboard open skips it');
        assert.dom('[data-key="a"]').hasAria('disabled', 'true');
        assert.dom('[data-key="b"]').doesNotHaveAria('disabled');

        await triggerKeyEvent('[role="menu"]', 'keydown', 'ArrowDown');
        assert
          .dom('[data-key="b"]')
          .hasAttribute('data-active', 'true', 'the arrows skip it');

        await click('[data-key="a"]');
        assert.deepEqual(actions, [], 'clicking it chooses nothing');
        assert.dom('[role="menu"]').exists('and leaves the menu open');
      });
    });
  }
);
