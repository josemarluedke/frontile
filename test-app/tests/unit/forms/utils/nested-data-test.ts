import { module, test } from 'qunit';
import { setupTest } from 'ember-qunit';
import {
  flattenData,
  unflattenData,
  hasNestedData,
  deepEqual
} from '@frontile/forms';

module('Unit | Forms | Utils | nested-data', function (hooks) {
  setupTest(hooks);

  module('flattenData', function () {
    test('flattens simple nested object', function (assert) {
      const nested = {
        name: { first: 'John', last: 'Doe' },
        email: 'john@example.com'
      };

      const result = flattenData(nested);

      assert.deepEqual(result, {
        'name.first': 'John',
        'name.last': 'Doe',
        email: 'john@example.com'
      });
    });

    test('flattens deeply nested object', function (assert) {
      const nested = {
        user: {
          profile: {
            contact: {
              email: 'john@example.com',
              phone: '123-456-7890'
            },
            name: 'John Doe'
          },
          id: 123
        }
      };

      const result = flattenData(nested);

      assert.deepEqual(result, {
        'user.profile.contact.email': 'john@example.com',
        'user.profile.contact.phone': '123-456-7890',
        'user.profile.name': 'John Doe',
        'user.id': 123
      });
    });

    test('handles arrays as primitive values', function (assert) {
      const nested = {
        user: {
          name: 'John',
          tags: ['developer', 'designer']
        }
      };

      const result = flattenData(nested);

      assert.deepEqual(result, {
        'user.name': 'John',
        'user.tags': ['developer', 'designer']
      });
    });

    test('handles special objects (Date, File)', function (assert) {
      const date = new Date('2025-01-01');
      const nested = {
        user: {
          name: 'John',
          birthdate: date
        }
      };

      const result = flattenData(nested);

      assert.deepEqual(result, {
        'user.name': 'John',
        'user.birthdate': date
      });
      assert.strictEqual(result['user.birthdate'], date);
    });

    test('handles null and undefined values', function (assert) {
      const nested = {
        user: {
          name: 'John',
          email: null,
          phone: undefined
        }
      };

      const result = flattenData(nested);

      assert.deepEqual(result, {
        'user.name': 'John',
        'user.email': null,
        'user.phone': undefined
      });
    });

    test('returns empty object for empty input', function (assert) {
      const result = flattenData({});
      assert.deepEqual(result, {});
    });

    test('handles already flat object', function (assert) {
      const flat = {
        name: 'John',
        email: 'john@example.com',
        age: 30
      };

      const result = flattenData(flat);

      assert.deepEqual(result, flat);
    });
  });

  module('unflattenData', function () {
    test('unflattens simple dotted keys', function (assert) {
      const flat = {
        'name.first': 'John',
        'name.last': 'Doe',
        email: 'john@example.com'
      };

      const result = unflattenData(flat);

      assert.deepEqual(result, {
        name: { first: 'John', last: 'Doe' },
        email: 'john@example.com'
      });
    });

    test('unflattens deeply nested paths', function (assert) {
      const flat = {
        'user.profile.contact.email': 'john@example.com',
        'user.profile.contact.phone': '123-456-7890',
        'user.profile.name': 'John Doe',
        'user.id': 123
      };

      const result = unflattenData(flat);

      assert.deepEqual(result, {
        user: {
          profile: {
            contact: {
              email: 'john@example.com',
              phone: '123-456-7890'
            },
            name: 'John Doe'
          },
          id: 123
        }
      });
    });

    test('handles arrays as primitive values', function (assert) {
      const flat = {
        'user.name': 'John',
        'user.tags': ['developer', 'designer']
      };

      const result = unflattenData(flat);

      assert.deepEqual(result, {
        user: {
          name: 'John',
          tags: ['developer', 'designer']
        }
      });
    });

    test('handles null and undefined values', function (assert) {
      const flat = {
        'user.name': 'John',
        'user.email': null,
        'user.phone': undefined
      };

      const result = unflattenData(flat);

      assert.deepEqual(result, {
        user: {
          name: 'John',
          email: null,
          phone: undefined
        }
      });
    });

    test('returns empty object for empty input', function (assert) {
      const result = unflattenData({});
      assert.deepEqual(result, {});
    });

    test('handles already nested object (no dots)', function (assert) {
      const flat = {
        name: 'John',
        email: 'john@example.com',
        age: 30
      };

      const result = unflattenData(flat);

      assert.deepEqual(result, flat);
    });

    test('round-trip: flatten then unflatten', function (assert) {
      const original = {
        user: {
          profile: {
            name: 'John Doe',
            email: 'john@example.com'
          },
          settings: {
            theme: 'dark',
            notifications: true
          }
        },
        timestamp: new Date('2025-01-01')
      };

      const flattened = flattenData(original);
      const unflattened = unflattenData(flattened);

      assert.deepEqual(unflattened, original);
    });
  });

  module('hasNestedData', function () {
    test('returns true for nested objects', function (assert) {
      const nested = {
        user: {
          name: 'John'
        }
      };

      assert.true(hasNestedData(nested));
    });

    test('returns false for flat objects', function (assert) {
      const flat = {
        name: 'John',
        email: 'john@example.com',
        age: 30
      };

      assert.false(hasNestedData(flat));
    });

    test('returns false for objects with arrays', function (assert) {
      const obj = {
        name: 'John',
        tags: ['developer', 'designer']
      };

      assert.false(hasNestedData(obj));
    });

    test('returns false for objects with special objects', function (assert) {
      const obj = {
        name: 'John',
        birthdate: new Date('2025-01-01')
      };

      assert.false(hasNestedData(obj));
    });

    test('returns false for empty objects', function (assert) {
      assert.false(hasNestedData({}));
    });

    test('returns true for mixed flat and nested', function (assert) {
      const mixed = {
        name: 'John',
        profile: {
          email: 'john@example.com'
        }
      };

      assert.true(hasNestedData(mixed));
    });
  });

  module('deepEqual', function () {
    test('compares primitives', function (assert) {
      assert.true(deepEqual(1, 1));
      assert.true(deepEqual('hello', 'hello'));
      assert.true(deepEqual(true, true));
      assert.true(deepEqual(null, null));
      assert.true(deepEqual(undefined, undefined));

      assert.false(deepEqual(1, 2));
      assert.false(deepEqual('hello', 'world'));
      assert.false(deepEqual(true, false));
      assert.false(deepEqual(null, undefined));
    });

    test('compares arrays', function (assert) {
      assert.true(deepEqual([1, 2, 3], [1, 2, 3]));
      assert.true(deepEqual(['a', 'b'], ['a', 'b']));
      assert.true(deepEqual([], []));

      assert.false(deepEqual([1, 2, 3], [1, 2, 4]));
      assert.false(deepEqual([1, 2], [1, 2, 3]));
      assert.false(deepEqual([1], [2]));
    });

    test('compares nested arrays', function (assert) {
      assert.true(
        deepEqual(
          [
            [1, 2],
            [3, 4]
          ],
          [
            [1, 2],
            [3, 4]
          ]
        )
      );
      assert.false(
        deepEqual(
          [
            [1, 2],
            [3, 4]
          ],
          [
            [1, 2],
            [3, 5]
          ]
        )
      );
    });

    test('compares simple objects', function (assert) {
      assert.true(deepEqual({ a: 1, b: 2 }, { a: 1, b: 2 }));
      assert.true(deepEqual({ a: 1, b: 2 }, { b: 2, a: 1 }));
      assert.true(deepEqual({}, {}));

      assert.false(deepEqual({ a: 1 }, { a: 2 }));
      assert.false(deepEqual({ a: 1 }, { a: 1, b: 2 }));
    });

    test('compares nested objects', function (assert) {
      const obj1 = {
        user: {
          name: 'John',
          profile: {
            email: 'john@example.com'
          }
        }
      };

      const obj2 = {
        user: {
          name: 'John',
          profile: {
            email: 'john@example.com'
          }
        }
      };

      const obj3 = {
        user: {
          name: 'Jane',
          profile: {
            email: 'john@example.com'
          }
        }
      };

      assert.true(deepEqual(obj1, obj2));
      assert.false(deepEqual(obj1, obj3));
    });

    test('compares objects with arrays', function (assert) {
      const obj1 = {
        name: 'John',
        tags: ['developer', 'designer']
      };

      const obj2 = {
        name: 'John',
        tags: ['developer', 'designer']
      };

      const obj3 = {
        name: 'John',
        tags: ['developer']
      };

      assert.true(deepEqual(obj1, obj2));
      assert.false(deepEqual(obj1, obj3));
    });

    test('compares null and undefined', function (assert) {
      assert.true(deepEqual(null, null));
      assert.true(deepEqual(undefined, undefined));
      assert.false(deepEqual(null, undefined));
      assert.false(deepEqual(null, 0));
      assert.false(deepEqual(undefined, 0));
    });

    test('compares special objects by reference', function (assert) {
      const date1 = new Date('2025-01-01');
      const date2 = new Date('2025-01-01');
      const date3 = date1;

      // Different Date instances with same value are not equal
      assert.false(deepEqual(date1, date2));
      // Same Date instance is equal
      assert.true(deepEqual(date1, date3));
    });

    test('handles different types', function (assert) {
      assert.false(deepEqual(1, '1'));
      assert.false(deepEqual([], {}));
      assert.false(deepEqual(null, {}));
      assert.false(deepEqual(undefined, {}));
    });
  });
});
