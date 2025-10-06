---
label: New
imports:
  - import Signature from 'site/components/signature';
---

# Field

A component wrapper that provides conveniences for form fields when using built-in validation. It automatically binds the appropriate form errors by name to yielded components, simplifying error handling in validated forms.

**Important:** The Field component is designed specifically for use with the Form component's built-in validation system (`@schema` or `@validate` props). It should only be used when implementing form validation.

## Import

```js
import { Form } from '@frontile/forms';
// Field is yielded from Form when using validation
```

## Usage

### Basic Field with Validation

The Field component is yielded from the Form component when validation is configured. It automatically passes validation errors to the appropriate form components.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Form, type FormResultData } from '@frontile/forms';
import { Button } from '@frontile/buttons';
import * as v from 'valibot';

export default class BasicFieldExample extends Component {
  @tracked formData: FormResultData = {};

  // Define validation schema
  schema = v.object({
    email: v.pipe(
      v.string(),
      v.nonEmpty('Email is required'),
      v.email('Please enter a valid email address')
    ),
    username: v.pipe(
      v.string(),
      v.nonEmpty('Username is required'),
      v.minLength(3, 'Username must be at least 3 characters')
    )
  });

  handleFormSubmit = (data: FormResultData) => {
    console.log('Form submitted:', data);
  };

  <template>
    <Form
      @schema={{this.schema}}
      @onSubmit={{this.handleFormSubmit}}
      as |form|
    >
      <div class='flex flex-col gap-4'>
        {{! Field component automatically handles error binding }}
        <form.Field @name='username' as |field|>
          <field.Input
            @label='Username'
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

        <Button type='submit'>
          Submit
        </Button>
      </div>
    </Form>
  </template>
}
```

### Field with Multiple Component Types

The Field component yields bound versions of all form components, each automatically receiving the correct errors for its field name.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Form, type FormResultData } from '@frontile/forms';
import { Button } from '@frontile/buttons';
import * as v from 'valibot';

export default class FieldComponentTypes extends Component {
  accountTypes = [
    { label: 'Personal', key: 'personal' },
    { label: 'Business', key: 'business' },
    { label: 'Enterprise', key: 'enterprise' }
  ];

  schema = v.object({
    name: v.pipe(
      v.string(),
      v.nonEmpty('Name is required')
    ),
    bio: v.pipe(
      v.string(),
      v.nonEmpty('Bio is required'),
      v.minLength(10, 'Bio must be at least 10 characters')
    ),
    accountType: v.pipe(
      v.fallback(v.string(), ''),
      v.string(),
      v.nonEmpty('Please select an account type')
    ),
    newsletter: v.pipe(
      v.boolean(),
      v.literal(true, 'You must subscribe to continue')
    )
  });

  handleFormSubmit = (data: FormResultData) => {
    console.log('Form submitted:', data);
  };

  <template>
    <Form
      @schema={{this.schema}}
      @onSubmit={{this.handleFormSubmit}}
      as |form|
    >
      <div class='flex flex-col gap-4'>
        {{! Input field }}
        <form.Field @name='name' as |field|>
          <field.Input
            @label='Full Name'
            @isRequired={{true}}
          />
        </form.Field>

        {{! Textarea field }}
        <form.Field @name='bio' as |field|>
          <field.Textarea
            @label='Biography'
            @description='Tell us about yourself'
            @isRequired={{true}}
            rows='4'
          />
        </form.Field>

        {{! Select field }}
        <form.Field @name='accountType' as |field|>
          <field.Select
            @label='Account Type'
            @items={{this.accountTypes}}
            @placeholder='Choose account type'
            @allowEmpty={{true}}
            @isRequired={{true}}
          />
        </form.Field>

        {{! Checkbox field }}
        <form.Field @name='newsletter' as |field|>
          <field.Checkbox
            @label='Subscribe to newsletter'
            @isRequired={{true}}
          />
        </form.Field>

        <Button type='submit'>
          Create Account
        </Button>
      </div>
    </Form>
  </template>
}
```

### Field with Custom Validation

Use custom validation functions alongside Field components for complex validation logic.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Form, type FormResultData } from '@frontile/forms';
import { Button } from '@frontile/buttons';
import * as v from 'valibot';

