import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render } from '@ember/test-helpers';
import { ModalFooter as Footer } from 'frontile/overlays';

module(
  'Integration | Component | @frontile/overlays/Modal::Footer',
  function (hooks) {
    setupRenderingTest(hooks);

    test('it renders, content and html attributes', async function (assert) {
      await render(
        <template>
          <Footer data-test-id="footer" class="other-class">
            My Footer
          </Footer>
        </template>
      );

      assert.dom('[data-test-id="footer"]').hasText('My Footer');
      assert.dom('[data-test-id="footer"]').hasClass('other-class');
    });
  }
);
