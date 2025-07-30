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
    <div class='flex flex-col gap-4'>
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
        <div class='p-4 bg-blue-50 rounded'>
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

The Form component works seamlessly with validation logic by providing access to the current form state.

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

  handleFormChange = (data: FormResultData, eventType: 'input' | 'submit') => {
    this.formData = data;

    if (eventType === 'submit') {
      this.handleSubmit(data);
    } else {
      // Clear errors on input for fields that now have values
      const newErrors = { ...this.errors };
      Object.keys(data).forEach((key) => {
        if (data[key] && newErrors[key]) {
          delete newErrors[key];
        }
      });
      // Also clear errors when select changes
      if (this.selectedAccountType.length > 0 && newErrors.accountType) {
        delete newErrors.accountType;
      }
      this.errors = newErrors;
    }
  };

  handleSubmit = async (data: FormResultData) => {
    this.isSubmitting = true;
    this.errors = {};
    this.submitMessage = '';

    // Validate form data
    const validationErrors: Record<string, string[]> = {};

    if (!data.name || typeof data.name !== 'string' || !data.name.trim()) {
      validationErrors.name = ['Name is required'];
    }

    if (
      !data.email ||
      typeof data.email !== 'string' ||
      !data.email.includes('@')
    ) {
      validationErrors.email = ['Valid email is required'];
    }

    if (
      !data.password ||
      typeof data.password !== 'string' ||
      data.password.length < 6
    ) {
      validationErrors.password = ['Password must be at least 6 characters'];
    }

    if (this.selectedAccountType.length === 0) {
      validationErrors.accountType = ['Please select an account type'];
    }

    if (!data.terms) {
      validationErrors.terms = ['You must accept the terms and conditions'];
    }

    if (Object.keys(validationErrors).length > 0) {
      this.errors = validationErrors;
      this.isSubmitting = false;
      return;
    }

    // Simulate API call
    try {
      await new Promise((resolve) => setTimeout(resolve, 1000));
      this.submitMessage = 'Account created successfully!';
      console.log('Form submitted successfully:', data);
    } catch (error) {
      this.submitMessage = 'An error occurred. Please try again.';
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
    <div class='flex flex-col gap-4'>
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

      <div class='p-4 bg-default-50 rounded'>
        <h4 class='font-medium mb-2'>Current Form State:</h4>
        <div class='grid grid-cols-1 md:grid-cols-2 gap-4 text-sm'>
          <div>
            <strong>Form Data:</strong>
            <pre class='mt-1 overflow-auto'>{{JSON.stringify
                this.formData
                null
                2
              }}</pre>
          </div>
          <div>
            <strong>Validation Errors:</strong>
            <pre class='mt-1 overflow-auto'>{{JSON.stringify
                this.errors
                null
                2
              }}</pre>
          </div>
        </div>
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
  @tracked isSubmitting = false;
  @tracked submitCount = 0;
  @tracked lastSubmitTime: Date | null = null;

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
    this.lastSubmitTime = new Date();

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

      console.log('Form submitted successfully:', {
        data,
        submitTime: this.lastSubmitTime,
        submitCount: this.submitCount
      });

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

  get validationErrorCount() {
    return this.validationErrors
      ? Object.keys(this.validationErrors).length
      : 0;
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

          <Button type='submit' @isDisabled={{this.isSubmitDisabled}}>
            {{#if this.isSubmitting}}
              Submitting...
              {{this.submitCount}}
            {{else}}
              Submit Form
            {{/if}}
          </Button>
        </div>
      </Form>

      <!-- Status Display -->
      <div class='grid grid-cols-1 md:grid-cols-3 gap-4 text-sm'>
        <div class='p-3 bg-blue-50 rounded'>
          <h4 class='font-medium mb-1'>Submit Count</h4>
          <p>{{this.submitCount}}</p>
        </div>

        <div class='p-3 bg-success-50 rounded'>
          <h4 class='font-medium mb-1'>Last Submit</h4>
          <p>{{if
              this.lastSubmitTime
              this.lastSubmitTime.toLocaleTimeString
              'Never'
            }}</p>
        </div>

        <div class='p-3 bg-danger-50 rounded'>
          <h4 class='font-medium mb-1'>Validation Errors</h4>
          <p>{{this.validationErrorCount}}</p>
        </div>
      </div>
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

```typescript
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
