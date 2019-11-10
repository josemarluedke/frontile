import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, click, find } from '@ember/test-helpers';
import hbs from 'htmlbars-inline-precompile';
import 'qunit-dom';

module('Integration | Component | InputRadio', function(hooks) {
  setupRenderingTest(hooks);

  test('it renders the label from argument', async function(assert) {
    await render(
      hbs`<InputRadio
            data-test-input
            @label="My Radio Input"
          />`
    );

    assert.dom('[data-test-input] + label').hasText('My Radio Input');
  });

  test('it renders the label from block param', async function(assert) {
    await render(hbs`<InputRadio data-test-input>My Block Label</InputRadio>`);

    assert.dom('[data-test-input] + label').hasText('My Block Label');
  });

  test('it renders the `name` HTML attribute', async function(assert) {
    await render(
      hbs`<InputRadio
            data-test-input
            name="my-input"
          />`
    );

    assert.dom('[data-test-input]').hasAttribute('name', 'my-input');
  });

  test('it renders the `name` from args', async function(assert) {
    await render(
      hbs`<InputRadio
            data-test-input
            @name="my-input"
          />`
    );

    assert.dom('[data-test-input]').hasAttribute('name', 'my-input');
  });

  test('it does not mutates the value directly', async function(assert) {
    this.set('myValue', undefined);

    await render(
      hbs`<InputRadio
            data-test-input
            name="my-input"
            @label="My Radio Input"
            @value={{true}}
            @checked={{this.myValue}}
          />`
    );

    await click('[data-test-input] + label');
    assert.equal(this.get('myValue'), undefined);
  });

  test('it calls onChange function to change value', async function(assert) {
    this.set('myValue', undefined);

    await render(
      hbs`<InputRadio
            data-test-input
            name="my-input"
            @label="My Radio Input"
            @value={{true}}
            @checked={{this.myValue}}
            @onChange={{action (mut this.myValue)}}
          />`
    );

    await click('[data-test-input] + label');
    assert.equal(this.get('myValue'), true);
  });

  test('it marks the input as checked if value matches', async function(assert) {
    this.set('myValue', false);

    await render(
      hbs`<InputRadio
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

  test('input id should match label for attribute', async function(assert) {
    this.set('myValue', false);

    await render(
      hbs`<InputRadio
            data-test-input
            @label="My Radio Input"
          />`
    );

    const inputId = find('[data-test-input]')!.getAttribute('id');
    const labelFor = find('[data-test-input] + label')!.getAttribute('for');

    assert.ok(inputId, 'input should have an id attribute');
    assert.equal(
      inputId,
      labelFor,
      'id attribute of input should be equal to for attribute of label'
    );
  });

  test('it adds has-margin class if @hasMargin is true', async function(assert) {
    await render(
      hbs`<InputRadio
            data-test-input
            @hasMargin={{true}}
          />`
    );

    assert.dom('.input-radio').hasClass('has-margin');
  });
});
