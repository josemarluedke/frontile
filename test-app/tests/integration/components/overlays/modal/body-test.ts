import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render } from '@ember/test-helpers';
import hbs from 'htmlbars-inline-precompile';

module(
  'Integration | Component | @frontile/overlays/Modal::Body',
  function (hooks) {
    setupRenderingTest(hooks);

    test('it renders, content and html attributes', async function (assert) {
      await render(hbs`
      <Modal::Body data-test-id="body" class="other-class">
        My Body
      </Modal::Body>
    `);

      assert.dom('[data-test-id="body"]').hasText('My Body');
      assert.dom('[data-test-id="body"]').hasClass('other-class');
    });
  }
);
