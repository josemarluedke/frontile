import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render } from '@ember/test-helpers';
import hbs from 'htmlbars-inline-precompile';

module(
  'Integration | Component | @frontile/overlays/Modal::Header',
  function (hooks) {
    setupRenderingTest(hooks);

    test('it renders, content, html attributes, and @labelledById', async function (assert) {
      await render(hbs`
      <Modal::Header @labelledById="hello" data-test-id="header" class="other-class">
        My Header
      </Modal::Header>
    `);

      assert.dom('[data-test-id="header"]').hasText('My Header');
      assert.dom('[data-test-id="header"]').hasAttribute('id', 'hello');
      assert.dom('[data-test-id="header"]').hasClass('other-class');
    });
  }
);
