import { module, test } from 'qunit';
import { setupTest } from 'ember-qunit';
import { flattenData, unflattenData, hasNestedData, deepEqual } from 'frontile';

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

    test('passes File values through untouched', function (assert) {
      const file = new File(['contents'], 'resume.txt', { type: 'text/plain' });
      const nested = {
        user: {
          name: 'John',
          resume: file
        }
      };

      const result = flattenData(nested);

      assert.strictEqual(
        result['user.resume'],
        file,
        'the same File instance is preserved'
      );
      assert.strictEqual(result['user.name'], 'John');
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

    test('passes File values through untouched', function (assert) {
      const file = new File(['contents'], 'resume.txt', { type: 'text/plain' });
      const flat = {
        'user.name': 'John',
        'user.resume': file
      };

      const result = unflattenData(flat);

      assert.strictEqual(
        (result['user'] as Record<string, unknown>)['resume'],
        file,
        'the same File instance is preserved'
      );
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

  module('prototype pollution', function (hooks) {
    // These tests write to a shared global (`Object.prototype`) if the guard
    // regresses, so scrub the known pollution targets after every test. A
    // leaked property here would silently corrupt every later test in the run.
    hooks.afterEach(function () {
      delete (Object.prototype as Record<string, unknown>)['isAdmin'];
      delete (Object.prototype as Record<string, unknown>)['polluted'];
    });

    test('unflattenData does not pollute Object.prototype via __proto__', function (assert) {
      const flat = {
        '__proto__.isAdmin': true,
        email: 'john@example.com'
      };

      const result = unflattenData(flat);

      assert.strictEqual(
        ({} as Record<string, unknown>)['isAdmin'],
        undefined,
        'Object.prototype was not polluted'
      );
      assert.deepEqual(
        result,
        { email: 'john@example.com' },
        'the dangerous path is dropped and safe data is kept'
      );
    });

    test('unflattenData does not pollute via constructor.prototype', function (assert) {
      // `constructor` never reached `Object.prototype` through the walk (it is
      // a function, which `isPlainObject` rejects) — before the guard this
      // produced `{constructor: {prototype: {polluted: true}}}`. It is refused
      // as defense in depth, so what this pins is the shape, plus the absence
      // of pollution if the walk is ever changed.
      const flat = {
        'constructor.prototype.polluted': true,
        email: 'john@example.com'
      };

      const result = unflattenData(flat);

      assert.strictEqual(
        ({} as Record<string, unknown>)['polluted'],
        undefined,
        'Object.prototype was not polluted'
      );
      assert.deepEqual(
        result,
        { email: 'john@example.com' },
        'the dangerous path is dropped and safe data is kept'
      );
    });

    test('unflattenData refuses a bare __proto__ final segment', function (assert) {
      // An object literal `{__proto__: ...}` would set the prototype rather
      // than create an own key, so build the own key explicitly.
      const flat: Record<string, unknown> = {};
      Object.defineProperty(flat, '__proto__', {
        value: { isAdmin: true },
        enumerable: true,
        writable: true,
        configurable: true
      });
      flat['email'] = 'john@example.com';

      const result = unflattenData(flat);

      assert.strictEqual(
        ({} as Record<string, unknown>)['isAdmin'],
        undefined,
        'Object.prototype was not polluted'
      );
      assert.notOk(
        Object.prototype.hasOwnProperty.call(result, '__proto__'),
        'no own __proto__ key is created on the result'
      );
      assert.strictEqual(
        result['email'],
        'john@example.com',
        'safe data is kept'
      );
    });

    test('unflattenData refuses dangerous segments in the middle of a path', function (assert) {
      const flat = {
        'user.__proto__.isAdmin': true,
        'user.constructor.prototype.polluted': true,
        'user.name': 'John'
      };

      const result = unflattenData(flat);

      assert.strictEqual(
        ({} as Record<string, unknown>)['isAdmin'],
        undefined,
        'Object.prototype was not polluted via __proto__'
      );
      assert.strictEqual(
        ({} as Record<string, unknown>)['polluted'],
        undefined,
        'Object.prototype was not polluted via constructor.prototype'
      );
      assert.deepEqual(
        result,
        { user: { name: 'John' } },
        'only the safe path is materialized'
      );
    });

    test('unflattenData returns objects with a normal prototype', function (assert) {
      // The result is consumed by Glimmer templates and Ember's `get()`, so it
      // must not be a null-prototype object.
      const result = unflattenData({ 'user.name': 'John' });

      assert.strictEqual(
        Object.getPrototypeOf(result),
        Object.prototype,
        'the root object has the normal Object prototype'
      );
      assert.strictEqual(
        Object.getPrototypeOf(result['user'] as object),
        Object.prototype,
        'nested objects have the normal Object prototype'
      );
    });

    test('flattenData drops dangerous keys so they cannot round-trip', function (assert) {
      const nested: Record<string, unknown> = { name: 'John' };
      Object.defineProperty(nested, '__proto__', {
        value: { isAdmin: true },
        enumerable: true,
        writable: true,
        configurable: true
      });

      const result = flattenData(nested);

      assert.deepEqual(
        result,
        { name: 'John' },
        'the dangerous key is not emitted'
      );
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
