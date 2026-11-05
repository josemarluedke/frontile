import { module, test } from 'qunit';
import { setupApplicationTest } from 'ember-qunit';
import { visit, click } from '@ember/test-helpers';
import { NavFolder, NavLink } from 'frontile';

const TRIGGER = '[data-part="nav-folder-trigger"]';

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
      '[data-part="nav-folder-panel"]'
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
