import { module, test } from 'qunit';
import { setupTest } from 'ember-qunit';
import { Timer } from '@frontile/notifications';
import { waitUntil } from '@ember/test-helpers';

module('Unit | Timer', function (hooks) {
  setupTest(hooks);

  test('it calls onFinish when timer is up', async function (assert) {
    assert.expect(2);

    const timer = new Timer(10, () => {
      assert.ok(true);
    });

    assert.ok(timer.remaining <= 10);

    await waitUntil(
      () => {
        return timer.isRunning === false;
      },
      { timeout: 11 }
    );
  });

  test('it can pause and resume', async function (assert) {
    const timer = new Timer(10, () => {
      // nothing
    });

    assert.ok(timer.remaining <= 10);

    timer.pause();

    await waitUntil(
      () => {
        return timer.isRunning === false;
      },
      { timeout: 2 }
    );

    assert.ok(timer.remaining <= 10);
    assert.ok(timer.remaining > 0);

    timer.resume();
    assert.ok(timer.isRunning);

    await waitUntil(
      () => {
        return timer.isRunning === false;
      },
      { timeout: timer.remaining + 1 } // eslint-disable-line
    );
  });
});
