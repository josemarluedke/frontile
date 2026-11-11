import { module, test } from 'qunit';
import { setupApplicationTest } from 'ember-qunit';
import {
  visit,
  click,
  currentURL,
  focus,
  triggerKeyEvent
} from '@ember/test-helpers';
import { AppLayout } from 'frontile';
import NavFolder from 'frontile/components/layout/nav-folder';
import NavLink from 'frontile/components/layout/nav-link';
import {
  mockMatchMedia,
  type MatchMediaMock
} from 'test-app/tests/helpers/match-media';

// Scoped to `main`: the playground's own sidebar holds a Fixtures folder
// (around these very routes) outside `main`, which must not be matched.
const TRIGGER = 'main [data-part="nav-folder-trigger"]';
const MENU = '[role="menu"]';

module('Acceptance | NavFolder routing', function (hooks) {
  setupApplicationTest(hooks);

  hooks.beforeEach(function () {
    // Reuse the sidebar-demo routes with a folder around the `second` route,
    // so the active state comes from the real router.
    this.owner.register(
      'template:sidebar-demo',
      <template>
        <NavLink @route="sidebar-demo.index" id="to-first">First</NavLink>
        <NavLink @route="sidebar-demo.second" id="to-second">Second</NavLink>
        <NavFolder @label="Reports" as |folder|>
          <folder.Item @route="sidebar-demo.second" id="child">
            Second
          </folder.Item>
        </NavFolder>
        {{outlet}}
      </template>
    );
  });

  test('opens on load when a child is the current route', async function (assert) {
    await visit('/sidebar-demo/second');

    assert.dom('#child').hasAttribute('aria-current', 'page');
    assert.dom(TRIGGER).hasAttribute('aria-expanded', 'true');
    assert.dom(TRIGGER).hasAttribute('data-active', 'true');
    assert.dom(TRIGGER).doesNotHaveAttribute('aria-current');

    const panel = document.querySelector(
      'main [data-part="nav-folder-panel"]'
    ) as HTMLElement;
    assert.strictEqual(
      panel.style.height,
      '',
      'started open: no inline height'
    );
    assert.strictEqual(panel.style.transition, '', 'no transition');
  });

  test('stays closed elsewhere and opens after a transition into a child', async function (assert) {
    await visit('/sidebar-demo');

    assert.dom(TRIGGER).hasAttribute('aria-expanded', 'false');
    assert.dom(TRIGGER).hasAttribute('data-active', 'false');

    await click('#to-second');
    assert.dom(TRIGGER).hasAttribute('aria-expanded', 'true');
    assert.dom(TRIGGER).hasAttribute('data-active', 'true');

    // The user closes it, leaves and comes back: a new activation reopens.
    await click(TRIGGER);
    await click('#to-first');
    assert.dom(TRIGGER).hasAttribute('aria-expanded', 'false');
    assert.dom(TRIGGER).hasAttribute('data-active', 'false');

    await click('#to-second');
    assert.dom(TRIGGER).hasAttribute('aria-expanded', 'true');
  });
});

module('Acceptance | NavFolder routing in the icon rail', function (hooks) {
  setupApplicationTest(hooks);

  let media: MatchMediaMock | undefined;

  hooks.afterEach(function () {
    media?.restore();
    media = undefined;
  });

  hooks.beforeEach(function () {
    media = mockMatchMedia(1200);
    this.owner.register(
      'template:sidebar-demo',
      <template>
        <AppLayout @defaultSidebarCollapsed={{true}} as |layout|>
          <layout.Sidebar as |sidebar|>
            <sidebar.Body>
              <sidebar.Item @route="sidebar-demo.index" id="to-first">
                First
              </sidebar.Item>
              <sidebar.Folder @label="Reports" as |folder|>
                <folder.Item @route="sidebar-demo.second" id="child">
                  Second
                </folder.Item>
              </sidebar.Folder>
            </sidebar.Body>
          </layout.Sidebar>
          <layout.Main>{{outlet}}</layout.Main>
        </AppLayout>
      </template>
    );
  });

  test('the router makes the folder active while its menu is closed', async function (assert) {
    await visit('/sidebar-demo/second');

    assert.dom(TRIGGER).hasAttribute('data-active', 'true');
    assert.dom(TRIGGER).hasAria('expanded', 'false', 'no menu on load');
    assert.dom(MENU).doesNotExist();
    assert.dom('#child').doesNotExist('not rendered until opened');

    await click('#to-first');
    assert.dom(TRIGGER).hasAttribute('data-active', 'false');

    await click(TRIGGER);
    assert.dom('#child').hasAttribute('role', 'menuitem');
    assert.dom('#child').doesNotHaveAria('current');
    await click('#child');
    assert.strictEqual(currentURL(), '/sidebar-demo/second');
    assert.dom(TRIGGER).hasAttribute('data-active', 'true');
    assert.dom(TRIGGER).hasAria('expanded', 'false', 'following it closed it');
    assert.dom(MENU).doesNotExist();

    await click(TRIGGER);
    assert.dom('#child').hasAria('current', 'page');
  });

  test('Enter on a @route item transitions to its route and closes the menu', async function (assert) {
    await visit('/sidebar-demo');
    assert.dom(TRIGGER).hasAttribute('data-active', 'false');

    await focus(TRIGGER);
    // Only the keyup: in a browser the keydown has already moved focus into
    // the menu, so a keyup on the trigger never happens.
    await triggerKeyEvent(TRIGGER, 'keyup', 'ArrowDown');
    assert.dom('#child').hasAttribute('data-active', 'true', 'on the item');
    assert.dom('#child a').hasAttribute('href', '/sidebar-demo/second');

    await triggerKeyEvent(MENU, 'keydown', 'Enter');
    assert.strictEqual(currentURL(), '/sidebar-demo/second', 'transitioned');
    assert.dom(MENU).doesNotExist('the menu closed');
    assert.dom(TRIGGER).hasAria('expanded', 'false');
    assert.dom(TRIGGER).hasAttribute('data-active', 'true', 'now active');
  });
});
