import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, fillIn, blur, focus, find } from '@ember/test-helpers';
import hbs from 'htmlbars-inline-precompile';

module('Integration | Component | FormTextarea', function (hooks) {
  setupRenderingTest(hooks);

  test('it renders', async function (assert) {
    await render(hbs`<FormTextarea @label="Name" />`);

    assert.dom('label').hasText('Name');
  });

  test('it renders html attributes', async function (assert) {
    await render(hbs`<FormTextarea
                        @label="Name"
                        name="some-name"
                        data-test-input
                      />`);

    assert.dom('[data-test-input]').exists();
    assert.dom('[name="some-name"]').exists();
  });

  test('it should have id attr with matching label attr `for`', async function (assert) {
    await render(hbs`<FormTextarea
                        @label="Comment"
                        data-test-input
                      />`);

    const el = find('[data-test-input]') as HTMLInputElement;
    const id = el.getAttribute('id') || '';

    assert.ok(/ember[1-9.]/.test(id), 'should have generated an id');

    assert.dom('[data-test-id="form-field-label"]').hasAttribute('for', id);
  });

  test('it renders yielded block next to input', async function (assert) {
    await render(hbs`
      <FormTextarea
        @label="Name"
        data-test-input
      >
        <button>My Button</button>
      </FormTextarea>`);

    assert.dom('[data-test-input] + button').exists();
  });

  test('show value on input, does not mutate value by default', async function (assert) {
    this.set('myInputValue', 'Josemar');
    await render(
      hbs`<FormTextarea data-test-input @label="Name" @value={{this.myInputValue}} />`
    );

    assert.dom('[data-test-input]').hasValue('Josemar');
    await fillIn('[data-test-input]', 'Sam');
    assert.equal(
      this.myInputValue,
      'Josemar',
      'should have not mutated the value'
    );
  });

  test('should mutate the value using onInput action', async function (assert) {
    this.set('myInputValue', 'Josemar');
    await render(
      hbs`<FormTextarea
            data-test-input
            @label="Name"
            @value={{this.myInputValue}}
            @onInput={{action (mut this.myInputValue)}}
          />`
    );

    assert.dom('[data-test-input]').hasValue('Josemar');
    await fillIn('[data-test-input]', 'Sam');
    assert.equal(this.myInputValue, 'Sam', 'should have mutated the value');
  });

  test('show error messages when errors array has items', async function (assert) {
    await render(
      hbs`<div class="my-container">
            <FormTextarea
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
            <FormTextarea
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
            <FormTextarea
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

    assert.dom('[data-test-input]').doesNotHaveAttribute('aria-invalid');
    assert.dom('[data-test-id="form-field-feedback"]').doesNotExist();
  });

  test('shows error message and adds the aria-invalid only when focus out', async function (assert) {
    await render(
      hbs`<div class="my-container">
            <FormTextarea
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
            <FormTextarea
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
            <FormTextarea
              @hasSubmitted={{true}}
              data-test-input
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

  test('always show error messages when showError is true', async function (assert) {
    await render(
      hbs`<div class="my-container">
            <FormTextarea
              @showError={{true}}
              data-test-input
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
      hbs`<FormTextarea
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
      hbs`<FormTextarea
            @containerClass="my-container-class"
          />`
    );

    assert.dom('.my-container-class').exists();
  });

  test('it adds size classes for @size', async function (assert) {
    this.set('size', 'sm');

    await render(
      hbs`<FormTextarea
            data-test-input
            @containerClass="my-container"
            @label="Label"
            @hint="Hint"
            @errors="Error"
            @hasSubmitted={{true}}
            @size={{this.size}}
          />`
    );

    assert.dom('.my-container').hasClass('form-textarea--sm');
    assert.dom('[data-test-input]').hasClass('form-textarea--sm__textarea');
    assert
      .dom('[data-test-id="form-field-label"]')
      .hasClass('form-textarea--sm__label');
    assert
      .dom('[data-test-id="form-field-hint"]')
      .hasClass('form-textarea--sm__hint');
    assert
      .dom('[data-test-id="form-field-feedback"]')
      .hasClass('form-textarea--sm__feedback');

    this.set('size', 'lg');
    assert.dom('.my-container').hasClass('form-textarea--lg');
    assert.dom('[data-test-input]').hasClass('form-textarea--lg__textarea');
    assert
      .dom('[data-test-id="form-field-label"]')
      .hasClass('form-textarea--lg__label');
    assert
      .dom('[data-test-id="form-field-hint"]')
      .hasClass('form-textarea--lg__hint');
    assert
      .dom('[data-test-id="form-field-feedback"]')
      .hasClass('form-textarea--lg__feedback');
  });
});
