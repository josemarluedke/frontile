import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, click, find } from '@ember/test-helpers';
import 'qunit-dom';
import { FormRadioGroup } from '@frontile/forms-legacy';
import { cell } from 'ember-resources';

module(
  'Integration | Component | @frontile/forms-legacy/FormRadioGroup',
  function (hooks) {
    setupRenderingTest(hooks);

    test('option names should be all the same', async function (assert) {
      const myValue = cell<boolean | undefined>(undefined);
      const hasError = cell<boolean | undefined>(undefined);
      const showError = cell<boolean | undefined>(undefined);
      const errors = cell<string[] | undefined>(undefined);
      const hasSubmitted = cell<boolean | undefined>(undefined);
      const isInline = cell<boolean | undefined>(undefined);
      const size = cell<string | undefined>(undefined);
      const containerClass = cell<string | undefined>(undefined);

      const setMyValue = (value: boolean) => {
        myValue.current = value;
      };

      await render(
        <template>
          <div class="my-container">
            <FormRadioGroup
              data-test-input-group
              @hasError={{hasError.current}}
              @showError={{showError.current}}
              @errors={{errors.current}}
              @hasSubmitted={{hasSubmitted.current}}
              @isInline={{isInline.current}}
              @size={{size.current}}
              @containerClass={{containerClass.current}}
              @label="My Group"
              @value={{myValue.current}}
              @onChange={{setMyValue}}
              as |Radio|
            >
              <Radio
                @value={{true}}
                @label="Yes"
                data-test-option-yes
                @containerClass="option-yes"
              />
              <Radio
                @value={{false}}
                @label="No"
                data-test-option-no
                @containerClass="option-no"
              />
            </FormRadioGroup>
          </div>
        </template>
      );

      const noName = find('[data-test-option-no]')?.getAttribute('name');
      const yesName = find('[data-test-option-yes]')?.getAttribute('name');

      assert.ok(noName, 'input should have an name attribute');
      assert.equal(
        noName,
        yesName,
        'each radio option should have the same name when used in a radio group'
      );
    });

    test('it renders the labels and options', async function (assert) {
      const myValue = cell<boolean | undefined>(undefined);
      const hasError = cell<boolean | undefined>(undefined);
      const showError = cell<boolean | undefined>(undefined);
      const errors = cell<string[] | undefined>(undefined);
      const hasSubmitted = cell<boolean | undefined>(undefined);
      const isInline = cell<boolean | undefined>(undefined);
      const size = cell<string | undefined>(undefined);
      const containerClass = cell<string | undefined>(undefined);

      const setMyValue = (value: boolean) => {
        myValue.current = value;
      };

      await render(
        <template>
          <div class="my-container">
            <FormRadioGroup
              data-test-input-group
              @hasError={{hasError.current}}
              @showError={{showError.current}}
              @errors={{errors.current}}
              @hasSubmitted={{hasSubmitted.current}}
              @isInline={{isInline.current}}
              @size={{size.current}}
              @containerClass={{containerClass.current}}
              @label="My Group"
              @value={{myValue.current}}
              @onChange={{setMyValue}}
              as |Radio|
            >
              <Radio
                @value={{true}}
                @label="Yes"
                data-test-option-yes
                @containerClass="option-yes"
              />
              <Radio
                @value={{false}}
                @label="No"
                data-test-option-no
                @containerClass="option-no"
              />
            </FormRadioGroup>
          </div>
        </template>
      );

      assert.dom('[data-test-input-group] label').hasText('My Group');
      assert.dom('[data-test-option-yes]').exists();
      assert.dom('[data-test-option-no]').exists();

      assert.dom('.option-no label').hasText('No');
      assert.dom('.option-yes label').hasText('Yes');
    });

    test('it marks the selected option correctly', async function (assert) {
      const myValue = cell<boolean>(true);
      const hasError = cell<boolean | undefined>(undefined);
      const showError = cell<boolean | undefined>(undefined);
      const errors = cell<string[] | undefined>(undefined);
      const hasSubmitted = cell<boolean | undefined>(undefined);
      const isInline = cell<boolean | undefined>(undefined);
      const size = cell<string | undefined>(undefined);
      const containerClass = cell<string | undefined>(undefined);

      const setMyValue = (value: boolean) => {
        myValue.current = value;
      };

      await render(
        <template>
          <div class="my-container">
            <FormRadioGroup
              data-test-input-group
              @hasError={{hasError.current}}
              @showError={{showError.current}}
              @errors={{errors.current}}
              @hasSubmitted={{hasSubmitted.current}}
              @isInline={{isInline.current}}
              @size={{size.current}}
              @containerClass={{containerClass.current}}
              @label="My Group"
              @value={{myValue.current}}
              @onChange={{setMyValue}}
              as |Radio|
            >
              <Radio
                @value={{true}}
                @label="Yes"
                data-test-option-yes
                @containerClass="option-yes"
              />
              <Radio
                @value={{false}}
                @label="No"
                data-test-option-no
                @containerClass="option-no"
              />
            </FormRadioGroup>
          </div>
        </template>
      );

      assert.dom('[data-test-option-no]').isNotChecked();
      assert.dom('[data-test-option-yes]').isChecked();
    });

    test('it changes the selected value', async function (assert) {
      const myValue = cell<boolean>(false);
      const hasError = cell<boolean | undefined>(undefined);
      const showError = cell<boolean | undefined>(undefined);
      const errors = cell<string[] | undefined>(undefined);
      const hasSubmitted = cell<boolean | undefined>(undefined);
      const isInline = cell<boolean | undefined>(undefined);
      const size = cell<string | undefined>(undefined);
      const containerClass = cell<string | undefined>(undefined);

      const setMyValue = (value: boolean) => {
        myValue.current = value;
      };

      await render(
        <template>
          <div class="my-container">
            <FormRadioGroup
              data-test-input-group
              @hasError={{hasError.current}}
              @showError={{showError.current}}
              @errors={{errors.current}}
              @hasSubmitted={{hasSubmitted.current}}
              @isInline={{isInline.current}}
              @size={{size.current}}
              @containerClass={{containerClass.current}}
              @label="My Group"
              @value={{myValue.current}}
              @onChange={{setMyValue}}
              as |Radio|
            >
              <Radio
                @value={{true}}
                @label="Yes"
                data-test-option-yes
                @containerClass="option-yes"
              />
              <Radio
                @value={{false}}
                @label="No"
                data-test-option-no
                @containerClass="option-no"
              />
            </FormRadioGroup>
          </div>
        </template>
      );

      await click('[data-test-option-yes]');
      assert.equal(myValue.current, true);
    });

    test('show error messages when errors array has items', async function (assert) {
      const myValue = cell<boolean | undefined>(undefined);
      const hasError = cell<boolean | undefined>(undefined);
      const showError = cell<boolean | undefined>(undefined);
      const errors = cell<string[]>(['This field is required']);
      const hasSubmitted = cell<boolean | undefined>(undefined);
      const isInline = cell<boolean | undefined>(undefined);
      const size = cell<string | undefined>(undefined);
      const containerClass = cell<string | undefined>(undefined);

      const setMyValue = (value: boolean) => {
        myValue.current = value;
      };

      await render(
        <template>
          <div class="my-container">
            <FormRadioGroup
              data-test-input-group
              @hasError={{hasError.current}}
              @showError={{showError.current}}
              @errors={{errors.current}}
              @hasSubmitted={{hasSubmitted.current}}
              @isInline={{isInline.current}}
              @size={{size.current}}
              @containerClass={{containerClass.current}}
              @label="My Group"
              @value={{myValue.current}}
              @onChange={{setMyValue}}
              as |Radio|
            >
              <Radio
                @value={{true}}
                @label="Yes"
                data-test-option-yes
                @containerClass="option-yes"
              />
              <Radio
                @value={{false}}
                @label="No"
                data-test-option-no
                @containerClass="option-no"
              />
            </FormRadioGroup>
          </div>
        </template>
      );

      assert
        .dom('.my-container [data-test-id="form-field-feedback"]')
        .doesNotExist();
      await click('[data-test-option-yes]');

      assert.dom('.my-container [data-test-id="form-field-feedback"]').exists();
      assert
        .dom('[data-test-id="form-field-feedback"]')
        .hasText('This field is required');
    });

    test('do not show error messages if errors has no elements', async function (assert) {
      const myValue = cell<boolean | undefined>(undefined);
      const hasError = cell<boolean | undefined>(undefined);
      const showError = cell<boolean | undefined>(undefined);
      const errors = cell<string[]>([]);
      const hasSubmitted = cell<boolean | undefined>(undefined);
      const isInline = cell<boolean | undefined>(undefined);
      const size = cell<string | undefined>(undefined);
      const containerClass = cell<string | undefined>(undefined);

      const setMyValue = (value: boolean) => {
        myValue.current = value;
      };

      await render(
        <template>
          <div class="my-container">
            <FormRadioGroup
              data-test-input-group
              @hasError={{hasError.current}}
              @showError={{showError.current}}
              @errors={{errors.current}}
              @hasSubmitted={{hasSubmitted.current}}
              @isInline={{isInline.current}}
              @size={{size.current}}
              @containerClass={{containerClass.current}}
              @label="My Group"
              @value={{myValue.current}}
              @onChange={{setMyValue}}
              as |Radio|
            >
              <Radio
                @value={{true}}
                @label="Yes"
                data-test-option-yes
                @containerClass="option-yes"
              />
              <Radio
                @value={{false}}
                @label="No"
                data-test-option-no
                @containerClass="option-no"
              />
            </FormRadioGroup>
          </div>
        </template>
      );

      assert
        .dom('.my-container [data-test-id="form-field-feedback"]')
        .doesNotExist();
      await click('[data-test-option-yes]');

      assert
        .dom('.my-container [data-test-id="form-field-feedback"]')
        .doesNotExist();
      assert.dom('[data-test-id="form-field-feedback"]').doesNotExist();
    });

    test('do not show errors if hasError is false even if errors has elements', async function (assert) {
      const myValue = cell<boolean | undefined>(undefined);
      const hasError = cell<boolean>(false);
      const showError = cell<boolean | undefined>(undefined);
      const errors = cell<string[]>(['This field is required']);
      const hasSubmitted = cell<boolean | undefined>(undefined);
      const isInline = cell<boolean | undefined>(undefined);
      const size = cell<string | undefined>(undefined);
      const containerClass = cell<string | undefined>(undefined);

      const setMyValue = (value: boolean) => {
        myValue.current = value;
      };

      await render(
        <template>
          <div class="my-container">
            <FormRadioGroup
              data-test-input-group
              @hasError={{hasError.current}}
              @showError={{showError.current}}
              @errors={{errors.current}}
              @hasSubmitted={{hasSubmitted.current}}
              @isInline={{isInline.current}}
              @size={{size.current}}
              @containerClass={{containerClass.current}}
              @label="My Group"
              @value={{myValue.current}}
              @onChange={{setMyValue}}
              as |Radio|
            >
              <Radio
                @value={{true}}
                @label="Yes"
                data-test-option-yes
                @containerClass="option-yes"
              />
              <Radio
                @value={{false}}
                @label="No"
                data-test-option-no
                @containerClass="option-no"
              />
            </FormRadioGroup>
          </div>
        </template>
      );

      assert
        .dom('.my-container [data-test-id="form-field-feedback"]')
        .doesNotExist();
      await click('[data-test-option-yes]');

      assert.dom('[data-test-id="form-field-feedback"]').doesNotExist();
      assert
        .dom('.my-container [data-test-id="form-field-feedback"]')
        .doesNotExist();
    });

    test('always show error messages when hasSubmitted is true', async function (assert) {
      const myValue = cell<boolean | undefined>(undefined);
      const hasError = cell<boolean | undefined>(undefined);
      const showError = cell<boolean | undefined>(undefined);
      const errors = cell<string[]>(['This field is required']);
      const hasSubmitted = cell<boolean>(true);
      const isInline = cell<boolean | undefined>(undefined);
      const size = cell<string | undefined>(undefined);
      const containerClass = cell<string | undefined>(undefined);

      const setMyValue = (value: boolean) => {
        myValue.current = value;
      };

      await render(
        <template>
          <div class="my-container">
            <FormRadioGroup
              data-test-input-group
              @hasError={{hasError.current}}
              @showError={{showError.current}}
              @errors={{errors.current}}
              @hasSubmitted={{hasSubmitted.current}}
              @isInline={{isInline.current}}
              @size={{size.current}}
              @containerClass={{containerClass.current}}
              @label="My Group"
              @value={{myValue.current}}
              @onChange={{setMyValue}}
              as |Radio|
            >
              <Radio
                @value={{true}}
                @label="Yes"
                data-test-option-yes
                @containerClass="option-yes"
              />
              <Radio
                @value={{false}}
                @label="No"
                data-test-option-no
                @containerClass="option-no"
              />
            </FormRadioGroup>
          </div>
        </template>
      );

      assert.dom('.my-container [data-test-id="form-field-feedback"]').exists();
      assert
        .dom('[data-test-id="form-field-feedback"]')
        .hasText('This field is required');
    });

    test('always show error messages when showError is true', async function (assert) {
      const myValue = cell<boolean | undefined>(undefined);
      const hasError = cell<boolean | undefined>(undefined);
      const showError = cell<boolean>(true);
      const errors = cell<string[]>(['This field is required']);
      const hasSubmitted = cell<boolean | undefined>(undefined);
      const isInline = cell<boolean | undefined>(undefined);
      const size = cell<string | undefined>(undefined);
      const containerClass = cell<string | undefined>(undefined);

      const setMyValue = (value: boolean) => {
        myValue.current = value;
      };

      await render(
        <template>
          <div class="my-container">
            <FormRadioGroup
              data-test-input-group
              @hasError={{hasError.current}}
              @showError={{showError.current}}
              @errors={{errors.current}}
              @hasSubmitted={{hasSubmitted.current}}
              @isInline={{isInline.current}}
              @size={{size.current}}
              @containerClass={{containerClass.current}}
              @label="My Group"
              @value={{myValue.current}}
              @onChange={{setMyValue}}
              as |Radio|
            >
              <Radio
                @value={{true}}
                @label="Yes"
                data-test-option-yes
                @containerClass="option-yes"
              />
              <Radio
                @value={{false}}
                @label="No"
                data-test-option-no
                @containerClass="option-no"
              />
            </FormRadioGroup>
          </div>
        </template>
      );

      assert.dom('.my-container [data-test-id="form-field-feedback"]').exists();
      assert
        .dom('[data-test-id="form-field-feedback"]')
        .hasText('This field is required');
    });

    test('it adds container class from @containerClass arg', async function (assert) {
      const myValue = cell<boolean | undefined>(undefined);
      const hasError = cell<boolean | undefined>(undefined);
      const showError = cell<boolean | undefined>(undefined);
      const errors = cell<string[] | undefined>(undefined);
      const hasSubmitted = cell<boolean | undefined>(undefined);
      const isInline = cell<boolean | undefined>(undefined);
      const size = cell<string | undefined>(undefined);
      const containerClass = cell<string>('my-container-class');

      const setMyValue = (value: boolean) => {
        myValue.current = value;
      };

      await render(
        <template>
          <div class="my-container">
            <FormRadioGroup
              data-test-input-group
              @hasError={{hasError.current}}
              @showError={{showError.current}}
              @errors={{errors.current}}
              @hasSubmitted={{hasSubmitted.current}}
              @isInline={{isInline.current}}
              @size={{size.current}}
              @containerClass={{containerClass.current}}
              @label="My Group"
              @value={{myValue.current}}
              @onChange={{setMyValue}}
              as |Radio|
            >
              <Radio
                @value={{true}}
                @label="Yes"
                data-test-option-yes
                @containerClass="option-yes"
              />
              <Radio
                @value={{false}}
                @label="No"
                data-test-option-no
                @containerClass="option-no"
              />
            </FormRadioGroup>
          </div>
        </template>
      );

      assert.dom('.my-container-class').exists();
    });
  }
);
