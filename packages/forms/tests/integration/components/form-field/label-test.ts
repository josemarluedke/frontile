import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render } from '@ember/test-helpers';
import hbs from 'htmlbars-inline-precompile';

module('Integration | Component | FormField::Label', function(hooks) {
  setupRenderingTest(hooks);

  test('it renders content, attributes and args', async function(assert) {
    await render(
      hbs`<FormField::Label @for="some-input-id" class="something-else">My Label</FormField::Label>`
    );
    assert
      .dom('[data-test-id="form-field-label"]')
      .hasAttribute('for', 'some-input-id');

    assert
      .dom('[data-test-id="form-field-label"]')
      .hasClass('form-field-label');
    assert.dom('[data-test-id="form-field-label"]').hasClass('something-else');
    assert
      .dom('[data-test-id="form-field-label"]')
      .hasTextContaining('My Label');
  });
});
