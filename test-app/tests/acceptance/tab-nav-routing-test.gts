import { module, test } from 'qunit';
import { setupApplicationTest } from 'ember-qunit';
import { visit, click } from '@ember/test-helpers';

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

  test('transitioning between routes moves the active state -- proves the router.currentURL reactivity path', async function (assert) {
    // This is the mechanism that makes the entire `@route` tier work: the
    // `isActive` getter reads `this.router.currentURL` purely to become a
    // dependent of it, so it recomputes on every transition. A single-visit
    // test (above) stays green even if that read is deleted, since the
    // getter's cached value from initial render happens to already be
    // correct. Only a transition proves the reactivity actually fires.
    await visit('/tab-nav-demo/second');

    let links = document.querySelectorAll('nav a');
    assert.dom(links[1] as HTMLElement).hasAttribute('data-selected', 'true');

    await click(links[0] as HTMLElement);

    links = document.querySelectorAll('nav a');
    const first = links[0] as HTMLElement;
    const second = links[1] as HTMLElement;

    assert.dom(first).hasAttribute('aria-current', 'page');
    assert.dom(first).hasAttribute('data-selected', 'true');
    assert
      .dom(second)
      .doesNotHaveAttribute(
        'aria-current',
        'the active state left the route we navigated away from'
      );
    assert.dom(second).hasAttribute('data-selected', 'false');
  });
});
