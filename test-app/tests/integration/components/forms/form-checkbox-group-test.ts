import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, click } from '@ember/test-helpers';
import hbs from 'htmlbars-inline-precompile';

module(
  'Integration | Component | @frontile/forms/FormCheckboxGroup',
  function (hooks) {
    setupRenderingTest(hooks);

    const template = hbs`
    <div class="my-container">
      <FormCheckboxGroup
        data-test-input-group
        @errors={{this.errors}}
        @hasError={{this.hasError}}
        @showError={{this.showError}}
        @containerClass={{this.containerClass}}
        @hasSubmitted={{this.hasSubmitted}}
        @isInline={{this.isInline}}
        @size={{this.size}}
        @label="My Group"
        @hint="Hint"
        as |Checkbox|
      >
        <Checkbox @label="Checkbox 1"
          data-test-checkbox-1
          @containerClass="checkbox-1"
          @name="checkbox1"
          @checked={{this.myValue1}}
          @onChange={{fn (mut this.myValue1)}}
        />
        <Checkbox @label="Checkbox 2"
          data-test-checkbox-2
          @containerClass="checkbox-2"
          @name="checkbox2"
          @checked={{this.myValue2}}
          @onChange={{fn (mut this.myValue2)}}
        />
      </FormCheckboxGroup>
    </div>`;

    test('it adds the accessibility html attributes', async function (assert) {
      this.set('myValue', undefined);
      await render(template);

      assert.dom('[data-test-input-group]').hasAttribute('role', 'group');
    });

    test('it renders the labels and options', async function (assert) {
      this.set('myValue', undefined);
      await render(template);

      assert.dom('[data-test-input-group] label').hasText('My Group');
      assert.dom('[data-test-checkbox-1]').exists();
      assert.dom('[data-test-checkbox-2]').exists();

      assert.dom('.checkbox-1 label').hasText('Checkbox 1');
      assert.dom('.checkbox-2 label').hasText('Checkbox 2');
    });

    test('show error messages when errors array has items', async function (assert) {
      this.set('errors', ['This field is required']);
      await render(template);

      assert
        .dom('.my-container [data-test-id="form-field-feedback"]')
        .doesNotExist();
      await click('[data-test-checkbox-1]');

      assert.dom('.my-container [data-test-id="form-field-feedback"]').exists();
      assert
        .dom('[data-test-id="form-field-feedback"]')
        .hasText('This field is required');
    });

    test('do not show error messages if errors has no elements', async function (assert) {
      this.set('errors', []);
      await render(template);

      assert
        .dom('.my-container [data-test-id="form-field-feedback"]')
        .doesNotExist();
      await click('[data-test-checkbox-1]');

      assert
        .dom('.my-container [data-test-id="form-field-feedback"]')
        .doesNotExist();
      assert.dom('[data-test-id="form-field-feedback"]').doesNotExist();
    });

    test('do not show errors if hasError is false even if errors has elements', async function (assert) {
      this.set('errors', ['This field is required']);
      this.set('hasError', false);
      await render(template);

      assert
        .dom('.my-container [data-test-id="form-field-feedback"]')
        .doesNotExist();
      await click('[data-test-checkbox-1]');

      assert.dom('[data-test-id="form-field-feedback"]').doesNotExist();
      assert
        .dom('.my-container [data-test-id="form-field-feedback"]')
        .doesNotExist();
    });

    test('always show error messages when hasSubmitted is true', async function (assert) {
      this.set('errors', ['This field is required']);
      this.set('hasSubmitted', true);
      await render(template);

      assert.dom('.my-container [data-test-id="form-field-feedback"]').exists();
      assert
        .dom('[data-test-id="form-field-feedback"]')
        .hasText('This field is required');
    });

    test('always show error messages when showError is true', async function (assert) {
      this.set('errors', ['This field is required']);
      this.set('showError', true);
      await render(template);

      assert.dom('.my-container [data-test-id="form-field-feedback"]').exists();
      assert
        .dom('[data-test-id="form-field-feedback"]')
        .hasText('This field is required');
    });

    test('it adds container class from @containerClass arg', async function (assert) {
      this.set('containerClass', 'my-container-class');
      await render(template);
      assert.dom('.my-container-class').exists();
    });
  }
);
