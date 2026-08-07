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

    test('it defaults to the text shape at md size', async function (assert) {
      await render(<template><Skeleton data-test-id="skeleton" /></template>);

      assert.dom('[data-test-id="skeleton"]').hasClass('w-full');
      assert.dom('[data-test-id="skeleton"]').hasClass('h-4');
      assert.dom('[data-test-id="skeleton"]').hasClass('rounded-default');
    });

    test('the circle shape is a fully rounded square', async function (assert) {
      await render(
        <template>
          <Skeleton @shape="circle" data-test-id="skeleton" />
        </template>
      );

      assert.dom('[data-test-id="skeleton"]').hasClass('rounded-full');
      assert.dom('[data-test-id="skeleton"]').hasClass('aspect-square');
      assert
        .dom('[data-test-id="skeleton"]')
        .hasClass('size-8', 'md maps to the Avatar md scale');
      assert
        .dom('[data-test-id="skeleton"]')
        .doesNotHaveClass('w-full', 'a circle must not stretch');
      assert
        .dom('[data-test-id="skeleton"]')
        .doesNotHaveClass(
          'rounded-default',
          'border-radius must come only from the shape variant'
        );
    });

    test('the square shape matches Avatar squircle radius', async function (assert) {
      await render(
        <template>
          <Skeleton @shape="square" data-test-id="skeleton" />
        </template>
      );

      assert.dom('[data-test-id="skeleton"]').hasClass('rounded-[20%]');
      assert.dom('[data-test-id="skeleton"]').hasClass('size-8');
    });

    test('circle size tracks the Avatar size scale', async function (assert) {
      await render(
        <template>
          <Skeleton @shape="circle" @size="xs" data-test-id="xs" />
          <Skeleton @shape="circle" @size="sm" data-test-id="sm" />
          <Skeleton @shape="circle" @size="lg" data-test-id="lg" />
          <Skeleton @shape="circle" @size="xl" data-test-id="xl" />
        </template>
      );

      assert.dom('[data-test-id="xs"]').hasClass('size-5');
      assert.dom('[data-test-id="sm"]').hasClass('size-6');
      assert.dom('[data-test-id="lg"]').hasClass('size-10');
      assert.dom('[data-test-id="xl"]').hasClass('size-12');
    });

    test('text size sets height only, leaving width full', async function (assert) {
      await render(
        <template>
          <Skeleton @size="xs" data-test-id="xs" />
          <Skeleton @size="xl" data-test-id="xl" />
        </template>
      );

      assert.dom('[data-test-id="xs"]').hasClass('h-2.5');
      assert.dom('[data-test-id="xs"]').hasClass('w-full');
      assert.dom('[data-test-id="xl"]').hasClass('h-6');
      assert.dom('[data-test-id="xl"]').hasClass('w-full');
    });

    test('the rounded and rect shapes differ only in radius', async function (assert) {
      await render(
        <template>
          <Skeleton @shape="rounded" data-test-id="rounded" />
          <Skeleton @shape="rect" data-test-id="rect" />
        </template>
      );

      assert.dom('[data-test-id="rounded"]').hasClass('rounded-lg');
      assert.dom('[data-test-id="rounded"]').hasClass('w-full');
      assert.dom('[data-test-id="rect"]').hasClass('rounded-none');
      assert.dom('[data-test-id="rect"]').hasClass('w-full');
    });

    test('no shape renders without an intrinsic height', async function (assert) {
      // A zero-height skeleton is invisible, which is the failure mode that
      // makes a loading state look like an empty state.
      await render(
        <template>
          <Skeleton @shape="text" data-test-id="text" />
          <Skeleton @shape="circle" data-test-id="circle" />
          <Skeleton @shape="square" data-test-id="square" />
          <Skeleton @shape="rounded" data-test-id="rounded" />
          <Skeleton @shape="rect" data-test-id="rect" />
        </template>
      );

      for (const id of ['text', 'circle', 'square', 'rounded', 'rect']) {
        const el = this.element.querySelector(`[data-test-id="${id}"]`);
        assert.ok(
          el instanceof HTMLElement && el.offsetHeight > 0,
          `${id} has a non-zero height`
        );
      }
    });

    test('@class still overrides a shape preset', async function (assert) {
      await render(
        <template>
          <Skeleton @shape="rounded" @class="h-32" data-test-id="skeleton" />
        </template>
      );

      assert.dom('[data-test-id="skeleton"]').hasClass('h-32');
      assert.dom('[data-test-id="skeleton"]').doesNotHaveClass('h-4');
    });
  }
);
