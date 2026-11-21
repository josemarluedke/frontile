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
  ).map((e) => e.textContent.trim());
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

  test('nested routes stack navbar actions and the aside', async function (assert) {
    await visit('/regions-demo');
    assert.deepEqual(
      actions(),
      ['No actions'],
      'the region shows its fallback'
    );
    assert.dom(TOGGLE).doesNotExist('no aside toggle without an aside');
    assert.dom('aside').doesNotExist();

    await visit('/regions-demo/orders');
    assert.deepEqual(actions(), ['New order']);
    assert.dom(TOGGLE).exists('the parent route fills the aside');

    await click(TOGGLE);
    assert.dom('aside [data-test-aside="orders"]').exists();

    await visit('/regions-demo/orders/1');
    assert.deepEqual(actions(), ['Refund'], 'the child replaces the parent');
    assert
      .dom('aside')
      .hasText('Order 1 details', 'the aside stays open with child content');

    await visit('/regions-demo/orders');
    assert.deepEqual(actions(), ['New order'], "the parent's comes back");
    assert.dom('aside').hasText('Orders filters');

    await visit('/regions-demo');
    assert.deepEqual(actions(), ['No actions']);
    assert.dom(TOGGLE).doesNotExist('the toggle hides again');
    assert.dom('aside').doesNotExist('an empty aside is hidden');

    await visit('/regions-demo/orders');
    assert
      .dom('aside')
      .hasText('Orders filters', 'coming back shows the panel again');
  });

  test('a deep link renders the child route content on first render', async function (assert) {
    await visit('/regions-demo/orders/7');
    assert.deepEqual(actions(), ['Refund']);
    await click(TOGGLE);
    assert.dom('aside').hasText('Order 7 details');
  });

  test('below lg, leaving the routes that fill the aside closes its drawer', async function (assert) {
    media?.setWidth(500);
    await visit('/regions-demo/orders');
    await click(TOGGLE);
    assert
      .dom('[role="dialog"] [data-test-aside="orders"]', document.body)
      .exists();

    await visit('/regions-demo/orders/1');
    assert
      .dom('[role="dialog"] [data-test-aside="order"]', document.body)
      .exists('the drawer stays open across routes that fill it');

    await visit('/regions-demo');
    assert.dom('[role="dialog"]', document.body).doesNotExist();

    await visit('/regions-demo/orders');
    assert
      .dom('[role="dialog"]', document.body)
      .doesNotExist('and navigating back does not open it');
  });
});