export default class CustomValidationField extends Component {
  schema = v.object({
    password: v.pipe(
      v.string(),
      v.nonEmpty('Password is required'),
      v.minLength(8, 'Password must be at least 8 characters'),
      v.regex(/[A-Z]/, 'Must contain an uppercase letter'),
      v.regex(/[0-9]/, 'Must contain a number')
    ),
    confirmPassword: v.pipe(
      v.string(),
      v.nonEmpty('Please confirm your password')
    )
  });

  // Custom validator for password matching
  customValidator = (data: FormResultData) => {
    if (data['password'] !== data['confirmPassword']) {
      return [{
        message: 'Passwords must match',
        path: [{ key: 'confirmPassword' }]
      }];
    }
  };

  handleFormSubmit = (data: FormResultData) => {
    console.log('Form submitted:', data);
  };

  <template>
    <Form
      @schema={{this.schema}}
      @validate={{this.customValidator}}
      @onSubmit={{this.handleFormSubmit}}
      as |form|
    >
      <div class='flex flex-col gap-4'>
        <form.Field @name='password' as |field|>
          <field.Input
            @label='Password'
            @type='password'
            @description='Must be 8+ characters with uppercase and number'
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

        <Button type='submit'>
          Set Password
        </Button>
      </div>
    </Form>
  </template>
}
```

### Field with Radio and Checkbox Groups

Field components work seamlessly with grouped form controls.  Note that checkbox groups contain individual checkboxes.  Validations may appear on the checkbox group OR individual checkboxes, unlike with radio groups.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Form, type FormResultData } from '@frontile/forms';
import { Button } from '@frontile/buttons';
import * as v from 'valibot';

export default class FieldWithGroups extends Component {
  schema = v.object({
    experience: v.pipe(
      v.fallback(v.string(), ''),
      v.string(),
      v.nonEmpty('Please select your experience level')
    ),
    skills: v.pipe(
      v.array(v.string()),
      v.custom((value) => {
        return value.length >= 2;
      }, 'Please select at least 2 skills')
    )
  });

  handleFormSubmit = (data: FormResultData) => {
    console.log('Form submitted:', data);
  };

  <template>
    <Form
      @schema={{this.schema}}
      @onSubmit={{this.handleFormSubmit}}
      as |form|
    >
      <div class='flex flex-col gap-4'>
        {{! RadioGroup field }}
        <form.Field @name='experience' as |field|>
          <field.RadioGroup
            @label='Experience Level'
            @isRequired={{true}}
            as |Radio|
          >
            <Radio @label='Junior (0-2 years)' @value='junior' />
            <Radio @label='Mid-level (3-5 years)' @value='mid' />
            <Radio @label='Senior (6+ years)' @value='senior' />
            <Radio @label='Lead/Principal' @value='lead' />
          </field.RadioGroup>
        </form.Field>

        {{! CheckboxGroup field }}
        <form.Field @name='skills' as |field|>
          <field.CheckboxGroup
            @label='Technical Skills'
            @description='Select at least 2 skills'
            @isRequired={{true}}
            as |Checkbox|
          >
            <Checkbox @label='Frontend Development' value="skill-frontend" />
            <Checkbox @label='Backend Development' value="skill-backend" />
            <Checkbox @label='Mobile Development' value="skill-mobile" />
            <Checkbox @label='DevOps & Infrastructure' value="skill-infra" />
          </field.CheckboxGroup>
        </form.Field>

        <Button type='submit'>
          Submit Application
        </Button>
      </div>
    </Form>
  </template>
}
```

### Complex Form with Multiple Fields

A comprehensive example showing Field components in a real-world scenario.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Form, type FormResultData } from '@frontile/forms';
import { Button } from '@frontile/buttons';
import * as v from 'valibot';

export default class CompleteFieldForm extends Component {
  @tracked submitMessage = '';

  countries = [
    { label: 'United States', key: 'us' },
    { label: 'Canada', key: 'ca' },
    { label: 'United Kingdom', key: 'uk' },
    { label: 'Germany', key: 'de' },
    { label: 'France', key: 'fr' }
  ];

