import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { render, click, fillIn, settled } from '@ember/test-helpers';
import { tracked } from '@glimmer/tracking';
import { on } from '@ember/modifier';
import {
  Form,
  type FormResultData,
  type FormErrors,
  type FormDataCompiled,
  type CustomValidatorReturn
} from 'frontile';
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

    /**
     * Reads a dotted path out of the nested form data the Form hands to a
     * custom validator.
     */
    function readPath(data: unknown, path: string): unknown {
      return path
        .split('.')
        .reduce<unknown>(
          (acc, key) =>
            acc && typeof acc === 'object'
              ? (acc as Record<string, unknown>)[key]
              : undefined,
          data
        );
    }

    /**
     * Issue paths that contain array indexes must produce (and match) the
     * dotted field name a consumer writes, e.g. `items.0.name`. The custom
     * validator path is used here because it hands the Form plain Standard
     * Schema issues, which is exactly what `validatorToFormErrors` and
     * `StandardValidator.filterFieldIssues` consume.
     */
    test('it surfaces array element errors on the indexed field name', async function (assert) {
      assert.expect(6);

      const validator = (data: FormDataCompiled): CustomValidatorReturn => {
        const issues = [];

        if (!readPath(data, 'items.0.name')) {
          issues.push({
            message: 'First name is required',
            path: [{ key: 'items' }, { key: 0 }, { key: 'name' }]
          });
        }

        if (!readPath(data, 'items.1.name')) {
          issues.push({
            message: 'Second name is required',
            path: [{ key: 'items' }, { key: 1 }, { key: 'name' }]
          });
        }

        return issues.length > 0 ? issues : undefined;
      };

      let lastErrors: FormErrors | undefined;
      let submitted = false;

      class TestComponent extends Component {
        handleSubmit = () => {
          submitted = true;
        };

        handleError = (errors: FormErrors) => {
          lastErrors = errors;
        };

        <template>
          <Form
            @validate={{validator}}
            @onSubmit={{this.handleSubmit}}
            @onError={{this.handleError}}
            as |form|
          >
            <div data-test-item-0>
              <form.Field @name="items.0.name" as |field|>
                <field.Input data-test-item-0-input />
              </form.Field>
            </div>

            <div data-test-item-1>
              <form.Field @name="items.1.name" as |field|>
                <field.Input data-test-item-1-input />
              </form.Field>
            </div>

            <button type="submit" data-test-submit>Submit</button>
          </Form>
        </template>
      }

      await render(<template><TestComponent /></template>);

      await click('[data-test-submit]');

      assert.false(submitted, 'submission is blocked by the validation errors');
      assert.ok(
        lastErrors?.['items.0.name'],
        'the index 0 error is keyed by the name a consumer writes'
      );
      assert.notOk(
        lastErrors?.['items.name'],
        'the index 0 error is not misfiled onto the unindexed field name'
      );

      assert
        .dom('[data-test-item-0] [data-component="form-feedback"]')
        .hasText(
          'First name is required',
          'the first element displays its own error'
        );
      assert
        .dom('[data-test-item-1] [data-component="form-feedback"]')
        .hasText(
          'Second name is required',
          'the second element displays its own error'
        );

      // Per-field validation (on change) has to match the indexed path too.
      await fillIn('[data-test-item-1-input]', 'Second');

      assert
        .dom('[data-test-item-1] [data-component="form-feedback"]')
        .doesNotExist(
          'the second element error clears once that element is valid'
        );
    });

    test('it validates a non-zero array element on change', async function (assert) {
      assert.expect(3);

      const validator = (data: FormDataCompiled): CustomValidatorReturn => {
        const value = (readPath(data, 'items.1.name') as string) ?? '';

        if (value.length > 0 && value.length < 3) {
          return [
            {
              message: 'Name must be at least 3 characters',
              path: [{ key: 'items' }, { key: 1 }, { key: 'name' }]
            }
          ];
        }

        return undefined;
      };

      class TestComponent extends Component {
        handleSubmit = () => {
          // noop
        };

        <template>
          <Form
            @validate={{validator}}
            @onSubmit={{this.handleSubmit}}
            as |form|
          >
            <div data-test-item-0>
              <form.Field @name="items.0.name" as |field|>
                <field.Input data-test-item-0-input />
              </form.Field>
            </div>

            <div data-test-item-1>
              <form.Field @name="items.1.name" as |field|>
                <field.Input data-test-item-1-input />
              </form.Field>
            </div>
          </Form>
        </template>
      }

      await render(<template><TestComponent /></template>);

      await fillIn('[data-test-item-1-input]', 'ab');

      assert
        .dom('[data-test-item-1] [data-component="form-feedback"]')
        .hasText(
          'Name must be at least 3 characters',
          'the second element shows its own error'
        );
      assert
        .dom('[data-test-item-0] [data-component="form-feedback"]')
        .doesNotExist('the first element is unaffected');

      await fillIn('[data-test-item-1-input]', 'abcd');

      assert
        .dom('[data-test-item-1] [data-component="form-feedback"]')
        .doesNotExist('the error clears once the element becomes valid');
    });

    module('prototype pollution', function (hooks) {
      // A regression here writes to a shared global, which would silently
      // corrupt every test that runs afterwards. Scrub the targets.
      hooks.afterEach(function () {
        delete (Object.prototype as Record<string, unknown>)['isAdmin'];
      });

      test('a hostile field name cannot pollute Object.prototype', async function (assert) {
        // Apps that render fields from a server-supplied schema, a CMS, or URL
        // state let untrusted input choose the `name` attribute.
        let lastData: Record<string, unknown> | undefined;

        class TestComponent extends Component {
          handleChange = (data: FormResultData<Record<string, unknown>>) => {
            lastData = data.data;
          };

          handleSubmit = (data: FormResultData<Record<string, unknown>>) => {
            lastData = data.data;
          };

          <template>
            <Form
              @onChange={{this.handleChange}}
              @onSubmit={{this.handleSubmit}}
              as |form|
            >
              <form.Field @name="__proto__.isAdmin" as |field|>
                <field.Input data-test-hostile />
              </form.Field>

              <form.Field @name="email" as |field|>
                <field.Input data-test-email />
              </form.Field>

              <button type="submit" data-test-submit>Submit</button>
            </Form>
          </template>
        }

        await render(<template><TestComponent /></template>);

        await fillIn('[data-test-hostile]', 'true');
        await fillIn('[data-test-email]', 'john@example.com');

        assert.strictEqual(
          ({} as Record<string, unknown>)['isAdmin'],
          undefined,
          'typing into the hostile field did not pollute Object.prototype'
        );

        await click('[data-test-submit]');

        assert.strictEqual(
          ({} as Record<string, unknown>)['isAdmin'],
          undefined,
          'submitting did not pollute Object.prototype'
        );
        assert.notOk(
          Object.prototype.hasOwnProperty.call(lastData ?? {}, '__proto__'),
          'no own __proto__ key reaches the consumer data'
        );
        assert.strictEqual(
          lastData?.['email'],
          'john@example.com',
          'safe fields still come through'
        );
      });
    });
  }
);
