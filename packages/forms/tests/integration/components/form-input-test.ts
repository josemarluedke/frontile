import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, fillIn, blur, focus, find } from '@ember/test-helpers';
import hbs from 'htmlbars-inline-precompile';

module('Integration | Component | FormInput', function (hooks) {
  setupRenderingTest(hooks);

  test('it renders', async function (assert) {
    await render(hbs`<FormInput @label="Name" />`);

    assert.dom('[data-test-id="form-field-label"]').hasText('Name');
  });

  test('it renders html attributes', async function (assert) {
    await render(hbs`<FormInput
                        @label="Name"
                        name="some-name"
                        data-test-input
                      />`);

    assert.dom('[data-test-input]').exists();
    assert.dom('[name="some-name"]').exists();
  });

  test('it should have id attr with matching label attr `for`', async function (assert) {
    await render(hbs`<FormInput
                        @label="Name"
                        data-test-input
                      />`);

    const el = find('[data-test-input]') as HTMLInputElement;
    const id = el.getAttribute('id') || '';

    assert.ok(/ember[1-9.]/.test(id), 'should have generated an id');

    assert.dom('[data-test-id="form-field-label"]').hasAttribute('for', id);
  });

  test('it renders yielded block next to input', async function (assert) {
    await render(hbs`
      <FormInput
        @label="Name"
        data-test-input
      >
        <button>My Button</button>
      </FormInput>`);

    assert.dom('[data-test-input] + button').exists();
  });

  test('show value on input, does not mutate value by default', async function (assert) {
    this.set('myInputValue', 'Josemar');
    await render(
      hbs`<FormInput
            data-test-input
            @label="Name"
            @value={{this.myInputValue}}
          />`
    );

    assert.dom('[data-test-input]').hasValue('Josemar');
    await fillIn('[data-test-input]', 'Sam');
    assert.equal(
      this.get('myInputValue'),
      'Josemar',
      'should have not mutated the value'
    );
  });

  test('should mutate the value using onInput action', async function (assert) {
    this.set('myInputValue', 'Josemar');
    await render(
      hbs`<FormInput
            data-test-input
            @label="Name"
            @value={{this.myInputValue}}
            @onInput={{action (mut this.myInputValue)}}
          />`
    );

    assert.dom('[data-test-input]').hasValue('Josemar');
    await fillIn('[data-test-input]', 'Sam');
    assert.equal(
      this.get('myInputValue'),
      'Sam',
      'should have mutated the value'
    );
  });

  test('show error messages when errors array has items', async function (assert) {
    await render(
      hbs`<div class="my-container">
          <FormInput
            data-test-input
            @errors={{array "This field is required"}}
            @label="Name"
          />
        </div>`
    );

    assert.dom('[data-test-input]').doesNotHaveAttribute('aria-invalid');

    await focus('[data-test-input]');
    await blur('[data-test-input]');

    assert.dom('[data-test-input]').hasAttribute('aria-invalid');
    assert
      .dom('[data-test-id="form-field-feedback"]')
      .hasText('This field is required');
  });

  test('do not show error messages if errors has no elements', async function (assert) {
    this.set('errors', []);
    await render(
      hbs`<div class="my-container">
            <FormInput
              data-test-input
              @errors={{this.errors}}
              @label="Name"
            />
          </div>`
    );

    assert.dom('[data-test-input]').doesNotHaveAttribute('aria-invalid');

    await focus('[data-test-input]');
    await blur('[data-test-input]');

    assert.dom('[data-test-input]').doesNotHaveAttribute('aria-invalid');
    assert.dom('[data-test-id="form-field-feedback"]').doesNotExist();
  });

  test('do not show errors if hasError is false even if errors has elements', async function (assert) {
    await render(
      hbs`<div class="my-container">
            <FormInput
              data-test-input
              @errors={{array "This field is required"}}
              @label="Name"
              @hasError={{false}}
            />
         </div>`
    );

    assert.dom('[data-test-input]').doesNotHaveAttribute('aria-invalid');

    await focus('[data-test-input]');
    await blur('[data-test-input]');

    assert.dom('[data-test-id="form-field-feedback"]').doesNotExist();
    assert.dom('[data-test-input]').doesNotHaveAttribute('aria-invalid');
  });

  test('shows error message and adds the aria-invalid only when focus out', async function (assert) {
    await render(
      hbs`<div class="my-container">
            <FormInput
              data-test-input
              @errors={{array "This field is required"}}
              @label="Name"
              @hasError={{true}}
            />
          </div>`
    );

    assert.dom('[data-test-input]').doesNotHaveAttribute('aria-invalid');

    await focus('[data-test-input]');
    await blur('[data-test-input]');

    assert.dom('[data-test-input]').hasAttribute('aria-invalid');
    assert
      .dom('[data-test-id="form-field-feedback"]')
      .hasText('This field is required');
  });

  test('it removes error indication when input is in focus', async function (assert) {
    await render(
      hbs`<div class="my-container">
            <FormInput
              data-test-input
              @label="Name"
              @errors={{array "Some error"}}
              @hasError={{true}}
            />
          </div>`
    );

    await focus('[data-test-input]');
    await blur('[data-test-input]');

    assert.dom('[data-test-input]').hasAttribute('aria-invalid');

    await focus('[data-test-input]');

    assert.dom('[data-test-input]').doesNotHaveAttribute('aria-invalid');
  });

  test('always show error messages when hasSubmitted is true', async function (assert) {
    await render(
      hbs`<div class="my-container">
            <FormInput
              data-test-input
              @hasSubmitted={{true}}
              @errors={{array "This field is required"}}
              @label="Name"
            />
          </div>`
    );

    assert.dom('[data-test-input]').hasAttribute('aria-invalid');
    assert
      .dom('[data-test-id="form-field-feedback"]')
      .hasText('This field is required');
  });

  test('it triggers actions for onFocusIn, onFocusOut and onChange', async function (assert) {
    const calls: string[] = [];

    this.set('onFocusIn', () => {
      calls.push('onFocusIn');
    });

    this.set('onFocusOut', () => {
      calls.push('onFocusOut');
    });

    this.set('onChange', () => {
      calls.push('onChange');
    });

    await render(
      hbs`<FormInput
            data-test-input
            @onFocusIn={{action this.onFocusIn}}
            @onFocusOut={{action this.onFocusOut}}
            @onChange={{action this.onChange}}
          />`
    );

    await focus('[data-test-input]');
    await blur('[data-test-input]');
    await fillIn('[data-test-input]', 'Josemar'); // This causes focusIn to trigger as well.
    assert.ok(calls.includes('onFocusIn'));
    assert.ok(calls.includes('onFocusOut'));
    assert.ok(calls.includes('onFocusIn'));
    assert.ok(calls.includes('onChange'));
  });

  test('it adds container class from @containerClass arg', async function (assert) {
    await render(
      hbs`<FormInput
            @containerClass="my-container-class"
          />`
    );

    assert.dom('.my-container-class').exists();
  });

  test('it adds size classes for @isSmall and @isLarge', async function (assert) {
    this.set('isSmall', true);
    this.set('isLarge', false);

    await render(
      hbs`<FormInput
            data-test-input
            @containerClass="my-container"
            @label="Label"
            @hint="Hint"
            @errors="Error"
            @hasSubmitted={{true}}
            @isSmall={{this.isSmall}}
            @isLarge={{this.isLarge}}
          />`
    );

    assert.dom('.my-container').hasClass('form-input-container--sm');
    assert.dom('[data-test-input]').hasClass('form__input--sm');
    assert.dom('[data-test-id="form-field-label"]').hasClass('form__label--sm');
    assert.dom('[data-test-id="form-field-hint"]').hasClass('form__hint--sm');
    assert
      .dom('[data-test-id="form-field-feedback"]')
      .hasClass('form__feedback--sm');

    this.set('isSmall', false);
    this.set('isLarge', true);
    assert.dom('.my-container').hasClass('form-input-container--lg');
    assert.dom('[data-test-input]').hasClass('form__input--lg');
    assert.dom('[data-test-id="form-field-label"]').hasClass('form__label--lg');
    assert.dom('[data-test-id="form-field-hint"]').hasClass('form__hint--lg');
    assert
      .dom('[data-test-id="form-field-feedback"]')
      .hasClass('form__feedback--lg');

    // should only add one size class
    this.set('isSmall', true);
    this.set('isLarge', true);
    assert.dom('.my-container').hasClass('form-input-container--sm');
    assert.dom('[data-test-input]').hasClass('form__input--sm');
    assert.dom('[data-test-id="form-field-label"]').hasClass('form__label--sm');
    assert.dom('[data-test-id="form-field-hint"]').hasClass('form__hint--sm');
    assert
      .dom('[data-test-id="form-field-feedback"]')
      .hasClass('form__feedback--sm');
    assert.dom('.my-container').doesNotHaveClass('form-input-container--lg');
    assert.dom('[data-test-input]').doesNotHaveClass('form__input--lg');
    assert
      .dom('[data-test-id="form-field-label"]')
      .doesNotHaveClass('form__label--lg');
    assert
      .dom('[data-test-id="form-field-hint"]')
      .doesNotHaveClass('form__hint--lg');
    assert
      .dom('[data-test-id="form-field-feedback"]')
      .doesNotHaveClass('form__feedback--lg');
  });
});
