import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, waitUntil } from '@ember/test-helpers';
import DocfyRouteLoadingBar from 'site/components/docfy/docfy-route-loading-bar';
import type RouteLoadingService from 'site/services/route-loading';
import { MIN_VISIBLE, SHOW_DELAY } from 'site/services/route-loading';

const BAR = '[data-test-id="route-loading-bar"]';

module(
  'Integration | Component | docfy/docfy-route-loading-bar',
  function (hooks) {
    setupRenderingTest(hooks);

    function routeLoading(context: object): RouteLoadingService {
      return (
        context as { owner: { lookup(name: string): RouteLoadingService } }
      ).owner.lookup('service:route-loading');
    }

    test('it shows nothing while no transition is in flight', async function (assert) {
      await render(<template><DocfyRouteLoadingBar /></template>);

      assert.dom(BAR).doesNotExist();
      assert.dom('[role="status"]').exists('the live region is always present');
    });

    test('a transition slower than the delay raises the hairline, and it drops once the transition settles', async function (assert) {
      const service = routeLoading(this);

      await render(<template><DocfyRouteLoadingBar /></template>);

      service.start();
      assert
        .dom(BAR)
        .doesNotExist('nothing appears before the delay has elapsed');

      await waitUntil(() => document.querySelector(BAR), {
        timeout: SHOW_DELAY + 1000,
      });
      assert.dom(BAR).hasClass('animate-swing');
      assert.dom('[role="status"]').hasText('Loading page');

      service.finish();
      await waitUntil(() => !document.querySelector(BAR), {
        timeout: MIN_VISIBLE + 1000,
      });
      assert.dom(BAR).doesNotExist();
    });

    test('a transition faster than the delay never raises the hairline', async function (assert) {
      const service = routeLoading(this);

      await render(<template><DocfyRouteLoadingBar /></template>);

      service.start();
      service.finish();

      await new Promise((resolve) => setTimeout(resolve, SHOW_DELAY * 2));
      assert.dom(BAR).doesNotExist();
    });
  }
);
