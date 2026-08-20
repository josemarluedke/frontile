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

    test('it adds the size classes, including the default md size', async function (assert) {
      await render(
        <template>
          <Spinner data-test-id="default" />
          <Spinner @size="sm" data-test-id="sm" />
        </template>
      );

      assert.dom('[data-test-id="default"]').hasClass('w-8');
      assert.dom('[data-test-id="default"]').hasClass('h-8');
      assert.dom('[data-test-id="sm"]').hasClass('w-6');
      assert.dom('[data-test-id="sm"]').hasClass('h-6');
    });

    test('it adds the class for the secondary intent', async function (assert) {
      await render(
        <template>
          <Spinner @intent="secondary" data-test-id="spinner" />
        </template>
      );

      assert.dom('[data-test-id="spinner"]').hasClass('fill-secondary');
    });
  }
);
