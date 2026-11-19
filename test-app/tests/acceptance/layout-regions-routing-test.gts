// PROTOTYPE: layout regions, second attempt, over real nested routes.
import { module, test } from 'qunit';
import { setupApplicationTest } from 'ember-qunit';
import { visit, click, find, currentURL } from '@ember/test-helpers';
import {
  mockMatchMedia,
  type MatchMediaMock
} from 'test-app/tests/helpers/match-media';

const TOGGLE = '[data-part="aside-toggle"]';

function visibleText(selector: string): string {
  return ((find(selector) as HTMLElement | null)?.innerText ?? '')
    .replace(/\s+/g, ' ')
    .trim();
}

function display(selector: string): string {
  const element = find(selector);
  return element ? getComputedStyle(element).display : 'absent';
}

module('Acceptance | layout regions routing', function (hooks) {
  setupApplicationTest(hooks);

  let media: MatchMediaMock | undefined;

  hooks.beforeEach(function () {
    media = mockMatchMedia(1200);
  });

  hooks.afterEach(function () {
    media?.restore();
    media = undefined;
  });

  test('each route level fills the navbar actions and the aside, and leaving restores the parent', async function (assert) {
    await visit('/regions-demo');

    assert.strictEqual(visibleText('[data-test-actions]'), 'No actions');
    assert.strictEqual(display(TOGGLE), 'none', 'no aside, no toggle');

    await click('[data-test-link="orders"]');
    assert.strictEqual(currentURL(), '/regions-demo/orders');
    assert.strictEqual(visibleText('[data-test-actions]'), 'New order');
    assert.notStrictEqual(display(TOGGLE), 'none', 'the toggle appears');

    await click(TOGGLE);
    assert.strictEqual(visibleText('[data-part="aside"]'), 'Orders summary');
    const filter = find('[data-test-orders-filter]') as HTMLInputElement;
    filter.value = 'open';

    await click('[data-test-link="order-1"]');
    assert.strictEqual(visibleText('[data-test-actions]'), 'Refund order 1');
    assert.strictEqual(
      visibleText('[data-part="aside"]'),
      'Order 1 details',
      'the child covers the parent, and the aside stays open'
    );

    await click('[data-test-link="order-2"]');
    assert.strictEqual(visibleText('[data-test-actions]'), 'Refund order 2');
    assert.strictEqual(visibleText('[data-part="aside"]'), 'Order 2 details');
    assert.dom('[data-part="aside"]').isVisible('still open after a sibling');

    await click('[data-test-link="orders"]');
    assert.strictEqual(visibleText('[data-test-actions]'), 'New order');
    assert.strictEqual(visibleText('[data-part="aside"]'), 'Orders summary');
    assert.strictEqual(
      find('[data-test-orders-filter]'),
      filter,
      'the parent content is the same DOM'
    );
    assert.dom(filter).hasValue('open', 'with its state');

    await click('[data-test-link="home"]');
    assert.strictEqual(visibleText('[data-test-actions]'), 'No actions');
    assert.strictEqual(display(TOGGLE), 'none');
    assert.dom('[data-part="aside"]').doesNotExist('emptied: the aside closed');

    await click('[data-test-link="orders"]');
    assert
      .dom('[data-part="aside"]')
      .doesNotExist('and stays closed on return');
    assert.notStrictEqual(display(TOGGLE), 'none');
  });

  test('a sibling route that fills the aside takes it over without closing it', async function (assert) {
    await visit('/regions-demo/orders');
    await click(TOGGLE);
    assert.strictEqual(visibleText('[data-part="aside"]'), 'Orders summary');

    // A different route: the orders source is destroyed, the customers one
    // is created in the same render.
    await click('[data-test-link="customers"]');
    assert.strictEqual(currentURL(), '/regions-demo/customers');
    assert.dom('[data-part="aside"]').isVisible('the aside stayed open');
    assert.strictEqual(visibleText('[data-part="aside"]'), 'Customers summary');
    assert.dom('[data-test-aside="orders"]').doesNotExist();
    assert.strictEqual(visibleText('[data-test-actions]'), 'No actions');
  });

  test('a deep link fills both levels at once', async function (assert) {
    await visit('/regions-demo/orders/7');

    assert.strictEqual(visibleText('[data-test-actions]'), 'Refund order 7');
    assert.notStrictEqual(display(TOGGLE), 'none');

    await click(TOGGLE);
    assert.strictEqual(visibleText('[data-part="aside"]'), 'Order 7 details');
  });
});
