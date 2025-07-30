---
label: New
imports:
  - import Signature from 'site/components/signature';
---

# Radio

A standalone radio button component that allows users to select a single option. While typically used within a RadioGroup, it can also be used individually when you need more control over the layout and behavior.

## Import

```js
import { Radio } from '@frontile/forms';
```

## Usage

### Basic Radio

The most basic usage of a Radio component with a label and value.

```gts preview
import { Radio } from '@frontile/forms';

<template><Radio @label='Accept Terms' @value='accepted' /></template>
```

### Controlled Radio

You can control the radio state by providing `@checkedValue` and handling updates with `@onChange`.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Radio } from '@frontile/forms';

export default class ControlledRadio extends Component {
  @tracked selectedValue = '';

  updateValue = (value: string) => {
    this.selectedValue = value;
  };

  <template>
    <div class='flex flex-col gap-4'>
      <Radio
        @label='Subscribe to newsletter'
        @value='newsletter'
        @checkedValue={{this.selectedValue}}
        @onChange={{this.updateValue}}
      />

      <div class='p-3 border border-default-300 rounded'>
        <p class='text-sm'>
          Status:
          {{if this.selectedValue 'Subscribed' 'Not subscribed'}}
        </p>
      </div>
    </div>
  </template>
}
```

### Multiple Independent Radios

When you need multiple independent radio buttons (not part of a group), each should have a unique name.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Radio } from '@frontile/forms';

export default class IndependentRadios extends Component {
  @tracked emailNotifications = '';
  @tracked smsNotifications = '';
  @tracked pushNotifications = '';

  updateEmailNotifications = (value: string) => {
    this.emailNotifications = value;
  };

  updateSmsNotifications = (value: string) => {
    this.smsNotifications = value;
  };

  updatePushNotifications = (value: string) => {
    this.pushNotifications = value;
  };

  <template>
    <div class='flex flex-col gap-4'>
      <div class='space-y-3'>
        <Radio
          @name='email-notifications'
          @label='Enable email notifications'
          @value='enabled'
          @checkedValue={{this.emailNotifications}}
          @onChange={{this.updateEmailNotifications}}
        />

        <Radio
          @name='sms-notifications'
          @label='Enable SMS notifications'
          @value='enabled'
          @checkedValue={{this.smsNotifications}}
          @onChange={{this.updateSmsNotifications}}
        />

        <Radio
          @name='push-notifications'
          @label='Enable push notifications'
          @value='enabled'
          @checkedValue={{this.pushNotifications}}
          @onChange={{this.updatePushNotifications}}
        />
      </div>

      <div class='p-4 bg-gray-50 rounded'>
        <h4 class='font-medium mb-2'>Notification Settings:</h4>
        <ul class='text-sm space-y-1'>
          <li>Email: {{if this.emailNotifications 'Enabled' 'Disabled'}}</li>
          <li>SMS: {{if this.smsNotifications 'Enabled' 'Disabled'}}</li>
          <li>Push: {{if this.pushNotifications 'Enabled' 'Disabled'}}</li>
        </ul>
      </div>
    </div>
  </template>
}
```

### Manual Radio Group

Create a custom radio group using individual Radio components with the same name.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Radio } from '@frontile/forms';

export default class ManualRadioGroup extends Component {
  @tracked selectedTheme = 'light';

  updateTheme = (value: string) => {
    this.selectedTheme = value;
  };

  <template>
    <div class='flex flex-col gap-4'>
      <fieldset>
        <legend class='text-lg font-medium mb-3'>Choose Theme</legend>
        <div class='space-y-3'>
          <Radio
            @name='theme-preference'
            @label='Light Theme'
            @value='light'
            @checkedValue={{this.selectedTheme}}
            @onChange={{this.updateTheme}}
          />
          <Radio
            @name='theme-preference'
            @label='Dark Theme'
            @value='dark'
            @checkedValue={{this.selectedTheme}}
            @onChange={{this.updateTheme}}
          />
          <Radio
            @name='theme-preference'
            @label='System Theme'
            @value='system'
            @checkedValue={{this.selectedTheme}}
            @onChange={{this.updateTheme}}
          />
        </div>
      </fieldset>

      <div class='p-3 border border-default-300 rounded'>
        <p class='text-sm'>
          Selected theme:
          <strong>{{this.selectedTheme}}</strong>
        </p>
      </div>
    </div>
  </template>
}
```

### Sizes

Control the size of radio buttons using the `@size` argument.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Radio } from '@frontile/forms';

export default class RadioSizes extends Component {
  @tracked smallValue = '';
  @tracked mediumValue = '';
  @tracked largeValue = '';

  updateSmallValue = (value: string) => {
    this.smallValue = value;
  };

  updateMediumValue = (value: string) => {
    this.mediumValue = value;
  };

  updateLargeValue = (value: string) => {
    this.largeValue = value;
  };

  <template>
    <div class='flex flex-col gap-4'>
      <Radio
        @name='small-radio'
        @label='Small Radio'
        @size='sm'
        @value='small'
        @checkedValue={{this.smallValue}}
        @onChange={{this.updateSmallValue}}
      />

      <Radio
        @name='medium-radio'
        @label='Medium Radio'
        @size='md'
        @value='medium'
        @checkedValue={{this.mediumValue}}
        @onChange={{this.updateMediumValue}}
      />

      <Radio
        @name='large-radio'
        @label='Large Radio'
        @size='lg'
        @value='large'
        @checkedValue={{this.largeValue}}
        @onChange={{this.updateLargeValue}}
      />
    </div>
  </template>
}
```

