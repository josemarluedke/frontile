---
label: New
imports:
  - import Signature from 'site/components/signature';
---

# Form

A powerful form wrapper component that automatically handles form data extraction and provides real-time updates on both input and submit events. It uses `form-data-utils` under the hood to serialize form data efficiently and supports all native HTML form elements as well as Frontile form components.

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
  @tracked selectedCountry: string[] = [];

  countries = [
    { label: 'United States', key: 'us' },
    { label: 'Canada', key: 'ca' },
    { label: 'United Kingdom', key: 'uk' },
    { label: 'Australia', key: 'au' }
  ];

  handleFormChange = (data: FormResultData, eventType: 'input' | 'submit') => {
    this.formData = data;
    console.log(`Form ${eventType}:`, data);
  };

  handleCountryChange = (selectedKeys: string[]) => {
    this.selectedCountry = selectedKeys;
  };

  <template>
    <div class='flex flex-col gap-4 w-80'>
      <Form @onChange={{this.handleFormChange}}>
        <div class='flex flex-col gap-4'>
          <Input @name='firstName' @label='First Name' />
          <Input @name='lastName' @label='Last Name' />
          <Input @name='email' @label='Email' @type='email' />

          <Select
            @name='country'
            @label='Country'
            @items={{this.countries}}
            @placeholder='Select your country'
            @selectedKeys={{this.selectedCountry}}
            @onSelectionChange={{this.handleCountryChange}}
          />

          <Button type='submit'>
            Submit
          </Button>
        </div>
      </Form>

      <div class='p-4 bg-default-50 rounded'>
        <h4 class='font-medium mb-2'>Current Form Data:</h4>
        <pre class='text-sm'>{{JSON.stringify this.formData null 2}}</pre>
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
  @tracked selectedRole: string[] = [];

  roles = [
    { label: 'User', key: 'user' },
    { label: 'Admin', key: 'admin' },
    { label: 'Moderator', key: 'moderator' },
    { label: 'Guest', key: 'guest' }
  ];

  handleFormChange = (
    data: FormResultData,
    eventType: 'input' | 'submit',
    event: Event | SubmitEvent
  ) => {
    if (eventType === 'input') {
      this.inputData = data;
    } else {
      this.submitData = data;
    }
  };

  handleRoleChange = (selectedKeys: string[]) => {
    this.selectedRole = selectedKeys;
  };

  <template>
    <div class='flex flex-col gap-4'>
      <Form @onChange={{this.handleFormChange}}>
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
            @selectedKeys={{this.selectedRole}}
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
  @tracked selectedSkillLevel: string[] = [];

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

  handleFormChange = (data: FormResultData, eventType: 'input' | 'submit') => {
    this.formData = data;
    this.lastEventType = eventType;
  };

  handleSkillLevelChange = (selectedKeys: string[]) => {
    this.selectedSkillLevel = selectedKeys;
  };

  <template>
    <div class='flex flex-col gap-4'>
      <Form @onChange={{this.handleFormChange}}>
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
            @selectedKeys={{this.selectedSkillLevel}}
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

The Form component works seamlessly with validation libraries like Valibot for scalable form validation. This example demonstrates how to use Valibot schemas for comprehensive form validation.

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
import * as v from 'valibot';

export default class ValidatedForm extends Component {
  @tracked formData: FormResultData = {};
  @tracked errors: Record<string, string[]> = {};
  @tracked isSubmitting = false;
  @tracked submitMessage = '';
  @tracked selectedAccountType: string[] = [];

  accountTypes = [
    { label: 'Personal', key: 'personal' },
    { label: 'Business', key: 'business' },
    { label: 'Enterprise', key: 'enterprise' }
  ];

