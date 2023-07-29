import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, click, find } from '@ember/test-helpers';
import hbs from 'htmlbars-inline-precompile';
import 'qunit-dom';

declare module '@ember/test-helpers' {
  interface TestContext {
    myValue: unknown;
    value: unknown;
    myInputValue: unknown;
  }
}

module(
  'Integration | Component | @frontile/forms/FormCheckbox',
  function (hooks) {
    setupRenderingTest(hooks);

    test('it renders with the label from argument', async function (assert) {
      await render(
        hbs`<FormCheckbox
            data-test-input
            @label="My Checkbox Input"
          />`
      );
      assert
        .dom('[data-test-id="form-field-label"]')
        .hasText('My Checkbox Input');
    });

    test('it renders the label from block param', async function (assert) {
      await render(
        hbs`<FormCheckbox data-test-input>My Block Label</FormCheckbox>`
      );

      assert.dom('[data-test-id="form-field-label"]').hasText('My Block Label');
    });

    test('it should have id attr with matching label attr `for`', async function (assert) {
      await render(hbs`<FormCheckbox
                        @label="Something Else"
                        data-test-input
                      />`);

      const el = find('[data-test-input]') as HTMLInputElement;
      const id = el.getAttribute('id') || '';

      assert.ok(/ember[1-9.]/.test(id), 'should have generated an id');

      assert.dom('[data-test-id="form-field-label"]').hasAttribute('for', id);
    });

    test('it renders the `name` from args', async function (assert) {
      await render(
        hbs`<FormCheckbox
            data-test-input
            @name="my-input"
          />`
      );

      assert.dom('[data-test-input]').hasAttribute('name', 'my-input');
    });

    test('it does not mutates the value directly', async function (assert) {
      this.set('myValue', undefined);

      await render(
        hbs`<FormCheckbox
            data-test-input
            name="my-input"
            @label="My Checkbox Input"
            @checked={{this.myValue}}
          />`
      );

      await click('[data-test-input]');
      assert.equal(this.myValue, undefined);
    });

    test('it calls onChange function to change value', async function (assert) {
      this.set('myValue', undefined);

      await render(
        hbs`<FormCheckbox
            data-test-input
            name="my-input"
            @label="My Checkbox Input"
            @checked={{this.myValue}}
            @onChange={{fn (mut this.myValue)}}
          />`
      );

      await click('[data-test-input]');
      assert.equal(this.myValue, true);
    });

    test('it marks the input as checked if value matches', async function (assert) {
      this.set('myValue', false);

      await render(
        hbs`<FormCheckbox
            data-test-input
            @label="My Checkbox Input"
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
        hbs`<FormCheckbox
            data-test-input
            @label="My Checkbox Input"
          />`
      );

      const inputId = find('[data-test-input]')?.getAttribute('id');
      const labelFor = find('[data-test-id="form-field-label"]')?.getAttribute(
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
        hbs`<FormCheckbox
            @containerClass="my-container-class"
          />`
      );

      assert.dom('.my-container-class').exists();
    });

    test('it adds class to input wrapper when checked to allow selected label css styling', async function (assert) {
      this.set('myValue', false);

      await render(
        hbs`<FormCheckbox
            data-test-input
            @label="My Checkbox Input"
            @checked={{this.myValue}}
          />`
      );

      assert.dom('[data-test-input]').isNotChecked();
      assert.dom('.form-checkbox--checked').doesNotExist();

      this.set('myValue', true);

      assert.dom('[data-test-input]').isChecked();
      assert.dom('.form-checkbox--checked').exists();
    });

    test('it adds size classes for @size', async function (assert) {
      this.set('size', 'sm');

      await render(
        hbs`<FormCheckbox
            data-test-input
            @containerClass="my-container"
            @label="Label"
            @hint="Hint"
            @size={{this.size}}
          />`
      );

      assert.dom('.my-container').hasClass('form-checkbox--sm');
      assert.dom('[data-test-input]').hasClass('form-checkbox--sm__checkbox');
      assert
        .dom('[data-test-id="form-field-label"]')
        .hasClass('form-checkbox--sm__label');
      assert
        .dom('[data-test-id="form-field-hint"]')
        .hasClass('form-checkbox--sm__hint');

      this.set('size', 'lg');
      assert.dom('.my-container').hasClass('form-checkbox--lg');
      assert.dom('[data-test-input]').hasClass('form-checkbox--lg__checkbox');
      assert
        .dom('[data-test-id="form-field-label"]')
        .hasClass('form-checkbox--lg__label');
      assert
        .dom('[data-test-id="form-field-hint"]')
        .hasClass('form-checkbox--lg__hint');
    });
  }
);
