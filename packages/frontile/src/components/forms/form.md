---
label: New
imports:
  - import Signature from 'site/components/signature';
---

# Form

Form wraps a native `<form>` element, serializes its fields with `form-data-utils`, and hands
the result to `@onChange` on every change and `@onSubmit` on submission. Through the yielded
`Field` component it also runs validation and tracks which fields the user has modified.

## Import

```js
import { Form } from 'frontile';
```

## Usage

Give every control a `@name` and Form collects it. `@onSubmit` is the only required argument;
it receives the serialized data and the `SubmitEvent`, with `preventDefault()` already applied.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Button, Form, Input, type FormResultData } from 'frontile';

export default class SimpleForm extends Component {
  @tracked submitted: FormResultData | null = null;

  handleSubmit = (data: FormResultData) => {
    this.submitted = data;
  };

  <template>
    <div class='flex flex-col gap-4 w-80'>
      <Form @onSubmit={{this.handleSubmit}}>
        <div class='flex flex-col gap-4'>
          <Input @name='firstName' @label='First Name' />
          <Input @name='email' @label='Email' @type='email' />
          <Button type='submit'>Submit</Button>
        </div>
      </Form>

      {{#if this.submitted}}
        <pre class='p-4 bg-neutral-subtle rounded text-sm'>{{JSON.stringify
            this.submitted.data
            null
            2
          }}</pre>
      {{/if}}
    </div>
  </template>
}
```

## Controlled and Uncontrolled Forms

Passing `@onChange` makes the form controlled: you own the state, and the data you assign back
to `@data` flows into the inputs. Reach for it when you need the values as they are typed —
live previews, dependent fields, computed summaries.

Without `@onChange` the form is uncontrolled. `@data` seeds the initial values, Form keeps the
current values internally, and you only see them in `@onSubmit`. Both patterns support
`@schema` and `@validate`.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Form, Input, Select, type FormResultData } from 'frontile';
import { Button } from 'frontile';

export default class BasicForm extends Component {
  @tracked formData: FormResultData = {};
  @tracked submittedData: FormResultData = {};
  @tracked selectedCountry: string | null = null;

  countries = [
    { label: 'United States', key: 'us' },
    { label: 'Canada', key: 'ca' },
    { label: 'United Kingdom', key: 'uk' },
    { label: 'Australia', key: 'au' }
  ];

  handleFormChange = (data: FormResultData, event: Event) => {
    this.formData = data;
    console.log('Form input:', { data, event });
  };

  handleFormSubmit = (data: FormResultData, event: SubmitEvent) => {
    this.submittedData = data;
    console.log('Form submit:', { data, event });
  };

  handleCountryChange = (selectedKey: string | null) => {
    this.selectedCountry = selectedKey;
  };

  <template>
    <div class='flex flex-col gap-4 w-80'>
      <Form
        @onChange={{this.handleFormChange}}
        @onSubmit={{this.handleFormSubmit}}
      >
        <div class='flex flex-col gap-4'>
          <Input @name='firstName' @label='First Name' />
          <Input @name='lastName' @label='Last Name' />
          <Input @name='email' @label='Email' @type='email' />

          <Select
            @name='country'
            @label='Country'
            @items={{this.countries}}
            @placeholder='Select your country'
            @selectedKey={{this.selectedCountry}}
            @onSelectionChange={{this.handleCountryChange}}
          />

          <Button type='submit'>
            Submit
          </Button>
        </div>
      </Form>

      <div class='grid gap-4'>
        <div class='p-4 bg-neutral-subtle rounded'>
          <h4 class='font-medium mb-2'>Current Form Data:</h4>
          <pre class='text-sm'>{{JSON.stringify this.formData null 2}}</pre>
        </div>

        <div class='p-4 bg-success-subtle rounded'>
          <h4 class='font-medium mb-2'>Last Submitted Data:</h4>
          <pre class='text-sm'>{{JSON.stringify
              this.submittedData
              null
              2
            }}</pre>
        </div>
      </div>
    </div>
  </template>
}
```

## Form Components

Every Frontile form component participates, as do plain HTML form elements. Data types follow
the markup: text inputs give strings, checkboxes and switches booleans, multi-selects arrays,
file inputs `File` objects.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import {
  Form,
  Input,
  Textarea,
  Checkbox,
  CheckboxGroup,
  RadioGroup,
  NativeSelect,
  Select,
  type FormResultData
} from 'frontile';
import { Button } from 'frontile';

export default class ComprehensiveForm extends Component {
  @tracked formData: FormResultData = {};
  @tracked lastEventType = '';
  @tracked selectedSkillLevel: string | null = null;

  countries = [
    'United States',
    'Canada',
    'United Kingdom',
    'Australia',
    'Germany'
  ];

  skillLevels = [
    { label: 'Beginner (0-1 years)', key: 'beginner' },
    { label: 'Intermediate (2-5 years)', key: 'intermediate' },
    { label: 'Advanced (5+ years)', key: 'advanced' },
    { label: 'Expert (10+ years)', key: 'expert' }
  ];

  handleFormChange = (data: FormResultData, event: Event) => {
    this.formData = data;
    this.lastEventType = 'input';
    console.log('Form input:', { data, event });
  };

  handleFormSubmit = (data: FormResultData, event: SubmitEvent) => {
    this.formData = data;
    this.lastEventType = 'submit';
    console.log('Form submit:', { data, event });
  };

  handleSkillLevelChange = (selectedKey: string | null) => {
    this.selectedSkillLevel = selectedKey;
  };

  <template>
    <div class='flex flex-col gap-4'>
      <Form
        @onChange={{this.handleFormChange}}
        @onSubmit={{this.handleFormSubmit}}
      >
        <div class='flex flex-col gap-4'>

          <div class='grid grid-cols-1 md:grid-cols-2 gap-4'>
            <Input @name='firstName' @label='First Name' />
            <Input @name='lastName' @label='Last Name' />
          </div>

          <Input @name='email' @label='Email Address' @type='email' />

          <Textarea
            @name='bio'
            @label='Biography'
            @description='Tell us about yourself'
            rows='4'
          />

          <NativeSelect
            @name='country'
            @label='Country'
            @items={{this.countries}}
            @placeholder='Select a country'
          />

          <Select
            @name='skillLevel'
            @label='Skill Level'
            @items={{this.skillLevels}}
            @placeholder='Select your skill level'
            @selectedKey={{this.selectedSkillLevel}}
            @onSelectionChange={{this.handleSkillLevelChange}}
          />

          <RadioGroup @name='experience' @label='Experience Level' as |Radio|>
            <Radio @label='Beginner' @value='beginner' />
            <Radio @label='Intermediate' @value='intermediate' />
            <Radio @label='Advanced' @value='advanced' />
          </RadioGroup>

          <CheckboxGroup
            @name='interests'
            @label='Areas of Interest'
            as |Checkbox|
          >
            <Checkbox @name='frontend' @label='Frontend Development' />
            <Checkbox @name='backend' @label='Backend Development' />
            <Checkbox @name='mobile' @label='Mobile Development' />
            <Checkbox @name='design' @label='UI/UX Design' />
          </CheckboxGroup>

          <div class='flex items-center gap-4'>
            <Checkbox @name='subscribe' @label='Subscribe to newsletter' />
            <Checkbox
              @name='terms'
              @label='I agree to the terms and conditions'
            />
          </div>

          <Button type='submit'>
            Submit Application
          </Button>
        </div>
      </Form>

      <div class='p-4 bg-neutral-subtle rounded'>
        <div class='flex justify-between items-center mb-2'>
          <h4 class='font-medium'>Form Data</h4>
          <span class='text-sm text-neutral'>
            Last event:
            <strong>{{this.lastEventType}}</strong>
          </span>
        </div>
        <pre class='text-sm overflow-auto max-h-64'>{{JSON.stringify
            this.formData
            null
            2
          }}</pre>
      </div>
    </div>
  </template>
}
```

## Validation

Validation is built in — running it on the right events, mapping issues back to fields, and
rendering the messages — but the schema is yours. Any
[Standard Schema](https://standardschema.dev/) library works; the examples use
[Valibot](https://valibot.dev/). `@validate` adds a hand-rolled check on top, for rules a
schema can't express (comparing two fields, for instance) and returns Standard Schema issues.

Built-in validation requires the yielded `Field` component — it is what binds a field's errors
to its control. See [Field](field) for its own arguments and more examples.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { array } from '@ember/helper';
import {
  Form,
  Input,
  Checkbox,
  Select,
  type FormResultData,
  type FormErrors
} from 'frontile';
import { Button } from 'frontile';
import * as v from 'valibot';

// Valibot schema for form validation
const schema = v.object({
  name: v.pipe(
    v.string(),
    v.nonEmpty('Name is required'),
    v.minLength(2, 'Name must be at least 2 characters')
  ),
  email: v.pipe(
    v.string(),
    v.nonEmpty('Email is required'),
    v.email('Please enter a valid email address')
  ),
  password: v.pipe(
    v.string(),
    v.nonEmpty('Password is required'),
    v.minLength(6, 'Password must be at least 6 characters'),
    v.regex(/[A-Z]/, 'Password must contain at least one uppercase letter'),
    v.regex(/[a-z]/, 'Password must contain at least one lowercase letter'),
    v.regex(/\d/, 'Password must contain at least one number')
  ),
  accountType: v.pipe(
    v.fallback(v.string(), ''),
    v.string(),
    v.nonEmpty('Please select an account type')
  ),
  communicationChannels: v.pipe(
    v.array(v.string()),
    v.minLength(1, 'Please select at least one communication channel')
  ),
  terms: v.pipe(
    v.boolean(),
    v.literal(true, 'You must accept the terms and conditions')
  )
});

type Schema = v.InferOutput<typeof schema>;

export default class ValidatedForm extends Component {
  // Provide a complete initial state for proper dirty tracking
  @tracked formData: Schema = {
    name: '',
    email: '',
    password: '',
    confirmPassword: '',
    accountType: '',
    communicationChannels: ['SMS'],
    terms: false
  };

  @tracked submitMessage = '';

  accountTypes = [
    { label: 'Personal', key: 'personal' },
    { label: 'Business', key: 'business' },
    { label: 'Enterprise', key: 'enterprise' }
  ];

  communicationChannels = [
    { label: 'Email', key: 'Email' },
    { label: 'SMS', key: 'SMS' },
    { label: 'Phone', key: 'Phone' },
    { label: 'Push Notifications', key: 'Push' }
  ];

  customValidator(data: FormResultData<Schema>) {
    if (data['password'] !== data['confirmPassword']) {
      return [
        {
          message: 'Passwords must match',
          path: [{ key: 'confirmPassword' }]
        }
      ];
    }
  }

  handleFormChange = (data: FormResultData<Schema>, event: Event) => {
    this.formData = data.data;
    console.log('Form input:', { data, event });
  };

  handleFormSubmit = async (
    data: FormResultData<Schema>,
    event: SubmitEvent
  ) => {
    // Simulate API call
    await new Promise((resolve) => setTimeout(resolve, 1000));
    this.submitMessage = 'Account created successfully!';
    console.log('Form submitted successfully:', data);
  };

  handleFormError = (errors: FormErrors, data: Schema, event: SubmitEvent) => {
    console.log('Validation errors:', errors);
  };

  get isSuccessMessage() {
    return this.submitMessage.includes('success');
  }

  <template>
    <div class='flex flex-col gap-4 w-80'>
      <Form
        @data={{this.formData}}
        @schema={{schema}}
        @validate={{this.customValidator}}
        @onChange={{this.handleFormChange}}
        @onSubmit={{this.handleFormSubmit}}
        @onError={{this.handleFormError}}
        as |form|
      >
        <div class='flex flex-col gap-4'>
          <form.Field @name='name' as |field|>
            <field.Input @label='Full Name' @isRequired={{true}} />
          </form.Field>

          <form.Field @name='email' as |field|>
            <field.Input
              @label='Email Address'
              @type='email'
              @isRequired={{true}}
            />
          </form.Field>

          <form.Field
            @name='password'
            @validateOn={{array 'input' 'blur'}}
            as |field|
          >
            <field.Input
              @label='Password'
              @type='password'
              @isRequired={{true}}
            />
          </form.Field>

          <form.Field @name='confirmPassword' as |field|>
            <field.Input
              @label='Confirm Password'
              @type='password'
              @isRequired={{true}}
            />
          </form.Field>

          <form.Field @name='accountType' as |field|>
            <field.SingleSelect
              @label='Account Type'
              @items={{this.accountTypes}}
              @allowEmpty={{true}}
              @placeholder='Select account type'
              @isRequired={{true}}
            />
          </form.Field>

          <form.Field @name='communicationChannels' as |field|>
            <field.MultiSelect
              @label='Preferred Communication Channels'
              @items={{this.communicationChannels}}
              @isRequired={{true}}
            />
          </form.Field>

          <form.Field @name='terms' as |field|>
            <field.Checkbox
              @label='I agree to the terms and conditions'
              @isRequired={{true}}
            />
          </form.Field>

          <Button type='submit' disabled={{form.isLoading}} @class='mt-4'>
            {{if form.isLoading 'Creating Account...' 'Create Account'}}
          </Button>

          <Button @appearance='outlined' type='reset'>Reset</Button>
        </div>
      </Form>

      {{#if this.submitMessage}}
        <div
          class='p-4 rounded
            {{if
              this.isSuccessMessage
              "bg-success-subtle text-success-strong"
              "bg-danger-subtle text-danger-strong"
            }}'
        >
          {{this.submitMessage}}
        </div>
      {{/if}}
    </div>
  </template>
}
```

### Validation Timing

`@validateOn` controls which events trigger validation. It defaults to
`{{array 'change' 'blur' 'submit'}}`.

| Value    | Validates                                                                 |
| -------- | ------------------------------------------------------------------------- |
| `change` | one field, when its value was modified and it loses focus (HTML `change`) |
| `blur`   | one field, whenever it loses focus — even if nothing changed              |
| `input`  | one field, on every keystroke                                             |
| `submit` | the whole form; on failure `@onError` runs and `@onSubmit` does not       |

```gts
{{! validate as the user types, and again on submit }}
<Form
  @schema={{schema}}
  @validateOn={{array 'input' 'submit'}}
  @onSubmit={{this.handleSubmit}}
  as |form|
>
  <form.Field @name='password' as |field|>
    <field.Input @label='Password' @type='password' />
  </form.Field>
</Form>
```

Which to pick: `change` is the least intrusive and catches most mistakes; add `blur` to flag
required fields a user tabbed straight past; use `input` only where per-keystroke feedback
earns the noise, such as password strength. Drop `submit` for long forms where an error summary
on submit would be jarring.

An empty array (`@validateOn={{array}}`) skips validation entirely: `@onSubmit` is called
regardless of validity and `@onError` never fires. That's the path for multi-step forms, draft
saves, or validating by hand inside `@onSubmit`. Everything else — dirty tracking, reset, data
snapshots — keeps working.

Two limits worth knowing: the field-level values (`change`, `blur`, `input`) need
`form.Field`, and [CheckboxGroup](checkbox-group) validates only on submit.

## Dirty Field Tracking

`form.dirty` is a `Set` of the fields whose value differs from the initial `@data`. Tracking
covers only the keys present in that initial data, so a field you never seeded is never
reported dirty. Submitting clears the set.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Form, Input, Checkbox, type FormResultData } from 'frontile';
import { Button } from 'frontile';

export default class DirtyTrackingForm extends Component {
  @tracked formData = {
    username: 'john_doe',
    email: 'john@example.com',
    notifications: true
  };

