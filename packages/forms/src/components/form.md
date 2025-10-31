---
label: New
imports:
  - import Signature from 'site/components/signature';
---

# Form

A powerful form wrapper component that automatically handles form data extraction and provides real-time updates via dedicated `@onChange` and `@onSubmit` callbacks. It uses `form-data-utils` under the hood to serialize form data efficiently and supports all native HTML form elements as well as Frontile form components.

## Import

```js
import { Form } from 'frontile';
```

## Usage

### Basic Form

The most basic usage of the Form component with automatic data extraction.

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
        <div class='p-4 bg-default-50 rounded'>
          <h4 class='font-medium mb-2'>Current Form Data:</h4>
          <pre class='text-sm'>{{JSON.stringify this.formData null 2}}</pre>
        </div>

        <div class='p-4 bg-success-50 rounded'>
          <h4 class='font-medium mb-2'>Last Submitted Data:</h4>
          <pre class='text-sm'>{{JSON.stringify this.submittedData null 2}}</pre>
        </div>
      </div>
    </div>
  </template>
}
```

### Real-time Form Updates

The Form component provides real-time updates as users interact with form elements.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import {
  Form,
  Input,
  Checkbox,
  Select,
  type FormResultData
} from 'frontile';
import { Button } from 'frontile';

export default class RealtimeForm extends Component {
  @tracked inputData: FormResultData = {};
  @tracked submitData: FormResultData = {};
  @tracked selectedRole: string | null = null;

  roles = [
    { label: 'User', key: 'user' },
    { label: 'Admin', key: 'admin' },
    { label: 'Moderator', key: 'moderator' },
    { label: 'Guest', key: 'guest' }
  ];

  handleFormChange = (data: FormResultData, event: Event) => {
    this.inputData = data;
    console.log('Input event:', { data, event });
  };

  handleFormSubmit = (data: FormResultData, event: SubmitEvent) => {
    this.submitData = data;
    console.log('Submit event:', { data, event });
  };

  handleRoleChange = (selectedKey: string | null) => {
    this.selectedRole = selectedKey;
  };

  <template>
    <div class='flex flex-col gap-4'>
      <Form
        @onChange={{this.handleFormChange}}
        @onSubmit={{this.handleFormSubmit}}
      >
        <div class='flex flex-col gap-4'>
          <Input
            @name='username'
            @label='Username'
            placeholder='Enter username'
          />

          <Input
            @name='password'
            @label='Password'
            @type='password'
            placeholder='Enter password'
          />

          <Select
            @name='role'
            @label='User Role'
            @items={{this.roles}}
            @placeholder='Select your role'
            @selectedKey={{this.selectedRole}}
            @onSelectionChange={{this.handleRoleChange}}
          />

          <Checkbox @name='rememberMe' @label='Remember me' />

          <Checkbox
            @name='agreeToTerms'
            @label='I agree to the terms and conditions'
          />

          <Button type='submit'>
            Sign In
          </Button>
        </div>
      </Form>

      <div class='grid grid-cols-1 md:grid-cols-2 gap-4'>
        <div class='p-4 bg-warning-50 rounded'>
          <h4 class='font-medium mb-2'>Input Events (Real-time):</h4>
          <pre class='text-sm overflow-auto'>{{JSON.stringify
              this.inputData
              null
              2
            }}</pre>
        </div>

        <div class='p-4 bg-success-50 rounded'>
          <h4 class='font-medium mb-2'>Submit Events:</h4>
          <pre class='text-sm overflow-auto'>{{JSON.stringify
              this.submitData
              null
              2
            }}</pre>
        </div>
      </div>
    </div>
  </template>
}
```

### Form with All Component Types

Demonstrate how the Form component works with all Frontile form components.

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

      <div class='p-4 bg-default-50 rounded'>
        <div class='flex justify-between items-center mb-2'>
          <h4 class='font-medium'>Form Data</h4>
          <span class='text-sm text-default-600'>
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

### Form Validation Integration

