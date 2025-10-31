import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { click, render, triggerKeyEvent } from '@ember/test-helpers';
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

      assert.dom('[data-test-id="listbox"]').doesNotExist();
      await click('[data-test-id="dropdown-trigger"]');

      assert.dom('[data-test-id="listbox"]').exists();

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

      assert.dom('[data-test-id="listbox"]').doesNotExist();
      await click('[data-test-id="dropdown-trigger"]');
      assert.dom('[data-test-id="listbox"]').exists();

      await click('[data-key="profile"]');
      assert.dom('[data-test-id="listbox"]').doesNotExist();
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

      assert.dom('[data-test-id="listbox"]').doesNotExist();
      await click('[data-test-id="dropdown-trigger"]');
      assert.dom('[data-test-id="listbox"]').exists();

      await click('[data-key="profile"]');
      assert.dom('[data-test-id="listbox"]').exists();
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

      assert.dom('[data-test-id="listbox"]').doesNotExist();
      await click('[data-test-id="dropdown-trigger"]');
      assert.dom('[data-test-id="listbox"]').exists();

      await click('#outside');
      assert.dom('[data-test-id="listbox"]').doesNotExist();
      assert.equal(calledClosed, true, 'should called didClose argument');
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

      assert.dom('[data-test-id="listbox"]').doesNotExist();
      await triggerKeyEvent(
        '[data-test-id="dropdown-trigger"]',
        'keyup',
        'ArrowDown'
      );

      assert.dom('[data-test-id="listbox"]').exists();
    });
  }
);
