import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render } from '@ember/test-helpers';
import hbs from 'htmlbars-inline-precompile';

module('Integration | Component | FieldHint', function(hooks) {
  setupRenderingTest(hooks);

  test('it renders content, attributes and args', async function(assert) {
    await render(
      hbs`<FieldHint @id="some-hint-id" class="something-else">Content</FieldHint>`
    );
    assert
      .dom('[data-test-id="field-hint"]')
      .hasAttribute('id', 'some-hint-id');

    assert.dom('[data-test-id="field-hint"]').hasClass('field-hint');
    assert.dom('[data-test-id="field-hint"]').hasClass('something-else');
    assert.dom('[data-test-id="field-hint"]').hasTextContaining('Content');
  });
});