  // Valibot schema for form validation
  FormSchema = v.object({
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
      v.array(v.string()),
      v.minLength(1, 'Please select an account type')
    ),
    terms: v.pipe(
      v.boolean(),
      v.literal(true, 'You must accept the terms and conditions')
    )
  });

  handleFormChange = (data: FormResultData, eventType: 'input' | 'submit') => {
    this.formData = data;

    if (eventType === 'submit') {
      this.handleSubmit(data);
    } else {
      // Real-time validation on input changes
      this.validateField(data);
    }
  };

  validateField = (data: FormResultData) => {
    // Prepare data for validation
    const validationData = {
      ...data,
      accountType: this.selectedAccountType
    };

    // Try to parse the entire form, but only clear errors for valid fields
    try {
      v.parse(this.FormSchema, validationData);
      // If validation passes completely, clear all errors
      this.errors = {};
    } catch (error) {
      if (error instanceof v.ValiError) {
        // Keep existing errors, but clear errors for fields that are now valid
        const newErrors = { ...this.errors };
        const invalidFields = new Set(
          error.issues.map((issue) => issue.path?.[0]?.key).filter(Boolean)
        );

        // Clear errors for fields that are no longer invalid
        Object.keys(newErrors).forEach((field) => {
          if (!invalidFields.has(field)) {
            delete newErrors[field];
          }
        });

        this.errors = newErrors;
      }
    }
  };

  handleSubmit = async (data: FormResultData) => {
    this.isSubmitting = true;
    this.errors = {};
    this.submitMessage = '';

    // Prepare data for validation
    const validationData = {
      ...data,
      accountType: this.selectedAccountType
    };

    // Validate using Valibot
    try {
      const validatedData = v.parse(this.FormSchema, validationData);

      // Simulate API call
      await new Promise((resolve) => setTimeout(resolve, 1000));
      this.submitMessage = 'Account created successfully!';
      console.log('Form submitted successfully:', validatedData);
    } catch (error) {
      if (error instanceof v.ValiError) {
        // Convert Valibot errors to our error format
        const validationErrors: Record<string, string[]> = {};

        for (const issue of error.issues) {
          const path = issue.path?.[0]?.key as string;
          if (path) {
            if (!validationErrors[path]) {
              validationErrors[path] = [];
            }
            validationErrors[path].push(issue.message);
          }
        }

        this.errors = validationErrors;
      } else {
        this.submitMessage = 'An error occurred. Please try again.';
      }
    } finally {
      this.isSubmitting = false;
    }
  };

  get isSuccessMessage() {
    return this.submitMessage.includes('success');
  }

  handleAccountTypeChange = (selectedKeys: string[]) => {
    this.selectedAccountType = selectedKeys;
    // Clear errors when selection is made
    if (selectedKeys.length > 0 && this.errors.accountType) {
      const newErrors = { ...this.errors };
      delete newErrors.accountType;
      this.errors = newErrors;
    }
  };

  <template>
    <div class='flex flex-col gap-4 w-80'>
      <Form @onChange={{this.handleFormChange}}>
        <div class='flex flex-col gap-4'>

          <Input
            @name='name'
            @label='Full Name'
            @errors={{this.errors.name}}
            @isRequired={{true}}
          />

          <Input
            @name='email'
            @label='Email Address'
            @type='email'
            @errors={{this.errors.email}}
            @isRequired={{true}}
          />

          <Input
            @name='password'
            @label='Password'
            @type='password'
            @description='Must be at least 6 characters'
            @errors={{this.errors.password}}
            @isRequired={{true}}
          />

          <Select
            @name='accountType'
            @label='Account Type'
            @items={{this.accountTypes}}
            @placeholder='Select account type'
            @selectedKeys={{this.selectedAccountType}}
            @onSelectionChange={{this.handleAccountTypeChange}}
            @errors={{this.errors.accountType}}
            @isRequired={{true}}
          />

          <Checkbox
            @name='terms'
            @label='I agree to the terms and conditions'
            @errors={{this.errors.terms}}
            @isRequired={{true}}
          />

          <Button type='submit' @isDisabled={{this.isSubmitting}} @class='mt-4'>
            {{if this.isSubmitting 'Creating Account...' 'Create Account'}}
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
  @tracked isSubmitting = false;
  @tracked submitCount = 0;

  handleFormChange = (
    data: FormResultData,
    eventType: 'input' | 'submit',
    event: Event | SubmitEvent
  ) => {
    this.formData = data;

    console.log('Form event:', {
      eventType,
      data,
      timestamp: new Date(),
      target: event.target
    });

    if (eventType === 'input') {
      this.handleRealTimeValidation(data);
    } else if (eventType === 'submit') {
      this.handleFormSubmission(data, event as SubmitEvent);
    }
  };

  handleRealTimeValidation = (data: FormResultData) => {
    const errors: Record<string, string[]> = {};

    // Real-time email validation
    if (data.email && typeof data.email === 'string') {
      if (!data.email.includes('@')) {
        errors.email = ['Email must contain @ symbol'];
      } else if (!data.email.includes('.')) {
        errors.email = ['Email must contain a domain'];
      }
    }

    // Real-time password validation
    if (data.password && typeof data.password === 'string') {
      const password = data.password;
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
    this.isSubmitting = true;
    this.submitCount += 1;

    // Comprehensive validation on submit
    const errors: Record<string, string[]> = {};

    if (
      !data.username ||
      typeof data.username !== 'string' ||
      data.username.length < 3
    ) {
      errors.username = ['Username must be at least 3 characters'];
    }

    if (
      !data.email ||
      typeof data.email !== 'string' ||
      !data.email.includes('@')
    ) {
      errors.email = ['Valid email is required'];
    }

    if (!data.agreeToTerms) {
      errors.agreeToTerms = ['You must agree to the terms'];
    }

    if (Object.keys(errors).length > 0) {
      this.validationErrors = errors;
      this.isSubmitting = false;
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
    } finally {
      this.isSubmitting = false;
    }
  };

  get hasValidationErrors() {
    return (
      this.validationErrors && Object.keys(this.validationErrors).length > 0
    );
  }

  get isSubmitDisabled() {
    return this.isSubmitting || this.hasValidationErrors;
  }

  <template>
    <div class='flex flex-col gap-4'>
      <Form @onChange={{this.handleFormChange}}>
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

          <Button type='submit' disabled={{this.isSubmitDisabled}}>
            {{#if this.isSubmitting}}
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

- **Input Events**: Fired on every form input change for real-time updates
- **Submit Events**: Fired when the form is submitted, with `preventDefault()` called automatically
- Access to the original DOM event for advanced use cases

### Data Types Support

- Strings, numbers, and booleans
- Arrays from multi-select elements
- Nested objects from grouped form elements
- File uploads (when using file inputs)

## Best Practices

### Form Validation

For scalable form validation, we recommend using validation libraries like [Valibot](https://valibot.dev/):

```typescript
// Define a Valibot schema for type-safe validation
FormSchema = v.object({
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

// Validate on both input and submit events
handleFormChange = (data: FormResultData, eventType: 'input' | 'submit') => {
  if (eventType === 'input') {
    // Real-time validation for better UX
    this.validateField(data);
  } else {
    // Comprehensive validation on submit
    this.validateAndSubmit(data);
  }
};

validateAndSubmit = async (data: FormResultData) => {
  try {
    const validatedData = v.parse(this.FormSchema, data);
    // Proceed with form submission
  } catch (error) {
    if (error instanceof v.ValiError) {
      // Convert Valibot errors to component error format
      const validationErrors = this.formatValiError(error);
      this.errors = validationErrors;
    }
  }
};
```

### State Management

```typescript
// Keep form data and validation errors separate
@tracked formData: FormResultData = {};
@tracked validationErrors: Record<string, string[]> = {};
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
