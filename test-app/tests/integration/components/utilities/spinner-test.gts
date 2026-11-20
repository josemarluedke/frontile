import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render } from '@ember/test-helpers';
import { Spinner } from 'frontile';
import { collectAssertions } from '../../../helpers/collect-assertions';

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

    test('it adds the class for the secondary color', async function (assert) {
      await render(
        <template>
          <Spinner @color="secondary" data-test-id="spinner" />
        </template>
      );

      assert.dom('[data-test-id="spinner"]').hasClass('fill-secondary');
    });

    test('@intent fails in development', async function (assert) {
      const failed = await collectAssertions(() =>
        render(
          <template>
            {{! @glint-expect-error -- removed in 0.19.0 }}
            <Spinner @intent="danger" data-test-id="spinner" />
          </template>
        )
      );

      assert.true(
        failed.includes('Spinner: @intent was removed in 0.19.0. Use @color.'),
        `got: ${failed.join(' | ')}`
      );
    });

    test('an explicitly undefined @intent stays silent', async function (assert) {
      const failed = await collectAssertions(() =>
        render(
          <template>
            {{! @glint-expect-error -- removed in 0.19.0 }}
            <Spinner @intent={{undefined}} data-test-id="spinner" />
          </template>
        )
      );

      assert.deepEqual(failed, []);
    });

    test('the color defaults to neutral', async function (assert) {
      await render(<template><Spinner data-test-id="spinner" /></template>);

      assert.dom('[data-test-id="spinner"]').hasClass('fill-neutral-strong');
    });

    test('renders data-component="spinner" on the root only, with data-part="base"', async function (assert) {
      await render(<template><Spinner /></template>);

      assert
        .dom('[data-component="spinner"]')
        .hasAttribute('data-part', 'base');
      assert.strictEqual(
        document.querySelectorAll('[data-component="spinner"]').length,
        1,
        'data-component="spinner" marks the root only'
      );
    });
  }
);
