import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render } from '@ember/test-helpers';
import { Skeleton } from 'frontile';

module(
  'Integration | Component | Skeleton | @frontile/utilities',
  function (hooks) {
    setupRenderingTest(hooks);

    test('it renders', async function (assert) {
      await render(<template><Skeleton data-test-id="skeleton" /></template>);

      assert.dom('[data-test-id="skeleton"]').exists();
    });

    test('it is hidden from assistive technology', async function (assert) {
      await render(<template><Skeleton data-test-id="skeleton" /></template>);

      assert
        .dom('[data-test-id="skeleton"]')
        .hasAttribute('aria-hidden', 'true');
    });

    test('it animates with shimmer by default', async function (assert) {
      await render(<template><Skeleton data-test-id="skeleton" /></template>);

      assert.dom('[data-test-id="skeleton"]').hasClass('animate-shimmer');
    });

    test('it supports the pulse animation', async function (assert) {
      await render(
        <template>
          <Skeleton @animation="pulse" data-test-id="skeleton" />
        </template>
      );

      assert.dom('[data-test-id="skeleton"]').hasClass('animate-pulse');
      assert
        .dom('[data-test-id="skeleton"]')
        .doesNotHaveClass('animate-shimmer');
    });

    test('it supports no animation', async function (assert) {
      await render(
        <template>
          <Skeleton @animation="none" data-test-id="skeleton" />
        </template>
      );

      assert
        .dom('[data-test-id="skeleton"]')
        .doesNotHaveClass('animate-shimmer');
      assert.dom('[data-test-id="skeleton"]').doesNotHaveClass('animate-pulse');
    });

    test('it merges a custom class over the default size', async function (assert) {
      await render(
        <template>
          <Skeleton @class="h-10 w-10 rounded-full" data-test-id="skeleton" />
        </template>
      );

      assert.dom('[data-test-id="skeleton"]').hasClass('h-10');
      assert.dom('[data-test-id="skeleton"]').hasClass('w-10');
      assert.dom('[data-test-id="skeleton"]').hasClass('rounded-full');
      assert
        .dom('[data-test-id="skeleton"]')
        .doesNotHaveClass(
          'h-4',
          'tailwind-merge drops the conflicting default'
        );
    });
  }
);
