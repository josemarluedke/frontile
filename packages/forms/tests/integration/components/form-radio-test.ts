import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, click, find } from '@ember/test-helpers';
import hbs from 'htmlbars-inline-precompile';
import 'qunit-dom';

module('Integration | Component | FormRadio', function (hooks) {
  setupRenderingTest(hooks);

  test('it renders the label from argument', async function (assert) {
    await render(
      hbs`<FormRadio
            data-test-input
            @label="My Radio Input"
          />`
    );

    assert.dom('[data-test-id="form-field-label"]').hasText('My Radio Input');
  });

  test('it renders the label from block param', async function (assert) {
    await render(hbs`<FormRadio data-test-input>My Block Label</FormRadio>`);

    assert.dom('[data-test-id="form-field-label"]').hasText('My Block Label');
  });

  test('it should have id attr with matching label attr `for`', async function (assert) {
    await render(hbs`<FormRadio
                        @label="Something"
                        data-test-input
                      />`);

    const el = find('[data-test-input]') as HTMLInputElement;
    const id = el.getAttribute('id') || '';

    assert.ok(/ember[1-9.]/.test(id), 'should have generated an id');

    assert.dom('[data-test-id="form-field-label"]').hasAttribute('for', id);
  });

  test('it renders the `name` HTML attribute', async function (assert) {
    await render(
      hbs`<FormRadio
            data-test-input
            name="my-input"
          />`
    );

    assert.dom('[data-test-input]').hasAttribute('name', 'my-input');
  });

  test('it renders the `name` from args', async function (assert) {
    await render(
      hbs`<FormRadio
            data-test-input
            @name="my-input"
          />`
    );

    assert.dom('[data-test-input]').hasAttribute('name', 'my-input');
  });

  test('it does not mutates the value directly', async function (assert) {
    this.set('myValue', undefined);

    await render(
      hbs`<FormRadio
            data-test-input
            name="my-input"
            @label="My Radio Input"
            @value={{true}}
            @checked={{this.myValue}}
          />`
    );

    await click('[data-test-input]');
    assert.equal(this.myValue, undefined);
  });

  test('it calls onChange function to change value', async function (assert) {
    this.set('myValue', undefined);

    await render(
      hbs`<FormRadio
            data-test-input
            name="my-input"
            @label="My Radio Input"
            @value={{true}}
            @checked={{this.myValue}}
            @onChange={{action (mut this.myValue)}}
          />`
    );

    await click('[data-test-input]');
    assert.equal(this.myValue, true);
  });

  test('it marks the input as checked if value matches', async function (assert) {
    this.set('myValue', false);

    await render(
      hbs`<FormRadio
            data-test-input
            @label="My Radio Input"
            @value={{true}}
            @checked={{this.myValue}}
          />`
    );

    assert.dom('[data-test-input]').isNotChecked();
    this.set('myValue', true);

    assert.dom('[data-test-input]').isChecked();
  });

  test('input id should match label for attribute', async function (assert) {
    this.set('myValue', false);

    await render(
      hbs`<FormRadio
            data-test-input
            @label="My Radio Input"
          />`
    );

    const inputId = find('[data-test-input]')!.getAttribute('id');
    const labelFor = find('[data-test-id="form-field-label"]')!.getAttribute(
      'for'
    );

    assert.ok(inputId, 'input should have an id attribute');
    assert.equal(
      inputId,
      labelFor,
      'id attribute of input should be equal to for attribute of label'
    );
  });

  test('it adds container class from @containerClass arg', async function (assert) {
    await render(
      hbs`<FormRadio
            @containerClass="my-container-class"
          />`
    );

    assert.dom('.my-container-class').exists();
  });

  test('it adds size classes for @isSmall and @isLarge', async function (assert) {
    this.set('isSmall', true);
    this.set('isLarge', false);

    await render(
      hbs`<FormRadio
            data-test-input
            @containerClass="my-container"
            @label="Label"
            @hint="Hint"
            @isSmall={{this.isSmall}}
            @isLarge={{this.isLarge}}
          />`
    );

    assert.dom('.my-container').hasClass('form-radio-container--sm');
    assert.dom('[data-test-input]').hasClass('form__radio--sm');
    assert.dom('[data-test-id="form-field-label"]').hasClass('form__label--sm');
    assert.dom('[data-test-id="form-field-hint"]').hasClass('form__hint--sm');

    this.set('isSmall', false);
    this.set('isLarge', true);
    assert.dom('.my-container').hasClass('form-radio-container--lg');
    assert.dom('[data-test-input]').hasClass('form__radio--lg');
    assert.dom('[data-test-id="form-field-label"]').hasClass('form__label--lg');
    assert.dom('[data-test-id="form-field-hint"]').hasClass('form__hint--lg');

    // should only add one size class
    this.set('isSmall', true);
    this.set('isLarge', true);
    assert.dom('.my-container').hasClass('form-radio-container--sm');
    assert.dom('[data-test-input]').hasClass('form__radio--sm');
    assert.dom('[data-test-id="form-field-label"]').hasClass('form__label--sm');
    assert.dom('[data-test-id="form-field-hint"]').hasClass('form__hint--sm');
    assert.dom('.my-container').doesNotHaveClass('form-radio-container--lg');
    assert.dom('[data-test-input]').doesNotHaveClass('form__radio--lg');
    assert
      .dom('[data-test-id="form-field-label"]')
      .doesNotHaveClass('form__label--lg');
    assert
      .dom('[data-test-id="form-field-hint"]')
      .doesNotHaveClass('form__hint--lg');
  });
});
