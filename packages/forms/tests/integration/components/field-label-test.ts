import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render } from '@ember/test-helpers';
import hbs from 'htmlbars-inline-precompile';

module('Integration | Component | FieldLabel', function(hooks) {
  setupRenderingTest(hooks);

  test('it renders content, attributes and args', async function(assert) {
    await render(
      hbs`<FieldLabel @for="some-input-id" class="something-else">My Label</FieldLabel>`
    );
    assert
      .dom('[data-test-id="field-label"]')
      .hasAttribute('for', 'some-input-id');

    assert.dom('[data-test-id="field-label"]').hasClass('field-label');
    assert.dom('[data-test-id="field-label"]').hasClass('something-else');
    assert.dom('[data-test-id="field-label"]').hasTextContaining('My Label');
  });
});
