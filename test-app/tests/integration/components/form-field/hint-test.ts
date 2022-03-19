import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render } from '@ember/test-helpers';
import hbs from 'htmlbars-inline-precompile';

module('Integration | Component | FormField::Hint', function (hooks) {
  setupRenderingTest(hooks);

  test('it renders content, attributes and args', async function (assert) {
    await render(
      hbs`<FormField::Hint @id="some-hint-id" class="something-else">Content</FormField::Hint>`
    );
    assert
      .dom('[data-test-id="form-field-hint"]')
      .hasAttribute('id', 'some-hint-id');

    assert.dom('[data-test-id="form-field-hint"]').hasClass('form-field-hint');
    assert.dom('[data-test-id="form-field-hint"]').hasClass('something-else');
    assert.dom('[data-test-id="form-field-hint"]').hasTextContaining('Content');
  });

  test('it adds size classes for @size', async function (assert) {
    this.set('size', 'sm');

    await render(hbs`<FormField::Hint data-test-input @size={{this.size}} />`);

    assert.dom('[data-test-input]').hasClass('form-field-hint--sm');
    this.set('size', 'lg');
    assert.dom('[data-test-input]').hasClass('form-field-hint--lg');
  });
});
