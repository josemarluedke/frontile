---
label: New
imports:
  - import Signature from 'site/components/signature';
---

# Form

A powerful form wrapper component that automatically handles form data extraction and provides real-time updates via dedicated `@onChange` and `@onSubmit` callbacks. It uses `form-data-utils` under the hood to serialize form data efficiently and supports all native HTML form elements as well as Frontile form components.

## Import

```js
import { Form } from '@frontile/forms';
```

## Usage

### Basic Form

The most basic usage of the Form component with automatic data extraction.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Form, Input, Select, type FormResultData } from '@frontile/forms';
import { Button } from '@frontile/buttons';

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
} from '@frontile/forms';
import { Button } from '@frontile/buttons';

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
} from '@frontile/forms';
import { Button } from '@frontile/buttons';

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

The Form component works seamlessly with any [Standard Schema](https://standardschema.dev/)-compliant validation libraries like Valibot for scalable form validation. This example demonstrates how to use Valibot schemas for comprehensive form validation.  The use of custom validators is also supported.

**Note**:  When using built-in form validation, the `Field` component _must_ be used (see example below).  The `Field` component handles auomatic error binding.  Use of `Field` is unnecessary when not using built-in form validation.  [Learn more about the `Field` component and see more form validation examples](field).

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import {
  Form,
  Input,
  Checkbox,
  Select,
  type FormResultData,
  type FormErrors
} from '@frontile/forms';
import { Button } from '@frontile/buttons';
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
    accountType: 'personal',
    terms: false
  };

  @tracked submitMessage = '';

  accountTypes = [
    { label: 'Personal', key: 'personal' },
    { label: 'Business', key: 'business' },
    { label: 'Enterprise', key: 'enterprise' }
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

          <form.Field @name='password' as |field|>
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

          <form.Field @name='terms' as |field|>
            <field.Checkbox
              @label='I agree to the terms and conditions'
              @isRequired={{true}}
            />
          </form.Field>

          <Button type='submit' disabled={{form.isLoading}} @class='mt-4'>
            {{if form.isLoading 'Creating Account...' 'Create Account'}}
          </Button>
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
import { Form, Input, Checkbox, type FormResultData } from '@frontile/forms';
import { Button } from '@frontile/buttons';

export default class DirtyTrackingForm extends Component {
  @tracked formData = {
    username: 'john_doe',
    email: 'john@example.com',
    notifications: true
  };

  @tracked dirtyFields = new Set<string>();

  handleFormChange = (data: FormResultData, event: Event) => {
    this.dirtyFields = data.dirty;
    console.log('Dirty fields:', Array.from(this.dirtyFields));
  };

  handleFormSubmit = (data: FormResultData, event: SubmitEvent) => {
    console.log('Submitted data:', data);
    // Reset dirty state by updating formData with submitted values
    this.formData = data.data;
  };

  get hasDirtyFields() {
    return this.dirtyFields.size > 0;
  }

  get dirtyFieldsArray() {
    return Array.from(this.dirtyFields);
  }

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
            disabled={{this.hasDirtyFields}}
          >
            Save Changes
          </Button>
        </div>
      </Form>

      <div class='p-4 rounded
        {{if this.hasDirtyFields "bg-warning-50" "bg-default-50"}}'>
        {{#if this.hasDirtyFields}}
          <p class='font-medium text-warning-800'>
            Unsaved changes in:
            {{#each this.dirtyFields as |field|}}
              <span class='inline-block px-2 py-1 bg-warning-100 rounded text-sm ml-1'>
                {{field}}
              </span>
            {{/each}}
          </p>
        {{else}}
          <p class='text-default-600'>No unsaved changes</p>
        {{/if}}
      </div>
    </div>
  </template>
}
```

### Custom Form Handling

Advanced usage showing how to handle complex form logic and custom validation.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Form, Input, Checkbox, type FormResultData } from '@frontile/forms';
import { Button } from '@frontile/buttons';

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

### Performance Considerations

- The Form component only re-renders when necessary
- Form data extraction is optimized using `form-data-utils`
- Consider debouncing input validation for complex forms

## Accessibility

The Form component maintains all standard HTML form accessibility features:

- Proper form semantics with native `<form>` element
- Submit handling with keyboard support (Enter key)
- Works with screen readers and assistive technologies
- Maintains focus management and navigation
- Supports all ARIA attributes when passed through `...attributes`

## API

<Signature @package="forms" @component="Form" />
