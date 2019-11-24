import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, fillIn, blur, focus } from '@ember/test-helpers';
import hbs from 'htmlbars-inline-precompile';

module('Integration | Component | InputText', function(hooks) {
  setupRenderingTest(hooks);

  test('it renders', async function(assert) {
    await render(hbs`<InputText @label="Name" />`);

    assert.dom('label').hasText('Name');
  });

  test('it renders html attributes', async function(assert) {
    await render(hbs`<InputText
                      @label="Name"
                      name="some-name"
                      data-test-my-input-text />`);

    assert.dom('[data-test-my-input-text]').exists();
    assert.dom('[name="some-name"]').exists();
  });

  test('it renders yielded block next to input', async function(assert) {
    await render(hbs`
    <InputText
      @label="Name"
      data-test-my-input-text
    >
      <button>My Button</button>
    </InputText>`);

    assert.dom('[data-test-my-input-text] + button').exists();
  });

  test('show value on input, does not mutate value by default', async function(assert) {
    this.set('myInputValue', 'Josemar');
    await render(
      hbs`<InputText class="my-input" @label="Name" @value={{this.myInputValue}} />`
    );

    assert.dom('.my-input').hasValue('Josemar');
    await fillIn('.my-input', 'Sam');
    assert.equal(
      this.get('myInputValue'),
      'Josemar',
      'should have not mutated the value'
    );
  });

  test('should mutate the value using onInput action', async function(assert) {
    this.set('myInputValue', 'Josemar');
    await render(
      hbs`<InputText
          class="my-input"
          @label="Name"
          @value={{this.myInputValue}}
          @onInput={{action (mut this.myInputValue)}} />`
    );

    assert.dom('.my-input').hasValue('Josemar');
    await fillIn('.my-input', 'Sam');
    assert.equal(
      this.get('myInputValue'),
      'Sam',
      'should have mutated the value'
    );
  });

  test('show error messages when errors array has items', async function(assert) {
    await render(
      hbs`<div class="my-container">
          <InputText
            class="my-input"
            @errors={{array "This field is required"}}
            @label="Name"
          />
        </div>`
    );

    assert.dom('.my-container .has-error').doesNotExist();
    await focus('.my-input');
    await blur('.my-input');
    assert.dom('.my-container .has-error').exists();
    assert
      .dom('[data-test-id="form-field-feedback"]')
      .hasText('This field is required');
  });

  test('do not show error messages if errors has no elements', async function(assert) {
    this.set('errors', []);
    await render(
      hbs`<div class="my-container">
          <InputText
            class="my-input"
            @errors={{this.errors}}
            @label="Name"
          />
        </div>`
    );

    assert.dom('.my-container .has-error').doesNotExist();
    await focus('.my-input');
    await blur('.my-input');
    assert.dom('.my-container .has-error').doesNotExist();
    assert.dom('[data-test-id="form-field-feedback"]').doesNotExist();
  });

  test('do not show errors if hasError is false even if errors has elements', async function(assert) {
    await render(
      hbs`<div class="my-container">
          <InputText
            class="my-input"
            @errors={{array "This field is required"}}
            @label="Name"
            @hasError={{false}}
          />
        </div>`
    );

    assert.dom('.my-container .has-error').doesNotExist();
    await focus('.my-input');
    await blur('.my-input');
    assert.dom('[data-test-id="form-field-feedback"]').doesNotExist();
    assert.dom('.my-container .has-error').doesNotExist();
  });

  test('shows error message and adds the has-error class only when focus out', async function(assert) {
    await render(
      hbs`<div class="my-container">
          <InputText
            class="my-input"
            @errors={{array "This field is required"}}
            @label="Name"
            @hasError={{true}}
          />
        </div>`
    );

    assert.dom('.my-container .has-error').doesNotExist();
    await focus('.my-input');
    await blur('.my-input');
    assert.dom('.my-container .has-error').exists();
    assert
      .dom('[data-test-id="form-field-feedback"]')
      .hasText('This field is required');
  });

  test('it hides the has-error when input is in focus', async function(assert) {
    await render(
      hbs`<div class="my-container">
          <InputText
            class="my-input"
            @label="Name"
            @errors={{array "Some error"}}
            @hasError={{true}}
          />
        </div>`
    );

    await focus('.my-input');
    await blur('.my-input');
    assert.dom('.my-container .has-error').exists();

    await focus('.my-input');
    assert.dom('.my-container .has-error').doesNotExist();
  });

  test('always show error messages when hasSubmitted is true', async function(assert) {
    await render(
      hbs`<div class="my-container">
          <InputText
            @hasSubmitted={{true}}
            class="my-input"
            @errors={{array "This field is required"}}
            @label="Name"
          />
        </div>`
    );

    assert.dom('.my-container .has-error').exists();
    assert
      .dom('[data-test-id="form-field-feedback"]')
      .hasText('This field is required');
  });

  test('it triggers actions for onFocusIn, onFocusOut and onChange', async function(assert) {
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
      hbs`<InputText
          class="my-input"
          @onFocusIn={{action this.onFocusIn}}
          @onFocusOut={{action this.onFocusOut}}
          @onChange={{action this.onChange}}
        />`
    );

    await focus('.my-input');
    await blur('.my-input');
    await fillIn('.my-input', 'Josemar'); // This causes focusIn to trigger as well.
    assert.ok(calls.includes('onFocusIn'));
    assert.ok(calls.includes('onFocusOut'));
    assert.ok(calls.includes('onFocusIn'));
    assert.ok(calls.includes('onChange'));
  });

  test('it adds has-margin class if @hasMargin is true', async function(assert) {
    this.set('hasMargin', undefined);

    await render(
      hbs`<InputText
          @hasMargin={{this.hasMargin}}
        />`
    );

    assert.dom('.input-text').doesNotHaveClass('has-margin');
    this.set('hasMargin', true);
    assert.dom('.input-text').hasClass('has-margin');
  });

  test('it adds has-button class if @hasButton is true', async function(assert) {
    this.set('hasButton', undefined);

    await render(
      hbs`<InputText
          @hasButton={{this.hasButton}}
        />`
    );

    assert.dom('.input-text').doesNotHaveClass('has-button');
    this.set('hasButton', true);
    assert.dom('.input-text').hasClass('has-button');
  });
});
