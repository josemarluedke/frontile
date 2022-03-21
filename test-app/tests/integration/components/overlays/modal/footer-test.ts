import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render } from '@ember/test-helpers';
import hbs from 'htmlbars-inline-precompile';

module(
  'Integration | Component | @frontile/overlays/Modal::Footer',
  function (hooks) {
    setupRenderingTest(hooks);

    test('it renders, content and html attributes', async function (assert) {
      await render(hbs`
      <Modal::Footer data-test-id="footer" class="other-class">
        My Footer
      </Modal::Footer>
    `);

      assert.dom('[data-test-id="footer"]').hasText('My Footer');
      assert.dom('[data-test-id="footer"]').hasClass('modal__footer');
      assert.dom('[data-test-id="footer"]').hasClass('other-class');
    });
  }
);
