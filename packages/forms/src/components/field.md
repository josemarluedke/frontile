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
import { action } from '@ember/object';
import { tracked } from '@glimmer/tracking';
import { Form, type FormResultData } from '@frontile/forms';
import { Button } from '@frontile/buttons';
import * as v from 'valibot';

// Define validation schema
const schema = v.object({
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

type Schema = v.InferOutput<typeof schema>;

export default class BasicFieldExample extends Component {
  @tracked formData: Schema = { username: 'rememberme' };

  handleFormChange = (result: FormResultData<Schema>) => {
    this.formData = result.data;
  };

  handleFormSubmit = (result: FormResultData<Schema>) => {
    console.log('Form submitted:', result);
  };

  @action
  changeEmail() {
    this.formData.email = 'test@test.com';
    this.formData = this.formData;
  }

  <template>
    <Form
      @data={{this.formData}}
      @schema={{schema}}
      @onChange={{this.handleFormChange}}
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

        <Button @onPress={{this.changeEmail}}>Update Email via formData</Button>
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

const schema = v.object({
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

type Schema = v.InferOutput<typeof schema>;

export default class FieldComponentTypes extends Component {
  @tracked formData: Schema = {
    accountType: 'personal',
    newsletter: true
  };

  accountTypes = [
    { label: 'Personal', key: 'personal' },
    { label: 'Business', key: 'business' },
    { label: 'Enterprise', key: 'enterprise' }
  ];

  handleFormSubmit = (data: FormResultData<Schema>) => {
    console.log('Form submitted:', data);
  };

  <template>
    <Form
      @data={{this.data}}
      @schema={{schema}}
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
          <field.SingleSelect
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

const schema = v.object({
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

type Schema = v.InferOutput<typeof schema>;

export default class CustomValidationField extends Component {
  // Custom validator for password matching
  customValidator = (data: Schema) => {
    if (data['password'] !== data['confirmPassword']) {
      return [{
        message: 'Passwords must match',
        path: [{ key: 'confirmPassword' }]
      }];
    }
  };

  handleFormSubmit = (data: FormResultData<Schema>) => {
    console.log('Form submitted:', data);
  };

  <template>
    <Form
      @schema={{schema}}
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

`RadioGroup` supports field-level validation (validates on change/blur/input events based on `@validateOn`), while `CheckboxGroup` currently only supports validation on form submit. Both components display validation errors and work with `form.Field`, but only RadioGroup will automatically validate when the user changes their selection before submitting the form.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Form, type FormResultData } from '@frontile/forms';
import { Button } from '@frontile/buttons';
import * as v from 'valibot';

const schema = v.object({
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

type Schema = v.InferOutput<typeof schema>;

export default class FieldWithGroups extends Component {
  handleFormSubmit = (data: FormResultData<Schema>) => {
    console.log('Form submitted:', data);
  };

  <template>
    <Form
      @schema={{schema}}
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

const schema = v.object({
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

type Schema = v.InferOutput<typeof schema>;

export default class CompleteFieldForm extends Component {
  @tracked submitMessage = '';

  countries = [
    { label: 'United States', key: 'us' },
    { label: 'Canada', key: 'ca' },
    { label: 'United Kingdom', key: 'uk' },
    { label: 'Germany', key: 'de' },
    { label: 'France', key: 'fr' }
  ];

  handleFormSubmit = async (data: FormResultData<Schema>) => {
    // Simulate API call
    await new Promise((resolve) => setTimeout(resolve, 1500));
    this.submitMessage = 'Registration completed successfully!';
    console.log('Form submitted:', data);
  };

  <template>
    <div class='max-w-2xl'>
      <Form
        @schema={{schema}}
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
                <field.SingleSelect
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

## Select Components with Field

When using select components **outside of `Field`**, you use the generic `Select` component.  Rendering of single vs. multi is handled by `Select`.

However, when using select components **with `Field`**, you must explicitly specify which variant you need:

- **`field.SingleSelect`** - For selecting a single item
- **`field.MultiSelect`** - For selecting multiple items

This distinction allows the Field component to properly bind values to the components.

### Field Select (with validation)

```gts
{{! Must specify SingleSelect or MultiSelect explicitly }}
<form.Field @name='country' as |field|>
  <field.SingleSelect
    @label='Country'
    @items={{this.countries}}
    @allowEmpty={{true}}
  />
</form.Field>

<form.Field @name='languages' as |field|>
  <field.MultiSelect
    @label='Languages'
    @items={{this.languages}}
  />
</form.Field>
```

**Key Differences:**
- With Field: Use `field.SingleSelect` or `field.MultiSelect`
- Field automatically handles value binding based on the component type

## Key Features

### Automatic Error Binding

The Field component automatically:
- Extracts errors for the specified field name from the form's validation errors
- Passes these errors to any yielded form component
- Updates error display in real-time as validation occurs

### Automatic Value Binding

When used with a Form component that provides `@data`, Field automatically binds values to form controls:

- Extracts the current value for the field from `form.data`
- Passes the appropriate value prop to each component type
- Provides a no-op change handler to put components in controlled mode
  - This ensures form-level `@onChange` handles all state updates
  - Prevents components from managing their own internal state
  - Enables the Form component to be the single source of truth

**Example:**
```gts
<Form @data={{this.formData}} @onChange={{this.handleChange}} as |form|>
  <form.Field @name="email" as |field|>
    {{! Value automatically bound from formData.email }}
    {{! onChange automatically handled by Form }}
    <field.Input @label="Email" />
  </form.Field>
</Form>
```

### Field-Level Validation

When the Form component's `@validateOn` argument includes `'change'` or `'input'` (defaults to `['change', 'submit']`), Field automatically validates individual fields as users interact with them. This provides feedback without waiting for form submission.

**Change Validation (`'change'`)**

Validates when a field loses focus (blur) after being modified:

**How it works:**
1. Form passes `@validateOn` to Field components (defaults to `['change']`)
2. Field's `handleChange` action checks if `'change'` is included
3. If change validation is enabled, Field calls `validateField` for that specific field when the field loses focus
4. Validation errors appear after the user moves to the next field (on blur)

**Note:** The `'change'` option validates on the HTML `change` event, which fires when a field loses focus (blur) after its value has been modified. It does NOT fire on every keystroke.

**Input Validation (`'input'`)**

Validates as the user types, on every keystroke:

**How it works:**
1. Form passes `@validateOn` to Field components
2. Field's `handleInput` action checks if `'input'` is included
3. If input validation is enabled, Field calls `validateField` for that specific field on every keystroke
4. Validation errors appear in real-time as the user types

**Note:** The `'input'` option validates on the HTML `input` event, which fires on every keystroke as the user types. This provides immediate feedback but may be distracting for some use cases.

**Example with change validation enabled (default):**
```gts
import * as v from 'valibot';

const schema = v.object({
  email: v.pipe(
    v.string(),
    v.email('Please enter a valid email address')
  )
});

<template>
  <Form @schema={{schema}} @onSubmit={{this.handleSubmit}} as |form|>
    {{! Change validation is enabled by default }}
    {{! Email field validates when user blurs/defocuses after changing value }}
    <form.Field @name="email" as |field|>
      <field.Input @label="Email" />
    </form.Field>
  </Form>
</template>
```

**Example with input validation enabled:**
```gts
import * as v from 'valibot';

const schema = v.object({
  password: v.pipe(
    v.string(),
    v.minLength(8, 'Password must be at least 8 characters')
  )
});

<template>
  <Form
    @schema={{schema}}
    @validateOn={{array 'input' 'submit'}}
    @onSubmit={{this.handleSubmit}}
    as |form|
  >
    {{! Input validation is enabled }}
    {{! Password field validates as user types }}
    <form.Field @name="password" as |field|>
      <field.Input @label="Password" @type="password" />
    </form.Field>
  </Form>
</template>
```

**Example with change validation disabled:**
```gts
<template>
  <Form
    @schema={{schema}}
    @validateOn={{array 'submit'}}
    @onSubmit={{this.handleSubmit}}
    as |form|
  >
    {{! Change validation is disabled }}
    {{! Email field only validates on form submit }}
    <form.Field @name="email" as |field|>
      <field.Input @label="Email" />
    </form.Field>
  </Form>
</template>
```

**Benefits of change validation:**
- **Early feedback**: Users see validation errors as they move between fields
- **Better UX**: Errors are caught before form submission, reducing frustration
- **Per-field validation**: Each field validates independently when blurred
- **Clear guidance**: Users know exactly what's wrong before submitting
- **Natural flow**: Validation happens when user is done with a field (on blur)

**Benefits of input validation:**
- **Immediate feedback**: Users see validation errors in real-time as they type
- **Perfect for specific cases**: Great for password strength, character limits, username availability
- **Continuous guidance**: Users can adjust their input immediately based on feedback
- **Progressive disclosure**: Errors clear as soon as the input becomes valid

**When to use input validation:**
- Password fields with strength requirements
- Fields with character limits or specific format requirements
- Username fields that check availability
- Fields where immediate feedback improves the user experience

**When to disable field-level validation:**
- Long forms where validation on every interaction might be distracting
- Forms where you want to allow incomplete data entry until final submission
- Multi-step forms where validation should only run at specific steps

**Overriding validation timing per field:**

Individual Fields can override the Form's `@validateOn` setting to customize when that specific field validates:

```gts
<template>
  <Form @validateOn={{array 'submit'}} as |form|>
    <form.Field @name="username" as |field|>
      {{! Inherits Form's validateOn - validates on submit only }}
      <field.Input />
    </form.Field>

    <form.Field @name="password" @validateOn={{array 'input'}} as |field|>
      {{! Overrides to validate as user types }}
      <field.Input @type="password" />
    </form.Field>
  </Form>
</template>
```

**Important notes:**
- Field-level validation (`'change'` or `'input'`) requires using `form.Field` components
- The Field component automatically handles the validation logic
- Both `@schema` and `@validate` custom validators work with field-level validation
- Field-level validation uses the same validation rules as submit validation
- The `'change'` event fires when a field loses focus (blur) after being modified, not on every keystroke
- The `'input'` event fires on every keystroke as the user types
- Input validation may trigger many validation calls, so consider performance for complex validation logic

### Yielded Components

Field yields bound versions of all form components:
- `field.Input` - Text input with automatic error and value binding
- `field.Textarea` - Textarea with automatic error and value binding
- `field.SingleSelect` - Select dropdown with automatic error and selectedKey binding
- `field.MultiSelect` - Select dropdown with automatic error and selectedKeys binding
- `field.Checkbox` - Single checkbox with automatic error and checked binding
- `field.CheckboxGroup` - Checkbox group with automatic error binding
- `field.RadioGroup` - Radio group with automatic error and value binding
- `field.Switch` - Toggle switch with automatic error and isSelected binding
- `field.Radio` - Individual radio button with automatic error and value binding

Each component automatically receives:
- The `@name` prop from the Field
- Any validation errors for that field name
- The current value from form data (if provided)
- A controlled change handler (when form data is provided)
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
  <field.SingleSelect
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