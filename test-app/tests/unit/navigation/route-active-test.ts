import { module, test } from 'qunit';
import type RouterService from '@ember/routing/router-service';
import { isRouteActive, normalizeRouteArgs } from 'frontile/utils/route-active';

interface Call {
  route: string;
  rest: unknown[];
}

function fakeRouter(
  impl: (route: string, ...rest: unknown[]) => boolean = () => true
) {
  const calls: Call[] = [];
  const router = {
    currentURL: '/',
    isActive(route: string, ...rest: unknown[]) {
      calls.push({ route, rest });
      return impl(route, ...rest);
    }
  } as unknown as RouterService;
  return { router, calls };
}

module('Unit | Utils | route-active', function () {
  test('explicit isActive wins', function (assert) {
    const { router, calls } = fakeRouter(() => true);

    assert.false(isRouteActive(router, { route: 'a', isActive: false }));
    assert.true(isRouteActive(router, { isActive: true }));
    assert.strictEqual(calls.length, 0, 'the router is never consulted');
  });

  test('no route is false', function (assert) {
    const { router, calls } = fakeRouter(() => true);

    assert.false(isRouteActive(router, {}));
    assert.strictEqual(calls.length, 0);
  });

  test('model 0 is kept', function (assert) {
    assert.deepEqual(normalizeRouteArgs({ model: 0 }).models, [0]);
    assert.deepEqual(normalizeRouteArgs({ model: '' }).models, ['']);
    assert.deepEqual(normalizeRouteArgs({ model: null }).models, []);
    assert.deepEqual(
      normalizeRouteArgs({ models: [1, 2], model: 3 }).models,
      [1, 2]
    );

    const { router, calls } = fakeRouter();
    isRouteActive(router, { route: 'a', model: 0 });
    assert.deepEqual(calls[0]?.rest[0], 0);
  });

  test('query defaults to {}', function (assert) {
    assert.deepEqual(normalizeRouteArgs({}).query, {});
    assert.deepEqual(normalizeRouteArgs({ query: { q: '1' } }).query, {
      q: '1'
    });
  });

  test('unreachable route is false', function (assert) {
    const { router } = fakeRouter(() => {
      throw new Error('not reachable');
    });

    assert.false(isRouteActive(router, { route: 'engine.home' }));
  });
});
