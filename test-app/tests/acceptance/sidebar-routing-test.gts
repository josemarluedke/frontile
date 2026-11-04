import { module, test } from 'qunit';
import { setupApplicationTest } from 'ember-qunit';
import { visit, click } from '@ember/test-helpers';

module('Acceptance | Sidebar.Item routing', function (hooks) {
  setupApplicationTest(hooks);

  test('route item renders a LinkTo and is active on its route', async function (assert) {
    await visit('/sidebar-demo/second');

    let links = document.querySelectorAll('[data-part="sidebar-item"]');
    assert.strictEqual(links.length, 2);
    const first = links[0] as HTMLAnchorElement;
    const second = links[1] as HTMLAnchorElement;

    assert.dom(first).hasAttribute('href', '/sidebar-demo');
    assert.dom(second).hasAttribute('href', '/sidebar-demo/second');
    assert.dom(second).hasAttribute('aria-current', 'page');
    assert.dom(second).hasAttribute('data-active', 'true');
    assert.dom(first).doesNotHaveAttribute('aria-current');
    assert.dom(first).hasAttribute('data-active', 'false');

    await click(first);

    links = document.querySelectorAll('[data-part="sidebar-item"]');
    assert.dom(links[0] as HTMLElement).hasAttribute('aria-current', 'page');
    assert
      .dom(links[1] as HTMLElement)
      .doesNotHaveAttribute('aria-current', 'the active state moved');
    assert.ok(
      document.body.textContent?.includes('First panel'),
      'LinkTo navigated to the route'
    );
  });
});
