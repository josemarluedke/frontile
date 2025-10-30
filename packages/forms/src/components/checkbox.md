---
label: New
imports:
  - import Signature from 'site/components/signature';
---

# Checkbox

A standalone checkbox component that allows users to select or deselect individual options. While typically used within a CheckboxGroup, it can also be used individually when you need more control over the layout and behavior. The component is controlled, requiring `@checked` and `@onChange` for state management.

## Import

```js
import { Checkbox } from '@frontile/forms';
```

## Usage

### Basic Checkbox

The most basic usage of a Checkbox component with a label.

```gts preview
import { Checkbox } from '@frontile/forms';

<template><Checkbox @label='Subscribe to newsletter' /></template>
```

### Controlled Checkbox

You can control the checkbox state by providing `@checked` and handling updates with `@onChange`.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Checkbox } from '@frontile/forms';

export default class ControlledCheckbox extends Component {
  @tracked isSubscribed = false;

  updateSubscription = (checked: boolean) => {
    this.isSubscribed = checked;
  };

  <template>
    <div class='flex flex-col gap-4'>
      <Checkbox
        @label='Subscribe to newsletter'
        @checked={{this.isSubscribed}}
        @onChange={{this.updateSubscription}}
      />

      <div class='p-3 border border-default-300 rounded'>
        <p class='text-sm'>
          Status:
          {{if this.isSubscribed 'Subscribed' 'Not subscribed'}}
        </p>
      </div>
    </div>
  </template>
}
```

### Multiple Independent Checkboxes

When you need multiple independent checkboxes, each should have a unique name and state.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Checkbox } from '@frontile/forms';

export default class IndependentCheckboxes extends Component {
  @tracked notifications = {
    email: false,
    sms: false,
    push: false
  };

  updateEmailNotifications = (checked: boolean) => {
    this.notifications = { ...this.notifications, email: checked };
  };

  updateSmsNotifications = (checked: boolean) => {
    this.notifications = { ...this.notifications, sms: checked };
  };

  updatePushNotifications = (checked: boolean) => {
    this.notifications = { ...this.notifications, push: checked };
  };

  get enabledNotifications() {
    return Object.entries(this.notifications)
      .filter(([_, enabled]) => enabled)
      .map(([type]) => type)
      .join(', ');
  }

  <template>
    <div class='flex flex-col gap-4'>
      <Checkbox
        @name='email-notifications'
        @label='Email notifications'
        @checked={{this.notifications.email}}
        @onChange={{this.updateEmailNotifications}}
      />

      <Checkbox
        @name='sms-notifications'
        @label='SMS notifications'
        @checked={{this.notifications.sms}}
        @onChange={{this.updateSmsNotifications}}
      />

      <Checkbox
        @name='push-notifications'
        @label='Push notifications'
        @checked={{this.notifications.push}}
        @onChange={{this.updatePushNotifications}}
      />

      <div class='p-4 bg-default-50 rounded'>
        <h4 class='font-medium mb-2'>Enabled Notifications:</h4>
        <p class='text-sm'>
          {{if
            this.enabledNotifications
            this.enabledNotifications
            'None selected'
          }}
        </p>
      </div>
    </div>
  </template>
}
```

> **Note:** This example shows manual state management. For forms with validation, see the "Form Validation" and "Complete Form Example" sections which use Form/Field components.

### Sizes

Control the size of checkboxes using the `@size` argument.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Checkbox } from '@frontile/forms';

export default class CheckboxSizes extends Component {
  @tracked smallChecked = false;
  @tracked mediumChecked = false;
  @tracked largeChecked = false;

  updateSmallChecked = (checked: boolean) => {
    this.smallChecked = checked;
  };

  updateMediumChecked = (checked: boolean) => {
    this.mediumChecked = checked;
  };

  updateLargeChecked = (checked: boolean) => {
    this.largeChecked = checked;
  };

  <template>
    <div class='flex flex-col gap-4'>
      <Checkbox
        @name='small-checkbox'
        @label='Small Checkbox'
        @size='sm'
        @checked={{this.smallChecked}}
        @onChange={{this.updateSmallChecked}}
      />

      <Checkbox
        @name='medium-checkbox'
        @label='Medium Checkbox'
        @size='md'
        @checked={{this.mediumChecked}}
        @onChange={{this.updateMediumChecked}}
      />

      <Checkbox
        @name='large-checkbox'
        @label='Large Checkbox'
        @size='lg'
        @checked={{this.largeChecked}}
        @onChange={{this.updateLargeChecked}}
      />
    </div>
  </template>
}
```

### Disabled State

Checkboxes can be disabled to prevent user interaction while maintaining their visual presence and current state.

```gts preview
import Component from '@glimmer/component';
import { Checkbox } from '@frontile/forms';

export default class DisabledCheckbox extends Component {
  <template>
    <div class='flex flex-col gap-4'>
      <Checkbox
        @name='disabled-checked'
        @label='Disabled Checked Checkbox'
        @checked={{true}}
        disabled={{true}}
      />

