import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, fillIn, click, settled } from '@ember/test-helpers';
import { selectOptionByKey } from '@frontile/forms/test-support';
import { tracked } from '@glimmer/tracking';

import { Field } from '@frontile/forms';
import { cell } from 'ember-resources';
import type { FormErrors } from '@frontile/forms';

module('Integration | Component | @frontile/forms/Field', function (hooks) {
  setupRenderingTest(hooks);

  test('it yields Input component correctly', async function (assert) {
    const value = cell('');
    const onInput = (val: string) => {
      value.current = val;
    };

    await render(
      <template>
        <Field @name="testField" as |field|>
          <field.Input
            @label="Test Input"
            @value={{value.current}}
            @onInput={{onInput}}
            data-test-input
          />
        </Field>
      </template>
    );

    assert.dom('[data-component="input"]').exists('Input component is yielded');
    assert.dom('[data-component="label"]').hasText('Test Input');
    assert.dom('[data-test-input]').hasAttribute('name', 'testField');

    // Test that input works
    await fillIn('[data-test-input]', 'Test Value');
    assert.equal(value.current, 'Test Value', 'Input updates the value');
  });

  test('it yields Checkbox component correctly', async function (assert) {
    const checked = cell(false);
    const onChange = (val: boolean) => {
      checked.current = val;
    };

    await render(
      <template>
        <Field @name="testCheckbox" as |field|>
          <field.Checkbox
            @label="Accept Terms"
            @checked={{checked.current}}
            @onChange={{onChange}}
            data-test-checkbox
          />
        </Field>
      </template>
    );

    assert
      .dom('[data-component="checkbox"]')
      .exists('Checkbox component is yielded');
    assert.dom('[data-component="label"]').hasText('Accept Terms');
    assert.dom('[data-test-checkbox]').hasAttribute('name', 'testCheckbox');

    // Test that checkbox works
    await click('[data-test-checkbox]');
    assert.true(checked.current, 'Checkbox updates the value');
  });

  test('it yields CheckboxGroup component correctly', async function (assert) {
    const opt1Checked = cell(false);
    const opt2Checked = cell(false);
    const opt3Checked = cell(false);

    const onChange1 = (val: boolean) => {
      opt1Checked.current = val;
    };
    const onChange2 = (val: boolean) => {
      opt2Checked.current = val;
    };
    const onChange3 = (val: boolean) => {
      opt3Checked.current = val;
    };

    await render(
      <template>
        <Field @name="testCheckboxGroup" as |field|>
          <field.CheckboxGroup
            @label="Select Options"
            data-test-checkbox-group
            as |Checkbox|
          >
            <Checkbox
              @label="Option 1"
              @checked={{opt1Checked.current}}
              @onChange={{onChange1}}
            />
            <Checkbox
              @label="Option 2"
              @checked={{opt2Checked.current}}
              @onChange={{onChange2}}
            />
            <Checkbox
              @label="Option 3"
              @checked={{opt3Checked.current}}
              @onChange={{onChange3}}
            />
          </field.CheckboxGroup>
        </Field>
      </template>
    );

    // CheckboxGroup component exists and is functional
    assert
      .dom('[data-test-checkbox-group]')
      .exists('CheckboxGroup component is yielded');
    assert.dom('[data-component="label"]').hasText('Select Options');
    // Individual checkboxes within the group have the name attribute
    assert.dom('[data-component="checkbox"]').exists({ count: 3 });

    // Test that checkbox group works
    const checkboxes = document.querySelectorAll('[data-component="checkbox"]');
    await click(checkboxes[0] as Element); // Option 1
    await click(checkboxes[2] as Element); // Option 3
    assert.true(opt1Checked.current, 'Option 1 is checked');
    assert.false(opt2Checked.current, 'Option 2 is not checked');
    assert.true(opt3Checked.current, 'Option 3 is checked');
  });

  test('it yields Radio component correctly', async function (assert) {
    const selected = cell('');
    const onChange = (val: string | number | boolean) => {
      selected.current = val as string;
    };

    await render(
      <template>
        <Field @name="testRadio" as |field|>
          <field.Radio
            @label="Single Radio"
            @value="radioValue"
            @checkedValue={{selected.current}}
            @onChange={{onChange}}
            data-test-radio
          />
        </Field>
      </template>
    );

    assert.dom('[data-component="radio"]').exists('Radio component is yielded');
    assert.dom('[data-component="label"]').hasText('Single Radio');
    assert.dom('[data-test-radio]').hasAttribute('name', 'testRadio');

    // Test that radio works
    await click('[data-test-radio]');
    assert.equal(selected.current, 'radioValue', 'Radio updates the value');
  });

  test('it yields RadioGroup component correctly', async function (assert) {
    const selected = cell('');
    const onChange = (val: string | number | boolean) => {
      selected.current = val as string;
    };

    await render(
      <template>
        <Field @name="testRadioGroup" as |field|>
          <field.RadioGroup
            @label="Choose Option"
            @value={{selected.current}}
            @onChange={{onChange}}
            data-test-radio-group
            as |Radio|
          >
            <Radio @label="Option A" @value="a" />
            <Radio @label="Option B" @value="b" />
            <Radio @label="Option C" @value="c" />
          </field.RadioGroup>
        </Field>
      </template>
    );

    // RadioGroup component exists and is functional
    assert
      .dom('[data-test-radio-group]')
      .exists('RadioGroup component is yielded');
    assert.dom('[data-component="label"]').hasText('Choose Option');
    // Individual radios have the name attribute
    assert.dom('[name="testRadioGroup"]').exists({ count: 3 });

    // Test that radio group works
    await click('[value="b"]');
    assert.equal(selected.current, 'b', 'RadioGroup updates the value');
  });

  test('it yields SingleSelect component correctly', async function (assert) {
    const selected = cell<string | null>(null);
    const onChange = (val: string | null) => {
      selected.current = val;
    };
    const items = ['Apple', 'Banana', 'Orange'];

    await render(
      <template>
        <Field @name="testSelect" as |field|>
          <field.SingleSelect
            @label="Choose Fruit"
            @items={{items}}
            @allowEmpty={{true}}
            @selectedKey={{selected.current}}
            @onSelectionChange={{onChange}}
            data-test-select
          />
        </Field>
      </template>
    );

    // Select component exists and is functional
    assert.dom('[data-test-select]').exists('Select component is yielded');
    assert.dom('[data-component="label"]').hasText('Choose Fruit');
    // Select components use internal structure, verify it's working
    assert.dom('[data-component="select-trigger"]').exists();

    // Test that select works
    await selectOptionByKey('[data-test-select]', 'Banana');
    assert.equal(selected.current, 'Banana', 'Select updates the value');
  });

  test('it yields MultiSelect component correctly', async function (assert) {
    const selected = cell<string[]>([]);
    const onChange = (val: string[]) => {
      selected.current = val;
    };
    const items = ['Apple', 'Banana', 'Orange', 'Grape'];

    await render(
      <template>
        <Field @name="testMultiSelect" as |field|>
          <field.MultiSelect
            @label="Choose Fruits"
            @items={{items}}
            @selectionMode="multiple"
            @selectedKeys={{selected.current}}
            @onSelectionChange={{onChange}}
            data-test-multi-select
          />
        </Field>
      </template>
    );

    // MultiSelect component exists and is functional
    assert
      .dom('[data-test-multi-select]')
      .exists('MultiSelect component is yielded');
    assert.dom('[data-component="label"]').hasText('Choose Fruits');
    assert.dom('[data-component="select-trigger"]').exists();

    // Test that multi-select works
    await click('[data-component="select-trigger"]');
    await click('[data-component="listbox"] [data-key="Banana"]');
    await click('[data-component="listbox"] [data-key="Orange"]');

    assert.deepEqual(
      selected.current,
      ['Banana', 'Orange'],
      'MultiSelect updates with multiple values'
    );
  });

  test('it yields Switch component correctly', async function (assert) {
    const checked = cell(false);
    const onChange = (val: boolean) => {
      checked.current = val;
    };

    await render(
      <template>
        <Field @name="testSwitch" as |field|>
          <field.Switch
            @label="Enable Feature"
            @isSelected={{checked.current}}
            @onChange={{onChange}}
            data-test-switch
          />
        </Field>
      </template>
    );

    assert
      .dom('[data-component="switch"]')
      .exists('Switch component is yielded');
    assert.dom('[data-component="label"]').hasText('Enable Feature');
    assert.dom('[data-test-switch]').hasAttribute('name', 'testSwitch');

    // Test that switch works
    await click('[data-test-switch]');
    assert.true(checked.current, 'Switch updates the value');
  });

  test('it yields Textarea component correctly', async function (assert) {
    const value = cell('');
    const onInput = (val: string) => {
      value.current = val;
    };

    await render(
      <template>
        <Field @name="testTextarea" as |field|>
          <field.Textarea
            @label="Description"
            @value={{value.current}}
            @onInput={{onInput}}
            data-test-textarea
          />
        </Field>
      </template>
    );

    assert
      .dom('[data-component="textarea"]')
      .exists('Textarea component is yielded');
    assert.dom('[data-component="label"]').hasText('Description');
    assert.dom('[data-test-textarea]').hasAttribute('name', 'testTextarea');

    // Test that textarea works
    await fillIn('[data-test-textarea]', 'This is a test description');
    assert.equal(
      value.current,
      'This is a test description',
      'Textarea updates the value'
    );
  });

  test('it displays errors for Input component', async function (assert) {
    const errors = cell<FormErrors>({});

    await render(
      <template>
        <Field @name="email" @errors={{errors.current}} as |field|>
          <field.Input @label="Email" data-test-input />
        </Field>
      </template>
    );

    // No errors initially
    assert
      .dom('[data-component="form-feedback"]')
      .doesNotExist('No error message initially');
    assert.dom('[data-test-input]').doesNotHaveAttribute('aria-invalid');

    // Add errors
    errors.current = { email: ['Invalid email format', 'Email is required'] };
    await settled();

    // Check errors are displayed
    assert
      .dom('[data-component="form-feedback"]')
      .exists('Error message is displayed');
    assert
      .dom('[data-component="form-feedback"]')
      .hasText('Invalid email format; Email is required');
    assert.dom('[data-test-input]').hasAttribute('aria-invalid', 'true');

    // Clear errors
    errors.current = {};
    await settled();

    assert
      .dom('[data-component="form-feedback"]')
      .doesNotExist('Error message is cleared');
    assert.dom('[data-test-input]').doesNotHaveAttribute('aria-invalid');
  });

  test('it displays errors for Checkbox component', async function (assert) {
    const errors = cell<FormErrors>({});

    await render(
      <template>
        <Field @name="terms" @errors={{errors.current}} as |field|>
          <field.Checkbox @label="Accept Terms" data-test-checkbox />
        </Field>
      </template>
    );

    // No errors initially
    assert
      .dom('[data-component="form-feedback"]')
      .doesNotExist('No error message initially');
    assert.dom('[data-test-checkbox]').doesNotHaveAttribute('aria-invalid');

    // Add errors
    errors.current = { terms: ['You must accept the terms'] };
    await settled();

    // Check errors are displayed
    assert
      .dom('[data-component="form-feedback"]')
      .exists('Error message is displayed');
    assert
      .dom('[data-component="form-feedback"]')
      .hasText('You must accept the terms');
    assert.dom('[data-test-checkbox]').hasAttribute('aria-invalid', 'true');
  });

  test('it displays errors for RadioGroup component', async function (assert) {
    const errors = cell<FormErrors>({});

    await render(
      <template>
        <Field @name="choice" @errors={{errors.current}} as |field|>
          <field.RadioGroup
            @label="Make a choice"
            data-test-radio-group
            as |Radio|
          >
            <Radio @label="Yes" @value="yes" />
            <Radio @label="No" @value="no" />
          </field.RadioGroup>
        </Field>
      </template>
    );

    // No errors initially
    assert
      .dom('[data-component="form-feedback"]')
      .doesNotExist('No error message initially');

    // Add errors
    errors.current = { choice: ['Please make a selection'] };
    await settled();

    // Check errors are displayed
    assert
      .dom('[data-component="form-feedback"]')
      .exists('Error message is displayed');
    assert
      .dom('[data-component="form-feedback"]')
      .hasText('Please make a selection');
    // Verify radio inputs exist and error is shown
    assert.dom('[name="choice"]').exists({ count: 2 }, 'Radio inputs exist');
  });

  test('it displays errors for Select component', async function (assert) {
    const errors = cell<FormErrors>({});
    const items = ['Option 1', 'Option 2'];

    await render(
      <template>
        <Field @name="selection" @errors={{errors.current}} as |field|>
          <field.SingleSelect
            @label="Select Option"
            @items={{items}}
            data-test-select
          />
        </Field>
      </template>
    );

    // No errors initially
    assert
      .dom('[data-component="form-feedback"]')
      .doesNotExist('No error message initially');

    // Add errors
    errors.current = { selection: ['Selection is required'] };
    await settled();

    // Check errors are displayed
    assert
      .dom('[data-component="form-feedback"]')
      .exists('Error message is displayed');
    assert
      .dom('[data-component="form-feedback"]')
      .hasText('Selection is required');
    // Verify select trigger exists and error is shown
    assert
      .dom('[data-component="select-trigger"]')
      .exists('Select trigger exists');
  });

  test('it displays errors for Textarea component', async function (assert) {
    const errors = cell<FormErrors>({});

    await render(
      <template>
        <Field @name="description" @errors={{errors.current}} as |field|>
          <field.Textarea @label="Description" data-test-textarea />
        </Field>
      </template>
    );

    // No errors initially
    assert
      .dom('[data-component="form-feedback"]')
      .doesNotExist('No error message initially');
    assert.dom('[data-test-textarea]').doesNotHaveAttribute('aria-invalid');

    // Add errors
    errors.current = {
      description: ['Description must be at least 10 characters']
    };
    await settled();

    // Check errors are displayed
    assert
      .dom('[data-component="form-feedback"]')
      .exists('Error message is displayed');
    assert
      .dom('[data-component="form-feedback"]')
      .hasText('Description must be at least 10 characters');
    assert.dom('[data-test-textarea]').hasAttribute('aria-invalid', 'true');
  });

  test('it passes field name to yielded components', async function (assert) {
    await render(
      <template>
        <Field @name="myFieldName" as |field|>
          <field.Input @label="Test" data-test-input />
          <field.Checkbox @label="Check" data-test-checkbox />
          <field.Textarea @label="Text" data-test-textarea />
        </Field>
      </template>
    );

    assert
      .dom('[data-test-input]')
      .hasAttribute('name', 'myFieldName', 'Input has correct name');
    assert
      .dom('[data-test-checkbox]')
      .hasAttribute('name', 'myFieldName', 'Checkbox has correct name');
    assert
      .dom('[data-test-textarea]')
      .hasAttribute('name', 'myFieldName', 'Textarea has correct name');
  });

  test('it passes errors only for the specific field', async function (assert) {
    const errors = cell<FormErrors>({
      field1: ['Error for field1'],
      field2: ['Error for field2']
    });

    await render(
      <template>
        <Field @name="field1" @errors={{errors.current}} as |field|>
          <field.Input @label="Field 1" data-test-field1 />
        </Field>
        <Field @name="field2" @errors={{errors.current}} as |field|>
          <field.Input @label="Field 2" data-test-field2 />
        </Field>
        <Field @name="field3" @errors={{errors.current}} as |field|>
          <field.Input @label="Field 3" data-test-field3 />
        </Field>
      </template>
    );

    // Check that each field only shows its own errors
    const feedbacks = document.querySelectorAll(
      '[data-component="form-feedback"]'
    );
    assert.equal(feedbacks.length, 2, 'Only fields with errors show feedback');

    // Field 1 has its error
    assert.dom('[data-test-field1]').hasAttribute('aria-invalid', 'true');
    assert.equal(
      feedbacks[0]?.textContent?.trim(),
      'Error for field1',
      'First error is for field1'
    );

    // Field 2 has its error
    assert.dom('[data-test-field2]').hasAttribute('aria-invalid', 'true');
    assert.equal(
      feedbacks[1]?.textContent?.trim(),
      'Error for field2',
      'Second error is for field2'
    );

    // Field 3 has no error
    assert.dom('[data-test-field3]').doesNotHaveAttribute('aria-invalid');
  });

  test('it handles multiple yielded components in the same field', async function (assert) {
    const inputValue = cell('');
    const checkboxValue = cell(false);
    const errors = cell<FormErrors>({});

    const onInput = (val: string) => {
      inputValue.current = val;
    };
    const onCheckboxChange = (val: boolean) => {
      checkboxValue.current = val;
    };

    await render(
      <template>
        <Field @name="multiField" @errors={{errors.current}} as |field|>
          <field.Input
            @label="Input in field"
            @value={{inputValue.current}}
            @onInput={{onInput}}
            data-test-input
          />
          <field.Checkbox
            @label="Checkbox in field"
            @checked={{checkboxValue.current}}
            @onChange={{onCheckboxChange}}
            data-test-checkbox
          />
        </Field>
      </template>
    );

    // Both components are rendered
    assert.dom('[data-test-input]').exists('Input is rendered');
    assert.dom('[data-test-checkbox]').exists('Checkbox is rendered');

    // Both have the same field name
    assert.dom('[data-test-input]').hasAttribute('name', 'multiField');
    assert.dom('[data-test-checkbox]').hasAttribute('name', 'multiField');

    // Add errors - both components should show errors
    errors.current = { multiField: ['Field error'] };
    await settled();

    assert.dom('[data-test-input]').hasAttribute('aria-invalid', 'true');
    assert.dom('[data-test-checkbox]').hasAttribute('aria-invalid', 'true');

    const feedbacks = document.querySelectorAll(
      '[data-component="form-feedback"]'
    );
    assert.equal(feedbacks.length, 2, 'Both components show error feedback');
  });

  /**
   * When formData is provided to Field, it should set the initial values
   * of yielded components based on the field name from formData.
   */
  test('it fills initial data from formData', async function (assert) {
    assert.expect(2);

    const formData = {
      field1: 'Initial value',
      field2: true
    };

    await render(
      <template>
        <Field @name="field1" @formData={{formData}} as |field|>
          <field.Input @label="Input in field" />
        </Field>
        <Field @name="field2" @formData={{formData}} as |field|>
          <field.Checkbox @label="Checkbox in field" />
        </Field>
      </template>
    );

    // Check initial values
    assert
      .dom('[name="field1"]')
      .hasValue('Initial value', 'Input has initial value');
    assert.dom('[name="field2"]').isChecked('Checkbox is checked');
  });

  /**
   * When formData changes mid-lifecycle, Field should reactively update
   * the bound values in the yielded components.
   */
  test('it reactively updates when formData changes', async function (assert) {
    assert.expect(4);

    class Model {
      @tracked formData = {
        username: 'john',
        email: 'john@example.com',
        isActive: true
      };
    }
    const model = new Model();

    await render(
      <template>
        <Field @name="username" @formData={{model.formData}} as |field|>
          <field.Input @label="Username" />
        </Field>
        <Field @name="email" @formData={{model.formData}} as |field|>
          <field.Input @label="Email" />
        </Field>
        <Field @name="isActive" @formData={{model.formData}} as |field|>
          <field.Checkbox @label="Active" />
        </Field>
      </template>
    );

    // Check initial values
    assert.dom('[name="username"]').hasValue('john');
    assert.dom('[name="email"]').hasValue('john@example.com');

    // Change formData
    model.formData = {
      username: 'jane',
      email: 'jane@example.com',
      isActive: false
    };
    await settled();

    // Check updated values
    assert.dom('[name="username"]').hasValue('jane');
    assert.dom('[name="email"]').hasValue('jane@example.com');
  });
});
