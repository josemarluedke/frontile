import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, RenderingTestContext } from '@ember/test-helpers';
import hbs from 'htmlbars-inline-precompile';

module(
  'Integration | Component | @frontile/core/VisuallyHidden',
  function (hooks) {
    setupRenderingTest(hooks);

    test('it renders', async function (this: RenderingTestContext, assert) {
      await render(hbs`
      <VisuallyHidden data-test-id="my-element">
        This text will be visually hidden
      </VisuallyHidden>
    `);

      assert.equal(
        this.element.textContent?.trim(),
        'This text will be visually hidden'
      );
      assert.dom('[data-test-id="my-element"]').hasClass('sr-only');
    });
  }
);
