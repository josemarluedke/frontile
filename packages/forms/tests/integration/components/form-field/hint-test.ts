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

    assert.dom('[data-test-id="form-field-hint"]').hasClass('form__hint');
    assert.dom('[data-test-id="form-field-hint"]').hasClass('something-else');
    assert.dom('[data-test-id="form-field-hint"]').hasTextContaining('Content');
  });

  test('it adds size classes for @isSmall and @isLarge', async function (assert) {
    this.set('isSmall', true);
    this.set('isLarge', false);

    await render(
      hbs`<FormField::Hint data-test-input @isSmall={{this.isSmall}} @isLarge={{this.isLarge}} />`
    );

    assert.dom('[data-test-input]').hasClass('form__hint--sm');
    this.set('isSmall', false);
    this.set('isLarge', true);
    assert.dom('[data-test-input]').hasClass('form__hint--lg');

    // should only add one size class
    this.set('isSmall', true);
    this.set('isLarge', true);
    assert.dom('[data-test-input]').hasClass('form__hint--sm');
    assert.dom('[data-test-input]').doesNotHaveClass('form__hint--lg');
  });
});
