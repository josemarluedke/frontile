import { module, test } from 'qunit';
import { settled } from '@ember/test-helpers';
import { getPendingWaiterState } from '@ember/test-waiters';
import { deferredWork } from 'frontile/utils/deferred-work';

const LABEL = '@frontile/test:deferred-work-shared';

module('Unit | utils | deferred-work', function () {
  // Every call site passes a constant label, and several of them live on a
  // per-instance field -- two segmented controls, or a segmented control and a
  // tab nav on one page, build the same-named waiter twice. `buildWaiter`
  // registers by name into a single global map, so the second registration
  // evicts the first and that first waiter never re-registers: its pending
  // work becomes invisible to `settled()` forever. One waiter per label,
  // shared across instances, is what keeps both visible.
  test('two instances sharing a label both stay visible to settled()', async function (assert) {
    const a = deferredWork(LABEL);
    const b = deferredWork(LABEL);

    a.schedule(() => {});
    b.schedule(() => {});

    const pending = getPendingWaiterState().waiters[LABEL];

    assert.ok(pending, 'the label is registered while work is pending');
    assert.strictEqual(
      Object.keys(pending as object).length,
      2,
      'both instances contribute a pending token'
    );

    await settled();

    assert.notOk(
      getPendingWaiterState().waiters[LABEL],
      'nothing is pending once the work has run'
    );
  });
});
