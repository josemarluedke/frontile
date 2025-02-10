import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render } from '@ember/test-helpers';
import { VisuallyHidden } from '@frontile/utilities';

module(
  'Integration | Component | @frontile/utilities/VisuallyHidden',
  function (hooks) {
    setupRenderingTest(hooks);

    test('it renders', async function (assert) {
      await render(
        <template>
          <VisuallyHidden data-test-id="my-element">
            This text will be visually hidden
          </VisuallyHidden>
        </template>
      );

      assert
        .dom('[data-test-id="my-element"]')
        .hasText('This text will be visually hidden');
      assert.dom('[data-test-id="my-element"]').hasClass('sr-only');
    });
  }
);
