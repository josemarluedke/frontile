import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import {
  render,
  fillIn,
  click,
  settled,
  triggerEvent
} from '@ember/test-helpers';
import { tracked } from '@glimmer/tracking';
import { array } from '@ember/helper';
import { Form, type FormResultData, type FormErrors } from '@frontile/forms';
import Component from '@glimmer/component';
import * as v from 'valibot';

const noop = () => {};

module(
  'Integration | Component | @frontile/forms | Blur Validation',
  function (hooks) {
    setupRenderingTest(hooks);

    test('it validates Input field on blur when validateOn includes "blur"', async function (assert) {
      assert.expect(5);

      const schema = v.object({
        email: v.pipe(v.string(), v.email('Invalid email format'))
      });

      type Schema = v.InferOutput<typeof schema>;

      class TestComponent extends Component {
        @tracked formData: Schema = {
          email: ''
        };

        handleChange = (data: FormResultData<Schema>) => {
          this.formData = data.data;
        };

        <template>
          <Form
            @data={{this.formData}}
            @schema={{schema}}
            @onChange={{this.handleChange}}
            @onSubmit={{noop}}
            @validateOn={{array "blur" "submit"}}
            as |form|
          >
            <form.Field @name="email" as |field|>
              <field.Input @label="Email" data-test-email />
            </form.Field>
          </Form>
        </template>
      }

      await render(<template><TestComponent /></template>);

      // Initially no errors
      assert
        .dom('[data-component="form-feedback"]')
        .doesNotExist('No errors initially');

      // Type invalid email but don't blur yet
      const emailInput = document.querySelector(
        '[data-test-email]'
      ) as HTMLInputElement;
      emailInput.value = 'invalid';
      emailInput.dispatchEvent(new Event('input', { bubbles: true }));
      await settled();

      // Error should NOT appear yet (only validates on blur, not input)
      assert
        .dom('[data-component="form-feedback"]')
        .doesNotExist('No error before blur');

      // Trigger blur
      await triggerEvent('[data-test-email]', 'blur');

      // Error should appear after blur
      assert
        .dom('[data-component="form-feedback"]')
        .exists('Error appears after blur');
      assert
        .dom('[data-component="form-feedback"]')
        .hasText('Invalid email format');

      // Fix email and blur again
      await fillIn('[data-test-email]', 'test@example.com');
      await triggerEvent('[data-test-email]', 'blur');

      // Error should clear after blur with valid value
      assert
        .dom('[data-component="form-feedback"]')
        .doesNotExist('Error cleared after blur with valid value');
    });

    test('it validates Textarea field on blur when validateOn includes "blur"', async function (assert) {
      assert.expect(4);

      const schema = v.object({
        message: v.pipe(
          v.string(),
          v.minLength(10, 'Message must be at least 10 characters')
        )
      });

      type Schema = v.InferOutput<typeof schema>;

      class TestComponent extends Component {
        @tracked formData: Schema = {
          message: ''
        };

        handleChange = (data: FormResultData<Schema>) => {
          this.formData = data.data;
        };

        <template>
          <Form
            @data={{this.formData}}
            @schema={{schema}}
            @onChange={{this.handleChange}}
            @onSubmit={{noop}}
            @validateOn={{array "blur" "submit"}}
            as |form|
          >
            <form.Field @name="message" as |field|>
              <field.Textarea @label="Message" data-test-message />
            </form.Field>
          </Form>
        </template>
      }

      await render(<template><TestComponent /></template>);

      // Initially no errors
      assert
        .dom('[data-component="form-feedback"]')
        .doesNotExist('No errors initially');

      // Type short message and blur
      await fillIn('[data-test-message]', 'short');
      await triggerEvent('[data-test-message]', 'blur');

      // Error should appear after blur
      assert
        .dom('[data-component="form-feedback"]')
        .exists('Error appears after blur');

      // Fix message and blur
      await fillIn('[data-test-message]', 'This is a long enough message');
      await triggerEvent('[data-test-message]', 'blur');

      // Error should clear
      assert
        .dom('[data-component="form-feedback"]')
        .doesNotExist('Error cleared after blur');

      // Type short message again but don't blur
      const textarea = document.querySelector(
        '[data-test-message]'
      ) as HTMLTextAreaElement;
      textarea.value = 'short';
      textarea.dispatchEvent(new Event('input', { bubbles: true }));
      await settled();

      // Error should NOT appear without blur
      assert
        .dom('[data-component="form-feedback"]')
        .doesNotExist('No error without blur');
    });

    test('it validates Checkbox field on blur when validateOn includes "blur"', async function (assert) {
      assert.expect(4);

      const schema = v.object({
        terms: v.pipe(v.boolean(), v.literal(true, 'You must accept the terms'))
      });

      type Schema = v.InferOutput<typeof schema>;

      class TestComponent extends Component {
        @tracked formData: Schema = {
          terms: false
        };

        handleChange = (data: FormResultData<Schema>) => {
          this.formData = data.data;
        };

        <template>
          <Form
            @data={{this.formData}}
            @schema={{schema}}
            @onChange={{this.handleChange}}
            @onSubmit={{noop}}
            @validateOn={{array "blur" "submit"}}
            as |form|
          >
            <form.Field @name="terms" as |field|>
              <field.Checkbox @label="Accept Terms" data-test-terms />
            </form.Field>
          </Form>
        </template>
      }

      await render(<template><TestComponent /></template>);

      // Initially no errors
      assert
        .dom('[data-component="form-feedback"]')
        .doesNotExist('No errors initially');

      // Trigger blur without checking
      await triggerEvent('[data-test-terms]', 'blur');

      // Error should appear after blur
      assert
        .dom('[data-component="form-feedback"]')
        .exists('Error appears after blur');

      // Check checkbox and blur
      await click('[data-test-terms]');
      await triggerEvent('[data-test-terms]', 'blur');

      // Error should clear
      assert
        .dom('[data-component="form-feedback"]')
        .doesNotExist('Error cleared after checking and blur');

      // Uncheck without blur
      await click('[data-test-terms]');

      // Error should NOT appear without blur
      assert
        .dom('[data-component="form-feedback"]')
        .doesNotExist('No error without blur');
    });

    test('it validates Radio field on blur when validateOn includes "blur"', async function (assert) {
      assert.expect(3);

      const schema = v.object({
        choice: v.pipe(v.string(), v.nonEmpty('Please make a selection'))
      });

      type Schema = v.InferOutput<typeof schema>;

      class TestComponent extends Component {
        @tracked formData: Schema = {
          choice: ''
        };

        handleChange = (data: FormResultData<Schema>) => {
          this.formData = data.data;
        };

        <template>
          <Form
            @data={{this.formData}}
            @schema={{schema}}
            @onChange={{this.handleChange}}
            @onSubmit={{noop}}
            @validateOn={{array "blur" "submit"}}
            as |form|
          >
            <form.Field @name="choice" as |field|>
              <field.Radio @label="Option A" @value="a" data-test-radio-a />
              <field.Radio @label="Option B" @value="b" data-test-radio-b />
            </form.Field>
          </Form>
        </template>
      }

      await render(<template><TestComponent /></template>);

      // Initially no errors
      assert
        .dom('[data-component="form-feedback"]')
        .doesNotExist('No errors initially');

      // Trigger blur on first radio without selecting
      await triggerEvent('[data-test-radio-a]', 'blur');

      // Error should appear after blur
      assert
        .dom('[data-component="form-feedback"]')
        .exists('Error appears after blur');

      // Select a radio and blur
      await click('[data-test-radio-b]');
      await triggerEvent('[data-test-radio-b]', 'blur');

      // Error should clear
      assert
        .dom('[data-component="form-feedback"]')
        .doesNotExist('Error cleared after selection and blur');
    });

    test('it validates Switch field on blur when validateOn includes "blur"', async function (assert) {
      assert.expect(4);

      const schema = v.object({
        enabled: v.pipe(
          v.boolean(),
          v.literal(true, 'You must enable this option')
        )
      });

      type Schema = v.InferOutput<typeof schema>;

      class TestComponent extends Component {
        @tracked formData: Schema = {
          enabled: false
        };

        handleChange = (data: FormResultData<Schema>) => {
          this.formData = data.data;
        };

        <template>
          <Form
            @data={{this.formData}}
            @schema={{schema}}
            @onChange={{this.handleChange}}
            @onSubmit={{noop}}
            @validateOn={{array "blur" "submit"}}
            as |form|
          >
            <form.Field @name="enabled" as |field|>
              <field.Switch @label="Enable Feature" data-test-switch />
            </form.Field>
          </Form>
        </template>
      }

      await render(<template><TestComponent /></template>);

      // Initially no errors
      assert
        .dom('[data-component="form-feedback"]')
        .doesNotExist('No errors initially');

      // Trigger blur without enabling
      await triggerEvent('[data-test-switch]', 'blur');

      // Error should appear after blur
      assert
        .dom('[data-component="form-feedback"]')
        .exists('Error appears after blur');

      // Enable switch and blur
      await click('[data-test-switch]');
      await triggerEvent('[data-test-switch]', 'blur');

      // Error should clear
      assert
        .dom('[data-component="form-feedback"]')
        .doesNotExist('Error cleared after enabling and blur');

      // Disable without blur
      await click('[data-test-switch]');

      // Error should NOT appear without blur
      assert
        .dom('[data-component="form-feedback"]')
        .doesNotExist('No error without blur');
    });

    test('it does NOT validate on blur when "blur" is not in validateOn', async function (assert) {
      assert.expect(3);

      const schema = v.object({
        email: v.pipe(v.string(), v.email('Invalid email format'))
      });

      type Schema = v.InferOutput<typeof schema>;

      class TestComponent extends Component {
        @tracked formData: Schema = {
          email: ''
        };

        handleChange = (data: FormResultData<Schema>) => {
          this.formData = data.data;
        };

        <template>
          <Form
            @data={{this.formData}}
            @schema={{schema}}
            @onChange={{this.handleChange}}
            @onSubmit={{noop}}
            @validateOn={{array "submit"}}
            as |form|
          >
            <form.Field @name="email" as |field|>
              <field.Input @label="Email" data-test-email />
            </form.Field>
            <button type="submit" data-test-submit>Submit</button>
          </Form>
        </template>
      }

      await render(<template><TestComponent /></template>);

      // Type invalid email and blur
      await fillIn('[data-test-email]', 'invalid');
      await triggerEvent('[data-test-email]', 'blur');

      // Error should NOT appear (blur validation not enabled)
      assert
        .dom('[data-component="form-feedback"]')
        .doesNotExist('No error after blur when blur validation disabled');

      // Submit form
      await click('[data-test-submit]');

      // Error should appear on submit
      assert
        .dom('[data-component="form-feedback"]')
        .exists('Error appears on submit');

      // Fix email and blur
      await fillIn('[data-test-email]', 'test@example.com');
      await triggerEvent('[data-test-email]', 'blur');

      // Error should NOT clear on blur (blur validation not enabled)
      assert
        .dom('[data-component="form-feedback"]')
        .exists('Error persists after blur when blur validation disabled');
    });

    test('it validates on blur with nested field names', async function (assert) {
      assert.expect(4);

      const schema = v.object({
        user: v.object({
          email: v.pipe(v.string(), v.email('Invalid email format'))
        })
      });

      type Schema = v.InferOutput<typeof schema>;

      class TestComponent extends Component {
        @tracked formData: Schema = {
          user: {
            email: ''
          }
        };

        handleChange = (data: FormResultData<Schema>) => {
          this.formData = data.data;
        };

        <template>
          <Form
            @data={{this.formData}}
            @schema={{schema}}
            @onChange={{this.handleChange}}
            @onSubmit={{noop}}
            @validateOn={{array "blur" "submit"}}
            as |form|
          >
            <form.Field @name="user.email" as |field|>
              <field.Input @label="Email" data-test-email />
            </form.Field>
          </Form>
        </template>
      }

      await render(<template><TestComponent /></template>);

      // Initially no errors
      assert
        .dom('[data-component="form-feedback"]')
        .doesNotExist('No errors initially');

      // Type invalid email and blur
      await fillIn('[data-test-email]', 'invalid');
      await triggerEvent('[data-test-email]', 'blur');

      // Error should appear after blur
      assert
        .dom('[data-component="form-feedback"]')
        .exists('Error appears after blur for nested field');
      assert
        .dom('[data-component="form-feedback"]')
        .hasText('Invalid email format');

      // Fix email and blur
      await fillIn('[data-test-email]', 'test@example.com');
      await triggerEvent('[data-test-email]', 'blur');

      // Error should clear
      assert
        .dom('[data-component="form-feedback"]')
        .doesNotExist('Error cleared after blur with valid value');
    });

    test('it supports combining blur with input validation', async function (assert) {
      assert.expect(5);

      const schema = v.object({
        password: v.pipe(
          v.string(),
          v.minLength(6, 'Password must be at least 6 characters')
        )
      });

      type Schema = v.InferOutput<typeof schema>;

      class TestComponent extends Component {
        @tracked formData: Schema = {
          password: ''
        };

        handleChange = (data: FormResultData<Schema>) => {
          this.formData = data.data;
        };

        <template>
          <Form
            @data={{this.formData}}
            @schema={{schema}}
            @onChange={{this.handleChange}}
            @onSubmit={{noop}}
            @validateOn={{array "blur" "input" "submit"}}
            as |form|
          >
            <form.Field @name="password" as |field|>
              <field.Input
                @label="Password"
                @type="password"
                data-test-password
              />
            </form.Field>
          </Form>
        </template>
      }

      await render(<template><TestComponent /></template>);

      // Initially no errors
      assert
        .dom('[data-component="form-feedback"]')
        .doesNotExist('No errors initially');

      // Type short password - should trigger input validation
      await fillIn('[data-test-password]', 'abc');

      // Error should appear after input
      assert
        .dom('[data-component="form-feedback"]')
        .exists('Error appears after input');

      // Fix password
      await fillIn('[data-test-password]', 'abcdef');

      // Error should clear after input
      assert
        .dom('[data-component="form-feedback"]')
        .doesNotExist('Error cleared after input with valid value');

      // Type short password again but don't wait
      const passwordInput = document.querySelector(
        '[data-test-password]'
      ) as HTMLInputElement;
      passwordInput.value = 'ab';
      passwordInput.dispatchEvent(new Event('input', { bubbles: true }));

      // Immediately trigger blur
      await triggerEvent('[data-test-password]', 'blur');

      // Error should appear (blur validation)
      assert
        .dom('[data-component="form-feedback"]')
        .exists('Error appears after blur');

      // Fix and blur
      await fillIn('[data-test-password]', 'abcdefgh');
      await triggerEvent('[data-test-password]', 'blur');

      // Error should clear (blur validation)
      assert
        .dom('[data-component="form-feedback"]')
        .doesNotExist('Error cleared after blur with valid value');
    });

    test('Field-level blur validation overrides Form-level validateOn', async function (assert) {
      assert.expect(4);

      const schema = v.object({
        email: v.pipe(v.string(), v.email('Invalid email')),
        name: v.pipe(v.string(), v.minLength(3, 'Name too short'))
      });

      type Schema = v.InferOutput<typeof schema>;

      class TestComponent extends Component {
        @tracked formData: Schema = {
          email: '',
          name: ''
        };

        handleChange = (data: FormResultData<Schema>) => {
          this.formData = data.data;
        };

        <template>
          <Form
            @data={{this.formData}}
            @schema={{schema}}
            @onChange={{this.handleChange}}
            @onSubmit={{noop}}
            @validateOn={{array "submit"}}
            as |form|
          >
            <form.Field @name="email" @validateOn={{array "blur"}} as |field|>
              <field.Input @label="Email" data-test-email />
            </form.Field>
            <form.Field @name="name" as |field|>
              <field.Input @label="Name" data-test-name />
            </form.Field>
          </Form>
        </template>
      }

      await render(<template><TestComponent /></template>);

      // Type invalid email and blur - should validate (Field override)
      await fillIn('[data-test-email]', 'invalid');
      await triggerEvent('[data-test-email]', 'blur');

      // Error should appear for email
      assert
        .dom('[data-component="form-feedback"]')
        .exists({ count: 1 }, 'Email validates on blur (Field override)');

      // Type invalid name and blur - should NOT validate (inherits Form setting)
      await fillIn('[data-test-name]', 'ab');
      await triggerEvent('[data-test-name]', 'blur');

      // No additional error for name
      assert
        .dom('[data-component="form-feedback"]')
        .exists(
          { count: 1 },
          'Name does not validate on blur (inherits Form setting)'
        );

      // Fix email and blur
      await fillIn('[data-test-email]', 'test@example.com');
      await triggerEvent('[data-test-email]', 'blur');

      // Email error should clear
      assert
        .dom('[data-component="form-feedback"]')
        .doesNotExist('Email error cleared on blur');

      // Fix name and blur - should NOT clear error (no blur validation)
      await fillIn('[data-test-name]', 'John');
      await triggerEvent('[data-test-name]', 'blur');

      // Still no errors visible (name never validated)
      assert
        .dom('[data-component="form-feedback"]')
        .doesNotExist('No errors visible');
    });

    test('it validates multiple fields independently on blur', async function (assert) {
      assert.expect(5);

      const schema = v.object({
        email: v.pipe(v.string(), v.email('Invalid email')),
        password: v.pipe(v.string(), v.minLength(6, 'Password too short')),
        username: v.pipe(v.string(), v.minLength(3, 'Username too short'))
      });

      type Schema = v.InferOutput<typeof schema>;

      class TestComponent extends Component {
        @tracked formData: Schema = {
          email: '',
          password: '',
          username: ''
        };

        handleChange = (data: FormResultData<Schema>) => {
          this.formData = data.data;
        };

        <template>
          <Form
            @data={{this.formData}}
            @schema={{schema}}
            @onChange={{this.handleChange}}
            @onSubmit={{noop}}
            @validateOn={{array "blur" "submit"}}
            as |form|
          >
            <form.Field @name="email" as |field|>
              <field.Input @label="Email" data-test-email />
            </form.Field>
            <form.Field @name="password" as |field|>
              <field.Input @label="Password" data-test-password />
            </form.Field>
            <form.Field @name="username" as |field|>
              <field.Input @label="Username" data-test-username />
            </form.Field>
          </Form>
        </template>
      }

      await render(<template><TestComponent /></template>);

      // Type invalid email and blur
      await fillIn('[data-test-email]', 'invalid');
      await triggerEvent('[data-test-email]', 'blur');

      assert
        .dom('[data-component="form-feedback"]')
        .exists({ count: 1 }, 'One error after first field blur');

      // Type invalid password and blur
      await fillIn('[data-test-password]', 'abc');
      await triggerEvent('[data-test-password]', 'blur');

      assert
        .dom('[data-component="form-feedback"]')
        .exists({ count: 2 }, 'Two errors after second field blur');

      // Type invalid username and blur
      await fillIn('[data-test-username]', 'ab');
      await triggerEvent('[data-test-username]', 'blur');

      assert
        .dom('[data-component="form-feedback"]')
        .exists({ count: 3 }, 'Three errors after third field blur');

      // Fix email and blur
      await fillIn('[data-test-email]', 'test@example.com');
      await triggerEvent('[data-test-email]', 'blur');

      assert
        .dom('[data-component="form-feedback"]')
        .exists({ count: 2 }, 'Email error cleared, two errors remain');

      // Fix password and blur
      await fillIn('[data-test-password]', 'abcdef');
      await triggerEvent('[data-test-password]', 'blur');

      assert
        .dom('[data-component="form-feedback"]')
        .exists({ count: 1 }, 'Password error cleared, one error remains');
    });
  }
);
