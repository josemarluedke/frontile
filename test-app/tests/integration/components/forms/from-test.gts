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
import { on } from '@ember/modifier';
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

  /**
   * Test that Form works in uncontrolled mode (without @onChange)
   * In uncontrolled mode, the form manages its own state internally
   * and only provides data to onSubmit
   */
  test('it works in uncontrolled mode without @onChange', async function (assert) {
    assert.expect(3);

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

    // Fill in form data
    await fillIn('[data-test-username]', 'john');
    await fillIn('[data-test-email]', 'john@example.com');

    // Submit the form
    await click('[data-test-submit]');

    // onSubmit should be called with the uncontrolled form data
    assert.ok(onSubmitSpy.calledOnce, 'onSubmit should be called once');
    assert.deepEqual(
      onSubmitSpy.firstCall.args[0].data,
      {
        username: 'john',
        email: 'john@example.com'
      },
      'onSubmit should be called with correct data'
    );
    assert.ok(
      onSubmitSpy.firstCall.args[0].isValid,
      'Form should be valid (no validation)'
    );
  });

  /**
   * Test that uncontrolled form with initial @data pre-fills fields
   */
  test('it pre-fills fields in uncontrolled mode with initial @data', async function (assert) {
    assert.expect(3);

    const initialData = {
      username: 'jane',
      email: 'jane@example.com'
    };

    const onSubmitSpy = sinon.spy();

    await render(
      <template>
        <Form @data={{initialData}} @onSubmit={{onSubmitSpy}} as |form|>
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

    // Check initial values are set
    assert.dom('[data-test-username]').hasValue('jane');
    assert.dom('[data-test-email]').hasValue('jane@example.com');

    // Submit the form without changes
    await click('[data-test-submit]');

    // onSubmit should be called with initial data
    assert.deepEqual(
      onSubmitSpy.firstCall.args[0].data,
      initialData,
      'onSubmit should be called with initial data'
    );
  });

  /**
   * Test that form.data in yielded context provides access to current form data
   */
  test('it yields form.data with current form data', async function (assert) {
    assert.expect(3);

    class Model {
      @tracked formData = {
        username: 'john',
        notifications: true
      };
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

          <form.Field @name="notifications" as |field|>
            <field.Checkbox />
          </form.Field>

          {{! Display current form data }}
          <div data-test-current-username>{{form.data.username}}</div>
          <div data-test-current-notifications>
            {{if form.data.notifications "yes" "no"}}
          </div>
        </Form>
      </template>
    );

    // Check yielded data reflects initial state
    assert.dom('[data-test-current-username]').hasText('john');
    assert
      .dom('[data-test-current-notifications]')
      .hasText('yes', 'notifications is true');

    // Update external data
    model.formData = {
      username: 'jane',
      notifications: false
    };
    await settled();

    // Check yielded data reflects updated state
    assert.dom('[data-test-current-username]').hasText('jane');
  });

  /**
   * Test that dirty state resets after successful form submission
   */
  test('it resets dirty state after successful submit', async function (assert) {
    assert.expect(4);

    const initialData = {
      username: 'john',
      email: 'john@example.com'
    };

    class Model {
      @tracked formData = { ...initialData };
    }
    const model = new Model();

    const onChange = (
      result: FormResultData<{ username: string; email: string }>
    ) => {
      model.formData = result.data;
    };

    const noop = () => {};

    await render(
      <template>
        <Form
          @data={{model.formData}}
          @onChange={{onChange}}
          @onSubmit={{noop}}
          as |form|
        >
          <form.Field @name="username" as |field|>
            <field.Input data-test-username />
          </form.Field>

          <form.Field @name="email" as |field|>
            <field.Input data-test-email />
          </form.Field>

          <div data-test-dirty-count>{{form.dirty.size}}</div>

          <button type="submit" data-test-submit>Submit</button>
        </Form>
      </template>
    );

    // Initially no dirty fields
    assert.dom('[data-test-dirty-count]').hasText('0');

    // Change a field
    await fillIn('[data-test-username]', 'jane');

    // Should have 1 dirty field
    assert.dom('[data-test-dirty-count]').hasText('1');

    // Change another field
    await fillIn('[data-test-email]', 'jane@example.com');

    // Should have 2 dirty fields
    assert.dom('[data-test-dirty-count]').hasText('2');

    // Submit the form
    await click('[data-test-submit]');

    // After successful submit, dirty state should reset
    assert
      .dom('[data-test-dirty-count]')
      .hasText('0', 'Dirty state resets after submit');
  });

  /**
   * Test that Form.Field correctly binds MultiSelect component
   * This ensures MultiSelect works within the Field abstraction
   */
  test('it works with form.Field yielding MultiSelect', async function (assert) {
    assert.expect(3);

    const schema = v.object({
      tags: v.pipe(
        v.fallback(v.array(v.string()), []),
        v.minLength(1, 'Please select at least 1 tag')
      )
    });

    class Model {
      @tracked formData: { tags: string[] } = {
        tags: ['js', 'ts'] // Start with valid data
      };
    }
    const model = new Model();

    const onChange = (result: FormResultData<{ tags: string[] }>) => {
      model.formData = result.data;
    };

    const onSubmitSpy = sinon.spy();
    const tags = [
      { label: 'JavaScript', key: 'js' },
      { label: 'TypeScript', key: 'ts' },
      { label: 'Python', key: 'python' }
    ];

    await render(
      <template>
        <Form
          @data={{model.formData}}
          @onChange={{onChange}}
          @schema={{schema}}
          @onSubmit={{onSubmitSpy}}
          as |form|
        >
          <form.Field @name="tags" as |field|>
            <field.MultiSelect
              @label="Tags"
              @items={{tags}}
              @selectionMode="multiple"
              data-test-tags
            />
          </form.Field>

          <button type="submit" data-test-submit>Submit</button>
        </Form>
      </template>
    );

    // Verify MultiSelect is rendered and bound with initial data
    assert
      .dom('[data-test-tags]')
      .exists('MultiSelect component is rendered within Field');

    // Submit with initial valid data - should succeed
    await click('[data-test-submit]');

    assert.ok(
      onSubmitSpy.calledOnce,
      'onSubmit should be called with valid data'
    );

    // Verify no validation errors
    assert
      .dom('[data-component="form-feedback"]')
      .doesNotExist('No validation errors with valid data');
  });

  /**
   * Test that Form can be disabled with @disabled={{true}}
   * When disabled, all yielded Field components should also be disabled
   */
  test('it disables all form fields when @disabled={{true}}', async function (assert) {
    assert.expect(7);

    class Model {
      @tracked isDisabled = false;
    }
    const model = new Model();

    const onSubmitSpy = sinon.spy();
    const countries = [
      { label: 'Brazil', key: 'brazil' },
      { label: 'Canada', key: 'canada' }
    ];

    await render(
      <template>
        <Form
          @disabled={{model.isDisabled}}
          @onSubmit={{onSubmitSpy}}
          as |form|
        >
          <form.Field @name="username" as |field|>
            <field.Input @label="Username" data-test-username />
          </form.Field>

          <form.Field @name="email" as |field|>
            <field.Input @label="Email" data-test-email />
          </form.Field>

          <form.Field @name="acceptTerms" as |field|>
            <field.Checkbox @label="Accept Terms" data-test-checkbox />
          </form.Field>

          <form.Field @name="country" as |field|>
            <field.SingleSelect
              @label="Country"
              @items={{countries}}
              data-test-select
            />
          </form.Field>

          <form.Field @name="bio" as |field|>
            <field.Textarea @label="Bio" data-test-textarea />
          </form.Field>

          <button type="submit" data-test-submit>Submit</button>
        </Form>
      </template>
    );

    // Initially, fields should not be disabled
    assert.dom('[data-test-username]').isNotDisabled('Input is not disabled');
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
    assert.dom('[data-test-username]').isDisabled('Input is disabled');
    assert.dom('[data-test-checkbox]').isDisabled('Checkbox is disabled');
    assert
      .dom('[data-component="select-trigger"]')
      .isDisabled('Select is disabled');
  });

  /**
   * Test that disabled form fields properly render as disabled
   * Validation is triggered on submit, not on field changes
   */
  test('it properly disables form fields', async function (assert) {
    assert.expect(1);

    const schema = v.object({
      email: v.pipe(v.string(), v.email('Invalid email address'))
    });

    const onSubmitSpy = sinon.spy();

    await render(
      <template>
        <Form
          @disabled={{true}}
          @schema={{schema}}
          @onSubmit={{onSubmitSpy}}
          as |form|
        >
          <form.Field @name="email" as |field|>
            <field.Input @label="Email" data-test-email />
          </form.Field>

          <button type="submit" data-test-submit>Submit</button>
        </Form>
      </template>
    );

    // Field should be disabled
    assert.dom('[data-test-email]').isDisabled('Input is disabled');
  });

  /**
   * Test that disabled state can be toggled dynamically
   */
  test('it dynamically updates disabled state', async function (assert) {
    assert.expect(4);

    class Model {
      @tracked isDisabled = false;
    }
    const model = new Model();

    const onSubmitSpy = sinon.spy();

    await render(
      <template>
        <Form
          @disabled={{model.isDisabled}}
          @onSubmit={{onSubmitSpy}}
          as |form|
        >
          <form.Field @name="username" as |field|>
            <field.Input @label="Username" data-test-username />
          </form.Field>

          <button type="submit" data-test-submit>Submit</button>
        </Form>
      </template>
    );

    // Initially not disabled
    assert.dom('[data-test-username]').isNotDisabled('Initially not disabled');

    // Disable the form
    model.isDisabled = true;
    await settled();
    assert.dom('[data-test-username]').isDisabled('Form is disabled');

    // Re-enable the form
    model.isDisabled = false;
    await settled();
    assert.dom('[data-test-username]').isNotDisabled('Form is enabled again');

    // Should be able to submit now
    await fillIn('[data-test-username]', 'john');
    await click('[data-test-submit]');
    assert.ok(onSubmitSpy.calledOnce, 'onSubmit is called when enabled');
  });

  /**
   * Test that form reset clears fields to initial values
   */
  test('it resets form fields to initial values', async function (assert) {
    assert.expect(4);

    const initialData = {
      username: 'john',
      email: 'john@example.com'
    };

    class Model {
      @tracked formData = { ...initialData };
    }
    const model = new Model();

    const onChange = (result: FormResultData<typeof initialData>) => {
      model.formData = result.data;
    };

    const onSubmitSpy = sinon.spy();

    await render(
      <template>
        <Form
          @data={{model.formData}}
          @onChange={{onChange}}
          @onSubmit={{onSubmitSpy}}
          as |form|
        >
          <form.Field @name="username" as |field|>
            <field.Input data-test-username />
          </form.Field>

          <form.Field @name="email" as |field|>
            <field.Input data-test-email />
          </form.Field>

          <button type="button" {{on "click" form.reset}} data-test-reset>
            Reset
          </button>
        </Form>
      </template>
    );

    // Verify initial values
    assert.dom('[data-test-username]').hasValue('john');
    assert.dom('[data-test-email]').hasValue('john@example.com');

    // Change values
    await fillIn('[data-test-username]', 'jane');
    await fillIn('[data-test-email]', 'jane@example.com');

    // Reset the form
    await click('[data-test-reset]');

    // Values should be reset to initial values
    assert.dom('[data-test-username]').hasValue('john');
    assert.dom('[data-test-email]').hasValue('john@example.com');
  });

  /**
   * Test that form reset clears validation errors
   */
  test('it clears validation errors on reset', async function (assert) {
    assert.expect(3);

    const schema = v.object({
      email: v.pipe(v.string(), v.email('Invalid email address')),
      password: v.pipe(
        v.string(),
        v.minLength(6, 'Password must be at least 6 characters')
      )
    });

    const initialData = {
      email: 'john@example.com',
      password: 'password123'
    };

    class Model {
      @tracked formData = { ...initialData };
    }
    const model = new Model();

    const onChange = (result: FormResultData<typeof initialData>) => {
      model.formData = result.data;
    };

    const onSubmitSpy = sinon.spy();

    await render(
      <template>
        <Form
          @data={{model.formData}}
          @schema={{schema}}
          @onChange={{onChange}}
          @onSubmit={{onSubmitSpy}}
          as |form|
        >
          <form.Field @name="email" as |field|>
            <field.Input data-test-email />
          </form.Field>

          <form.Field @name="password" as |field|>
            <field.Input @type="password" data-test-password />
          </form.Field>

          <button type="submit" data-test-submit>Submit</button>
          <button type="button" {{on "click" form.reset}} data-test-reset>
            Reset
          </button>
        </Form>
      </template>
    );

    // Enter invalid data
    await fillIn('[data-test-email]', 'invalid-email');
    await fillIn('[data-test-password]', 'abc');

    // Submit to trigger validation
    await click('[data-test-submit]');

    // Errors should be displayed
    assert
      .dom('[data-component="form-feedback"]')
      .exists('Validation errors are displayed');

    // Reset the form
    await click('[data-test-reset]');

    // Errors should be cleared
    assert
      .dom('[data-component="form-feedback"]')
      .doesNotExist('Validation errors are cleared after reset');

    // Values should be reset to initial valid values
    assert.dom('[data-test-email]').hasValue('john@example.com');
  });

  /**
   * Test that form reset clears dirty state
   */
  test('it clears dirty state on reset', async function (assert) {
    assert.expect(4);

    const initialData = {
      username: 'john',
      email: 'john@example.com'
    };

    class Model {
      @tracked formData = { ...initialData };
    }
    const model = new Model();

    const onChange = (result: FormResultData<typeof initialData>) => {
      model.formData = result.data;
    };

    const onSubmitSpy = sinon.spy();

    await render(
      <template>
        <Form
          @data={{model.formData}}
          @onChange={{onChange}}
          @onSubmit={{onSubmitSpy}}
          as |form|
        >
          <form.Field @name="username" as |field|>
            <field.Input data-test-username />
          </form.Field>

          <form.Field @name="email" as |field|>
            <field.Input data-test-email />
          </form.Field>

          <div data-test-dirty-count>{{form.dirty.size}}</div>

          <button type="button" {{on "click" form.reset}} data-test-reset>
            Reset
          </button>
        </Form>
      </template>
    );

    // Initially no dirty fields
    assert.dom('[data-test-dirty-count]').hasText('0');

    // Change values
    await fillIn('[data-test-username]', 'jane');
    await fillIn('[data-test-email]', 'jane@example.com');

    // Should have dirty fields
    assert.dom('[data-test-dirty-count]').hasText('2');

    // Reset the form
    await click('[data-test-reset]');

    // Dirty state should be cleared
    assert.dom('[data-test-dirty-count]').hasText('0');

    // Values should be reset
    assert.dom('[data-test-username]').hasValue('john');
  });

  /**
   * Test that form reset works in uncontrolled mode
   */
  test('it resets form in uncontrolled mode', async function (assert) {
    assert.expect(3);

    const initialData = {
      username: 'john',
      email: 'john@example.com'
    };

    const onSubmitSpy = sinon.spy();

    await render(
      <template>
        <Form @data={{initialData}} @onSubmit={{onSubmitSpy}} as |form|>
          <form.Field @name="username" as |field|>
            <field.Input data-test-username />
          </form.Field>

          <form.Field @name="email" as |field|>
            <field.Input data-test-email />
          </form.Field>

          <button type="button" {{on "click" form.reset}} data-test-reset>
            Reset
          </button>
        </Form>
      </template>
    );

    // Verify initial values
    assert.dom('[data-test-username]').hasValue('john');

    // Change values
    await fillIn('[data-test-username]', 'jane');
    await fillIn('[data-test-email]', 'jane@example.com');

    // Reset the form
    await click('[data-test-reset]');

    // Values should be reset to initial values
    assert.dom('[data-test-username]').hasValue('john');
    assert.dom('[data-test-email]').hasValue('john@example.com');
  });

  /**
   * Test that form reset works with no initial data
   */
  test('it resets form with no initial data', async function (assert) {
    assert.expect(2);

    const onSubmitSpy = sinon.spy();

    await render(
      <template>
        <Form @onSubmit={{onSubmitSpy}} as |form|>
          <form.Field @name="username" as |field|>
            <field.Input data-test-username />
          </form.Field>

          <button type="button" {{on "click" form.reset}} data-test-reset>
            Reset
          </button>
        </Form>
      </template>
    );

    // Enter value
    await fillIn('[data-test-username]', 'john');

    // Reset the form
    await click('[data-test-reset]');

    // Value should be cleared (native reset behavior)
    assert.dom('[data-test-username]').hasValue('');
    assert.ok(onSubmitSpy.notCalled, 'onSubmit should not be called on reset');
  });

  /**
   * Test that reset restores data from last successful submit, not original initial data
   */
  test('it resets to last successful submit data, not original initial data', async function (assert) {
    assert.expect(6);

    const initialData = {
      username: 'john',
      email: 'john@example.com'
    };

    class Model {
      @tracked formData = { ...initialData };
    }
    const model = new Model();

    const onChange = (result: FormResultData<typeof initialData>) => {
      model.formData = result.data;
    };

    const onSubmit = sinon.spy();

    await render(
      <template>
        <Form
          @data={{model.formData}}
          @onChange={{onChange}}
          @onSubmit={{onSubmit}}
          as |form|
        >
          <form.Field @name="username" as |field|>
            <field.Input data-test-username />
          </form.Field>

          <form.Field @name="email" as |field|>
            <field.Input data-test-email />
          </form.Field>

          <button type="submit" data-test-submit>Submit</button>
          <button type="button" {{on "click" form.reset}} data-test-reset>
            Reset
          </button>
        </Form>
      </template>
    );

    // Verify original initial values
    assert.dom('[data-test-username]').hasValue('john');
    assert.dom('[data-test-email]').hasValue('john@example.com');

    // Change to new values and submit successfully
    await fillIn('[data-test-username]', 'jane');
    await fillIn('[data-test-email]', 'jane@example.com');
    await click('[data-test-submit]');

    assert.ok(onSubmit.calledOnce, 'onSubmit was called');

    // Now dirty the form again with different values
    await fillIn('[data-test-username]', 'bob');
    await fillIn('[data-test-email]', 'bob@example.com');

    // Reset should restore to the last successful submit (jane), not original (john)
    await click('[data-test-reset]');

    // Values should match the last successful submit data
    assert
      .dom('[data-test-username]')
      .hasValue('jane', 'username reset to last submit value, not original');
    assert
      .dom('[data-test-email]')
      .hasValue(
        'jane@example.com',
        'email reset to last submit value, not original'
      );

    // Verify the component state also matches
    assert.deepEqual(
      model.formData,
      { username: 'jane', email: 'jane@example.com' },
      'component data matches last submit values'
    );
  });

  /**
   * Test that onChange receives correct data structure on reset
   */
  test('it calls onChange with correct data structure on reset', async function (assert) {
    assert.expect(6);

    const initialData = {
      username: 'john',
      email: 'john@example.com',
      age: 30
    };

    class Model {
      @tracked formData = { ...initialData };
    }
    const model = new Model();

    let onChangeCallCount = 0;
    const onChange = (result: FormResultData<typeof initialData>) => {
      onChangeCallCount++;
      model.formData = result.data;

      // On reset (after initial changes), verify the data structure
      if (onChangeCallCount === 3) {
        // After reset
        assert.strictEqual(
          result.data.username,
          'john',
          'onChange receives correct username'
        );
        assert.strictEqual(
          result.data.email,
          'john@example.com',
          'onChange receives correct email'
        );
        assert.strictEqual(
          result.data.age,
          30,
          'onChange receives correct age'
        );
        assert.strictEqual(
          result.dirty.size,
          0,
          'dirty set is empty after reset'
        );
        assert.ok(result.isValid, 'form is valid after reset');
      }
    };

    const onSubmitSpy = sinon.spy();

    await render(
      <template>
        <Form
          @data={{model.formData}}
          @onChange={{onChange}}
          @onSubmit={{onSubmitSpy}}
          as |form|
        >
          <form.Field @name="username" as |field|>
            <field.Input data-test-username />
          </form.Field>

          <form.Field @name="email" as |field|>
            <field.Input data-test-email />
          </form.Field>

          <form.Field @name="age" as |field|>
            <field.Input @type="number" data-test-age />
          </form.Field>

          <button type="button" {{on "click" form.reset}} data-test-reset>
            Reset
          </button>
        </Form>
      </template>
    );

    // Change values (triggers onChange)
    await fillIn('[data-test-username]', 'jane');
    await fillIn('[data-test-email]', 'jane@example.com');

    // Reset the form (should trigger onChange with initial data)
    await click('[data-test-reset]');

    assert.strictEqual(
      onChangeCallCount,
      3,
      'onChange called exactly 3 times (2 changes + 1 reset)'
    );
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
