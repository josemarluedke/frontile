import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, RenderingTestContext } from '@ember/test-helpers';
import hbs from 'htmlbars-inline-precompile';

module(
  'Integration | Helper | @frontile/core/use-frontile-class',
  function (hooks) {
    setupRenderingTest(hooks);

    test('it adds base class', async function (this: RenderingTestContext, assert) {
      await render(hbs`{{use-frontile-class "base-class"}}`);

      assert.equal(this.element.textContent?.trim(), 'base-class');
    });

    test('it adds variant classes', async function (this: RenderingTestContext, assert) {
      await render(
        hbs`{{use-frontile-class "base-class" "variant-1" "variant-2"}}`
      );

      assert.equal(
        this.element.textContent?.trim(),
        'base-class base-class--variant-1 base-class--variant-2'
      );
    });

    test('it ignores empty variants', async function (this: RenderingTestContext, assert) {
      await render(hbs`{{use-frontile-class "base-class" "variant-1" ""}}`);

      assert.equal(
        this.element.textContent?.trim(),
        'base-class base-class--variant-1'
      );
    });

    test('it works with expressions', async function (this: RenderingTestContext, assert) {
      await render(
        hbs`{{use-frontile-class "base-class" (if false "variant-1") "variant-2"}}`
      );

      assert.equal(
        this.element.textContent?.trim(),
        'base-class base-class--variant-2'
      );
    });

    test('it adds part', async function (this: RenderingTestContext, assert) {
      await render(hbs`{{use-frontile-class "base-class" part="part-name"}}`);

      assert.equal(this.element.textContent?.trim(), 'base-class__part-name');
    });

    test('it adds part with variants', async function (this: RenderingTestContext, assert) {
      await render(
        hbs`{{use-frontile-class "base-class" "variant-1" "variant-2" part="part-name"}}`
      );

      assert.equal(
        this.element.textContent?.trim(),
        'base-class__part-name base-class--variant-1__part-name base-class--variant-2__part-name'
      );
    });

    test('it adds additional classes', async function (this: RenderingTestContext, assert) {
      await render(hbs`{{use-frontile-class "base-class" class="my-class"}}`);

      assert.equal(this.element.textContent?.trim(), 'base-class my-class');
    });
  }
);
