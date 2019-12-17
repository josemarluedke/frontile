import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, click, find } from '@ember/test-helpers';
import hbs from 'htmlbars-inline-precompile';
import 'qunit-dom';

module('Integration | Component | FormRadioGroup', function(hooks) {
  setupRenderingTest(hooks);

  const template = hbs`
    <div class="my-container">
      <FormRadioGroup
        data-test-input-group
        @hasError={{this.hasError}}
        @errors={{this.errors}}
        @hasSubmitted={{this.hasSubmitted}}
        @containerClass={{this.containerClass}}
        @label="My Group"
        @value={{this.myValue}}
        @onChange={{action (mut this.myValue)}} as |Radio|
      >
        <Radio @value={{true}} @label="Yes" data-test-option-yes />
        <Radio @value={{false}} @label="No" data-test-option-no />
      </FormRadioGroup>
    </div>`;

  test('option names should be all the same', async function(assert) {
    this.set('myValue', undefined);
    await render(template);

    const noName = find('[data-test-option-no]')!.getAttribute('name');
    const yesName = find('[data-test-option-yes]')!.getAttribute('name');

    assert.ok(noName, 'input should have an name attribute');
    assert.equal(
      noName,
      yesName,
      'each radio option should have the same name when used in a radio group'
    );
  });

  test('it renders the labels and options', async function(assert) {
    this.set('myValue', undefined);
    await render(template);

    assert.dom('[data-test-input-group] label').hasText('My Group');
    assert.dom('[data-test-option-yes]').exists();
    assert.dom('[data-test-option-no]').exists();

    assert.dom('[data-test-option-no] ~ label').hasText('No');
    assert.dom('[data-test-option-yes] ~ label').hasText('Yes');
  });

  test('it marks the selected option correctly', async function(assert) {
    this.set('myValue', true);
    await render(template);

    assert.dom('[data-test-option-no]').isNotChecked();
    assert.dom('[data-test-option-yes]').isChecked();
  });

  test('it changes the selected value', async function(assert) {
    this.set('myValue', false);
    await render(template);

    await click('[data-test-option-yes] ~ label');
    assert.equal(this.get('myValue'), true);
  });

  test('show error messages when errors array has items', async function(assert) {
    this.set('errors', ['This field is required']);
    await render(template);

    assert.dom('.my-container .has-error').doesNotExist();
    await click('[data-test-option-yes] + label');

    assert.dom('.my-container .has-error').exists();
    assert
      .dom('[data-test-id="form-field-feedback"]')
      .hasText('This field is required');
  });

  test('do not show error messages if errors has no elements', async function(assert) {
    this.set('errors', []);
    await render(template);

    assert.dom('.my-container .has-error').doesNotExist();
    await click('[data-test-option-yes] + label');

    assert.dom('.my-container .has-error').doesNotExist();
    assert.dom('[data-test-id="form-field-feedback"]').doesNotExist();
  });

  test('do not show errors if hasError is false even if errors has elements', async function(assert) {
    this.set('errors', ['This field is required']);
    this.set('hasError', false);
    await render(template);

    assert.dom('.my-container .has-error').doesNotExist();
    await click('[data-test-option-yes] + label');

    assert.dom('[data-test-id="form-field-feedback"]').doesNotExist();
    assert.dom('.my-container .has-error').doesNotExist();
  });

  test('always show error messages when hasSubmitted is true', async function(assert) {
    this.set('errors', ['This field is required']);
    this.set('hasSubmitted', true);
    await render(template);

    assert.dom('.my-container .has-error').exists();
    assert
      .dom('[data-test-id="form-field-feedback"]')
      .hasText('This field is required');
  });

  test('it adds container class from @containerClass arg', async function(assert) {
    this.set('containerClass', 'my-container-class');

    await render(template);

    assert.dom('.my-container-class').exists();
  });
});
