import { module, test } from 'qunit';
import { setupTest } from 'ember-qunit';
import { waitUntil } from '@ember/test-helpers';
import { MIN_VISIBLE, SHOW_DELAY } from 'site/services/route-loading';

function wait(ms: number): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

module('Unit | Service | route-loading', function (hooks) {
  setupTest(hooks);

  test('it stays quiet for a transition that settles inside the delay', async function (assert) {
    const service = this.owner.lookup('service:route-loading');

    service.start();
    service.finish();
    await wait(SHOW_DELAY * 2);

    assert.false(service.isLoading);
  });

  test('it reports loading once a transition outlives the delay', async function (assert) {
    const service = this.owner.lookup('service:route-loading');

    service.start();
    await waitUntil(() => service.isLoading, { timeout: SHOW_DELAY + 1000 });

    assert.true(service.isLoading);
  });

  test('it holds the indicator for the minimum visible time', async function (assert) {
    const service = this.owner.lookup('service:route-loading');

    service.start();
    await waitUntil(() => service.isLoading, { timeout: SHOW_DELAY + 1000 });

    service.finish();
    assert.true(
      service.isLoading,
      'a transition that finishes right away does not blink the bar off'
    );

    await waitUntil(() => !service.isLoading, { timeout: MIN_VISIBLE + 1000 });
    assert.false(service.isLoading);
  });

  test('a redirect mid-transition keeps the same wait', async function (assert) {
    const service = this.owner.lookup('service:route-loading');

    service.start();
    service.start();
    await waitUntil(() => service.isLoading, { timeout: SHOW_DELAY + 1000 });

    service.finish();
    await waitUntil(() => !service.isLoading, { timeout: MIN_VISIBLE + 1000 });

    assert.false(service.isLoading);
  });

  test('a new transition while the bar is winding down keeps it up', async function (assert) {
    const service = this.owner.lookup('service:route-loading');

    service.start();
    await waitUntil(() => service.isLoading, { timeout: SHOW_DELAY + 1000 });
    service.finish();

    service.start();
    await wait(MIN_VISIBLE + 50);
    assert.true(service.isLoading, 'the pending hide was cancelled');

    service.finish();
    await waitUntil(() => !service.isLoading, { timeout: MIN_VISIBLE + 1000 });
    assert.false(service.isLoading);
  });
});
