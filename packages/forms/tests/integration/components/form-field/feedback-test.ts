import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render } from '@ember/test-helpers';
import hbs from 'htmlbars-inline-precompile';

module('Integration | Component | FormField::Feedback', function(hooks) {
  setupRenderingTest(hooks);

  const template = hbs`<FormField::Feedback @id="feedback-id" @errors={{this.errors}} />`;

  test('it renders an array of errors', async function(assert) {
    this.set('errors', ['Some error']);
    await render(template);

    assert
      .dom('[data-test-id="form-field-feedback"]')
      .hasAttribute('id', 'feedback-id');

    assert
      .dom('[data-test-id="form-field-feedback"]')
      .containsText('Some error');
    assert.dom('[data-test-id="form-field-feedback"]').hasClass('is-error');
  });

  test('it renders an array of errors by joing elements', async function(assert) {
    this.set('errors', ['Some error', 'Another error']);
    await render(template);
    assert
      .dom('[data-test-id="form-field-feedback"]')
      .containsText('Some error; Another error');
    assert.dom('[data-test-id="form-field-feedback"]').hasClass('is-error');
  });

  test('it renders when passing an string', async function(assert) {
    this.set('errors', 'Another error');
    await render(template);
    assert
      .dom('[data-test-id="form-field-feedback"]')
      .containsText('Another error');
    assert.dom('[data-test-id="form-field-feedback"]').hasClass('is-error');
  });

  test('it adds aria-live as assertive', async function(assert) {
    this.set('errors', 'An error');
    await render(template);
    assert
      .dom('[data-test-id="form-field-feedback"]')
      .hasAttribute('aria-live', 'assertive');
  });

  test('it adds size classes for @isSmall and @isLarge', async function(assert) {
    this.set('isSmall', true);
    this.set('isLarge', false);

    await render(
      hbs`<FormField::Feedback data-test-input @isSmall={{this.isSmall}} @isLarge={{this.isLarge}} />`
    );

    assert.dom('[data-test-input]').hasClass('form-field-feedback-sm');
    this.set('isSmall', false);
    this.set('isLarge', true);
    assert.dom('[data-test-input]').hasClass('form-field-feedback-lg');

    // should only add one size class
    this.set('isSmall', true);
    this.set('isLarge', true);
    assert.dom('[data-test-input]').hasClass('form-field-feedback-sm');
    assert.dom('[data-test-input]').doesNotHaveClass('form-field-feedback-lg');
  });

  test('it does not break if passed an undefined arg', async function(assert) {
    this.set('errors', undefined);
    await render(template);
    assert.dom('[data-test-id="form-field-feedback"]').exists();
    assert
      .dom('[data-test-id="form-field-feedback"]')
      .doesNotHaveClass('is-error');
    assert
      .dom('[data-test-id="form-field-feedback"]')
      .hasAttribute('aria-live', 'polite');
  });

  test('it renders passed in block', async function(assert) {
    await render(hbs`<FormField::Feedback>Block content</FormField::Feedback>`);
    assert
      .dom('[data-test-id="form-field-feedback"]')
      .doesNotHaveClass('is-error');
    assert
      .dom('[data-test-id="form-field-feedback"]')
      .containsText('Block content');
  });

  test('it adds errors class if @isError is passed in', async function(assert) {
    await render(
      hbs`<FormField::Feedback @isError={{true}}>Block content</FormField::Feedback>`
    );
    assert.dom('[data-test-id="form-field-feedback"]').hasClass('is-error');
    assert
      .dom('[data-test-id="form-field-feedback"]')
      .containsText('Block content');
  });
});
