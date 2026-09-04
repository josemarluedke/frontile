import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, settled } from '@ember/test-helpers';
import DocfyRouteLoadingBar from 'site/components/docfy/docfy-route-loading-bar';

const BAR = '[data-test-id="route-loading-bar"]';

// The component's whole job is to render the bar while the service says a
// transition is in flight. When it decides to say so — the show delay and the
// minimum visible time — is pinned by the service's own unit tests, so these
// drive the flag directly rather than waiting on real clocks.
module(
  'Integration | Component | docfy/docfy-route-loading-bar',
  function (hooks) {
    setupRenderingTest(hooks);

    test('it shows nothing while no transition is in flight', async function (assert) {
      await render(<template><DocfyRouteLoadingBar /></template>);

      assert.dom(BAR).doesNotExist();
      assert.dom('[role="status"]').exists('the live region is always present');
    });

    test('it raises the bar while the service reports loading, and drops it after', async function (assert) {
      const service = this.owner.lookup('service:route-loading');

      await render(<template><DocfyRouteLoadingBar /></template>);

      service.isLoading = true;
      await settled();
      assert.dom(BAR).hasClass('animate-swing');
      assert.dom('[role="status"]').hasText('Loading page');

      service.isLoading = false;
      await settled();
      assert.dom(BAR).doesNotExist();
    });
  }
);