  handleFormChange = (data: FormResultData, event: Event) => {
    console.log('Dirty fields:', Array.from(data.dirty));
  };

  handleFormSubmit = (data: FormResultData, event: SubmitEvent) => {
    console.log('Submitted data:', data);
    // Reset dirty state by updating formData with submitted values
    this.formData = data.data;
  };

  <template>
    <div class='flex flex-col gap-4 w-96'>
      <Form
        @data={{this.formData}}
        @onChange={{this.handleFormChange}}
        @onSubmit={{this.handleFormSubmit}}
        as |form|
      >
        <div class='flex flex-col gap-4'>
          <form.Field @name='username' as |field|>
            <field.Input @label='Username' />
          </form.Field>

          <form.Field @name='email' as |field|>
            <field.Input @label='Email' @type='email' />
          </form.Field>

          <form.Field @name='notifications' as |field|>
            <field.Checkbox @label='Enable email notifications' />
          </form.Field>

          <Button type='submit'>
            Save Changes
          </Button>
        </div>

        <div
          class='mt-4 p-4 rounded
            {{if form.dirty.size "bg-warning-subtle" "bg-neutral-subtle"}}'
        >
          {{#if form.dirty.size}}
            <p class='font-medium text-warning-strong'>
              Unsaved changes in:
              {{#each form.dirty as |field|}}
                <span
                  class='inline-block px-2 py-1 bg-warning-subtle rounded text-sm ml-1'
                >
                  {{field}}
                </span>
              {{/each}}
            </p>
          {{else}}
            <p class='text-neutral'>No unsaved changes</p>
          {{/if}}
        </div>
      </Form>
    </div>
  </template>
}
```

## Validating Without a Schema

`Field` is unnecessary when you are not using built-in validation. Pass `@errors` to each
control yourself and you keep full control of when and how validation runs.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Form, Input, Checkbox, type FormResultData } from 'frontile';
import { Button } from 'frontile';

export default class CustomHandlingForm extends Component {
  @tracked formData: FormResultData = {};
  @tracked validationErrors: Record<string, string[]> = {};
  @tracked submitCount = 0;

  handleFormChange = (data: FormResultData, event: Event) => {
    this.formData = data;

    console.log('Form input event:', {
      data,
      timestamp: new Date(),
      target: event.target
    });

    this.handleRealTimeValidation(data);
  };

  handleFormSubmit = async (data: FormResultData, event: SubmitEvent) => {
    this.formData = data;

    console.log('Form submit event:', {
      data,
      timestamp: new Date(),
      target: event.target
    });

    await this.handleFormSubmission(data, event);
  };

  handleRealTimeValidation = (data: FormResultData) => {
    const errors: Record<string, string[]> = {};

    // Real-time email validation
    if (data['data']['email'] && typeof data['data']['email'] === 'string') {
      if (!data['data']['email'].includes('@')) {
        errors.email = ['Email must contain @ symbol'];
      } else if (!data['data']['email'].includes('.')) {
        errors.email = ['Email must contain a domain'];
      }
    }

    // Real-time password validation
    if (
      data['data']['password'] &&
      typeof data['data']['password'] === 'string'
    ) {
      const password = data['data']['password'];
      const passwordErrors = [];

      if (password.length < 8) {
        passwordErrors.push('At least 8 characters');
      }
      if (!/[A-Z]/.test(password)) {
        passwordErrors.push('At least one uppercase letter');
      }
      if (!/[a-z]/.test(password)) {
        passwordErrors.push('At least one lowercase letter');
      }
      if (!/\d/.test(password)) {
        passwordErrors.push('At least one number');
      }

      if (passwordErrors.length > 0) {
        errors.password = passwordErrors;
      }
    }

    this.validationErrors = errors;
  };

  handleFormSubmission = async (data: FormResultData, event: SubmitEvent) => {
    this.submitCount += 1;

    // Comprehensive validation on submit
    const errors: Record<string, string[]> = {};

    if (
      !data['data']['username'] ||
      typeof data['data']['username'] !== 'string' ||
      data['data']['username'].length < 3
    ) {
      errors.username = ['Username must be at least 3 characters'];
    }

    if (
      !data['data']['email'] ||
      typeof data['data']['email'] !== 'string' ||
      !data['data']['email'].includes('@')
    ) {
      errors.email = ['Valid email is required'];
    }

    if (!data['data']['agreeToTerms']) {
      errors.agreeToTerms = ['You must agree to the terms'];
    }

    if (Object.keys(errors).length > 0) {
      this.validationErrors = errors;
      return;
    }

    try {
      // Simulate API call
      await new Promise((resolve) => setTimeout(resolve, 2000));

      // Reset form on successful submission
      this.formData = {};
      this.validationErrors = {};
    } catch (error) {
      console.error('Submission failed:', error);
    }
  };

  or(a: unknown, b: unknown) {
    return a || b;
  }

  get hasValidationErrors() {
    return (
      this.validationErrors && Object.keys(this.validationErrors).length > 0
    );
  }

  <template>
    <div class='flex flex-col gap-4'>
      <Form
        @onChange={{this.handleFormChange}}
        @onSubmit={{this.handleFormSubmit}}
        as |form|
      >
        <div class='flex flex-col gap-4'>

          <Input
            @name='username'
            @label='Username'
            @errors={{this.validationErrors.username}}
            @description='Must be at least 3 characters'
          />

          <Input
            @name='email'
            @label='Email'
            @type='email'
            @errors={{this.validationErrors.email}}
          />

          <Input
            @name='password'
            @label='Password'
            @type='password'
            @errors={{this.validationErrors.password}}
            @description='Must contain uppercase, lowercase, and number'
          />

          <Checkbox
            @name='agreeToTerms'
            @label='I agree to the terms and conditions'
            @errors={{this.validationErrors.agreeToTerms}}
          />

          <Button
            type='submit'
            disabled={{this.or form.isLoading this.hasValidationErrors}}
          >
            {{#if form.isLoading}}
              Submitting...
              {{this.submitCount}}
            {{else}}
              Submit Form
            {{/if}}
          </Button>
        </div>
      </Form>
    </div>
  </template>
}
```

## Nested Fields

Nested data is addressed with dot notation: `@name='user.profile.email'`. Form flattens the
object internally and unflattens it again for `@onChange` and `@onSubmit`, so your schema and
your `@data` keep the shape you actually want. Errors and dirty entries are keyed by the same
dotted path down to the leaf — `user.name.first`, never just `user`.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Form, type FormResultData } from 'frontile';
import { Button } from 'frontile';

const formData = {
  user: {
    name: {
      first: 'John',
      last: 'Doe'
    },
    email: 'john@example.com'
  },
  preferences: {
    theme: 'light',
    notifications: true
  }
};

export default class NestedForm extends Component {
  @tracked formData = formData;

  @tracked submittedData = {};

  handleFormChange = (data: FormResultData<typeof formData>) => {
    this.formData = data.data;
  };

  handleFormSubmit = (data: FormResultData<typeof formData>) => {
    this.submittedData = data.data;
  };

  <template>
    <div class='flex flex-col gap-4 w-96'>
      <Form
        @data={{this.formData}}
        @onChange={{this.handleFormChange}}
        @onSubmit={{this.handleFormSubmit}}
        as |form|
      >
        <div class='flex flex-col gap-4'>
          <h3 class='text-lg font-semibold'>User Information</h3>

          <form.Field @name='user.name.first' as |field|>
            <field.Input @label='First Name' />
          </form.Field>

          <form.Field @name='user.name.last' as |field|>
            <field.Input @label='Last Name' />
          </form.Field>

          <form.Field @name='user.email' as |field|>
            <field.Input @label='Email' @type='email' />
          </form.Field>

          <h3 class='text-lg font-semibold mt-4'>Preferences</h3>

          <form.Field @name='preferences.theme' as |field|>
            <field.Input @label='Theme' />
          </form.Field>

          <form.Field @name='preferences.notifications' as |field|>
            <field.Checkbox @label='Enable notifications' />
          </form.Field>

          {{#if form.dirty.size}}
            <div class='p-3 bg-warning-subtle rounded text-sm'>
              <strong>Unsaved changes in:</strong>
              {{#each form.dirty as |field|}}
                <span
                  class='inline-block px-2 py-1 bg-warning-subtle rounded ml-1'
                >
                  {{field}}
                </span>
              {{/each}}
            </div>
          {{/if}}

          <Button type='submit'>
            Save Changes
          </Button>
        </div>
      </Form>

      <div class='p-4 bg-neutral-subtle rounded'>
        <h4 class='font-medium mb-2'>Submitted Data:</h4>
        <pre class='text-sm overflow-auto'>{{JSON.stringify
            this.submittedData
            null
            2
          }}</pre>
      </div>
    </div>
  </template>
}
```

### Nested Fields with Validation

Mirror the data shape in the schema and issues land on the right control.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Form, type FormResultData, type FormErrors } from 'frontile';
import { Button } from 'frontile';
import * as v from 'valibot';

// Define nested schema
const userSchema = v.object({
  profile: v.object({
    firstName: v.pipe(
      v.string(),
      v.nonEmpty('First name is required'),
      v.minLength(2, 'Must be at least 2 characters')
    ),
    lastName: v.pipe(v.string(), v.nonEmpty('Last name is required')),
    contact: v.object({
      email: v.pipe(
        v.string(),
        v.nonEmpty('Email is required'),
        v.email('Must be a valid email address')
      ),
      phone: v.pipe(
        v.string(),
        v.nonEmpty('Phone is required'),
        v.regex(/^\+?[\d\s-()]+$/, 'Must be a valid phone number')
      )
    })
  }),
  settings: v.object({
    newsletter: v.boolean()
  })
});

type UserSchema = v.InferOutput<typeof userSchema>;

export default class ValidatedNestedForm extends Component {
  @tracked formData: UserSchema = {
    profile: {
      firstName: '',
      lastName: '',
      contact: {
        email: '',
        phone: ''
      }
    },
    settings: {
      newsletter: false
    }
  };

  @tracked submitMessage = '';

  handleFormSubmit = async (data: FormResultData<UserSchema>) => {
    // Simulate API call
    await new Promise((resolve) => setTimeout(resolve, 1000));
    this.submitMessage = 'Profile updated successfully!';
    console.log('Submitted nested data:', data.data);
  };

  handleFormError = (errors: FormErrors) => {
    this.submitMessage = '';
    console.log('Validation errors:', errors);
  };

  <template>
    <div class='flex flex-col gap-4 w-96'>
      <Form
        @data={{this.formData}}
        @schema={{userSchema}}
        @onSubmit={{this.handleFormSubmit}}
        @onError={{this.handleFormError}}
        as |form|
      >
        <div class='flex flex-col gap-4'>
          <div>
            <h3 class='text-lg font-semibold mb-3'>Profile Information</h3>

            <div class='flex flex-col gap-4'>
              <form.Field @name='profile.firstName' as |field|>
                <field.Input @label='First Name' @isRequired={{true}} />
              </form.Field>

              <form.Field @name='profile.lastName' as |field|>
                <field.Input @label='Last Name' @isRequired={{true}} />
              </form.Field>
            </div>
          </div>

          <div>
            <h3 class='text-lg font-semibold mb-3'>Contact Information</h3>

            <div class='flex flex-col gap-4'>
              <form.Field @name='profile.contact.email' as |field|>
                <field.Input
                  @label='Email Address'
                  @type='email'
                  @isRequired={{true}}
                />
              </form.Field>

              <form.Field @name='profile.contact.phone' as |field|>
                <field.Input
                  @label='Phone Number'
                  @type='tel'
                  @isRequired={{true}}
                />
              </form.Field>
            </div>
          </div>

          <div>
            <h3 class='text-lg font-semibold mb-3'>Settings</h3>

            <form.Field @name='settings.newsletter' as |field|>
              <field.Checkbox @label='Subscribe to newsletter' />
            </form.Field>
          </div>

          <Button type='submit' disabled={{form.isLoading}}>
            {{if form.isLoading 'Saving...' 'Save Profile'}}
          </Button>
        </div>
      </Form>

      {{#if this.submitMessage}}
        <div class='p-4 bg-success-subtle text-success-strong rounded'>
          {{this.submitMessage}}
        </div>
      {{/if}}
    </div>
  </template>
}
```

### Mixing Flat and Nested Fields

Flat and nested names can sit side by side in one form.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Form, type FormResultData } from 'frontile';
import { Button } from 'frontile';

const formData = {
  // Flat fields
  username: 'johndoe',
  age: 30,
  // Nested fields
  address: {
    street: '123 Main St',
    city: 'Springfield',
    country: 'USA'
  },
  // Another flat field
  acceptTerms: true
};

export default class MixedFieldsForm extends Component {
  @tracked formData = formData;

  handleFormSubmit = (data: FormResultData<typeof formData>) => {
    console.log('Mixed data structure:', data.data);
  };

  <template>
    <div class='w-96'>
      <Form
        @data={{this.formData}}
        @onSubmit={{this.handleFormSubmit}}
        as |form|
      >
        <div class='flex flex-col gap-4'>
          {{! Flat fields }}
          <form.Field @name='username' as |field|>
            <field.Input @label='Username' />
          </form.Field>

          <form.Field @name='age' as |field|>
            <field.Input @label='Age' @type='number' />
          </form.Field>

          {{! Nested fields }}
          <h3 class='text-lg font-semibold mt-2'>Address</h3>

          <form.Field @name='address.street' as |field|>
            <field.Input @label='Street' />
          </form.Field>

          <form.Field @name='address.city' as |field|>
            <field.Input @label='City' />
          </form.Field>

          <form.Field @name='address.country' as |field|>
            <field.Input @label='Country' />
          </form.Field>

          {{! Another flat field }}
          <form.Field @name='acceptTerms' as |field|>
            <field.Checkbox @label='I accept the terms and conditions' />
          </form.Field>

          <Button type='submit'>Submit</Button>
        </div>
      </Form>
    </div>
  </template>
}
```

## Resetting Forms

`form.reset` calls the native form reset, restores `@data`'s initial values, clears validation
errors, and empties the dirty set. In a controlled form it reports the initial data back through
`@onChange`; in an uncontrolled one it updates the internal state. With no `@data` at all it
just clears the fields.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Form, type FormResultData } from 'frontile';
import { Button } from 'frontile';
import { on } from '@ember/modifier';

export default class ResetForm extends Component {
  @tracked formData = {
    username: 'johndoe',
    email: 'john@example.com',
    bio: 'Software developer'
  };

  handleChange = (data: FormResultData<typeof this.formData>) => {
    this.formData = data.data;
  };

  handleSubmit = (data: FormResultData<typeof this.formData>) => {
    console.log('Form submitted:', data.data);
  };

  <template>
    <div class='flex flex-col gap-4 w-96'>
      <Form
        @data={{this.formData}}
        @onChange={{this.handleChange}}
        @onSubmit={{this.handleSubmit}}
        as |form|
      >
        <div class='flex flex-col gap-4'>
          <form.Field @name='username' as |field|>
            <field.Input @label='Username' />
          </form.Field>

          <form.Field @name='email' as |field|>
            <field.Input @label='Email' @type='email' />
          </form.Field>

          <form.Field @name='bio' as |field|>
            <field.Textarea @label='Bio' rows='4' />
          </form.Field>

          {{#if form.dirty.size}}
            <div class='p-3 bg-warning-subtle rounded text-sm'>
              You have unsaved changes
            </div>
          {{/if}}

          <div class='flex gap-2'>
            <Button type='submit'>
              Save Changes
            </Button>
            <Button
              type='button'
              @intent='default'
              @appearance='outlined'
              {{on 'click' form.reset}}
            >
              Reset
            </Button>
          </div>
        </div>
      </Form>
    </div>
  </template>
}
```

### Reset with Validation

Errors already on screen are cleared along with the values.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Form, type FormResultData, type FormErrors } from 'frontile';
import { Button } from 'frontile';
import { on } from '@ember/modifier';
import * as v from 'valibot';

const schema = v.object({
  email: v.pipe(
    v.string(),
    v.nonEmpty('Email is required'),
    v.email('Must be a valid email address')
  ),
  password: v.pipe(
    v.string(),
    v.nonEmpty('Password is required'),
    v.minLength(8, 'Password must be at least 8 characters')
  )
});

type Schema = v.InferOutput<typeof schema>;

export default class ResetValidationForm extends Component {
  @tracked formData: Schema = {
    email: 'user@example.com',
    password: 'password123'
  };

  handleChange = (data: FormResultData<Schema>) => {
    this.formData = data.data;
  };

  handleSubmit = (data: FormResultData<Schema>) => {
    console.log('Form submitted:', data.data);
  };

  handleError = (errors: FormErrors) => {
    console.log('Validation errors:', errors);
  };

  <template>
    <div class='flex flex-col gap-4 w-96'>
      <Form
        @data={{this.formData}}
        @schema={{schema}}
        @onChange={{this.handleChange}}
        @onSubmit={{this.handleSubmit}}
        @onError={{this.handleError}}
        as |form|
      >
        <div class='flex flex-col gap-4'>
          <form.Field @name='email' as |field|>
            <field.Input @label='Email' @type='email' @isRequired={{true}} />
          </form.Field>

          <form.Field @name='password' as |field|>
            <field.Input
              @label='Password'
              @type='password'
              @isRequired={{true}}
            />
          </form.Field>

          <div class='flex gap-2'>
            <Button type='submit' disabled={{form.isLoading}}>
              {{if form.isLoading 'Saving...' 'Save'}}
            </Button>
            <Button
              type='button'
              @intent='default'
              @appearance='outlined'
              {{on 'click' form.reset}}
            >
              Reset
            </Button>
          </div>
        </div>
      </Form>
    </div>
  </template>
}
```

## Disabled Forms

`@disabled` disables every yielded `Field` and the control inside it at once — useful while a
submission is in flight, in read-only views, or for steps of a wizard that are already done. It
reaches `Field` children only; controls used without `Field` manage their own `disabled`.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { on } from '@ember/modifier';
import { Form, type FormResultData } from 'frontile';
import { Button } from 'frontile';
import * as v from 'valibot';

const schema = v.object({
  email: v.pipe(
    v.string(),
    v.nonEmpty('Email is required'),
    v.email('Please enter a valid email address')
  ),
  password: v.pipe(
    v.string(),
    v.nonEmpty('Password is required'),
    v.minLength(6, 'Password must be at least 6 characters')
  )
});

type Schema = v.InferOutput<typeof schema>;

export default class DisabledForm extends Component {
  @tracked formData: Schema = {
    email: '',
    password: ''
  };
  @tracked isFormDisabled = false;
  @tracked submitMessage = '';

  handleFormChange = (data: FormResultData<Schema>) => {
    this.formData = data.data;
  };

  handleFormSubmit = async (data: FormResultData<Schema>) => {
    // Simulate API call
    this.isFormDisabled = true;
    await new Promise((resolve) => setTimeout(resolve, 2000));
    this.submitMessage = 'Login successful!';
    this.isFormDisabled = false;
    console.log('Form submitted:', data);
  };

  toggleDisabled = () => {
    this.isFormDisabled = !this.isFormDisabled;
  };

  or(a: unknown, b: unknown) {
    return a || b;
  }

  <template>
    <div class='flex flex-col gap-4 w-80'>
      <div class='flex items-center gap-2 p-3 bg-neutral-subtle rounded'>
        <label class='flex items-center gap-2 cursor-pointer'>
          <input
            type='checkbox'
            checked={{this.isFormDisabled}}
            {{on 'change' this.toggleDisabled}}
            class='w-4 h-4'
          />
          <span class='text-sm font-medium'>Disable form</span>
        </label>
      </div>

      <Form
        @disabled={{this.isFormDisabled}}
        @data={{this.formData}}
        @schema={{schema}}
        @onChange={{this.handleFormChange}}
        @onSubmit={{this.handleFormSubmit}}
        as |form|
      >
        <div class='flex flex-col gap-4'>
          <form.Field @name='email' as |field|>
            <field.Input @label='Email' @type='email' @isRequired={{true}} />
          </form.Field>

          <form.Field @name='password' as |field|>
            <field.Input
              @label='Password'
              @type='password'
              @isRequired={{true}}
            />
          </form.Field>

          <Button
            type='submit'
            disabled={{this.or form.isLoading this.isFormDisabled}}
          >
            {{if form.isLoading 'Logging in...' 'Log In'}}
          </Button>
        </div>
      </Form>

      {{#if this.submitMessage}}
        <div class='p-4 bg-success-subtle text-success-strong rounded'>
          {{this.submitMessage}}
        </div>
      {{/if}}
    </div>
  </template>
}
```

## Feedback Messages

When a field fails validation, `Form`/`Field` render a `FormFeedback` with the `danger` intent
and an assertive `aria-live` region — no wiring needed.

For feedback that isn't a validation error — hints, confirmations, warnings — render
`FormFeedback` yourself and pick an `@intent` from `primary`, `secondary`, `tertiary`,
`success`, `warning`, or `danger`. Anything other than `danger` announces politely.

```gts preview
import { FormFeedback } from 'frontile';

<template>
  <div class='flex flex-col gap-2'>
    <FormFeedback @intent='primary' @messages='Your changes are being saved.' />
    <FormFeedback
      @intent='secondary'
      @messages='This field supports Markdown.'
    />
    <FormFeedback
      @intent='tertiary'
      @messages='This field supports Markdown.'
    />
    <FormFeedback @intent='success' @messages='Looks good!' />
    <FormFeedback
      @intent='warning'
      @messages='This username is close to the limit.'
    />
    <FormFeedback @intent='danger' @messages='This field is required.' />
  </div>
</template>
```

## Accessibility

Form renders a native `<form>`, so submission on <kbd>Enter</kbd>, field labelling, and
`...attributes` pass-through all behave natively.

- **Invalid fields** get `aria-invalid='true'` from `Field`, removed again once the field
  validates.
- **Error messages** render in a `FormFeedback` with `aria-live='assertive'` and are associated
  with the control, so a screen reader announces them as they appear.
- **Disabled fields** carry the real `disabled` attribute rather than a styling-only state.
- **Focus** is not managed or trapped by Form; it stays where the browser puts it. If you
  redirect focus to the first invalid field in `@onError`, see
  [focus management](/docs/accessibility/focus-management).

## API

The default block yields a context object:

| Property                | Description                                                       |
| ----------------------- | ----------------------------------------------------------------- |
| `data`                  | Current form data as key/value pairs                              |
| `isLoading`             | `true` while an async `@onSubmit` is in flight                    |
| `isValid` / `isInvalid` | Whether the form currently has validation errors                  |
| `errors`                | Validation errors keyed by field name                             |
| `dirty`                 | `Set` of fields changed from their initial values                 |
| `reset`                 | Resets values, errors, and dirty tracking                         |
| `Field`                 | The `Field` component, with `errors` and `formData` already bound |

<Signature @component="Form" />
