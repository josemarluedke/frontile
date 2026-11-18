import { module, test } from 'qunit';
// Relative source import on purpose: private modules are emitted as hashed
// chunks, so `frontile/-private/...` does not resolve.
import { assertRemovedArg } from '../../../packages/frontile/src/-private/removed-args';
import { collectAssertions } from '../helpers/collect-assertions';

module('Unit | -private | assertRemovedArg', function () {
  test('fails with the removal message for a defined old arg', async function (assert) {
    const failed = await collectAssertions(() =>
      assertRemovedArg('Select', { intent: 'primary' }, 'intent', 'color')
    );

    assert.deepEqual(failed, [
      'Select: @intent was removed in 0.19.0. Use @color.'
    ]);
  });

  test('fails for a falsy but defined old arg', async function (assert) {
    const failed = await collectAssertions(() =>
      assertRemovedArg('Select', { intent: null }, 'intent', 'color')
    );

    assert.strictEqual(failed.length, 1);
  });

  test('is silent when the old arg is absent', async function (assert) {
    const failed = await collectAssertions(() =>
      assertRemovedArg('Select', { color: 'primary' }, 'intent', 'color')
    );

    assert.deepEqual(failed, []);
  });

  test('is silent when the old arg is explicitly undefined', async function (assert) {
    const failed = await collectAssertions(() =>
      assertRemovedArg('Select', { intent: undefined }, 'intent', 'color')
    );

    assert.deepEqual(failed, []);
  });
});