  schema = v.object({
    // Personal Information
    firstName: v.pipe(
      v.string(),
      v.nonEmpty('First name is required'),
      v.minLength(2, 'Must be at least 2 characters')
    ),
    lastName: v.pipe(
      v.string(),
      v.nonEmpty('Last name is required'),
      v.minLength(2, 'Must be at least 2 characters')
    ),
    email: v.pipe(
      v.string(),
      v.nonEmpty('Email is required'),
      v.email('Please enter a valid email')
    ),
    phone: v.pipe(
      v.string(),
      v.nonEmpty('Phone number is required'),
      v.regex(/^\+?[\d\s-()]+$/, 'Please enter a valid phone number')
    ),

    // Address Information
    country: v.pipe(
      v.fallback(v.string(), ''),
      v.string(),
      v.nonEmpty('Please select a country')
    ),
    bio: v.pipe(
      v.string(),
      v.nonEmpty('Bio is required'),
      v.minLength(20, 'Bio must be at least 20 characters'),
      v.maxLength(500, 'Bio must be less than 500 characters')
    ),

    // Preferences
    contactMethod: v.pipe(
      v.fallback(v.string(), ''),
      v.string(),
      v.nonEmpty('Please select a contact method')
    ),
    notifications: v.pipe(
      v.array(v.string()),
      v.custom((value) => {
        return value.length >= 1;
      }, 'Please select at least 1 notification method')
    ),

    // Legal
    terms: v.pipe(
      v.boolean(),
      v.literal(true, 'You must accept the terms')
    ),
    privacy: v.pipe(
      v.boolean(),
      v.literal(true, 'You must accept the privacy policy')
    )
  });

  handleFormSubmit = async (data: FormResultData) => {
    // Simulate API call
    await new Promise((resolve) => setTimeout(resolve, 1500));
    this.submitMessage = 'Registration completed successfully!';
    console.log('Form submitted:', data);
  };

  <template>
    <div class='max-w-2xl'>
      <Form
        @schema={{this.schema}}
        @onSubmit={{this.handleFormSubmit}}
        as |form|
      >
        <div class='flex flex-col gap-6'>
          {{! Personal Information Section }}
          <div class='border-b border-default-200 pb-6'>
            <h3 class='text-lg font-medium mb-4'>Personal Information</h3>

            <div class='grid grid-cols-2 gap-4'>
              <form.Field @name='firstName' as |field|>
                <field.Input
                  @label='First Name'
                  @isRequired={{true}}
                />
              </form.Field>

              <form.Field @name='lastName' as |field|>
                <field.Input
                  @label='Last Name'
                  @isRequired={{true}}
                />
              </form.Field>
            </div>

            <div class='mt-4 space-y-4'>
              <form.Field @name='email' as |field|>
                <field.Input
                  @label='Email Address'
                  @type='email'
                  @isRequired={{true}}
                />
              </form.Field>

              <form.Field @name='phone' as |field|>
                <field.Input
                  @label='Phone Number'
                  @type='tel'
                  @isRequired={{true}}
                />
              </form.Field>

              <form.Field @name='country' as |field|>
                <field.Select
                  @label='Country'
                  @items={{this.countries}}
                  @placeholder='Select your country'
                  @allowEmpty={{true}}
                  @isRequired={{true}}
                />
              </form.Field>

              <form.Field @name='bio' as |field|>
                <field.Textarea
                  @label='Bio'
                  @description='Tell us about yourself (20-500 characters)'
                  @isRequired={{true}}
                  rows='4'
                />
              </form.Field>
            </div>
          </div>

          {{! Communication Preferences Section }}
          <div class='border-b border-default-200 pb-6'>
            <h3 class='text-lg font-medium mb-4'>Communication Preferences</h3>

            <form.Field @name='contactMethod' as |field|>
              <field.RadioGroup
                @label='Preferred Contact Method'
                @isRequired={{true}}
                as |Radio|
              >
                <Radio @label='Email' @value='email' />
                <Radio @label='Phone' @value='phone' />
                <Radio @label='SMS' @value='sms' />
              </field.RadioGroup>
            </form.Field>

            <form.Field @name='notifications' as |field|>
              <field.CheckboxGroup
                @label='Notification Preferences'
                @description='Choose how you want to receive updates'
                as |Checkbox|
              >
                <Checkbox @label='Email notifications' value='email' />
                <Checkbox @label='SMS notifications' value='sms' />
                <Checkbox @label='Push notifications' value='push' />
              </field.CheckboxGroup>
            </form.Field>
          </div>