### Radio with Description

Add helpful description text that appears below the radio label.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Radio } from '@frontile/forms';

export default class RadioWithDescription extends Component {
  @tracked agreement = '';

  updateAgreement = (value: string) => {
    this.agreement = value;
  };

  <template>
    <div class='flex flex-col gap-4'>
      <Radio
        @name='terms-agreement'
        @label='I agree to the terms and conditions'
        @description='By checking this box, you agree to our terms of service, privacy policy, and cookie policy. You can review these documents at any time.'
        @value='agreed'
        @checkedValue={{this.agreement}}
        @onChange={{this.updateAgreement}}
      />

      <Radio
        @name='marketing-consent'
        @label='I consent to receive marketing communications'
        @description='We will send you occasional updates about new features, promotions, and company news. You can unsubscribe at any time.'
        @value='consented'
      />
    </div>
  </template>
}
```

### Form Validation

The Radio component integrates with form validation by displaying error messages and updating ARIA attributes accordingly.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Radio } from '@frontile/forms';
import { on } from '@ember/modifier';
import { Button } from '@frontile/buttons';

export default class ValidatedRadio extends Component {
  @tracked termsAccepted = '';
  @tracked termsErrors: string[] = [];

  updateTermsAccepted = (value: string) => {
    this.termsAccepted = value;
    // Clear errors when user makes a selection
    this.termsErrors = [];
  };

  validateTerms = () => {
    if (!this.termsAccepted) {
      this.termsErrors = [
        'You must accept the terms and conditions to continue'
      ];
    } else {
      this.termsErrors = [];
      console.log('Terms accepted');
    }
  };

  <template>
    <div class='flex flex-col gap-4'>
      <Radio
        @name='terms-validation'
        @label='I accept the terms and conditions'
        @description='Please read and accept our terms and conditions before proceeding.'
        @value='accepted'
        @checkedValue={{this.termsAccepted}}
        @onChange={{this.updateTermsAccepted}}
        @errors={{this.termsErrors}}
        @isRequired={{true}}
      />

      <div>
        <Button {{on 'click' this.validateTerms}}>
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
import { Radio } from '@frontile/forms';

export default class HorizontalRadios extends Component {
  @tracked rating = '';

  updateRating = (value: string) => {
    this.rating = value;
  };

  <template>
    <div class='flex flex-col gap-4'>
      <fieldset>
        <legend class='text-lg font-medium mb-3'>Rate your experience</legend>
        <div class='flex gap-4'>
          <Radio
            @name='experience-rating'
            @label='Poor'
            @value='poor'
            @checkedValue={{this.rating}}
            @onChange={{this.updateRating}}
          />
          <Radio
            @name='experience-rating'
            @label='Fair'
            @value='fair'
            @checkedValue={{this.rating}}
            @onChange={{this.updateRating}}
          />
          <Radio
            @name='experience-rating'
            @label='Good'
            @value='good'
            @checkedValue={{this.rating}}
            @onChange={{this.updateRating}}
          />
          <Radio
            @name='experience-rating'
            @label='Excellent'
            @value='excellent'
            @checkedValue={{this.rating}}
            @onChange={{this.updateRating}}
          />
        </div>
      </fieldset>

      {{#if this.rating}}
        <div class='p-3 border border-default-300 rounded'>
          <p class='text-sm'>You rated your experience as:
            <strong>{{this.rating}}</strong></p>
        </div>
      {{/if}}
    </div>
  </template>
}
```

### Custom Styling

You can customize the appearance of different parts of the radio using the `@classes` argument.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Radio } from '@frontile/forms';
import { hash } from '@ember/helper';

export default class CustomStyledRadio extends Component {
  @tracked customValue = '';

  updateCustomValue = (value: string) => {
    this.customValue = value;
  };

  <template>
    <Radio
      @name='custom-styled'
      @label='Custom Styled Radio'
      @value='custom'
      @checkedValue={{this.customValue}}
      @onChange={{this.updateCustomValue}}
      @classes={{hash
        base='my-custom-radio-base'
        input='my-custom-radio-input'
        labelContainer='my-custom-label-container'
        label='my-custom-radio-label'
      }}
    />
  </template>
}
```

## When to Use Radio vs RadioGroup

**Use the standalone Radio component when:**

- You need a single checkbox-like behavior (independent selection)
- You want complete control over layout and spacing
- You're building a custom form layout
- Each radio represents a separate boolean choice

**Use RadioGroup when:**

- You have multiple mutually exclusive options
- You want automatic grouping and name management
- You need consistent spacing and layout
- You want built-in label and description support for the group

## Accessibility

The Radio component follows accessibility best practices:

- Proper label association using `for` and `id` attributes
- ARIA attributes for invalid states (`aria-invalid`)
- Descriptive text association using `aria-describedby`
- Support for required field indication
- Keyboard navigation follows standard radio button patterns
- Screen reader announcements for labels, descriptions, and validation messages
- Proper focus management and visual focus indicators

## API

<Signature @package="forms" @component="Radio" />
