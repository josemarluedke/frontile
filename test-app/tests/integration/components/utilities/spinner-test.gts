import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render } from '@ember/test-helpers';
import { Spinner } from 'frontile';

module(
  'Integration | Component | Spinner | @frontile/utilities',
  function (hooks) {
    setupRenderingTest(hooks);

    test('it renders', async function (assert) {
      await render(<template><Spinner data-test-id="spinner" /></template>);
      assert.dom('[data-test-id="spinner"]').exists();
    });

    test('it adds the class for the accent intent', async function (assert) {
      await render(
        <template><Spinner @intent="accent" data-test-id="spinner" /></template>
      );

      assert.dom('[data-test-id="spinner"]').hasClass('fill-accent');
    });
  }
);
