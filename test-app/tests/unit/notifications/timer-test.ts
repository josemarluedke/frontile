import { module, test } from 'qunit';
import { setupTest } from 'ember-qunit';
import { Timer } from 'frontile/notifications';
import { waitUntil } from '@ember/test-helpers';

const sleep = (ms: number): Promise<void> =>
  new Promise((resolve) => setTimeout(resolve, ms));

module('Unit | @frontile/notifications/Timer', function (hooks) {
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

  test('pause is idempotent and does not double-subtract remaining', async function (assert) {
    const timer = new Timer(2000, () => {
      // nothing
    });

    await sleep(100);

    timer.pause();
    const remainingAfterFirstPause = timer.remaining;

    await sleep(100);

    timer.pause();

    assert.equal(
      timer.remaining,
      remainingAfterFirstPause,
      'a second pause does not subtract the elapsed time again'
    );
    assert.ok(timer.remaining > 0, 'remaining is still positive');
  });

  test('pause never leaves remaining negative', async function (assert) {
    const timer = new Timer(10, () => {
      // nothing
    });

    // Let the duration fully elapse before pausing.
    await sleep(100);

    timer.pause();

    assert.ok(
      timer.remaining >= 0,
      `remaining should never be negative, got ${timer.remaining}`
    );

    // A resume must not fire immediately because of a negative remaining.
    timer.resume();
    assert.ok(timer.isRunning);
    timer.clear();
  });

  test('resume while running does not restart the remaining time', async function (assert) {
    const timer = new Timer(2000, () => {
      // nothing
    });

    await sleep(200);
    timer.resume();
    await sleep(200);
    timer.pause();

    assert.ok(
      timer.remaining <= 1700,
      `remaining should account for all elapsed time, got ${timer.remaining}`
    );
  });
});
