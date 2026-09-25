import { module, test } from 'qunit';
import { getPath } from 'frontile/utils/get-path';

module('Unit | Forms | Utils | getPath', function () {
  test('reads a flat key', function (assert) {
    assert.strictEqual(
      getPath({ email: 'a@example.com' }, 'email'),
      'a@example.com'
    );
  });

  test('reads a dotted path through nested objects', function (assert) {
    const data = { user: { profile: { email: 'a@example.com' } } };

    assert.strictEqual(getPath(data, 'user.profile.email'), 'a@example.com');
    assert.deepEqual(getPath(data, 'user.profile'), { email: 'a@example.com' });
  });

  test('returns falsy leaf values as-is', function (assert) {
    const data = { a: { zero: 0, off: false, empty: '', nothing: null } };

    assert.strictEqual(getPath(data, 'a.zero'), 0);
    assert.false(getPath(data, 'a.off'));
    assert.strictEqual(getPath(data, 'a.empty'), '');
    assert.strictEqual(getPath(data, 'a.nothing'), null);
  });

  test('returns undefined for a missing key or intermediate', function (assert) {
    const data = { user: { name: 'Ada' } };

    assert.strictEqual(getPath(data, 'missing'), undefined);
    assert.strictEqual(getPath(data, 'user.missing'), undefined);
    assert.strictEqual(getPath(data, 'missing.deeper.still'), undefined);
  });

  test('returns undefined when an intermediate is null or a primitive', function (assert) {
    const data = { user: null, count: 3 } as Record<string, unknown>;

    assert.strictEqual(getPath(data, 'user.name'), undefined);
    assert.strictEqual(getPath(data, 'count.toFixed'), undefined);
  });

  test('reads array indices', function (assert) {
    assert.strictEqual(getPath({ tags: ['a', 'b'] }, 'tags.1'), 'b');
  });

  test('refuses unsafe segments instead of reaching the prototype', function (assert) {
    const data = { user: { name: 'Ada' } };

    assert.strictEqual(getPath(data, '__proto__'), undefined);
    assert.strictEqual(getPath(data, 'user.__proto__'), undefined);
    assert.strictEqual(getPath(data, 'constructor'), undefined);
    assert.strictEqual(getPath(data, 'user.constructor.prototype'), undefined);
  });

  test('does not read inherited properties', function (assert) {
    assert.strictEqual(getPath({}, 'toString'), undefined);
    assert.strictEqual(getPath({ a: {} }, 'a.hasOwnProperty'), undefined);
  });
});
