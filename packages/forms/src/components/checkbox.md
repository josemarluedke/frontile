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

The Checkbox component integrates with form validation by displaying error messages and updating ARIA attributes accordingly.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Checkbox } from '@frontile/forms';
import { on } from '@ember/modifier';
import { Button } from '@frontile/buttons';

export default class ValidatedCheckbox extends Component {
  @tracked termsAccepted = false;
  @tracked privacyAccepted = false;
  @tracked termsErrors: string[] = [];
  @tracked privacyErrors: string[] = [];

  updateTermsAccepted = (checked: boolean) => {
    this.termsAccepted = checked;
    // Clear errors when user checks the box
    if (checked) {
      this.termsErrors = [];
    }
  };

  updatePrivacyAccepted = (checked: boolean) => {
    this.privacyAccepted = checked;
    // Clear errors when user checks the box
    if (checked) {
      this.privacyErrors = [];
    }
  };

  validateForm = () => {
    // Reset errors
    this.termsErrors = [];
    this.privacyErrors = [];

    let hasErrors = false;

    if (!this.termsAccepted) {
      this.termsErrors = [
        'You must accept the terms and conditions to continue'
      ];
      hasErrors = true;
    }

    if (!this.privacyAccepted) {
      this.privacyErrors = ['You must accept the privacy policy to continue'];
      hasErrors = true;
    }

    if (!hasErrors) {
      console.log('Form is valid!');
    }
  };

  <template>
    <div class='flex flex-col gap-4'>
      <Checkbox
        @name='terms-validation'
        @label='I accept the terms and conditions'
        @description='Please read and accept our terms and conditions before proceeding.'
        @checked={{this.termsAccepted}}
        @onChange={{this.updateTermsAccepted}}
        @errors={{this.termsErrors}}
        @isRequired={{true}}
      />

      <Checkbox
        @name='privacy-validation'
        @label='I accept the privacy policy'
        @description='Please read and accept our privacy policy before proceeding.'
        @checked={{this.privacyAccepted}}
        @onChange={{this.updatePrivacyAccepted}}
        @errors={{this.privacyErrors}}
        @isRequired={{true}}
      />

      <div>
        <Button {{on 'click' this.validateForm}}>
          Continue
        </Button>
      </div>
    </div>
  </template>
}
```

### Horizontal Layout

Create a horizontal layout using CSS Grid or Flexbox.

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

Here's a comprehensive example showing Checkbox components in a form context:

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Checkbox } from '@frontile/forms';
import { Input } from '@frontile/forms';
import { on } from '@ember/modifier';
import { Button } from '@frontile/buttons';

export default class CompleteFormWithCheckbox extends Component {
  @tracked email = '';
  @tracked firstName = '';
  @tracked agreements = {
    terms: false,
    privacy: false,
    marketing: false
  };

  @tracked emailErrors: string[] = [];
  @tracked firstNameErrors: string[] = [];
  @tracked termsErrors: string[] = [];
  @tracked privacyErrors: string[] = [];

  updateEmail = (value: string) => {
    this.email = value;
    this.emailErrors = [];
  };

  updateFirstName = (value: string) => {
    this.firstName = value;
    this.firstNameErrors = [];
  };

  updateAgreement = (key: string) => (checked: boolean) => {
    this.agreements = { ...this.agreements, [key]: checked };
    // Clear respective errors
    if (key === 'terms') this.termsErrors = [];
    if (key === 'privacy') this.privacyErrors = [];
  };

  handleSubmit = (event: Event) => {
    event.preventDefault();

    // Reset errors
    this.emailErrors = [];
    this.firstNameErrors = [];
    this.termsErrors = [];
    this.privacyErrors = [];

    // Validate form
    let hasErrors = false;

    if (!this.firstName.trim()) {
      this.firstNameErrors = ['First name is required'];
      hasErrors = true;
    }

    if (!this.email.trim()) {
      this.emailErrors = ['Email is required'];
      hasErrors = true;
    } else if (!this.email.includes('@')) {
      this.emailErrors = ['Please enter a valid email address'];
      hasErrors = true;
    }

    if (!this.agreements.terms) {
      this.termsErrors = ['You must accept the terms and conditions'];
      hasErrors = true;
    }

    if (!this.agreements.privacy) {
      this.privacyErrors = ['You must accept the privacy policy'];
      hasErrors = true;
    }

    if (!hasErrors) {
      console.log('Form submitted successfully!', {
        firstName: this.firstName,
        email: this.email,
        agreements: this.agreements
      });
    }
  };

  <template>
    <form {{on 'submit' this.handleSubmit}}>
      <div class='flex flex-col gap-4'>

        <Input
          @label='First Name'
          @value={{this.firstName}}
          @onInput={{this.updateFirstName}}
          @isRequired={{true}}
          @errors={{this.firstNameErrors}}
        />

        <Input
          @label='Email Address'
          @type='email'
          @value={{this.email}}
          @onInput={{this.updateEmail}}
          @isRequired={{true}}
          @errors={{this.emailErrors}}
        />

        <Checkbox
          @name='terms-agreement'
          @label='I agree to the Terms and Conditions'
          @description='You must accept our terms to create an account'
          @checked={{this.agreements.terms}}
          @onChange={{this.updateAgreement 'terms'}}
          @errors={{this.termsErrors}}
          @isRequired={{true}}
        />

        <Checkbox
          @name='privacy-agreement'
          @label='I agree to the Privacy Policy'
          @description='You must accept our privacy policy to create an account'
          @checked={{this.agreements.privacy}}
          @onChange={{this.updateAgreement 'privacy'}}
          @errors={{this.privacyErrors}}
          @isRequired={{true}}
        />

        <Checkbox
          @name='marketing-consent'
          @label='I would like to receive marketing emails'
          @description='Optional: Get updates about new features and promotions'
          @checked={{this.agreements.marketing}}
          @onChange={{this.updateAgreement 'marketing'}}
        />

        <div>
          <Button @class='mt-4'>
            Create Account
          </Button>
        </div>

      </div>
    </form>
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

**Use CheckboxGroup when:**

- You have multiple related options that can be selected together
- You want automatic grouping and consistent layout
- You need group-level validation and error handling
- You want built-in label and description support for the group

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
