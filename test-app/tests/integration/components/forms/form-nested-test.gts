import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, click, fillIn, settled } from '@ember/test-helpers';
import { tracked } from '@glimmer/tracking';
import { on } from '@ember/modifier';
import { Form, type FormResultData, type FormErrors } from '@frontile/forms';
import * as v from 'valibot';
import Component from '@glimmer/component';

module(
  'Integration | Component | @frontile/forms/Form | Nested Fields',
  function (hooks) {
    setupRenderingTest(hooks);

    test('it supports nested data with dotted field names', async function (assert) {
      const formData = {
        user: {
          name: {
            first: '',
            last: ''
          },
          email: ''
        },
        preferences: {
          theme: ''
        }
      };

      let lastOnChangeData: FormResultData<typeof formData> | undefined;

      class TestComponent extends Component {
        @tracked formData = formData;

        handleChange = (data: FormResultData<typeof formData>) => {
          lastOnChangeData = data;
          this.formData = data.data;
        };

        handleSubmit = () => {
          // noop for form requirement
        };

        <template>
          <Form
            @data={{this.formData}}
            @onChange={{this.handleChange}}
            @onSubmit={{this.handleSubmit}}
            as |form|
          >
            <form.Field @name="user.name.first" as |field|>
              <field.Input data-test-first-name />
            </form.Field>

            <form.Field @name="user.name.last" as |field|>
              <field.Input data-test-last-name />
            </form.Field>

            <form.Field @name="user.email" as |field|>
              <field.Input data-test-email />
            </form.Field>

            <form.Field @name="preferences.theme" as |field|>
              <field.Input data-test-theme />
            </form.Field>

            <button type="submit" data-test-submit>Submit</button>
          </Form>
        </template>
      }

      await render(<template><TestComponent /></template>);

      await fillIn('[data-test-first-name]', 'John');

      assert.strictEqual(
        lastOnChangeData?.data.user.name.first,
        'John',
        'First name updated'
      );

      await fillIn('[data-test-last-name]', 'Doe');

      assert.strictEqual(
        lastOnChangeData?.data.user.name.last,
        'Doe',
        'Last name updated'
      );

      await fillIn('[data-test-email]', 'john@example.com');

      assert.strictEqual(
        lastOnChangeData?.data.user.email,
        'john@example.com',
        'Email updated'
      );

      await fillIn('[data-test-theme]', 'dark');

      assert.strictEqual(
        lastOnChangeData?.data.preferences.theme,
        'dark',
        'Theme preference updated'
      );
    });

    test('it tracks dirty fields for nested data', async function (assert) {
      let lastDirty: Set<string> | undefined;

      const formData = {
        user: {
          name: {
            first: 'John',
            last: 'Doe'
          },
          email: ''
        }
      };

      class TestComponent extends Component {
        @tracked formData = formData;

        handleChange = (data: FormResultData<typeof formData>) => {
          lastDirty = data.dirty;
          this.formData = data.data;
        };

        handleSubmit = () => {
          // noop
        };

        <template>
          <Form
            @data={{this.formData}}
            @onChange={{this.handleChange}}
            @onSubmit={{this.handleSubmit}}
            as |form|
          >
            <form.Field @name="user.name.first" as |field|>
              <field.Input data-test-first-name />
            </form.Field>

            <form.Field @name="user.name.last" as |field|>
              <field.Input data-test-last-name />
            </form.Field>

            <form.Field @name="user.email" as |field|>
              <field.Input data-test-email />
            </form.Field>

            <div data-test-dirty-fields>
              {{#each form.dirty as |field|}}
                <span data-test-dirty-field={{field}}>{{field}}</span>
              {{/each}}
            </div>
          </Form>
        </template>
      }

      await render(<template><TestComponent /></template>);

      // Initially, no onChange has been called yet, so lastDirty is undefined
      // or if it has been called, dirty should be empty
      if (lastDirty !== undefined) {
        assert.strictEqual(lastDirty.size, 0, 'No dirty fields initially');
      }

      await fillIn('[data-test-first-name]', 'Jane');

      assert.true(lastDirty?.has('user.name.first'), 'First name is dirty');
      assert.strictEqual(lastDirty?.size, 1, 'Only one dirty field');

      await fillIn('[data-test-email]', 'jane@example.com');

      assert.true(lastDirty?.has('user.name.first'), 'First name still dirty');
      assert.true(lastDirty?.has('user.email'), 'Email is dirty');
      assert.strictEqual(lastDirty?.size, 2, 'Two dirty fields');

      // Reset first name to original value
      await fillIn('[data-test-first-name]', 'John');

      assert.false(
        lastDirty?.has('user.name.first'),
        'First name no longer dirty'
      );
      assert.true(lastDirty?.has('user.email'), 'Email still dirty');
      assert.strictEqual(lastDirty?.size, 1, 'Only one dirty field again');
    });

    test('it validates nested fields with schema', async function (assert) {
      const schema = v.object({
        user: v.object({
          name: v.object({
            first: v.pipe(
              v.string(),
              v.nonEmpty('First name is required'),
              v.minLength(2, 'First name must be at least 2 characters')
            ),
            last: v.pipe(v.string(), v.nonEmpty('Last name is required'))
          }),
          email: v.pipe(
            v.string(),
            v.nonEmpty('Email is required'),
            v.email('Must be a valid email')
          )
        })
      });

      type Schema = v.InferOutput<typeof schema>;

      let lastErrors: FormErrors | undefined;
      let submitCalled = false;

      class TestComponent extends Component {
        @tracked formData: Schema = {
          user: {
            name: {
              first: '',
              last: ''
            },
            email: ''
          }
        };

        handleSubmit = (data: FormResultData<Schema>) => {
          submitCalled = true;
          this.formData = data.data;
        };

        handleError = (errors: FormErrors) => {
          lastErrors = errors;
        };

        <template>
          <Form
            @data={{this.formData}}
            @schema={{schema}}
            @onSubmit={{this.handleSubmit}}
            @onError={{this.handleError}}
            as |form|
          >
            <form.Field @name="user.name.first" as |field|>
              <field.Input data-test-first-name />
            </form.Field>

            <form.Field @name="user.name.last" as |field|>
              <field.Input data-test-last-name />
            </form.Field>

            <form.Field @name="user.email" as |field|>
              <field.Input data-test-email />
            </form.Field>

            <button type="submit" data-test-submit>Submit</button>
          </Form>
        </template>
      }

      await render(<template><TestComponent /></template>);

      // Try submitting with empty fields
      await click('[data-test-submit]');

      assert.false(submitCalled, 'Submit handler not called with invalid data');
      assert.ok(lastErrors, 'Validation errors present');
      assert.ok(lastErrors?.['user.name.first'], 'First name error present');
      assert.ok(lastErrors?.['user.name.last'], 'Last name error present');
      assert.ok(lastErrors?.['user.email'], 'Email error present');

      // Fill in valid data
      await fillIn('[data-test-first-name]', 'John');
      await fillIn('[data-test-last-name]', 'Doe');
      await fillIn('[data-test-email]', 'john@example.com');

      submitCalled = false;
      await click('[data-test-submit]');

      assert.true(submitCalled, 'Submit handler called with valid data');
    });

    test('it resets dirty fields on successful submit for nested data', async function (assert) {
      let lastDirty: Set<string> | undefined;

      const formData = {
        user: {
          name: {
            first: 'John',
            last: 'Doe'
          },
          email: ''
        }
      };

      class TestComponent extends Component {
        @tracked formData = formData;

        handleChange = (data: FormResultData<typeof formData>) => {
          lastDirty = data.dirty;
          this.formData = data.data;
        };

        handleSubmit = (data: FormResultData<typeof formData>) => {
          this.formData = data.data;
        };

        <template>
          <Form
            @data={{this.formData}}
            @onChange={{this.handleChange}}
            @onSubmit={{this.handleSubmit}}
            as |form|
          >
            <form.Field @name="user.name.first" as |field|>
              <field.Input data-test-first-name />
            </form.Field>

            <form.Field @name="user.name.last" as |field|>
              <field.Input data-test-last-name />
            </form.Field>

            <button type="submit" data-test-submit>Submit</button>

            <div data-test-dirty-size>{{form.dirty.size}}</div>
          </Form>
        </template>
      }

      await render(<template><TestComponent /></template>);

      await fillIn('[data-test-first-name]', 'Jane');

      assert.true(lastDirty?.has('user.name.first'), 'Field is dirty');

      await click('[data-test-submit]');

      const dirtySize = document.querySelector(
        '[data-test-dirty-size]'
      )?.textContent;
      assert.strictEqual(dirtySize, '0', 'Dirty fields reset after submit');
    });

    test('it works with mixed flat and nested fields', async function (assert) {
      let lastOnChangeData: FormResultData | undefined;

      const formData = {
        username: '',
        profile: {
          email: '',
          bio: ''
        },
        age: 0
      };

      class TestComponent extends Component {
        @tracked formData = formData;

        handleChange = (data: FormResultData<typeof formData>) => {
          lastOnChangeData = data;
          this.formData = data.data;
        };

        handleSubmit = () => {
          // noop
        };

        <template>
          <Form
            @data={{this.formData}}
            @onChange={{this.handleChange}}
            @onSubmit={{this.handleSubmit}}
            as |form|
          >
            <form.Field @name="username" as |field|>
              <field.Input data-test-username />
            </form.Field>

            <form.Field @name="profile.email" as |field|>
              <field.Input data-test-email />
            </form.Field>

            <form.Field @name="profile.bio" as |field|>
              <field.Input data-test-bio />
            </form.Field>

            <form.Field @name="age" as |field|>
              <field.Input data-test-age type="number" />
            </form.Field>
          </Form>
        </template>
      }

      await render(<template><TestComponent /></template>);

      await fillIn('[data-test-username]', 'johndoe');

      assert.strictEqual(
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        (lastOnChangeData?.data as any).username,
        'johndoe',
        'Flat field updated'
      );

      await fillIn('[data-test-email]', 'john@example.com');

      assert.strictEqual(
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        (lastOnChangeData?.data as any).profile.email,
        'john@example.com',
        'Nested field updated'
      );

      await fillIn('[data-test-bio]', 'Software developer');

      assert.strictEqual(
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        (lastOnChangeData?.data as any).profile.bio,
        'Software developer',
        'Another nested field updated'
      );

      await fillIn('[data-test-age]', '30');

      assert.strictEqual(
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        (lastOnChangeData?.data as any).age,
        30,
        'Flat number field updated'
      );
    });

    test('Field component correctly binds values for nested paths', async function (assert) {
      class TestComponent extends Component {
        @tracked formData = {
          user: {
            name: {
              first: 'John',
              last: 'Doe'
            },
            email: 'john@example.com'
          }
        };

        handleSubmit = () => {
          // noop
        };

        <template>
          <Form
            @data={{this.formData}}
            @onSubmit={{this.handleSubmit}}
            as |form|
          >
            <form.Field @name="user.name.first" as |field|>
              <field.Input data-test-first-name />
            </form.Field>

            <form.Field @name="user.name.last" as |field|>
              <field.Input data-test-last-name />
            </form.Field>

            <form.Field @name="user.email" as |field|>
              <field.Input data-test-email />
            </form.Field>
          </Form>
        </template>
      }

      await render(<template><TestComponent /></template>);

      const firstNameInput = document.querySelector(
        '[data-test-first-name]'
      ) as HTMLInputElement;
      const lastNameInput = document.querySelector(
        '[data-test-last-name]'
      ) as HTMLInputElement;
      const emailInput = document.querySelector(
        '[data-test-email]'
      ) as HTMLInputElement;

      assert.strictEqual(
        firstNameInput?.value,
        'John',
        'First name bound correctly'
      );
      assert.strictEqual(
        lastNameInput?.value,
        'Doe',
        'Last name bound correctly'
      );
      assert.strictEqual(
        emailInput?.value,
        'john@example.com',
        'Email bound correctly'
      );
    });

    test('it displays errors for nested fields correctly', async function (assert) {
      const schema = v.object({
        user: v.object({
          profile: v.object({
            email: v.pipe(
              v.string(),
              v.nonEmpty('Email is required'),
              v.email('Must be a valid email')
            )
          })
        })
      });

      type Schema = v.InferOutput<typeof schema>;

      class TestComponent extends Component {
        @tracked formData: Schema = {
          user: {
            profile: {
              email: ''
            }
          }
        };

        handleSubmit = () => {
          // noop
        };

        <template>
          <Form
            @data={{this.formData}}
            @schema={{schema}}
            @onSubmit={{this.handleSubmit}}
            as |form|
          >
            <form.Field @name="user.profile.email" as |field|>
              <field.Input data-test-email />
            </form.Field>

            <div data-test-email-errors>
              {{#if form.errors.[user.profile.email]}}has-error{{/if}}
            </div>

            <button type="submit" data-test-submit>Submit</button>
          </Form>
        </template>
      }

      await render(<template><TestComponent /></template>);

      await click('[data-test-submit]');

      const errorText = document
        .querySelector('[data-test-email-errors]')
        ?.textContent?.trim();
      assert.ok(errorText, 'Error displayed for nested field');
      assert.strictEqual(errorText, 'has-error', 'Error indicator shown');
    });

    test('it resets nested data to initial values', async function (assert) {
      const initialData = {
        user: {
          name: {
            first: 'John',
            last: 'Doe'
          },
          email: 'john@example.com'
        },
        preferences: {
          theme: 'dark'
        }
      };

      class TestComponent extends Component {
        @tracked formData = { ...initialData };

        handleChange = (data: FormResultData<typeof initialData>) => {
          this.formData = data.data;
        };

        handleSubmit = () => {
          // noop
        };

        <template>
          <Form
            @data={{this.formData}}
            @onChange={{this.handleChange}}
            @onSubmit={{this.handleSubmit}}
            as |form|
          >
            <form.Field @name="user.name.first" as |field|>
              <field.Input data-test-first-name />
            </form.Field>

            <form.Field @name="user.name.last" as |field|>
              <field.Input data-test-last-name />
            </form.Field>

            <form.Field @name="user.email" as |field|>
              <field.Input data-test-email />
            </form.Field>

            <form.Field @name="preferences.theme" as |field|>
              <field.Input data-test-theme />
            </form.Field>

            <button type="button" {{on "click" form.reset}} data-test-reset>
              Reset
            </button>
          </Form>
        </template>
      }

      await render(<template><TestComponent /></template>);

      // Verify initial values
      assert.strictEqual(
        (document.querySelector('[data-test-first-name]') as HTMLInputElement)
          ?.value,
        'John',
        'Initial first name'
      );
      assert.strictEqual(
        (document.querySelector('[data-test-email]') as HTMLInputElement)
          ?.value,
        'john@example.com',
        'Initial email'
      );

      // Change values
      await fillIn('[data-test-first-name]', 'Jane');
      await fillIn('[data-test-last-name]', 'Smith');
      await fillIn('[data-test-email]', 'jane@example.com');
      await fillIn('[data-test-theme]', 'light');

      // Reset the form
      await click('[data-test-reset]');

      // Values should be reset to initial nested structure
      const firstNameInput = document.querySelector(
        '[data-test-first-name]'
      ) as HTMLInputElement;
      const lastNameInput = document.querySelector(
        '[data-test-last-name]'
      ) as HTMLInputElement;
      const emailInput = document.querySelector(
        '[data-test-email]'
      ) as HTMLInputElement;
      const themeInput = document.querySelector(
        '[data-test-theme]'
      ) as HTMLInputElement;

      assert.strictEqual(
        firstNameInput?.value,
        'John',
        'First name reset to initial value'
      );
      assert.strictEqual(
        lastNameInput?.value,
        'Doe',
        'Last name reset to initial value'
      );
      assert.strictEqual(
        emailInput?.value,
        'john@example.com',
        'Email reset to initial value'
      );
      assert.strictEqual(
        themeInput?.value,
        'dark',
        'Theme reset to initial value'
      );
    });

    test('it clears validation errors on reset for nested fields', async function (assert) {
      const schema = v.object({
        user: v.object({
          name: v.object({
            first: v.pipe(
              v.string(),
              v.nonEmpty('First name is required'),
              v.minLength(2, 'First name must be at least 2 characters')
            )
          }),
          email: v.pipe(
            v.string(),
            v.nonEmpty('Email is required'),
            v.email('Must be a valid email')
          )
        })
      });

      type Schema = v.InferOutput<typeof schema>;

      const initialData: Schema = {
        user: {
          name: {
            first: 'John'
          },
          email: 'john@example.com'
        }
      };

      class TestComponent extends Component {
        @tracked formData = { ...initialData };

        handleChange = (data: FormResultData<Schema>) => {
          this.formData = data.data;
        };

        handleSubmit = () => {
          // noop
        };

        <template>
          <Form
            @data={{this.formData}}
            @schema={{schema}}
            @onChange={{this.handleChange}}
            @onSubmit={{this.handleSubmit}}
            as |form|
          >
            <form.Field @name="user.name.first" as |field|>
              <field.Input data-test-first-name />
            </form.Field>

            <form.Field @name="user.email" as |field|>
              <field.Input data-test-email />
            </form.Field>

            <button type="submit" data-test-submit>Submit</button>
            <button type="button" {{on "click" form.reset}} data-test-reset>
              Reset
            </button>
          </Form>
        </template>
      }

      await render(<template><TestComponent /></template>);

      // Enter invalid data
      await fillIn('[data-test-first-name]', 'J'); // Too short
      await fillIn('[data-test-email]', 'invalid'); // Invalid email

      // Submit to trigger validation
      await click('[data-test-submit]');

      // Errors should be displayed
      assert.ok(
        document.querySelectorAll('[data-component="form-feedback"]').length >
          0,
        'Validation errors are displayed'
      );

      // Reset the form
      await click('[data-test-reset]');

      // Errors should be cleared
      assert.strictEqual(
        document.querySelectorAll('[data-component="form-feedback"]').length,
        0,
        'Validation errors are cleared after reset'
      );

      // Values should be reset to initial valid values
      const firstNameInput = document.querySelector(
        '[data-test-first-name]'
      ) as HTMLInputElement;
      assert.strictEqual(
        firstNameInput?.value,
        'John',
        'First name reset to initial value'
      );
    });
  }
);
