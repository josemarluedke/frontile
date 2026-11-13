import { module, test } from 'qunit';
import { setupApplicationTest } from 'ember-qunit';
import { visit, click } from '@ember/test-helpers';
import {
  mockMatchMedia,
  type MatchMediaMock
} from 'test-app/tests/helpers/match-media';

function actions(): string[] {
  return Array.from(
    document.querySelectorAll('[data-region="actions"] > *')
  ).map((e) => e.textContent!.trim());
}

function crumbs(): string[] {
  return Array.from(
    document.querySelectorAll('[data-component="breadcrumbs"] li')
  )
    .map((e) => e.textContent!.trim())
    .filter(Boolean);
}

const TOGGLE = '[data-part="aside-toggle"]';

module('Acceptance | Layout regions routing', function (hooks) {
  setupApplicationTest(hooks);

  let media: MatchMediaMock | undefined;

  hooks.beforeEach(function () {
    media = mockMatchMedia(1200);
  });

  hooks.afterEach(function () {
    media?.restore();
    media = undefined;
  });

  test('nested routes stack navbar actions, the aside and breadcrumbs', async function (assert) {
    await visit('/regions-demo');
    assert.deepEqual(actions(), [], 'the index route fills nothing');
    assert.dom(TOGGLE).doesNotExist('no aside toggle without an aside');
    assert.dom('aside').doesNotExist();
    assert.deepEqual(crumbs(), ['Home']);

    await visit('/regions-demo/orders');
    assert.deepEqual(actions(), ['New order']);
    assert.dom(TOGGLE).exists('the parent route fills the aside');
    assert.deepEqual(crumbs(), ['Home', 'Orders']);

    await click(TOGGLE);
    assert.dom('aside [data-test-aside="orders"]').exists();

    await visit('/regions-demo/orders/1');
    assert.deepEqual(actions(), ['Refund'], 'the child replaces the parent');
    assert
      .dom('aside')
      .hasText('Order 1 details', 'the aside stays open with child content');
    assert.deepEqual(crumbs(), ['Home', 'Orders', 'Order 1']);

    await visit('/regions-demo/orders');
    assert.deepEqual(actions(), ['New order'], "the parent's comes back");
    assert.dom('aside').hasText('Orders filters');
    assert.deepEqual(crumbs(), ['Home', 'Orders']);

    await visit('/regions-demo');
    assert.deepEqual(actions(), []);
    assert.dom(TOGGLE).doesNotExist('the toggle hides again');
    assert.dom('aside').doesNotExist();
    assert
      .dom('[data-component="app-layout"]')
      .hasAttribute('data-aside-open', 'false', 'leaving closes the aside');

    await visit('/regions-demo/orders');
    assert
      .dom('aside')
      .doesNotExist('coming back does not reopen a closed aside');
  });

  test('a deep link renders the child route content on first render', async function (assert) {
    await visit('/regions-demo/orders/1');
    assert.deepEqual(actions(), ['Refund']);
    assert.deepEqual(crumbs(), ['Home', 'Orders', 'Order 1']);
    await click(TOGGLE);
    assert.dom('aside').hasText('Order 1 details');
  });
});
