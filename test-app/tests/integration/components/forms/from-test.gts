import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import {
  render,
  click,
  fillIn,
  settled,
  triggerEvent,
  triggerKeyEvent
} from '@ember/test-helpers';
import { selectOptionByKey } from '@frontile/forms/test-support';

import { tracked } from '@glimmer/tracking';
import {
  Form,
  Input,
  Checkbox,
  RadioGroup,
  Textarea,
  NativeSelect,
  Select,
  type FormDataCompiled,
  type FormResultData,
  type CustomValidatorReturn
} from '@frontile/forms';
import { cell } from 'ember-resources';
import * as v from 'valibot';
import sinon from 'sinon';

module('Integration | Component | @frontile/forms/Form', function (hooks) {
  setupRenderingTest(hooks);

  const inputData = cell<FormDataCompiled>();
  const submitData = cell<FormDataCompiled>();
  const onChange = (data: FormResultData, _event: Event) => {
    inputData.current = data['data'];
  };

  const onSubmit = async (data: FormResultData, _event: SubmitEvent) => {
    submitData.current = data['data'];
  };

  const countries = ['Argentina', 'Brazil', 'Chile', 'United States'];

  hooks.beforeEach(async function () {
    await render(
      <template>
        <Form data-test-form @onChange={{onChange}} @onSubmit={{onSubmit}}>
          <Input @name="firstName" />
          <Checkbox @name="acceptTerms" />
          <RadioGroup @name="interests" as |Radio|>
            <Radio @label="Music" @value="music" />
            <Radio @label="IoT" @value="iot" />
          </RadioGroup>
          <Textarea @name="bio" />
          <NativeSelect @name="country" @items={{countries}} />

          <Select
            @name="traveledTo"
            @items={{countries}}
            @selectionMode="multiple"
          />
          <button type="submit">Submit</button>
        </Form>
      </template>
    );
  });

  test('it updates data as oninput event happens', async function (assert) {
    await fillIn('[name="firstName"]', 'John');
    assert.equal(inputData.current['firstName'], 'John');

    await fillIn('[name="bio"]', 'My bio');
    assert.equal(inputData.current['bio'], 'My bio');

    await click('[name="acceptTerms"]');
    assert.equal(inputData.current['acceptTerms'], true);

    await click('[value="music"]');
    assert.equal(inputData.current['interests'], 'music');

    await selectNativeOptionByKey('[name="country"]', 'Brazil');
    assert.equal(inputData.current['country'], 'Brazil');

    await click('[data-component="select-trigger"]');
    await click('[data-component="listbox"] [data-key="Chile"]');
    await click('[data-component="listbox"] [data-key="Argentina"]');
    assert.deepEqual(inputData.current['traveledTo'], ['Argentina', 'Chile']);
  });

  test('it updates data on submit event', async function (assert) {
    await fillIn('[name="firstName"]', 'John');
    await click('[name="acceptTerms"]');
    await click('[value="music"]');
    await fillIn('[name="bio"]', 'My bio');
    await selectNativeOptionByKey('[name="country"]', 'Brazil');

    await click('[data-component="select-trigger"]');
    await click('[data-component="listbox"] [data-key="Chile"]');
    await click('[data-component="listbox"] [data-key="Argentina"]');
    await triggerKeyEvent('[data-component="listbox"]', 'keydown', 'Escape'); // Close the select

    assert.equal(submitData.current, undefined);
    await click('[data-test-form] button[type="submit"]');

    assert.deepEqual(submitData.current, {
      firstName: 'John',
      acceptTerms: true,
      interests: 'music',
      bio: 'My bio',
      country: 'Brazil',
      traveledTo: ['Argentina', 'Chile']
    });
  });

  test('it yields isLoading state during form submission', async function (assert) {
    assert.expect(4);

    let resolveSubmit!: () => void;
    const onSubmitWithDelay = () =>
      new Promise<void>((resolve) => {
        resolveSubmit = resolve;
      });

    await render(
      <template>
        <Form data-test-form @onSubmit={{onSubmitWithDelay}} as |form|>
          <button type="submit" disabled={{form.isLoading}} data-test-submit>
            {{if form.isLoading "Submitting..." "Submit"}}
          </button>
        </Form>
      </template>
    );

    assert.dom('[data-test-submit]').isNotDisabled();

    const submission = click('[data-test-submit]');

    // Wait for tracked state to flush to the DOM.
    await settled();

    assert.dom('[data-test-submit]').isDisabled();
    assert.dom('[data-test-submit]').hasText('Submitting...');

    resolveSubmit();

    await submission;
    await settled();

    assert.dom('[data-test-submit]').isNotDisabled();
  });

  /**
   * - Form validation using a @schema works automatically
   * 2. When validation fails, error messages are displayed for both email and
   *    password fields
   * 3. onSubmit is not called when validation fails
   * 4. When valid data is submitted, error messages are cleared and onSubmit
   *    is called with the correct data
   */
  test('it validates form using schema with submitted form data and prevents submission on validation errors', async function (assert) {
    assert.expect(10);

    const schema = v.object({
      email: v.pipe(v.string(), v.email('Invalid email address')),
      password: v.pipe(
        v.string(),
        v.minLength(6, 'Password must be at least 6 characters')
      ),
      country: v.pipe(
        v.fallback(v.string(), ''),
        v.string(),
        v.check(
          (val) => val !== undefined && val !== '',
          'Please select a country'
        )
      ),
      favoriteColor: v.pipe(
        v.fallback(v.string(), ''),
        v.string(),
        v.check((val) => val === 'taupe', 'The correct answer is taupe')
      ),
      terms: v.pipe(
        v.boolean(),
        v.check((val) => val === true, 'You must accept the terms')
      )
    });

    const onSubmitSpy = sinon.spy();
    const countries = [
      { label: 'Brazil', key: 'brazil' },
      { label: 'Canada', key: 'canada' },
      { label: 'United States', key: 'us' }
    ];

    await render(
      <template>
        <Form @schema={{schema}} @onSubmit={{onSubmitSpy}} as |form|>
          <form.Field @name="email" as |field|>
            <field.Input data-test-email />
          </form.Field>

          <form.Field @name="password" as |field|>
            <field.Input @type="password" data-test-password />
          </form.Field>

          <form.Field @name="country" as |field|>
            <field.SingleSelect
              @items={{countries}}
              @allowEmpty={{true}}
              @placeholder="Select a country"
              data-test-country
            />
          </form.Field>

          <form.Field @name="favoriteColor" as |field|>
            <field.RadioGroup data-test-favorite-color as |Radio|>
              <Radio @label="Taupe" @value="taupe" />
              <Radio @label="Mauve" @value="mauve" />
              <Radio @label="Celadon" @value="celadon" />
              <Radio @label="Puce" @value="puce" />
            </field.RadioGroup>
          </form.Field>

          <form.Field @name="terms" as |field|>
            <field.Checkbox @label="I accept the terms" data-test-terms />
          </form.Field>

          <button type="submit" data-test-submit>Submit</button>
        </Form>
      </template>
    );

    // Submit with invalid data
    await fillIn('[data-test-email]', 'invalid-email');
    await fillIn('[data-test-password]', 'abc');
    await click('[data-test-submit]');

    // onSubmit should not be called due to validation errors
    assert.ok(onSubmitSpy.notCalled, 'onSubmit should not be called');

    // Verify error messages are displayed
    const feedbackElements = document.querySelectorAll(
      '[data-component="form-feedback"]'
    );
    assert.equal(
      feedbackElements.length,
      5,
      'Five error messages are displayed'
    );
    assert.ok(
      Array.from(feedbackElements).some((el) =>
        el.textContent?.includes('Invalid email address')
      ),
      'Email error message is displayed'
    );
    assert.ok(
      Array.from(feedbackElements).some((el) =>
        el.textContent?.includes('Password must be at least 6 characters')
      ),
      'Password error message is displayed'
    );
    assert.ok(
      Array.from(feedbackElements).some((el) =>
        el.textContent?.includes('Please select a country')
      ),
      'Country error message is displayed'
    );
    assert.ok(
      Array.from(feedbackElements).some((el) =>
        el.textContent?.includes('You must accept the terms')
      ),
      'Terms error message is displayed'
    );
    assert.ok(
      Array.from(feedbackElements).some((el) =>
        el.textContent?.includes('The correct answer is taupe')
      ),
      'Favorite color error message is displayed'
    );

    // Submit with valid data
    await fillIn('[data-test-email]', 'test@example.com');
    await fillIn('[data-test-password]', 'password123');
    await selectOptionByKey('[data-test-country]', 'canada');
    await click('[data-test-favorite-color] [value="taupe"]');
    await click('[data-test-terms]');
    await click('[data-test-submit]');

    // Verify error messages are cleared
    assert
      .dom('[data-component="form-feedback"]')
      .doesNotExist('Error messages are cleared');

    // onSubmit should be called with valid data
    assert.ok(onSubmitSpy.calledOnce, 'onSubmit should be called once');
    assert.deepEqual(
      onSubmitSpy.firstCall.args[0].data,
      {
        email: 'test@example.com',
        password: 'password123',
        country: 'canada',
        favoriteColor: 'taupe',
        terms: true
      },
      'onSubmit should be called with correct data'
    );
  });

  /**
   * Test that Form validates against a custom validator function
   * 1. Custom validator runs on form submission
   * 2. When validation fails, error messages from custom validator are displayed
   * 3. onSubmit is not called when custom validation fails
   * 4. When valid data is submitted, error messages are cleared and onSubmit is called
   */
  test('it validates form using custom validator function', async function (assert) {
    assert.expect(6);

    // Custom validator that checks if password matches confirmPassword
    const customValidator = (data: FormDataCompiled): CustomValidatorReturn => {
      const issues = [];
      if (data['password'] !== data['confirmPassword']) {
        issues.push({
          message: 'Passwords do not match',
          path: [{ key: 'confirmPassword' }]
        });
      }
      if (
        data['username'] &&
        (data['username'] as string).toLowerCase() === 'admin'
      ) {
        issues.push({
          message: 'Username "admin" is reserved',
          path: [{ key: 'username' }]
        });
      }
      return issues.length > 0 ? issues : undefined;
    };

    const onSubmitSpy = sinon.spy();

    await render(
      <template>
        <Form @validate={{customValidator}} @onSubmit={{onSubmitSpy}} as |form|>
          <form.Field @name="username" as |field|>
            <field.Input data-test-username />
          </form.Field>

          <form.Field @name="password" as |field|>
            <field.Input @type="password" data-test-password />
          </form.Field>

          <form.Field @name="confirmPassword" as |field|>
            <field.Input @type="password" data-test-confirm-password />
          </form.Field>

          <button type="submit" data-test-submit>Submit</button>
        </Form>
      </template>
    );

    // Submit with invalid data (mismatched passwords and reserved username)
    await fillIn('[data-test-username]', 'admin');
    await fillIn('[data-test-password]', 'password123');
    await fillIn('[data-test-confirm-password]', 'password456');
    await click('[data-test-submit]');

    // onSubmit should not be called due to validation errors
    assert.ok(onSubmitSpy.notCalled, 'onSubmit should not be called');

    // Verify error messages are displayed
    const feedbackElements = document.querySelectorAll(
      '[data-component="form-feedback"]'
    );
    assert.equal(
      feedbackElements.length,
      2,
      'Two error messages are displayed'
    );
    assert.ok(
      Array.from(feedbackElements).some((el) =>
        el.textContent?.includes('Passwords do not match')
      ),
      'Password mismatch error message is displayed'
    );
    assert.ok(
      Array.from(feedbackElements).some((el) =>
        el.textContent?.includes('Username "admin" is reserved')
      ),
      'Reserved username error message is displayed'
    );

    // Submit with valid data
    await fillIn('[data-test-username]', 'john');
    await fillIn('[data-test-password]', 'password123');
    await fillIn('[data-test-confirm-password]', 'password123');
    await click('[data-test-submit]');

    // Verify error messages are cleared
    assert
      .dom('[data-component="form-feedback"]')
      .doesNotExist('Error messages are cleared');

    // onSubmit should be called with valid data
    assert.ok(onSubmitSpy.calledOnce, 'onSubmit should be called once');
  });

  /**
   * Test that Form can validate using both a schema and a custom validator function
   * 1. Schema validation runs first
   * 2. Custom validator runs after schema validation
   * 3. Both validation errors are displayed when both fail
   * 4. onSubmit is not called when either validation fails
   * 5. When valid data is submitted, both validations pass and onSubmit is called
   */
  test('it validates form using both schema and custom validator function', async function (assert) {
    assert.expect(11);

    const schema = v.object({
      email: v.pipe(v.string(), v.email('Invalid email address')),
      password: v.pipe(
        v.string(),
        v.minLength(6, 'Password must be at least 6 characters')
      ),
      confirmPassword: v.pipe(v.string(), v.minLength(1))
    });

    // Custom validator that checks if password matches confirmPassword
    const customValidator = (data: FormDataCompiled): CustomValidatorReturn => {
      const issues = [];
      if (data['password'] !== data['confirmPassword']) {
        issues.push({
          message: 'Passwords do not match',
          path: [{ key: 'confirmPassword' }]
        });
      }
      return issues.length > 0 ? issues : undefined;
    };

    const onSubmitSpy = sinon.spy();

    await render(
      <template>
        <Form
          @schema={{schema}}
          @validate={{customValidator}}
          @onSubmit={{onSubmitSpy}}
          as |form|
        >
          <form.Field @name="email" as |field|>
            <field.Input data-test-email />
          </form.Field>

          <form.Field @name="password" as |field|>
            <field.Input @type="password" data-test-password />
          </form.Field>

          <form.Field @name="confirmPassword" as |field|>
            <field.Input @type="password" data-test-confirm-password />
          </form.Field>

          <button type="submit" data-test-submit>Submit</button>
        </Form>
      </template>
    );

    // Submit with invalid data (both schema and custom validator should fail)
    await fillIn('[data-test-email]', 'invalid-email');
    await fillIn('[data-test-password]', 'abc');
    await fillIn('[data-test-confirm-password]', 'xyz');
    await click('[data-test-submit]');

    // onSubmit should not be called due to validation errors
    assert.ok(onSubmitSpy.notCalled, 'onSubmit should not be called');

    // Verify both schema and custom validator errors are displayed (3 total: 2 schema + 1 custom)
    let feedbackElements = document.querySelectorAll(
      '[data-component="form-feedback"]'
    );
    assert.equal(
      feedbackElements.length,
      3,
      'Three error messages are displayed (2 schema errors + 1 custom validator error)'
    );
    assert.ok(
      Array.from(feedbackElements).some((el) =>
        el.textContent?.includes('Invalid email address')
      ),
      'Email error message is displayed'
    );
    assert.ok(
      Array.from(feedbackElements).some((el) =>
        el.textContent?.includes('Password must be at least 6 characters')
      ),
      'Password error message is displayed'
    );
    assert.ok(
      Array.from(feedbackElements).some((el) =>
        el.textContent?.includes('Passwords do not match')
      ),
      'Password mismatch error message is displayed'
    );

    // Submit with valid schema but invalid custom validator
    await fillIn('[data-test-email]', 'test@example.com');
    await fillIn('[data-test-password]', 'password123');
    await fillIn('[data-test-confirm-password]', 'password456');
    await click('[data-test-submit]');

    // onSubmit should not be called due to custom validation error
    assert.ok(onSubmitSpy.notCalled, 'onSubmit should not be called');

    // Verify custom validator error is displayed
    feedbackElements = document.querySelectorAll(
      '[data-component="form-feedback"]'
    );
    assert.equal(
      feedbackElements.length,
      1,
      'One error message is displayed (custom validator error)'
    );
    assert.ok(
      Array.from(feedbackElements).some((el) =>
        el.textContent?.includes('Passwords do not match')
      ),
      'Password mismatch error message is displayed'
    );

    // Submit with valid data (both schema and custom validator should pass)
    await fillIn('[data-test-email]', 'test@example.com');
    await fillIn('[data-test-password]', 'password123');
    await fillIn('[data-test-confirm-password]', 'password123');
    await click('[data-test-submit]');

    // Verify error messages are cleared
    assert
      .dom('[data-component="form-feedback"]')
      .doesNotExist('Error messages are cleared');

    // onSubmit should be called with valid data
    assert.ok(onSubmitSpy.calledOnce, 'onSubmit should be called once');
    assert.deepEqual(
      onSubmitSpy.firstCall.args[0].data,
      {
        email: 'test@example.com',
        password: 'password123',
        confirmPassword: 'password123'
      },
      'onSubmit should be called with correct data'
    );
  });

  /**
   * Test that Form can submit successfully without any validation
   * 1. Form with neither schema nor custom validator allows submission
   * 2. onSubmit is called with the form data
   * 3. No validation errors are displayed
   */
  test('it submits form with neither schema nor custom validator', async function (assert) {
    assert.expect(2);

    const onSubmitSpy = sinon.spy();

    await render(
      <template>
        <Form @onSubmit={{onSubmitSpy}} as |form|>
          <form.Field @name="username" as |field|>
            <field.Input data-test-username />
          </form.Field>

          <form.Field @name="email" as |field|>
            <field.Input data-test-email />
          </form.Field>

          <button type="submit" data-test-submit>Submit</button>
        </Form>
      </template>
    );

    // Fill in form data and submit
    await fillIn('[data-test-username]', 'john');
    await fillIn('[data-test-email]', 'not-even-a-valid-email');
    await click('[data-test-submit]');

    // onSubmit should be called with the data (no validation)
    assert.ok(onSubmitSpy.calledOnce, 'onSubmit should be called once');
    assert.deepEqual(
      onSubmitSpy.firstCall.args[0].data,
      {
        username: 'john',
        email: 'not-even-a-valid-email'
      },
      'onSubmit should be called with the form data'
    );
  });

  /**
   * Test that Form calls onError handler when validation fails
   * 1. onError is called with validation errors when form submission fails validation
   * 2. onError receives the correct error object, form data, and event
   * 3. onSubmit is not called when validation fails
   * 4. When valid data is submitted, onError is not called
   */
  test('it calls onError handler when validation fails', async function (assert) {
    assert.expect(7);

    const schema = v.object({
      email: v.pipe(v.string(), v.email('Invalid email address')),
      password: v.pipe(
        v.string(),
        v.minLength(6, 'Password must be at least 6 characters')
      )
    });

    const onSubmitSpy = sinon.spy();
    const onErrorSpy = sinon.spy();

    await render(
      <template>
        <Form
          @schema={{schema}}
          @onSubmit={{onSubmitSpy}}
          @onError={{onErrorSpy}}
          as |form|
        >
          <form.Field @name="email" as |field|>
            <field.Input data-test-email />
          </form.Field>

          <form.Field @name="password" as |field|>
            <field.Input @type="password" data-test-password />
          </form.Field>

          <button type="submit" data-test-submit>Submit</button>
        </Form>
      </template>
    );

    // Submit with invalid data
    await fillIn('[data-test-email]', 'invalid-email');
    await fillIn('[data-test-password]', 'abc');
    await click('[data-test-submit]');

    // onError should be called with validation errors
    assert.ok(onErrorSpy.calledOnce, 'onError should be called once');
    assert.ok(onSubmitSpy.notCalled, 'onSubmit should not be called');

    // Check the errors object passed to onError
    const errorArg = onErrorSpy.firstCall.args[0];
    assert.ok(errorArg.email, 'Email error should be present');
    assert.equal(
      errorArg.email,
      'Invalid email address',
      'Email error message should match'
    );
    assert.ok(errorArg.password, 'Password error should be present');

    // Submit with valid data
    await fillIn('[data-test-email]', 'test@example.com');
    await fillIn('[data-test-password]', 'password123');
    await click('[data-test-submit]');

    // onError should not be called again, onSubmit should be called
    assert.ok(
      onErrorSpy.calledOnce,
      'onError should still be called only once'
    );
    assert.ok(onSubmitSpy.calledOnce, 'onSubmit should be called once');
  });

  /**
   * Test that Form handles async onError handler
   */
  test('it handles async onError handler', async function (assert) {
    assert.expect(3);

    const schema = v.object({
      email: v.pipe(v.string(), v.email('Invalid email'))
    });

    let resolveError!: () => void;
    const onErrorWithDelay = () =>
      new Promise<void>((resolve) => {
        resolveError = resolve;
      });

    const noop = () => {};

    await render(
      <template>
        <Form
          @schema={{schema}}
          @onError={{onErrorWithDelay}}
          @onSubmit={{noop}}
          as |form|
        >
          <button type="submit" disabled={{form.isLoading}} data-test-submit>
            {{if form.isLoading "Processing..." "Submit"}}
          </button>
        </Form>
      </template>
    );

    assert.dom('[data-test-submit]').isNotDisabled();

    const submission = click('[data-test-submit]');

    // Wait for tracked state to flush to the DOM
    await settled();

    assert.dom('[data-test-submit]').isDisabled();

    resolveError();
    await submission;
    await settled();

    assert.dom('[data-test-submit]').isNotDisabled();
  });

  /**
   * When data is provided to Form, it should set the initial values
   * of yielded components based on the field name from formData.
   */
  test('it fills initial data from data', async function (assert) {
    assert.expect(2);

    const formData = {
      field1: 'Initial value',
      field2: true
    };

    const noop = () => {};

    await render(
      <template>
        <Form @data={{formData}} @onSubmit={{noop}} as |form|>
          <form.Field @name="field1" as |field|>
            <field.Input />
          </form.Field>

          <form.Field @name="field2" as |field|>
            <field.Checkbox />
          </form.Field>

          <button type="submit" data-test-submit>Submit</button>
        </Form>
      </template>
    );

    assert
      .dom('[name="field1"]')
      .hasValue('Initial value', 'Input has initial value');
    assert.dom('[name="field2"]').isChecked('Checkbox is checked');
  });

  test('it reflects changes in the bound form data', async function (assert) {
    assert.expect(4);
    class Model {
      @tracked formData = { username: 'john', email: 'john@example.com' };
    }
    const model = new Model();
    const noop = () => {};

    await render(
      <template>
        <Form
          @data={{model.formData}}
          @onChange={{noop}}
          @onSubmit={{noop}}
          as |form|
        >
          <form.Field @name="username" as |field|>
            <field.Input />
          </form.Field>

          <form.Field @name="email" as |field|>
            <field.Input />
          </form.Field>
        </Form>
      </template>
    );

    assert.dom('[name="username"]').hasValue('john');
    assert.dom('[name="email"]').hasValue('john@example.com');

    model.formData = { username: 'jane', email: 'jane@example.com' };
    await settled();

    assert.dom('[name="username"]').hasValue('jane');
    assert.dom('[name="email"]').hasValue('jane@example.com');
  });

  test('it passes a `dirty` field when the form changes', async function (assert) {
    assert.expect(4);
    class Model {
      @tracked formData = { username: 'john', email: 'john@example.com' };
    }
    const model = new Model();
    const noop = () => {};

    let changeCount = 0;
    const onChange = (
      result: FormResultData<{ username: string; email: string }>,
      _event: Event
    ) => {
      changeCount++;
      if (changeCount === 1) {
        // After first change (username)
        assert.ok(result.dirty.has('username'), 'dirty contains username');
        assert.false(result.dirty.has('email'), 'dirty does not contain email');
      } else if (changeCount === 2) {
        // After second change (email)
        assert.ok(
          result.dirty.has('username'),
          'dirty still contains username'
        );
        assert.ok(result.dirty.has('email'), 'dirty now contains email');
      }
    };

    await render(
      <template>
        <Form
          @data={{model.formData}}
          @onChange={{onChange}}
          @onSubmit={{noop}}
          as |form|
        >
          <form.Field @name="username" as |field|>
            <field.Input />
          </form.Field>

          <form.Field @name="email" as |field|>
            <field.Input />
          </form.Field>
        </Form>
      </template>
    );

    // Change username field
    await fillIn('[name="username"]', 'jane');

    // Change email field
    await fillIn('[name="email"]', 'jane@example.com');
  });
});

function selectNativeOptionByKey(
  selectSelector: string,
  key: string
): Promise<void> {
  return changeOption('selectNativeOptionByKey', selectSelector, key, false);
}

async function changeOption(
  functionName: string,
  selectSelector: string,
  key: string,
  toggle: boolean
): Promise<void> {
  const select = document.querySelector(selectSelector);
  if (!select) {
    throw new Error(
      `You called "${functionName}('${selectSelector}', '${key}')" but no select was found using selector "${selectSelector}"`
    );
  }
  const option = select.querySelector(`[data-key="${key}"]`) as
    | HTMLOptionElement
    | undefined;
  if (!option) {
    throw new Error(
      `You called "${functionName}('${selectSelector}', '${key}')" but no option with key "${key}" was found`
    );
  }
  if (option.selected && toggle) {
    option.selected = false;
  } else {
    option.selected = true;
  }
  await triggerEvent(select, 'change');

  let parent = select.parentElement;
  while (parent) {
    if (parent.tagName === 'FORM') {
      await triggerEvent(parent, 'input');
      break;
    }
    parent = parent.parentElement;
  }
}