          {{! Legal Section }}
          <div>
            <h3 class='text-lg font-medium mb-4'>Legal Agreements</h3>

            <div class='space-y-4'>
              <form.Field @name='terms' as |field|>
                <field.Checkbox
                  @label='I accept the Terms and Conditions'
                  @description='You must accept our terms to create an account'
                  @isRequired={{true}}
                />
              </form.Field>

              <form.Field @name='privacy' as |field|>
                <field.Checkbox
                  @label='I accept the Privacy Policy'
                  @description='You must accept our privacy policy to create an account'
                  @isRequired={{true}}
                />
              </form.Field>
            </div>
          </div>

          <Button type='submit' disabled={{form.isLoading}}>
            {{if form.isLoading 'Creating Account...' 'Create Account'}}
          </Button>
        </div>
      </Form>

      {{#if this.submitMessage}}
        <div class='mt-4 p-4 bg-success-50 text-success-800 rounded'>
          {{this.submitMessage}}
        </div>
      {{/if}}
    </div>
  </template>
}
```

## Key Features

### Automatic Error Binding

The Field component automatically:
- Extracts errors for the specified field name from the form's validation errors
- Passes these errors to any yielded form component
- Updates error display in real-time as validation occurs

### Yielded Components

Field yields bound versions of all form components:
- `field.Input` - Text input with automatic error binding
- `field.Textarea` - Textarea with automatic error binding
- `field.Select` - Select dropdown with automatic error binding
- `field.Checkbox` - Single checkbox with automatic error binding
- `field.CheckboxGroup` - Checkbox group with automatic error binding
- `field.RadioGroup` - Radio group with automatic error binding
- `field.Switch` - Toggle switch with automatic error binding
- `field.Radio` - Individual radio button with automatic error binding

Each component automatically receives:
- The `@name` prop from the Field
- Any validation errors for that field name
- All other props passed through normally

## When to Use Field

**Use the Field component when:**
- You're implementing form validation with `@schema` or `@validate`
- You want automatic error handling for form fields
- You need consistent error binding across multiple form components
- You're building forms with complex validation requirements

**Don't use the Field component when:**
- You're building simple forms without validation
- You want direct control over error handling
- You're not using the Form component's validation features

## Best Practices

### Consistent Field Names

Ensure field names match between your validation schema and Field components:

```typescript
// Schema definition
schema = v.object({
  userEmail: v.string().email(), // Field name: 'userEmail'
});

// Field usage
<form.Field @name='userEmail' as |field|> {{! Must match schema }}
  <field.Input @label='Email' />
</form.Field>
```

### Select Field Schema Validation

**Important:** When working with select fields in validated forms, follow these guidelines:

1. **Schema Definition**: Always use `v.fallback(v.string(), '')` before `v.string()` to ensure null values are normalized to empty strings:

```typescript
// Correct schema for select fields
schema = v.object({
  country: v.pipe(
    v.fallback(v.string(), ''), // Normalize null to empty string
    v.string(),
    v.nonEmpty('Please select a country')
  )
});
```

2. **Component Configuration**: Specify `@allowEmpty={{true}}` on the Select component when there is no initial value:

```handlebars
<form.Field @name='country' as |field|>
  <field.Select
    @label='Country'
    @items={{this.countries}}
    @placeholder='Select a country'
    @allowEmpty={{true}}  {{! Important when no initial value }}
    @isRequired={{true}}
  />
</form.Field>
```

These patterns ensure proper handling of select field validation, especially when fields start without a selected value.

### Error Display

Field components automatically display errors, but you can customize the display:

```gts
<form.Field @name='email' as |field|>
  <field.Input
    @label='Email'
    @description='We will never share your email'
    {{! Errors appear automatically below the input }}
  />
</form.Field>
```

## Accessibility

The Field component maintains all accessibility features of the underlying form components:
- Proper ARIA attributes for error states
- Automatic `aria-invalid` and `aria-describedby` updates
- Screen reader announcements for validation errors
- Maintains all keyboard navigation of wrapped components

## API

<Signature @package="forms" @component="Field" />