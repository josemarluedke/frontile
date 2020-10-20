import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render } from '@ember/test-helpers';
import hbs from 'htmlbars-inline-precompile';

module('Integration | Component | Drawer::Body', function (hooks) {
  setupRenderingTest(hooks);

  test('it renders, content and html attributes', async function (assert) {
    await render(hbs`
      <Drawer::Body data-test-id="body" class="other-class">
        My Body
      </Drawer::Body>
    `);

    assert.dom('[data-test-id="body"]').hasText('My Body');
    assert.dom('[data-test-id="body"]').hasClass('drawer__body');
    assert.dom('[data-test-id="body"]').hasClass('other-class');
  });
});