      <Checkbox
        @name='disabled-unchecked'
        @label='Disabled Unchecked Checkbox'
        @checked={{false}}
        disabled={{true}}
      />

      <Checkbox
        @name='disabled-with-description'
        @label='Disabled Checkbox with Description'
        @description='This checkbox is disabled and cannot be modified'
        @checked={{true}}
        disabled={{true}}
      />
    </div>
  </template>
}
```

### Checkbox with Description

Add helpful description text that appears below the checkbox label.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Checkbox } from '@frontile/forms';

export default class CheckboxWithDescription extends Component {
  @tracked termsAccepted = false;
  @tracked marketingConsent = false;

  updateTermsAccepted = (checked: boolean) => {
    this.termsAccepted = checked;
  };

  updateMarketingConsent = (checked: boolean) => {
    this.marketingConsent = checked;
  };

  <template>
    <div class='flex flex-col gap-4'>
      <Checkbox
        @name='terms-acceptance'
        @label='I agree to the terms and conditions'
        @description='By checking this box, you agree to our terms of service, privacy policy, and cookie policy. You can review these documents at any time.'
        @checked={{this.termsAccepted}}
        @onChange={{this.updateTermsAccepted}}
      />

      <Checkbox
        @name='marketing-consent'
        @label='I consent to receive marketing communications'
        @description='We will send you occasional updates about new features, promotions, and company news. You can unsubscribe at any time.'
        @checked={{this.marketingConsent}}
        @onChange={{this.updateMarketingConsent}}
      />
    </div>
  </template>
}
```

### Form Validation

**Note:** When used with `field.Checkbox` as demonstrated in the examples below, individual Checkbox components support field-level validation (validates on change/blur/input events based on `@validateOn`). This differs from CheckboxGroup, which currently only supports validation on form submit.

The Checkbox component integrates with the Form validation system, providing automatic error display and field-level validation. This example demonstrates using a required checkbox with the Form/Field components.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { Form, type FormResultData } from '@frontile/forms';
import { Button } from '@frontile/buttons';
import { array } from '@ember/helper';
import * as v from 'valibot';

// Define validation schema - checkbox must be true
const schema = v.object({
  termsAccepted: v.pipe(
    v.boolean(),
    v.literal(true, 'You must accept the terms and conditions to continue')
  )
});

type Schema = v.InferOutput<typeof schema>;

export default class ValidatedCheckbox extends Component {
  @tracked formData: Schema = {
    termsAccepted: false
  };
  @tracked submitMessage = '';

  @action
  handleFormChange(data: FormResultData<Schema>) {
    this.formData = data.data;
  }

  @action
  handleFormSubmit(data: FormResultData<Schema>) {
    this.submitMessage = 'Terms accepted successfully!';
    console.log('Form submitted:', data.data);
  }

  <template>
    <div class='flex flex-col gap-4'>
      <Form
        @data={{this.formData}}
        @schema={{schema}}
        @onChange={{this.handleFormChange}}
        @onSubmit={{this.handleFormSubmit}}
        @validateOn={{array 'change' 'submit'}}
        as |form|
      >
        <form.Field @name='termsAccepted' as |field|>
          <field.Checkbox
            @label='I accept the terms and conditions'
            @description='Please read and accept our terms and conditions before proceeding.'
            @isRequired={{true}}
          />
        </form.Field>

        <div>
          <Button type='submit'>
            Continue
          </Button>
        </div>
      </Form>

