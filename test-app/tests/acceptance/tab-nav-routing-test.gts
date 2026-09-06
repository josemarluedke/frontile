import { module, test } from 'qunit';
import { setupApplicationTest } from 'ember-qunit';
import { visit } from '@ember/test-helpers';

module('Acceptance | tab-nav routing', function (hooks) {
  setupApplicationTest(hooks);

  test('a TabNav.Item with @route derives its active state from the router', async function (assert) {
    await visit('/tab-nav-demo/second');

    const links = document.querySelectorAll('nav a');
    const first = links[0] as HTMLElement;
    const second = links[1] as HTMLElement;

    assert.dom(second).hasAttribute('aria-current', 'page');
    assert.dom(second).hasAttribute('data-selected', 'true');
    assert
      .dom(first)
      .doesNotHaveAttribute(
        'aria-current',
        'the non-active route link carries no aria-current'
      );
    assert.dom(first).hasAttribute('data-selected', 'false');

    assert.ok(
      document.body.textContent?.includes('Second panel'),
      'renders the routed-to template'
    );
  });
});
