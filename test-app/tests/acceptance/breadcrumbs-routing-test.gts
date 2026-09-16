import { module, test } from 'qunit';
import { setupApplicationTest } from 'ember-qunit';
import { visit, click } from '@ember/test-helpers';

module('Acceptance | breadcrumbs routing', function (hooks) {
  setupApplicationTest(hooks);

  test('a Breadcrumbs.Item with @route renders a real link and derives its current state', async function (assert) {
    await visit('/breadcrumbs-demo/second');

    const crumbs = document.querySelectorAll(
      'nav[data-component="breadcrumbs"] [data-part="link"]'
    );
    const first = crumbs[0] as HTMLElement;
    const second = crumbs[1] as HTMLElement;

    assert.dom(first).hasTagName('a');
    assert.dom(first).hasAttribute('href', '/breadcrumbs-demo');

    assert.dom(second).hasAttribute('aria-current', 'page');
    assert.dom(second).hasAttribute('data-current', 'true');
    assert
      .dom(first)
      .doesNotHaveAttribute(
        'aria-current',
        'the non-active route crumb carries no aria-current'
      );
    assert.dom(first).hasAttribute('data-current', 'false');

    assert.ok(
      document.body.textContent?.includes('Second panel'),
      'renders the routed-to template'
    );
  });

  test('transitioning moves the current state -- proves the router.currentURL reactivity path', async function (assert) {
    // This is the mechanism that makes the entire `@route` tier work: the
    // `isCurrent` getter reads `this.router.currentURL` purely to become a
    // dependent of it, so it recomputes on every transition. A single-visit
    // test stays green even if that read is deleted, since the getter's cached
    // value from initial render happens to already be correct. Only a
    // transition proves the reactivity actually fires.
    await visit('/breadcrumbs-demo/second');

    let crumbs = document.querySelectorAll(
      'nav[data-component="breadcrumbs"] [data-part="link"]'
    );
    assert.dom(crumbs[1] as HTMLElement).hasAttribute('data-current', 'true');

    await click(crumbs[0] as HTMLElement);

    crumbs = document.querySelectorAll(
      'nav[data-component="breadcrumbs"] [data-part="link"]'
    );

    assert.dom(crumbs[0] as HTMLElement).hasAttribute('aria-current', 'page');
    assert.dom(crumbs[0] as HTMLElement).hasAttribute('data-current', 'true');
    assert
      .dom(crumbs[1] as HTMLElement)
      .doesNotHaveAttribute(
        'aria-current',
        'the current state left the route we navigated away from'
      );
  });

  test('@model reaches the LinkTo', async function (assert) {
    await visit('/breadcrumbs-demo/item/42');

    const crumbs = document.querySelectorAll(
      'nav[data-component="breadcrumbs"] [data-part="link"]'
    );
    const itemCrumb = crumbs[crumbs.length - 1] as HTMLElement;

    assert.dom(itemCrumb).hasAttribute('href', '/breadcrumbs-demo/item/42');
    assert.dom(itemCrumb).hasAttribute('aria-current', 'page');
  });

  test('a falsy @model is not dropped', async function (assert) {
    await visit('/breadcrumbs-demo/item/0');

    const crumbs = document.querySelectorAll(
      'nav[data-component="breadcrumbs"] [data-part="link"]'
    );
    const itemCrumb = crumbs[crumbs.length - 1] as HTMLElement;

    assert
      .dom(itemCrumb)
      .hasAttribute(
        'href',
        '/breadcrumbs-demo/item/0',
        'a 0 dynamic segment survives the != null check'
      );
  });

  test('a disabled @route crumb falls through to an anchor with no href', async function (assert) {
    await visit('/breadcrumbs-demo/second');

    const disabled = document.querySelector(
      '[data-test-disabled-crumb]'
    ) as HTMLElement;

    assert.dom(disabled).hasTagName('a');
    assert
      .dom(disabled)
      .doesNotHaveAttribute(
        'href',
        'LinkTo cannot be talked out of a navigable href, so a disabled route crumb renders a plain anchor instead'
      );
    assert.dom(disabled).hasAttribute('aria-disabled', 'true');
  });
});
