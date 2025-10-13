import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import {
  render,
  fillIn,
  click,
  settled,
  triggerEvent
} from '@ember/test-helpers';
import { selectOptionByKey } from '@frontile/forms/test-support';
import { tracked } from '@glimmer/tracking';
import { Field, Form } from '@frontile/forms';
import { cell } from 'ember-resources';
import type { FormErrors } from '@frontile/forms';
import * as v from 'valibot';
import sinon from 'sinon';
import { array } from '@ember/helper';

const noop = () => {};

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

  /**
   * Test that Field respects the @disabled argument
   * When disabled, all yielded components should be disabled
   */
  test('it disables yielded components when @disabled={{true}}', async function (assert) {
    assert.expect(8);

    class Model {
      @tracked isDisabled = false;
    }
    const model = new Model();

    const items = ['Option 1', 'Option 2'];

    await render(
      <template>
        <Field @name="input" @disabled={{model.isDisabled}} as |field|>
          <field.Input @label="Input Field" data-test-input />
        </Field>

        <Field @name="checkbox" @disabled={{model.isDisabled}} as |field|>
          <field.Checkbox @label="Checkbox Field" data-test-checkbox />
        </Field>

        <Field @name="select" @disabled={{model.isDisabled}} as |field|>
          <field.SingleSelect
            @label="Select Field"
            @items={{items}}
            data-test-select
          />
        </Field>

        <Field @name="textarea" @disabled={{model.isDisabled}} as |field|>
          <field.Textarea @label="Textarea Field" data-test-textarea />
        </Field>
      </template>
    );

    // Initially not disabled
    assert.dom('[data-test-input]').isNotDisabled('Input is not disabled');
    assert
      .dom('[data-test-checkbox]')
      .isNotDisabled('Checkbox is not disabled');
    assert
      .dom('[data-component="select-trigger"]')
      .isNotDisabled('Select is not disabled');
    assert
      .dom('[data-test-textarea]')
      .isNotDisabled('Textarea is not disabled');

    // Enable disabled state
    model.isDisabled = true;
    await settled();

    // Now all fields should be disabled
    assert.dom('[data-test-input]').isDisabled('Input is disabled');
    assert.dom('[data-test-checkbox]').isDisabled('Checkbox is disabled');
    assert
      .dom('[data-component="select-trigger"]')
      .isDisabled('Select is disabled');
    assert.dom('[data-test-textarea]').isDisabled('Textarea is disabled');
  });

  /**
   * Test that Field validates on change when @validateOn includes 'change'
   * and @validateField function is provided
   * Note: 'change' event fires on blur, not on every keystroke
   */
  test('it validates field on change when validateOn includes "change"', async function (assert) {
    assert.expect(5);

    const formData = cell({ email: '' });
    const errors = cell<FormErrors>({});
    const validateOnChange: 'change'[] = ['change'];
    let validateCallCount = 0;

    const validateField = async (
      data: typeof formData.current,
      name: string
    ): Promise<FormErrors | undefined> => {
      validateCallCount++;

      // Simple validation: email must contain @
      if (name === 'email' && data.email && !data.email.includes('@')) {
        const fieldErrors = { [name]: 'Invalid email format' };
        errors.current = { ...errors.current, ...fieldErrors };
        return fieldErrors;
      } else if (name === 'email') {
        // Clear error for this field
        const { [name]: _, ...rest } = errors.current;
        errors.current = rest;
      }
      return undefined;
    };

    const onInput = (val: string) => {
      formData.current = { email: val };
    };

    await render(
      <template>
        <Field
          @name="email"
          @formData={{formData.current}}
          @errors={{errors.current}}
          @validateOn={{validateOnChange}}
          @validateField={{validateField}}
          as |field|
        >
          <field.Input
            @label="Email"
            @value={{formData.current.email}}
            @onInput={{onInput}}
            data-test-email
          />
        </Field>
      </template>
    );

    // Initially no errors
    assert
      .dom('[data-component="form-feedback"]')
      .doesNotExist('No errors initially');

    // Type invalid email - fillIn triggers blur
    await fillIn('[data-test-email]', 'invalid');

    // Validation should have been called after blur
    assert.equal(validateCallCount, 1, 'validateField called once after blur');

    // Error should appear
    await settled();
    assert
      .dom('[data-component="form-feedback"]')
      .exists('Error appears after blur');
    assert
      .dom('[data-component="form-feedback"]')
      .hasText('Invalid email format');

    // Fix email - fillIn triggers blur
    await fillIn('[data-test-email]', 'test@example.com');

    // Validation should have been called again after blur
    assert.equal(validateCallCount, 2, 'validateField called twice');
  });

  /**
   * Test that Field does NOT validate on change when @validateOn is empty
   * Even though fillIn triggers blur, validation should not run
   */
  test('it does not validate field on change when validateOn is empty', async function (assert) {
    assert.expect(2);

    const formData = cell({ email: '' });
    const errors = cell<FormErrors>({});
    const emptyValidateOn: 'change'[] = [];
    let validateCallCount = 0;

    const validateField = async (): Promise<FormErrors | undefined> => {
      validateCallCount++;
      return undefined;
    };

    const onInput = (val: string) => {
      formData.current = { email: val };
    };

    await render(
      <template>
        <Field
          @name="email"
          @formData={{formData.current}}
          @errors={{errors.current}}
          @validateOn={{emptyValidateOn}}
          @validateField={{validateField}}
          as |field|
        >
          <field.Input
            @label="Email"
            @value={{formData.current.email}}
            @onInput={{onInput}}
            data-test-email
          />
        </Field>
      </template>
    );

    // Type in the field - fillIn triggers blur but validation should not run
    await fillIn('[data-test-email]', 'test@example.com');

    // Validation should NOT have been called (validateOn is empty)
    assert.equal(
      validateCallCount,
      0,
      'validateField not called when validateOn is empty'
    );

    // No errors should appear
    assert
      .dom('[data-component="form-feedback"]')
      .doesNotExist('No errors when validation is disabled');
  });

  /**
   * Test that Field does NOT validate when @validateField is not provided
   */
  test('it does not validate when validateField is not provided', async function (assert) {
    assert.expect(1);

    const formData = cell({ email: '' });
    const errors = cell<FormErrors>({});
    const validateOnChange: 'change'[] = ['change'];

    const onInput = (val: string) => {
      formData.current = { email: val };
    };

    await render(
      <template>
        <Field
          @name="email"
          @formData={{formData.current}}
          @errors={{errors.current}}
          @validateOn={{validateOnChange}}
          as |field|
        >
          <field.Input
            @label="Email"
            @value={{formData.current.email}}
            @onInput={{onInput}}
            data-test-email
          />
        </Field>
      </template>
    );

    // Type in the field
    await fillIn('[data-test-email]', 'invalid');

    // No errors should appear (no validateField function provided)
    assert
      .dom('[data-component="form-feedback"]')
      .doesNotExist('No errors when validateField is not provided');
  });

  /**
   * Test that Field validates correctly with nested field names
   * Validation should trigger on blur for nested fields too
   */
  test('it validates nested fields on change', async function (assert) {
    assert.expect(3);

    const formData = cell({ user: { email: '' } });
    const errors = cell<FormErrors>({});
    const validateOnChange: 'change'[] = ['change'];
    let validateCallCount = 0;

    const validateField = async (
      data: typeof formData.current,
      name: string
    ): Promise<FormErrors | undefined> => {
      validateCallCount++;

      if (
        name === 'user.email' &&
        data.user.email &&
        !data.user.email.includes('@')
      ) {
        const fieldErrors = { [name]: 'Invalid email' };
        errors.current = { ...errors.current, ...fieldErrors };
        return fieldErrors;
      } else if (name === 'user.email') {
        const { [name]: _, ...rest } = errors.current;
        errors.current = rest;
      }
      return undefined;
    };

    const onInput = (val: string) => {
      formData.current = { user: { email: val } };
    };

    await render(
      <template>
        <Field
          @name="user.email"
          @formData={{formData.current}}
          @errors={{errors.current}}
          @validateOn={{validateOnChange}}
          @validateField={{validateField}}
          as |field|
        >
          <field.Input
            @label="Email"
            @value={{formData.current.user.email}}
            @onInput={{onInput}}
            data-test-email
          />
        </Field>
      </template>
    );

    // Type invalid email - fillIn triggers blur
    await fillIn('[data-test-email]', 'invalid');

    // Validation should have been called with nested field name after blur
    assert.equal(validateCallCount, 1, 'validateField called once after blur');

    // Error should appear
    await settled();
    assert
      .dom('[data-component="form-feedback"]')
      .exists('Error appears for nested field');

    // Fix email - fillIn triggers blur
    await fillIn('[data-test-email]', 'test@example.com');

    // Validation called again after blur
    assert.equal(validateCallCount, 2, 'validateField called twice');
  });

  /**
   * Test that Field respects the HTML disabled attribute
   * This ensures that passing disabled={{true}} as a regular HTML attribute
   * also works correctly (in addition to the @disabled argument)
   */
  test('it disables yielded components when HTML disabled={{true}} attribute is passed', async function (assert) {
    assert.expect(4);

    class Model {
      @tracked isDisabled = false;
    }
    const model = new Model();

    await render(
      <template>
        <Field @name="input" as |field|>
          <field.Input
            @label="Input Field"
            disabled={{model.isDisabled}}
            data-test-input
          />
        </Field>

        <Field @name="checkbox" as |field|>
          <field.Checkbox
            @label="Checkbox Field"
            disabled={{model.isDisabled}}
            data-test-checkbox
          />
        </Field>
      </template>
    );

    // Initially not disabled
    assert
      .dom('[data-test-input]')
      .isNotDisabled('Input is not disabled initially');
    assert
      .dom('[data-test-checkbox]')
      .isNotDisabled('Checkbox is not disabled initially');

    // Enable disabled state via HTML attribute
    model.isDisabled = true;
    await settled();

    // Now fields should be disabled via HTML attribute
    assert
      .dom('[data-test-input]')
      .isDisabled('Input is disabled via HTML attribute');
    assert
      .dom('[data-test-checkbox]')
      .isDisabled('Checkbox is disabled via HTML attribute');
  });

  /**
   * Test that Field can override Form's validateOn setting with 'input'
   * Form validates on submit only, but specific Field validates on input
   */
  test('it allows Field to override Form validateOn with input validation', async function (assert) {
    assert.expect(7);

    const schema = v.object({
      username: v.pipe(v.string(), v.minLength(3, 'Username too short')),
      password: v.pipe(
        v.string(),
        v.minLength(6, 'Password must be at least 6 characters')
      )
    });

    const validateOnSubmit: ('change' | 'input' | 'submit')[] = ['submit'];
    const validateOnInput: ('change' | 'input')[] = ['input'];
    const onSubmitSpy = sinon.spy();

    await render(
      <template>
        <Form
          @schema={{schema}}
          @validateOn={{validateOnSubmit}}
          @onSubmit={{onSubmitSpy}}
          as |form|
        >
          <form.Field @name="username" as |field|>
            {{! This field inherits Form's validateOn=['submit'] }}
            <field.Input data-test-username />
          </form.Field>

          <form.Field
            @name="password"
            @validateOn={{validateOnInput}}
            as |field|
          >
            {{! This field overrides with validateOn=['input'] }}
            <field.Input @type="password" data-test-password />
          </form.Field>

          <button type="submit" data-test-submit>Submit</button>
        </Form>
      </template>
    );

    // Initially no errors
    assert
      .dom('[data-component="form-feedback"]')
      .doesNotExist('No errors initially');

    // Type in username field - should NOT validate (inherits Form's submit-only validation)
    await fillIn('[data-test-username]', 'ab');

    assert
      .dom('[data-component="form-feedback"]')
      .doesNotExist(
        'Username does not validate on input (inherits Form setting)'
      );

    // Type in password field - SHOULD validate on input (Field override)
    await fillIn('[data-test-password]', 'abc');

    assert
      .dom('[data-component="form-feedback"]')
      .exists({ count: 1 }, 'Password validates on input (Field override)');
    assert
      .dom('[data-component="form-feedback"]')
      .hasText('Password must be at least 6 characters');

    // Fix password - error should clear immediately
    await fillIn('[data-test-password]', 'abcdef');

    assert
      .dom('[data-component="form-feedback"]')
      .doesNotExist('Password error clears on input');

    // Submit with invalid username - both fields should now show errors
    await click('[data-test-submit]');

    assert
      .dom('[data-component="form-feedback"]')
      .exists({ count: 1 }, 'Username error appears on submit');
    assert.ok(onSubmitSpy.notCalled, 'onSubmit not called with invalid data');
  });

  /**
   * Test that Field can disable field-level validation by overriding with empty validateOn
   * Form validates on change and submit, but specific Field disables change validation only
   * Note: Submit validation still runs for all fields (form-level validation)
   */
  test('it allows Field to disable field-level validation by overriding with empty validateOn', async function (assert) {
    assert.expect(6);

    const schema = v.object({
      email: v.pipe(v.string(), v.email('Invalid email')),
      notes: v.pipe(v.string(), v.minLength(10, 'Notes too short'))
    });

    const validateOnChange: ('change' | 'input' | 'submit')[] = [
      'change',
      'submit'
    ];
    const emptyValidateOn: ('change' | 'input')[] = [];

    await render(
      <template>
        <Form
          @schema={{schema}}
          @validateOn={{validateOnChange}}
          @onSubmit={{noop}}
          as |form|
        >
          <form.Field @name="email" as |field|>
            {{! This field inherits Form's validateOn=['change', 'submit'] }}
            <field.Input data-test-email />
          </form.Field>

          <form.Field @name="notes" @validateOn={{emptyValidateOn}} as |field|>
            {{! This field overrides with empty array - disables field-level validation }}
            <field.Textarea data-test-notes />
          </form.Field>

          <button type="submit" data-test-submit>Submit</button>
        </Form>
      </template>
    );

    // Initially no errors
    assert
      .dom('[data-component="form-feedback"]')
      .doesNotExist('No errors initially');

    // Type invalid email - should validate on blur (inherits Form setting)
    await fillIn('[data-test-email]', 'invalid');

    assert
      .dom('[data-component="form-feedback"]')
      .exists(
        { count: 1 },
        'Email validates on change (inherits Form setting)'
      );

    // Type invalid notes - should NOT validate on blur (Field override disables change validation)
    await fillIn('[data-test-notes]', 'short');

    assert
      .dom('[data-component="form-feedback"]')
      .exists(
        { count: 1 },
        'Notes does not validate on change (Field override)'
      );

    // Submit - both email and notes should validate (form-level submit validation)
    await click('[data-test-submit]');

    // Both fields show errors on submit (form-level validation runs for all fields)
    assert
      .dom('[data-component="form-feedback"]')
      .exists(
        { count: 2 },
        'Both fields validate on submit (form-level validation)'
      );

    // Fix email - this should clear on change validation
    await fillIn('[data-test-email]', 'test@example.com');
    // Wait for email validation

    // Email error should clear, but notes error persists (no change validation for notes)
    assert
      .dom('[data-component="form-feedback"]')
      .exists(
        { count: 1 },
        'Email error clears on change, notes error persists'
      );

    // Fix notes - this won't clear on change (empty validateOn), need to submit again
    await fillIn('[data-test-notes]', 'This is long enough');
    await click('[data-test-submit]');

    // All errors cleared after successful submit
    assert
      .dom('[data-component="form-feedback"]')
      .doesNotExist('All errors cleared after successful submit');
  });

  /**
   * Test multiple Fields with different validateOn overrides
   * Demonstrates fine-grained control over validation timing per field
   */
  test('it supports multiple Fields with different validateOn overrides', async function (assert) {
    assert.expect(8);

    const schema = v.object({
      username: v.pipe(v.string(), v.minLength(3, 'Username too short')),
      email: v.pipe(v.string(), v.email('Invalid email')),
      password: v.pipe(
        v.string(),
        v.minLength(6, 'Password must be at least 6 characters')
      )
    });

    // Form default: only validate on submit
    const formValidateOn: ('change' | 'input' | 'submit')[] = ['submit'];
    // Override for username: validate on blur
    const usernameValidateOn: ('change' | 'input')[] = ['change'];
    // Override for password: validate on every keystroke
    const passwordValidateOn: ('change' | 'input')[] = ['input'];
    // Email inherits form default (submit only)

    await render(
      <template>
        <Form
          @schema={{schema}}
          @validateOn={{formValidateOn}}
          @onSubmit={{noop}}
          as |form|
        >
          <form.Field
            @name="username"
            @validateOn={{usernameValidateOn}}
            as |field|
          >
            {{! Validates on blur }}
            <field.Input data-test-username />
          </form.Field>

          <form.Field @name="email" as |field|>
            {{! Validates on submit only (inherits) }}
            <field.Input data-test-email />
          </form.Field>

          <form.Field
            @name="password"
            @validateOn={{passwordValidateOn}}
            as |field|
          >
            {{! Validates on every keystroke }}
            <field.Input @type="password" data-test-password />
          </form.Field>

          <button type="submit" data-test-submit>Submit</button>
        </Form>
      </template>
    );

    // Initially no errors
    assert
      .dom('[data-component="form-feedback"]')
      .doesNotExist('No errors initially');

    // Type invalid password - validates on input
    await fillIn('[data-test-password]', 'abc');

    assert
      .dom('[data-component="form-feedback"]')
      .exists({ count: 1 }, 'Password error appears on input');

    // Type invalid username - validates on blur
    await fillIn('[data-test-username]', 'ab');

    assert
      .dom('[data-component="form-feedback"]')
      .exists({ count: 2 }, 'Username error appears on blur');

    // Type invalid email - does NOT validate (submit only)
    await fillIn('[data-test-email]', 'invalid');

    assert
      .dom('[data-component="form-feedback"]')
      .exists({ count: 2 }, 'Email does not validate yet (submit only)');

    // Fix password - error clears on input
    await fillIn('[data-test-password]', 'abcdef');

    assert
      .dom('[data-component="form-feedback"]')
      .exists({ count: 1 }, 'Password error clears on input');

    // Fix username - error clears on blur
    await fillIn('[data-test-username]', 'john');

    assert
      .dom('[data-component="form-feedback"]')
      .doesNotExist('Username error clears on blur');

    // Submit - email validation should now run
    await click('[data-test-submit]');

    assert
      .dom('[data-component="form-feedback"]')
      .exists({ count: 1 }, 'Email error appears on submit');

    // Fix email
    await fillIn('[data-test-email]', 'john@example.com');
    await click('[data-test-submit]');

    assert
      .dom('[data-component="form-feedback"]')
      .doesNotExist('All errors cleared, form submits successfully');
  });

  /**
   * Test that Field validates on input when validateOn includes 'input'
   * Field-level input validation works best within Form context
   */
  test('it validates field on input when validateOn includes "input"', async function (assert) {
    assert.expect(6);

    const schema = v.object({
      password: v.pipe(
        v.string(),
        v.minLength(6, 'Password must be at least 6 characters')
      )
    });

    // Form has submit-only validation by default
    const formValidateOn: ('change' | 'input' | 'submit')[] = ['submit'];
    // Field overrides with input validation
    const fieldValidateOn: ('change' | 'input')[] = ['input'];
    const noop = () => {};

    await render(
      <template>
        <Form
          @schema={{schema}}
          @validateOn={{formValidateOn}}
          @onSubmit={{noop}}
          as |form|
        >
          <form.Field @name="password" @validateOn={{fieldValidateOn}} as |field|>
            <field.Input @label="Password" @type="password" data-test-password />
          </form.Field>
        </Form>
      </template>
    );

    // Initially no errors
    assert
      .dom('[data-component="form-feedback"]')
      .doesNotExist('No errors initially');

    // Type "a" - should trigger input validation at Field level
    await fillIn('[data-test-password]', 'a');
    await settled();

    // Error should appear after input
    assert
      .dom('[data-component="form-feedback"]')
      .exists('Error appears after input');
    assert
      .dom('[data-component="form-feedback"]')
      .hasText('Password must be at least 6 characters');

    // Type more characters "abc"
    await fillIn('[data-test-password]', 'abc');
    await settled();

    // Error should still be visible
    assert
      .dom('[data-component="form-feedback"]')
      .exists('Error still visible');

    // Type enough to pass validation "abcdef"
    await fillIn('[data-test-password]', 'abcdef');
    await settled();

    // Error should clear
    assert
      .dom('[data-component="form-feedback"]')
      .doesNotExist('Error cleared after typing valid value');

    // Type back to invalid
    await fillIn('[data-test-password]', 'ab');
    await settled();

    // Error should reappear
    assert
      .dom('[data-component="form-feedback"]')
      .exists('Error reappears on input');
  });

  /**
   * Test that Field validates on both input and change when validateOn includes both
   */
  test('it validates field on both input and change when validateOn includes both', async function (assert) {
    assert.expect(5);

    const schema = v.object({
      email: v.pipe(v.string(), v.email('Invalid email format'))
    });

    // Form has submit-only validation
    const formValidateOn: ('change' | 'input' | 'submit')[] = ['submit'];
    // Field overrides with both input and change validation
    const fieldValidateOn: ('change' | 'input')[] = ['input', 'change'];
    const noop = () => {};

    await render(
      <template>
        <Form
          @schema={{schema}}
          @validateOn={{formValidateOn}}
          @onSubmit={{noop}}
          as |form|
        >
          <form.Field @name="email" @validateOn={{fieldValidateOn}} as |field|>
            <field.Input @label="Email" data-test-email />
          </form.Field>
        </Form>
      </template>
    );

    // Initially no errors
    assert
      .dom('[data-component="form-feedback"]')
      .doesNotExist('No errors initially');

    // Type invalid email - should trigger input validation
    await fillIn('[data-test-email]', 'invalid');
    await settled();

    // Error should appear after input
    assert
      .dom('[data-component="form-feedback"]')
      .exists('Error appears after input');

    // Trigger blur (change event) - should also trigger validation
    await triggerEvent('[data-test-email]', 'blur');
    await settled();

    // Error should still be visible (still invalid)
    assert
      .dom('[data-component="form-feedback"]')
      .exists('Error still visible after blur');

    // Fix email
    await fillIn('[data-test-email]', 'test@example.com');
    await settled();

    // Error should clear after input
    assert
      .dom('[data-component="form-feedback"]')
      .doesNotExist('Error cleared after typing valid email');

    // Type invalid again - should show error on input
    await fillIn('[data-test-email]', 'bad');
    await settled();

    // Error should reappear
    assert
      .dom('[data-component="form-feedback"]')
      .exists('Error reappears on input after typing invalid email');
  });

  /**
   * Test that Field explicitly inherits Form validateOn when not specified
   */
  test('it inherits Form validateOn when Field validateOn is not specified', async function (assert) {
    assert.expect(4);

    const schema = v.object({
      username: v.pipe(
        v.string(),
        v.minLength(3, 'Username must be at least 3 characters')
      )
    });

    // Form validates on both input and change
    const formValidateOn: ('change' | 'input' | 'submit')[] = [
      'input',
      'change'
    ];
    const noop = () => {};

    await render(
      <template>
        <Form
          @schema={{schema}}
          @validateOn={{formValidateOn}}
          @onSubmit={{noop}}
          as |form|
        >
          <form.Field @name="username" as |field|>
            {{! Field does not specify @validateOn, should inherit from Form }}
            <field.Input data-test-username />
          </form.Field>
        </Form>
      </template>
    );

    // Initially no errors
    assert
      .dom('[data-component="form-feedback"]')
      .doesNotExist('No errors initially');

    // Type invalid username - should trigger input validation (inherited)
    await fillIn('[data-test-username]', 'ab');

    // Error should appear after input
    assert
      .dom('[data-component="form-feedback"]')
      .exists('Error appears after input (inherited from Form)');

    // Fix username
    await fillIn('[data-test-username]', 'john');

    // Error should clear after input
    assert
      .dom('[data-component="form-feedback"]')
      .doesNotExist('Error cleared after input (inherited from Form)');

    // Type invalid again and blur - should trigger change validation (inherited)
    await fillIn('[data-test-username]', 'ab');

    assert
      .dom('[data-component="form-feedback"]')
      .exists('Error appears on input and persists through blur (inherited)');
  });
});
