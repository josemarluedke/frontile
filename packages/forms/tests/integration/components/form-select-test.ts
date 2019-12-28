import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, focus, blur } from '@ember/test-helpers';
import hbs from 'htmlbars-inline-precompile';
// @ts-ignore
import { selectChoose } from 'ember-power-select/test-support';
// @ts-ignore
import { clickTrigger } from 'ember-power-select/test-support/helpers';

module('Integration | Component | FormSelect', function(hooks) {
  setupRenderingTest(hooks);

  const template = hbs`<FormSelect
                          @isMultiple={{this.isMultiple}}
                          @containerClass="my-container"
                          @label="Select Countries"
                          @hint="The countries where you have lived"
                          @onChange={{action (mut this.value)}}
                          @isSmall={{this.isSmall}}
                          @isLarge={{this.isLarge}}
                          @hasError={{this.hasError}}
                          @errors={{this.errors}}
                          @hasSubmitted={{this.hasSubmitted}}
                          @triggerClass="test-select"
                          @options={{this.options}}
                          @selected={{this.value}}
                          @onOpen={{this.onOpen}}
                          @onClose={{this.onClose}}
                          @onFocusIn={{this.onFocusIn}}
                          @onFocusOut={{this.onFocusOut}}
                          @onFocus={{this.onFocus}}
                          @onBlur={{this.onBlur}}
                          as |option|
                        >
                          {{option}}
                        </FormSelect>`;

  test('it renders the label', async function(assert) {
    await render(template);

    assert.dom('[data-test-id="form-field-label"]').hasText('Select Countries');
  });

  test('show the select option', async function(assert) {
    this.set('options', ['Brazil', 'United States of America']);
    this.set('value', 'Brazil');
    await render(template);

    assert.dom('.test-select').containsText('Brazil');
  });

  test('it renders the hint', async function(assert) {
    await render(template);

    assert
      .dom('[data-test-id="form-field-hint"]')
      .containsText('The countries where you have lived');
  });

  test('it calls onOpen & onClose', async function(assert) {
    assert.expect(2);

    this.set('onOpen', () => {
      assert.ok(true, 'should have called onOpen');
    });

    this.set('onClose', () => {
      assert.ok(true, 'should have called onClose');
    });
    await render(template);

    await clickTrigger('.my-container');
    await clickTrigger('.my-container');
  });

  test('it calls onFocusIn/onFocus & onFocusOut/onBlur', async function(assert) {
    assert.expect(4);

    this.set('onFocusIn', () => {
      assert.ok(true, 'should have called onFocusIn');
    });

    this.set('onFocus', () => {
      assert.ok(true, 'should have called onFocus');
    });

    this.set('onFocusOut', () => {
      assert.ok(true, 'should have called onFocusOut');
    });

    this.set('onBlur', () => {
      assert.ok(true, 'should have called onBlur');
    });

    await render(template);

    await focus('.test-select');
    await blur('.test-select');
  });

  test('mutates the value using onChange', async function(assert) {
    this.set('options', ['Brazil', 'China']);
    this.set('value', undefined);
    await render(template);

    await clickTrigger('.my-container');
    await selectChoose('.test-select', 'Brazil');

    assert.deepEqual(this.get('value'), 'Brazil');
  });

  test('it handle multiple options', async function(assert) {
    this.set('options', ['Brazil', 'China', 'United States of America']);
    this.set('value', []);
    this.set('isMultiple', true);

    await render(template);
    assert
      .dom('.my-container .ember-power-select-multiple-trigger')
      .exists('should have rendered the multiple power select');

    await clickTrigger('.my-container');
    await selectChoose('.my-container .ember-power-select-trigger', 'Brazil');

    await clickTrigger('.my-container');
    await selectChoose('.my-container .ember-power-select-trigger', 'China');
    assert.deepEqual(this.get('value'), ['Brazil', 'China']);
  });

  test('shows error messages and adds aria-invalid on close', async function(assert) {
    this.set('errors', ['This field is required']);
    await render(template);

    assert.dom('.test-select').hasNoAttribute('aria-invalid');
    await focus('.test-select');
    await blur('.test-select');

    assert.dom('.test-select').hasAttribute('aria-invalid', 'true');
    assert
      .dom('[data-test-id="form-field-feedback"]')
      .hasText('This field is required');
  });

  test('do not show errors if errors are empty', async function(assert) {
    this.set('errors', []);
    await render(template);

    assert.dom('.test-select').hasNoAttribute('aria-invalid');

    await focus('.test-select');
    await blur('.test-select');

    assert.dom('.test-select').hasNoAttribute('aria-invalid');
    assert.dom('[data-test-id="form-field-feedback"]').doesNotExist();
  });

  test('do not show errors if hasError is false even if errors has elements', async function(assert) {
    this.set('hasError', false);
    this.set('errors', ['Some error']);
    await render(template);

    await focus('.test-select');
    await blur('.test-select');

    assert.dom('.test-select').hasNoAttribute('aria-invalid');
    assert.dom('[data-test-id="form-field-feedback"]').doesNotExist();
  });

  test('always show error messages when hasSubmitted is true', async function(assert) {
    this.set('errors', ['This field is required']);
    this.set('hasSubmitted', true);
    await render(template);

    assert.dom('.test-select').hasAttribute('aria-invalid', 'true');
    assert
      .dom('[data-test-id="form-field-feedback"]')
      .hasText('This field is required');
  });

  test('it adds size classes for @isSmall and @isLarge', async function(assert) {
    this.set('isSmall', true);
    this.set('isLarge', false);
    this.set('errors', ['something']);
    this.set('hasSubmitted', true);

    await render(template);

    assert.dom('.my-container').hasClass('form-select-container-sm');
    assert
      .dom('.ember-power-select-trigger')
      .hasClass('ember-power-select-trigger-sm');
    assert
      .dom('[data-test-id="form-field-label"]')
      .hasClass('form-field-label-sm');
    assert
      .dom('[data-test-id="form-field-hint"]')
      .hasClass('form-field-hint-sm');
    assert
      .dom('[data-test-id="form-field-feedback"]')
      .hasClass('form-field-feedback-sm');

    this.set('isSmall', false);
    this.set('isLarge', true);
    assert.dom('.my-container').hasClass('form-select-container-lg');
    assert
      .dom('.ember-power-select-trigger')
      .hasClass('ember-power-select-trigger-lg');
    assert
      .dom('[data-test-id="form-field-label"]')
      .hasClass('form-field-label-lg');
    assert
      .dom('[data-test-id="form-field-hint"]')
      .hasClass('form-field-hint-lg');
    assert
      .dom('[data-test-id="form-field-feedback"]')
      .hasClass('form-field-feedback-lg');

    // should only add one size class
    this.set('isSmall', true);
    this.set('isLarge', true);
    assert.dom('.my-container').hasClass('form-select-container-sm');
    assert
      .dom('.ember-power-select-trigger')
      .hasClass('ember-power-select-trigger-sm');
    assert
      .dom('[data-test-id="form-field-label"]')
      .hasClass('form-field-label-sm');
    assert
      .dom('[data-test-id="form-field-hint"]')
      .hasClass('form-field-hint-sm');
    assert
      .dom('[data-test-id="form-field-feedback"]')
      .hasClass('form-field-feedback-sm');
    assert.dom('.my-container').doesNotHaveClass('form-select-container-lg');
    assert
      .dom('.ember-power-select-trigger')
      .doesNotHaveClass('ember-power-select-trigger-lg');
    assert
      .dom('[data-test-id="form-field-label"]')
      .doesNotHaveClass('form-field-label-lg');
    assert
      .dom('[data-test-id="form-field-hint"]')
      .doesNotHaveClass('form-field-hint-lg');
    assert
      .dom('[data-test-id="form-field-feedback"]')
      .doesNotHaveClass('form-field-feedback-lg');
  });
});