The Form component works seamlessly with any [Standard Schema](https://standardschema.dev/)-compliant validation library, such as Valibot, for scalable form validation.  Frontile does not ship with a validation library by default, so you can choose which is right for you.  The only requirement is that it is compatible with Standard Schema.  _Validation logic_, however, is built in--concerns such as running validation on submit and blur events.  The following example demonstrates how to use Valibot for comprehensive form validation.  The use of hand-rolled custom validators is also supported.

**Note**:  When using built-in form validation, the `Field` component _must_ be used (see example below).  The `Field` component handles automatic error binding.  Use of `Field` is unnecessary when not using built-in form validation.  [Learn more about the `Field` component and see more form validation examples](field).

**Validation timing:** Most form components support field-level validation (validates on change/blur/input events). However, `CheckboxGroup` currently only supports validation on form submit, not field-level validation events. See the [CheckboxGroup](checkbox-group) and [Field](field) documentation for more details.

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
      return [{
        message: 'Passwords must match',
        path: [{ key: 'confirmPassword' }]
      }];
    }
  };

  handleFormChange = (data: FormResultData<Schema>, event: Event) => {
    this.formData = data.data;
    console.log('Form input:', { data, event });
  };

  handleFormSubmit = async (data: FormResultData<Schema>, event: SubmitEvent) => {
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
            <field.Input
              @label='Full Name'
              @isRequired={{true}}
            />
          </form.Field>

          <form.Field @name='email' as |field|>
            <field.Input
              @label='Email Address'
              @type='email'
              @isRequired={{true}}
            />
          </form.Field>

          <form.Field @name='password' @validateOn={{array 'input' 'blur'}} as |field|>
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

          <Button @appearance="outlined" type="reset">Reset</Button>
        </div>
      </Form>

      {{#if this.submitMessage}}
        <div
          class='p-4 rounded
            {{if
              this.isSuccessMessage
              "bg-success-100 text-success-800"
              "bg-danger-100 text-danger-800"
            }}'
        >
          {{this.submitMessage}}
        </div>
      {{/if}}
    </div>
  </template>
}
```

### Dirty Field Tracking

The Form component automatically tracks which fields have been modified by the user. This is useful for showing unsaved changes warnings or enabling/disabling submit buttons.

Enable dirty field tracking by specifying a field in the initial `@data` passed into a `Form` component.  Dirty tracking is enabled only for fields specified in initial data.

Dirty fields reset on submit.  After a sucessful submit, any tracked data is considered clean.

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

          <Button
            type='submit'
          >
            Save Changes
          </Button>
        </div>

        <div class='mt-4 p-4 rounded
        {{if form.dirty.size "bg-warning-50" "bg-default-50"}}'>
        {{#if form.dirty.size}}
          <p class='font-medium text-warning-800'>
            Unsaved changes in:
            {{#each form.dirty as |field|}}
              <span class='inline-block px-2 py-1 bg-warning-100 rounded text-sm ml-1'>
                {{field}}
              </span>
            {{/each}}
          </p>
        {{else}}
          <p class='text-default-600'>No unsaved changes</p>
        {{/if}}
      </div>
      </Form>
    </div>
  </template>
}
```

### Custom Form Handling

Advanced usage showing how to handle complex form logic and custom validation.

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
    if (data['data']['password'] && typeof data['data']['password'] === 'string') {
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

  or(a: unknown, b:unknown) {
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

          <Button type='submit' disabled={{this.or form.isLoading this.hasValidationErrors}}>
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

## Key Features

### Automatic Data Extraction

- Uses `form-data-utils` to automatically serialize form data
- Works with all HTML form elements and Frontile components
- Handles complex data types including arrays and nested objects

### Event Handling

- **`@onChange`**: Fired on every form input change for real-time updates and receives `(data, event)`
- **`@onSubmit`**: Fired when the form is submitted with `preventDefault()` applied and receives `(data, submitEvent)`
- Access to the original DOM event for advanced use cases in both handlers

### Data Types Support

- Strings, numbers, and booleans
- Arrays from multi-select elements
- Nested objects from grouped form elements
- File uploads (when using file inputs)

### Controlled vs Uncontrolled Forms

The Form component supports both controlled and uncontrolled patterns, similar to React form handling:

**Controlled Forms** (with `@onChange` + `@data`)
- You provide both `@data` and `@onChange`
- Form values are controlled by your component state
- You update state in `@onChange`, which flows back to form inputs
- Best for forms where you need to validate or transform data in real-time
- Example: `<Form @data={{this.formData}} @onChange={{this.handleChange}}>`

**Uncontrolled Forms** (without `@onChange`)
- You provide only `@data` for initial values (or omit it entirely)
- Form manages its own internal state
- You receive final data only in `@onSubmit`
- Simpler pattern for basic forms
- Example: `<Form @data={{this.initialData}} @onSubmit={{this.handleSubmit}}>`

**Choosing Between Patterns:**
- Use **controlled** when you need real-time form data access, validation as user types, or complex interdependent fields
- Use **uncontrolled** for simpler forms where you only care about the final submitted data
- Both patterns support validation via `@schema` and `@validate`

## Best Practices

### Form Validation

For scalable form validation, use built-in validation with a library that implements [Standard Schema](https://standardschema.dev/), such as [Valibot](https://valibot.dev/):

```gts
// Define a Valibot schema for type-safe validation
schema = v.object({
  email: v.pipe(
    v.string(),
    v.nonEmpty('Email is required'),
    v.email('Please enter a valid email address')
  ),
  password: v.pipe(
    v.string(),
    v.minLength(6, 'Password must be at least 6 characters')
  )
});

<template>
  <Form
    @schema={{schema}}
    as |form|
  >
    ...
  </Form>
</template>
```

### Validation Timing

By default, the Form component validates data both on field changes and form submission. You can control when validation runs using the `@validateOn` argument.

**Available options:**
- `change` - Validate individual fields when users change a value and blur/defocus the field (per-field validation)
- `input` - Validate individual fields as users type (real-time validation on every keystroke)
- `blur` - Validate individual fields when they lose focus, regardless of whether the value changed
- `submit` - Validate the entire form when submitted

**Default behavior:** `@validateOn={{array 'change' 'submit'}}` - validates on both field changes (blur) and form submission.

**Note on `'change'` vs `'blur'`:** The `'change'` option validates on the HTML `change` event, which fires when a field loses focus (blur) **only if** its value has been modified. The `'blur'` option validates on the HTML `blur` event, which fires whenever a field loses focus, regardless of whether the value changed. The `'input'` option validates on the HTML `input` event, which fires on every keystroke as the user types.

**Usage:**

```gts
// Default behavior - validates on both change and submit
<Form @schema={{schema}} @onSubmit={{this.handleSubmit}} as |form|>
  ...
</Form>

// Equivalent to default - explicit both change and submit
<Form
  @schema={{schema}}
  @validateOn={{array 'change' 'submit'}}
  @onSubmit={{this.handleSubmit}}
  as |form|
>
  ...
</Form>

// Change validation only - validate on blur after modification, but not on submit
<Form
  @schema={{schema}}
  @validateOn={{array 'change'}}
  @onSubmit={{this.handleSubmit}}
  as |form|
>
  ...
</Form>

// Blur validation only - validate on any focus loss, but not on submit
<Form
  @schema={{schema}}
  @validateOn={{array 'blur'}}
  @onSubmit={{this.handleSubmit}}
  as |form|
>
  ...
</Form>

// Input validation only - validate as users type, but not on submit
<Form
  @schema={{schema}}
  @validateOn={{array 'input'}}
  @onSubmit={{this.handleSubmit}}
  as |form|
>
  ...
</Form>

// Combined validation - validate on change, blur, AND as users type
<Form
  @schema={{schema}}
  @validateOn={{array 'change' 'blur' 'input' 'submit'}}
  @onSubmit={{this.handleSubmit}}
  as |form|
>
  ...
</Form>

// Submit validation only - validate only when form is submitted
<Form
  @schema={{schema}}
  @validateOn={{array 'submit'}}
  @onSubmit={{this.handleSubmit}}
  as |form|
>
  ...
</Form>

// Skip validation entirely by omitting a schema or setting `validateOn` to an
// empty array.  `onSubmit` is called regardless of data validity.
<Form
  @schema={{schema}}
  @validateOn={{array}}
  @onSubmit={{this.handleSubmit}}
  as |form|
>
  ...
</Form>
```

**Validation behavior details:**

**Change validation (`'change'`)**:
- Individual fields validate when users change a value and then blur/defocus the field
- Validation errors appear after the user moves to the next field
- Each field validates independently using its specific validation rules
- Provides feedback without waiting for form submission
- Uses the Field component's `handleChange` action to trigger validation
- Based on the HTML `change` event (fires on blur after value modification, not on every keystroke)

**Blur validation (`'blur'`)**:
- Individual fields validate whenever they lose focus, regardless of whether the value changed
- Validation errors appear immediately when the user tabs away or clicks outside the field
- Each field validates independently using its specific validation rules
- Provides feedback as users navigate between fields
- Uses the Field component's `handleBlur` action to trigger validation
- Based on the HTML `blur` event (fires whenever a field loses focus)
- Useful for ensuring fields are validated even when users skip over them without making changes

**Input validation (`'input'`)**:
- Individual fields validate as users type, on every keystroke
- Validation errors appear in real-time as the user types
- Each field validates independently using its specific validation rules
- Provides immediate feedback while the user is still focused on the field
- Uses the Field component's `handleInput` action to trigger validation
- Based on the HTML `input` event (fires on every keystroke)
- Best for fields where real-time feedback is valuable (e.g., password strength, character limits)

**Submit validation (`'submit'`)**:
- The entire form validates when the submit button is clicked
- All fields are validated together before calling `@onSubmit`
- If validation fails, `@onError` is called and `@onSubmit` is not called
- Validation errors are displayed for all invalid fields

**Common validation patterns:**

**On-blur validation (recommended for most forms):**
```gts
// Default - validates when field loses focus after modification AND on submit
<Form @schema={{schema}} @onSubmit={{this.handleSubmit}} as |form|>
  <form.Field @name="email" as |field|>
    <field.Input @label="Email" />
  </form.Field>
</Form>
```

**Explicit blur validation (validates on any focus loss):**
```gts
// Validates whenever field loses focus, even if value didn't change
// Useful for catching empty required fields as users navigate
<Form
  @schema={{schema}}
  @validateOn={{array 'blur' 'submit'}}
  @onSubmit={{this.handleSubmit}}
  as |form|
>
  <form.Field @name="email" as |field|>
    <field.Input @label="Email" />
  </form.Field>
</Form>
```

**Real-time validation (best for immediate feedback):**
```gts
// Validates as user types - great for password strength, character limits, etc.
<Form
  @schema={{schema}}
  @validateOn={{array 'input' 'submit'}}
  @onSubmit={{this.handleSubmit}}
  as |form|
>
  <form.Field @name="password" as |field|>
    <field.Input @label="Password" @type="password" />
  </form.Field>
</Form>
```

**Combined blur and input validation:**
```gts
// Validates both as user types AND when field loses focus
// Provides comprehensive feedback throughout the form-filling experience
<Form
  @schema={{schema}}
  @validateOn={{array 'blur' 'input' 'submit'}}
  @onSubmit={{this.handleSubmit}}
  as |form|
>
  <form.Field @name="password" as |field|>
    <field.Input @label="Password" @type="password" />
  </form.Field>
</Form>
```

**Submit-only validation (less intrusive for long forms):**
```gts
// Only validates on submit - users can fill entire form without interruption
<Form
  @schema={{schema}}
  @validateOn={{array 'submit'}}
  @onSubmit={{this.handleSubmit}}
  as |form|
>
  <form.Field @name="email" as |field|>
    <field.Input @label="Email" />
  </form.Field>
</Form>
```

**Manual validation (advanced use cases):**
```gts
// Skip automatic validation - handle it manually
<Form
  @schema={{schema}}
  @validateOn={{array}}
  @onSubmit={{this.handleSubmit}}
  as |form|
>
  ...
</Form>
```

**When to skip validation:**
- When you want to handle validation manually in your `@onSubmit` handler
- When building multi-step forms where validation should only run on the final step
- When you need to submit partial or draft data without validation

**Important notes:**
- When `@validateOn` includes `'change'`, `'blur'`, or `'input'`, you must use the `form.Field` component for automatic field-level validation
- When `@validateOn` is an empty array, validation is completely skipped and `@onError` will never be called
- All other form functionality (dirty state tracking, form reset, data snapshots) continues to work normally regardless of validation timing
- **Difference between `'change'` and `'blur'`:**
  - `'change'` validates only when a field's value has been modified AND the field loses focus
  - `'blur'` validates whenever a field loses focus, even if the value didn't change
  - Use `'blur'` to catch empty required fields as users navigate through the form
  - Use `'change'` for a less intrusive experience that only validates when users actually modify fields
- Change validation provides better user experience by catching errors as users move between fields
- Blur validation ensures all fields are validated as users navigate, even if they skip over fields
- Input validation provides immediate feedback but may be distracting for some use cases
- The `'change'` event fires when a field loses focus (blur) after being modified, not on every keystroke
- The `'blur'` event fires whenever a field loses focus, regardless of whether the value changed
- The `'input'` event fires on every keystroke as the user types
- Consider using `'input'` validation for fields where real-time feedback is valuable (password strength, character limits, username availability)
- Consider using `'blur'` validation when you want to ensure required fields are validated even if users skip over them

### Performance Considerations

- The Form component only re-renders when necessary
- Form data extraction is optimized using `form-data-utils`
- Consider debouncing input validation for complex forms

### Disabling Forms

The Form component supports disabling all form fields at once using the `@disabled` argument. This is useful for preventing user interaction during form submission or when certain conditions aren't met.

When `@disabled={{true}}` is passed to the Form component, all yielded Field components and their child form controls (Input, Checkbox, Select, Textarea, etc.) are automatically disabled.

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
      <div class='flex items-center gap-2 p-3 bg-default-100 rounded'>
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
            <field.Input
              @label='Email'
              @type='email'
              @isRequired={{true}}
            />
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
        <div class='p-4 bg-success-100 text-success-800 rounded'>
          {{this.submitMessage}}
        </div>
      {{/if}}
    </div>
  </template>
}
```

**Common use cases for disabled forms:**

- **During submission**: Disable the form while an async operation is in progress to prevent duplicate submissions
- **Conditional access**: Disable forms when user permissions or prerequisites aren't met
- **Read-only mode**: Show form data in a non-editable state
- **Multi-step forms**: Disable previous steps once completed

**Note:** The `@disabled` argument affects only the yielded `Field` components. If you're using individual form components without `Field`, you'll need to manage their disabled state separately.

## Nested Fields

The Form component fully supports nested data structures, allowing you to organize form data hierarchically while maintaining flat HTML form field names. Nested objects are automatically converted to dotted field notation (e.g., `user.profile.email`).

### Basic Nested Form

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
            <div class='p-3 bg-warning-50 rounded text-sm'>
              <strong>Unsaved changes in:</strong>
              {{#each form.dirty as |field|}}
                <span class='inline-block px-2 py-1 bg-warning-100 rounded ml-1'>
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

      <div class='p-4 bg-default-50 rounded'>
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

### Nested Form with Validation

Nested fields work seamlessly with validation schemas. Use nested object structures in your schema that match your data structure.

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
    lastName: v.pipe(
      v.string(),
      v.nonEmpty('Last name is required')
    ),
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
        <div class='p-4 bg-success-100 text-success-800 rounded'>
          {{this.submitMessage}}
        </div>
      {{/if}}
    </div>
  </template>
}
```

### Mixed Flat and Nested Fields

You can freely mix flat and nested fields in the same form. The Form component automatically detects and handles both structures.

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

### Key Points for Nested Fields

**Field Naming Convention:**
- Use dot notation for nested fields: `@name="user.profile.email"`
- Validation errors are automatically mapped to dotted field names
- Dirty tracking works at the leaf level (e.g., `user.name.first` not just `user`)

**Data Structure:**
- Pass nested objects via `@data`.
- `@onChange` and `@onSubmit` callbacks receive nested data structure
- The form automatically flattens data internally and unflattens for callbacks

**Validation:**
- Schema validators should mirror your data structure
- Error messages are keyed by dotted paths (e.g., `"user.email": "Email is required"`)
- Custom validators work with nested data structures

**Dirty Field Tracking:**
- Dirty fields are tracked using dotted notation
- Deep comparison ensures nested object changes are detected
- `form.dirty` contains paths like `"user.profile.email"`, not just `"user"`

## Resetting Forms

The Form component provides a `reset` function that allows you to reset the form to its initial state. This is useful for implementing "Cancel" or "Reset" buttons in your forms.

### Basic Reset

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
            <div class='p-3 bg-warning-50 rounded text-sm'>
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

The `reset` function clears validation errors and restores the form to its initial state, including resetting dirty field tracking.

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

### Reset Behavior

When you call `form.reset()`:

1. **Calls native form reset**: The underlying HTML form element's `reset()` method is called, which resets all form controls to their default values
2. **Restores initial data**: The form data is restored to the values provided in the initial `@data` prop
3. **Clears validation errors**: Any validation errors are cleared
4. **Clears dirty state**: The dirty field tracking is reset to an empty set

**For controlled forms** (with `@onChange`):
- Calls `@onChange` with the initial data, allowing your component to update its state

**For uncontrolled forms** (without `@onChange`):
- Updates the internal form state to the initial data

**With no initial data**:
- Simply calls the native form reset, clearing all fields to empty values

## Accessibility

The Form component maintains all standard HTML form accessibility features:

- Proper form semantics with native `<form>` element
- Submit handling with keyboard support (Enter key)
- Works with screen readers and assistive technologies
- Maintains focus management and navigation
- Supports all ARIA attributes when passed through `...attributes`
- Disabled form fields are properly marked with the `disabled` attribute and announced by screen readers

## API

### Yielded Context

The Form component yields an object with the following properties:

- **`data`**: The current form data as key/value pairs (matches the `@data` prop in controlled forms)
- **`isLoading`**: Boolean indicating if the form is currently submitting (async `@onSubmit` in progress)
- **`isValid`**: Boolean indicating if the form has no validation errors
- **`isInvalid`**: Boolean indicating if the form has validation errors
- **`errors`**: Object containing validation errors keyed by field name
- **`dirty`**: Set containing field names that have changed from their initial values
- **`reset`**: Function to reset the form to its initial state (clears fields, errors, and dirty tracking)
- **`Field`**: The Field component with `errors` and `formData` already bound

Example usage:
```gts
<Form @data={{this.formData}} @onSubmit={{this.handleSubmit}} as |form|>
  {{! Access current form data }}
  <div>Current email: {{form.data.email}}</div>

  {{! Show loading state }}
  <button type="submit" disabled={{form.isLoading}}>
    {{if form.isLoading "Saving..." "Save"}}
  </button>

  {{! Reset form to initial state }}
  <button type="button" {{on "click" form.reset}}>
    Reset
  </button>

  {{! Check validation state }}
  {{#if form.isInvalid}}
    <div class="error">Please fix errors before submitting</div>
  {{/if}}

  {{! Check for unsaved changes }}
  {{#if form.dirty.size}}
    <div class="warning">You have unsaved changes</div>
  {{/if}}
</Form>
```

<Signature @package="forms" @component="Form" />
