import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, click, settled } from '@ember/test-helpers';
import { FormCheckboxGroup } from '@frontile/forms-legacy';
import { cell } from 'ember-resources';

module(
  'Integration | Component | @frontile/forms-legacy/FormCheckboxGroup',
  function (hooks) {
    setupRenderingTest(hooks);

    test('it adds the accessibility html attributes', async function (assert) {
      const myValue1 = cell<boolean | undefined>(undefined);
      const myValue2 = cell<boolean | undefined>(undefined);
      const errors = cell<string[] | undefined>(undefined);
      const hasError = cell<boolean | undefined>(undefined);
      const showError = cell<boolean | undefined>(undefined);
      const containerClass = cell<string | undefined>(undefined);
      const hasSubmitted = cell<boolean | undefined>(undefined);
      const isInline = cell<boolean | undefined>(undefined);
      const size = cell<string | undefined>(undefined);

      const setMyValue1 = (value: boolean) => {
        myValue1.current = value;
      };
      const setMyValue2 = (value: boolean) => {
        myValue2.current = value;
      };

      await render(
        <template>
          <div class="my-container">
            <FormCheckboxGroup
              data-test-input-group
              @errors={{errors.current}}
              @hasError={{hasError.current}}
              @showError={{showError.current}}
              @containerClass={{containerClass.current}}
              @hasSubmitted={{hasSubmitted.current}}
              @isInline={{isInline.current}}
              @size={{size.current}}
              @label="My Group"
              @hint="Hint"
              as |Checkbox|
            >
              <Checkbox
                @label="Checkbox 1"
                data-test-checkbox-1
                @containerClass="checkbox-1"
                @name="checkbox1"
                @checked={{myValue1.current}}
                @onChange={{setMyValue1}}
              />
              <Checkbox
                @label="Checkbox 2"
                data-test-checkbox-2
                @containerClass="checkbox-2"
                @name="checkbox2"
                @checked={{myValue2.current}}
                @onChange={{setMyValue2}}
              />
            </FormCheckboxGroup>
          </div>
        </template>
      );

      assert.dom('[data-test-input-group]').hasAttribute('role', 'group');
    });

    test('it renders the labels and options', async function (assert) {
      const myValue1 = cell<boolean | undefined>(undefined);
      const myValue2 = cell<boolean | undefined>(undefined);
      const errors = cell<string[] | undefined>(undefined);
      const hasError = cell<boolean | undefined>(undefined);
      const showError = cell<boolean | undefined>(undefined);
      const containerClass = cell<string | undefined>(undefined);
      const hasSubmitted = cell<boolean | undefined>(undefined);
      const isInline = cell<boolean | undefined>(undefined);
      const size = cell<string | undefined>(undefined);

      const setMyValue1 = (value: boolean) => {
        myValue1.current = value;
      };
      const setMyValue2 = (value: boolean) => {
        myValue2.current = value;
      };

      await render(
        <template>
          <div class="my-container">
            <FormCheckboxGroup
              data-test-input-group
              @errors={{errors.current}}
              @hasError={{hasError.current}}
              @showError={{showError.current}}
              @containerClass={{containerClass.current}}
              @hasSubmitted={{hasSubmitted.current}}
              @isInline={{isInline.current}}
              @size={{size.current}}
              @label="My Group"
              @hint="Hint"
              as |Checkbox|
            >
              <Checkbox
                @label="Checkbox 1"
                data-test-checkbox-1
                @containerClass="checkbox-1"
                @name="checkbox1"
                @checked={{myValue1.current}}
                @onChange={{setMyValue1}}
              />
              <Checkbox
                @label="Checkbox 2"
                data-test-checkbox-2
                @containerClass="checkbox-2"
                @name="checkbox2"
                @checked={{myValue2.current}}
                @onChange={{setMyValue2}}
              />
            </FormCheckboxGroup>
          </div>
        </template>
      );

      assert.dom('[data-test-input-group] label').hasText('My Group');
      assert.dom('[data-test-checkbox-1]').exists();
      assert.dom('[data-test-checkbox-2]').exists();

      assert.dom('.checkbox-1 label').hasText('Checkbox 1');
      assert.dom('.checkbox-2 label').hasText('Checkbox 2');
    });

    test('show error messages when errors array has items', async function (assert) {
      const myValue1 = cell<boolean | undefined>(undefined);
      const myValue2 = cell<boolean | undefined>(undefined);
      const errors = cell<string[] | undefined>(['This field is required']);
      const hasError = cell<boolean | undefined>(undefined);
      const showError = cell<boolean | undefined>(undefined);
      const containerClass = cell<string | undefined>(undefined);
      const hasSubmitted = cell<boolean | undefined>(undefined);
      const isInline = cell<boolean | undefined>(undefined);
      const size = cell<string | undefined>(undefined);

      const setMyValue1 = (value: boolean) => {
        myValue1.current = value;
      };
      const setMyValue2 = (value: boolean) => {
        myValue2.current = value;
      };

      await render(
        <template>
          <div class="my-container">
            <FormCheckboxGroup
              data-test-input-group
              @errors={{errors.current}}
              @hasError={{hasError.current}}
              @showError={{showError.current}}
              @containerClass={{containerClass.current}}
              @hasSubmitted={{hasSubmitted.current}}
              @isInline={{isInline.current}}
              @size={{size.current}}
              @label="My Group"
              @hint="Hint"
              as |Checkbox|
            >
              <Checkbox
                @label="Checkbox 1"
                data-test-checkbox-1
                @containerClass="checkbox-1"
                @name="checkbox1"
                @checked={{myValue1.current}}
                @onChange={{setMyValue1}}
              />
              <Checkbox
                @label="Checkbox 2"
                data-test-checkbox-2
                @containerClass="checkbox-2"
                @name="checkbox2"
                @checked={{myValue2.current}}
                @onChange={{setMyValue2}}
              />
            </FormCheckboxGroup>
          </div>
        </template>
      );

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
      const myValue1 = cell<boolean | undefined>(undefined);
      const myValue2 = cell<boolean | undefined>(undefined);
      const errors = cell<string[]>([]);
      const hasError = cell<boolean | undefined>(undefined);
      const showError = cell<boolean | undefined>(undefined);
      const containerClass = cell<string | undefined>(undefined);
      const hasSubmitted = cell<boolean | undefined>(undefined);
      const isInline = cell<boolean | undefined>(undefined);
      const size = cell<string | undefined>(undefined);

      const setMyValue1 = (value: boolean) => {
        myValue1.current = value;
      };
      const setMyValue2 = (value: boolean) => {
        myValue2.current = value;
      };

      await render(
        <template>
          <div class="my-container">
            <FormCheckboxGroup
              data-test-input-group
              @errors={{errors.current}}
              @hasError={{hasError.current}}
              @showError={{showError.current}}
              @containerClass={{containerClass.current}}
              @hasSubmitted={{hasSubmitted.current}}
              @isInline={{isInline.current}}
              @size={{size.current}}
              @label="My Group"
              @hint="Hint"
              as |Checkbox|
            >
              <Checkbox
                @label="Checkbox 1"
                data-test-checkbox-1
                @containerClass="checkbox-1"
                @name="checkbox1"
                @checked={{myValue1.current}}
                @onChange={{setMyValue1}}
              />
              <Checkbox
                @label="Checkbox 2"
                data-test-checkbox-2
                @containerClass="checkbox-2"
                @name="checkbox2"
                @checked={{myValue2.current}}
                @onChange={{setMyValue2}}
              />
            </FormCheckboxGroup>
          </div>
        </template>
      );

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
      const myValue1 = cell<boolean | undefined>(undefined);
      const myValue2 = cell<boolean | undefined>(undefined);
      const errors = cell<string[]>(['This field is required']);
      const hasError = cell<boolean>(false);
      const showError = cell<boolean | undefined>(undefined);
      const containerClass = cell<string | undefined>(undefined);
      const hasSubmitted = cell<boolean | undefined>(undefined);
      const isInline = cell<boolean | undefined>(undefined);
      const size = cell<string | undefined>(undefined);

      const setMyValue1 = (value: boolean) => {
        myValue1.current = value;
      };
      const setMyValue2 = (value: boolean) => {
        myValue2.current = value;
      };

      await render(
        <template>
          <div class="my-container">
            <FormCheckboxGroup
              data-test-input-group
              @errors={{errors.current}}
              @hasError={{hasError.current}}
              @showError={{showError.current}}
              @containerClass={{containerClass.current}}
              @hasSubmitted={{hasSubmitted.current}}
              @isInline={{isInline.current}}
              @size={{size.current}}
              @label="My Group"
              @hint="Hint"
              as |Checkbox|
            >
              <Checkbox
                @label="Checkbox 1"
                data-test-checkbox-1
                @containerClass="checkbox-1"
                @name="checkbox1"
                @checked={{myValue1.current}}
                @onChange={{setMyValue1}}
              />
              <Checkbox
                @label="Checkbox 2"
                data-test-checkbox-2
                @containerClass="checkbox-2"
                @name="checkbox2"
                @checked={{myValue2.current}}
                @onChange={{setMyValue2}}
              />
            </FormCheckboxGroup>
          </div>
        </template>
      );

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
      const myValue1 = cell<boolean | undefined>(undefined);
      const myValue2 = cell<boolean | undefined>(undefined);
      const errors = cell<string[]>(['This field is required']);
      const hasError = cell<boolean | undefined>(undefined);
      const showError = cell<boolean | undefined>(undefined);
      const containerClass = cell<string | undefined>(undefined);
      const hasSubmitted = cell<boolean>(true);
      const isInline = cell<boolean | undefined>(undefined);
      const size = cell<string | undefined>(undefined);

      const setMyValue1 = (value: boolean) => {
        myValue1.current = value;
      };
      const setMyValue2 = (value: boolean) => {
        myValue2.current = value;
      };

      await render(
        <template>
          <div class="my-container">
            <FormCheckboxGroup
              data-test-input-group
              @errors={{errors.current}}
              @hasError={{hasError.current}}
              @showError={{showError.current}}
              @containerClass={{containerClass.current}}
              @hasSubmitted={{hasSubmitted.current}}
              @isInline={{isInline.current}}
              @size={{size.current}}
              @label="My Group"
              @hint="Hint"
              as |Checkbox|
            >
              <Checkbox
                @label="Checkbox 1"
                data-test-checkbox-1
                @containerClass="checkbox-1"
                @name="checkbox1"
                @checked={{myValue1.current}}
                @onChange={{setMyValue1}}
              />
              <Checkbox
                @label="Checkbox 2"
                data-test-checkbox-2
                @containerClass="checkbox-2"
                @name="checkbox2"
                @checked={{myValue2.current}}
                @onChange={{setMyValue2}}
              />
            </FormCheckboxGroup>
          </div>
        </template>
      );

      assert.dom('.my-container [data-test-id="form-field-feedback"]').exists();
      assert
        .dom('[data-test-id="form-field-feedback"]')
        .hasText('This field is required');
    });

    test('always show error messages when showError is true', async function (assert) {
      const myValue1 = cell<boolean | undefined>(undefined);
      const myValue2 = cell<boolean | undefined>(undefined);
      const errors = cell<string[]>(['This field is required']);
      const hasError = cell<boolean | undefined>(undefined);
      const showError = cell<boolean>(true);
      const containerClass = cell<string | undefined>(undefined);
      const hasSubmitted = cell<boolean | undefined>(undefined);
      const isInline = cell<boolean | undefined>(undefined);
      const size = cell<string | undefined>(undefined);

      const setMyValue1 = (value: boolean) => {
        myValue1.current = value;
      };
      const setMyValue2 = (value: boolean) => {
        myValue2.current = value;
      };

      await render(
        <template>
          <div class="my-container">
            <FormCheckboxGroup
              data-test-input-group
              @errors={{errors.current}}
              @hasError={{hasError.current}}
              @showError={{showError.current}}
              @containerClass={{containerClass.current}}
              @hasSubmitted={{hasSubmitted.current}}
              @isInline={{isInline.current}}
              @size={{size.current}}
              @label="My Group"
              @hint="Hint"
              as |Checkbox|
            >
              <Checkbox
                @label="Checkbox 1"
                data-test-checkbox-1
                @containerClass="checkbox-1"
                @name="checkbox1"
                @checked={{myValue1.current}}
                @onChange={{setMyValue1}}
              />
              <Checkbox
                @label="Checkbox 2"
                data-test-checkbox-2
                @containerClass="checkbox-2"
                @name="checkbox2"
                @checked={{myValue2.current}}
                @onChange={{setMyValue2}}
              />
            </FormCheckboxGroup>
          </div>
        </template>
      );

      assert.dom('.my-container [data-test-id="form-field-feedback"]').exists();
      assert
        .dom('[data-test-id="form-field-feedback"]')
        .hasText('This field is required');
    });

    test('it adds container class from @containerClass arg', async function (assert) {
      const myValue1 = cell<boolean | undefined>(undefined);
      const myValue2 = cell<boolean | undefined>(undefined);
      const errors = cell<string[] | undefined>(undefined);
      const hasError = cell<boolean | undefined>(undefined);
      const showError = cell<boolean | undefined>(undefined);
      const containerClass = cell<string>('my-container-class');
      const hasSubmitted = cell<boolean | undefined>(undefined);
      const isInline = cell<boolean | undefined>(undefined);
      const size = cell<string | undefined>(undefined);

      const setMyValue1 = (value: boolean) => {
        myValue1.current = value;
      };
      const setMyValue2 = (value: boolean) => {
        myValue2.current = value;
      };

      await render(
        <template>
          <div class="my-container">
            <FormCheckboxGroup
              data-test-input-group
              @errors={{errors.current}}
              @hasError={{hasError.current}}
              @showError={{showError.current}}
              @containerClass={{containerClass.current}}
              @hasSubmitted={{hasSubmitted.current}}
              @isInline={{isInline.current}}
              @size={{size.current}}
              @label="My Group"
              @hint="Hint"
              as |Checkbox|
            >
              <Checkbox
                @label="Checkbox 1"
                data-test-checkbox-1
                @containerClass="checkbox-1"
                @name="checkbox1"
                @checked={{myValue1.current}}
                @onChange={{setMyValue1}}
              />
              <Checkbox
                @label="Checkbox 2"
                data-test-checkbox-2
                @containerClass="checkbox-2"
                @name="checkbox2"
                @checked={{myValue2.current}}
                @onChange={{setMyValue2}}
              />
            </FormCheckboxGroup>
          </div>
        </template>
      );
      assert.dom('.my-container-class').exists();
    });
  }
);