      {{#if this.submitMessage}}
        <div class='p-3 bg-success-50 text-success-800 rounded'>
          {{this.submitMessage}}
        </div>
      {{/if}}

      <div class='p-4 bg-default-50 rounded'>
        <h4 class='font-medium mb-2'>Form Data:</h4>
        <pre class='text-sm overflow-auto'>{{JSON.stringify
            this.formData
            null
            2
          }}</pre>
      </div>
    </div>
  </template>
}
```

### Horizontal Layout

Create a horizontal layout using CSS Grid or Flexbox.

> **Note:** For horizontal layouts of related checkboxes, consider using `CheckboxGroup` with `@orientation='horizontal'`.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Checkbox } from '@frontile/forms';

export default class HorizontalCheckboxes extends Component {
  @tracked preferences = {
    newsletter: false,
    updates: false,
    promotions: false
  };

  updatePreference = (key: string) => (checked: boolean) => {
    this.preferences = { ...this.preferences, [key]: checked };
  };

  <template>
    <div class='flex flex-col gap-4'>
      <fieldset>
        <legend class='text-lg font-medium mb-3'>Email Preferences</legend>
        <div class='flex gap-4'>
          <Checkbox
            @name='newsletter-pref'
            @label='Newsletter'
            @checked={{this.preferences.newsletter}}
            @onChange={{this.updatePreference 'newsletter'}}
          />
          <Checkbox
            @name='updates-pref'
            @label='Product Updates'
            @checked={{this.preferences.updates}}
            @onChange={{this.updatePreference 'updates'}}
          />
          <Checkbox
            @name='promotions-pref'
            @label='Promotions'
            @checked={{this.preferences.promotions}}
            @onChange={{this.updatePreference 'promotions'}}
          />
        </div>
      </fieldset>

      <div class='p-3 border border-default-300 rounded'>
        <p class='text-sm'>
          Selected preferences:
          {{#each-in this.preferences as |key value|}}
            {{#if value}}{{key}} {{/if}}
          {{/each-in}}
        </p>
      </div>
    </div>
  </template>
}
```

### Complete Form Example

Here's a comprehensive example showing Checkbox components integrated with the Form validation system. This example demonstrates a registration form with an Input field, a required checkbox, and an optional checkbox.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { Form, type FormResultData } from '@frontile/forms';
import { Button } from '@frontile/buttons';
import { array } from '@ember/helper';
import * as v from 'valibot';

// Define validation schema
const schema = v.object({
  email: v.pipe(
    v.string(),
    v.nonEmpty('Email is required'),
    v.email('Please enter a valid email address')
  ),
  termsAccepted: v.pipe(
    v.boolean(),
    v.literal(true, 'You must accept the terms and conditions')
  ),
  marketingConsent: v.boolean() // Optional checkbox - no literal(true) requirement
});

type Schema = v.InferOutput<typeof schema>;

export default class CompleteFormWithCheckbox extends Component {
  @tracked formData: Schema = {
    email: '',
    termsAccepted: false,
    marketingConsent: false
  };
  @tracked submitMessage = '';

  @action
  handleFormChange(data: FormResultData<Schema>) {
    this.formData = data.data;
  }

  @action
  handleFormSubmit(data: FormResultData<Schema>) {
    this.submitMessage = 'Account created successfully!';
    console.log('Form submitted:', data.data);
  }

  <template>
    <div class='flex flex-col gap-4'>
      <Form
        @data={{this.formData}}
        @schema={{schema}}
        @onChange={{this.handleFormChange}}
        @onSubmit={{this.handleFormSubmit}}
        @validateOn={{array 'change' 'submit'}}
        as |form|
      >
        <div class='flex flex-col gap-4'>
          <form.Field @name='email' as |field|>
            <field.Input
              @label='Email Address'
              @type='email'
              @isRequired={{true}}
            />
          </form.Field>

          <form.Field @name='termsAccepted' as |field|>
            <field.Checkbox
              @label='I agree to the Terms and Conditions'
              @description='You must accept our terms to create an account'
              @isRequired={{true}}
            />
          </form.Field>

          <form.Field @name='marketingConsent' as |field|>
            <field.Checkbox
              @label='I would like to receive marketing emails'
              @description='Optional: Get updates about new features and promotions'
            />
          </form.Field>

          <div>
            <Button type='submit' disabled={{form.isSubmitting}}>
              {{if form.isSubmitting 'Creating Account...' 'Create Account'}}
            </Button>
          </div>
        </div>
      </Form>

      {{#if this.submitMessage}}
        <div class='p-3 bg-success-50 text-success-800 rounded'>
          {{this.submitMessage}}
        </div>
      {{/if}}

      <div class='p-4 bg-default-50 rounded'>
        <h4 class='font-medium mb-2'>Form Data:</h4>
        <pre class='text-sm overflow-auto'>{{JSON.stringify
            this.formData
            null
            2
          }}</pre>
      </div>
    </div>
  </template>
}
```

### Custom Styling

You can customize the appearance of different parts of the checkbox using the `@classes` argument.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Checkbox } from '@frontile/forms';
import { hash } from '@ember/helper';

export default class CustomStyledCheckbox extends Component {
  @tracked customChecked = false;

  updateCustomChecked = (checked: boolean) => {
    this.customChecked = checked;
  };

  <template>
    <Checkbox
      @name='custom-styled'
      @label='Custom Styled Checkbox'
      @description='This checkbox has custom styling applied'
      @checked={{this.customChecked}}
      @onChange={{this.updateCustomChecked}}
      @classes={{hash
        base='my-custom-checkbox-base'
        input='my-custom-checkbox-input'
        labelContainer='my-custom-label-container'
        label='my-custom-checkbox-label'
      }}
    />
  </template>
}
```

## When to Use Checkbox vs CheckboxGroup

**Use the standalone Checkbox component when:**

- You need independent boolean choices
- You want complete control over layout and spacing
- You're building a custom form layout
- Each checkbox represents a separate decision
- You need field-level validation with change/blur/input events

**Use CheckboxGroup when:**

- You have multiple related options that can be selected together
- You want automatic grouping and consistent layout
- You need group-level validation and error handling
- You want built-in label and description support for the group
- Note: CheckboxGroup currently only supports validation on form submit, not on change/blur/input events

## Accessibility

The Checkbox component follows accessibility best practices:

- Proper label association using `for` and `id` attributes
- ARIA attributes for invalid states (`aria-invalid`)
- Descriptive text association using `aria-describedby`
- Support for required field indication
- Keyboard navigation follows standard checkbox patterns (space to toggle)
- Screen reader announcements for labels, descriptions, and validation messages
- Proper focus management and visual focus indicators

## API

<Signature @package="forms" @component="Checkbox" />
