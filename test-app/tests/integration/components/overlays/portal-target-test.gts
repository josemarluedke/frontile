import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render } from '@ember/test-helpers';
import { PortalTarget } from 'frontile';

module(
  'Integration | Component | @frontile/overlays/PortalTarget',
  function (hooks) {
    setupRenderingTest(hooks);

    test('it renders the portal target', async function (assert) {
      await render(<template><PortalTarget /></template>);

      assert.dom('[data-portal-target]').exists();
    });

    test('it renders a named portal target', async function (assert) {
      await render(<template><PortalTarget @for="my-name" /></template>);

      assert
        .dom('[data-portal-target]')
        .hasAttribute('data-portal-for', 'my-name');
    });
  }
);
