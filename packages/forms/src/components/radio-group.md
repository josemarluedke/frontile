---
label: New
imports:
  - import Signature from 'site/components/signature';
---

# Radio Group

A flexible radio group component that allows users to select a single option from multiple choices. It provides a clean interface with support for labels, validation, different orientations, and comprehensive accessibility features.

## Import

```js
import { RadioGroup } from '@frontile/forms';
```

## Usage

### Basic Radio Group

The most basic usage of the RadioGroup component with a label and options.

```gts preview
import { RadioGroup } from '@frontile/forms';

<template>
  <RadioGroup @name='interests' @label='Interests' as |Radio|>
    <Radio @label='Music' @value='music' />
    <Radio @label='Sports' @value='sports' />
    <Radio @label='Technology' @value='technology' />
  </RadioGroup>
</template>
```

### Controlled Radio Group

You can control the radio group value by providing `@value` and handling updates with `@onChange`.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { RadioGroup } from '@frontile/forms';

export default class ControlledRadioGroup extends Component {
  @tracked selectedValue = 'music';

  updateValue = (value: string) => {
    this.selectedValue = value;
  };

  <template>
    <div class='flex flex-col gap-4'>
      <RadioGroup
        @name='interests'
        @label='What are your interests?'
        @value={{this.selectedValue}}
        @onChange={{this.updateValue}}
        as |Radio|
      >
        <Radio @label='Music' @value='music' />
        <Radio @label='Sports' @value='sports' />
        <Radio @label='Technology' @value='technology' />
        <Radio @label='Art' @value='art' />
      </RadioGroup>

      <div class='mt-4 p-3 border border-default-300 rounded'>
        <p class='text-sm'>Selected: <strong>{{this.selectedValue}}</strong></p>
      </div>
    </div>
  </template>
}
```

### Orientation

Control the layout orientation of radio options using the `@orientation` argument. Options can be arranged vertically (default) or horizontally.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { RadioGroup } from '@frontile/forms';

export default class OrientationExample extends Component {
  @tracked verticalValue = '';
  @tracked horizontalValue = '';

  updateVertical = (value: string) => {
    this.verticalValue = value;
  };

  updateHorizontal = (value: string) => {
    this.horizontalValue = value;
  };

  <template>
    <div class='flex flex-col gap-4'>
      <RadioGroup
        @name='vertical-example'
        @label='Vertical Layout (Default)'
        @orientation='vertical'
        @value={{this.verticalValue}}
        @onChange={{this.updateVertical}}
        as |Radio|
      >
        <Radio @label='Option 1' @value='option1' />
        <Radio @label='Option 2' @value='option2' />
        <Radio @label='Option 3' @value='option3' />
      </RadioGroup>

      <RadioGroup
        @name='horizontal-example'
        @label='Horizontal Layout'
        @orientation='horizontal'
        @value={{this.horizontalValue}}
        @onChange={{this.updateHorizontal}}
        as |Radio|
      >
        <Radio @label='Small' @value='sm' />
        <Radio @label='Medium' @value='md' />
        <Radio @label='Large' @value='lg' />
        <Radio @label='Extra Large' @value='xl' />
      </RadioGroup>
    </div>
  </template>
}
```

### Sizes

Control the size of radio inputs using the `@size` argument.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { RadioGroup } from '@frontile/forms';

export default class RadioGroupSizes extends Component {
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
      <RadioGroup
        @name='small-size'
        @label='Small Size'
        @size='sm'
        @value={{this.smallValue}}
        @onChange={{this.updateSmallValue}}
        as |Radio|
      >
        <Radio @label='Option A' @value='a' />
        <Radio @label='Option B' @value='b' />
      </RadioGroup>

      <RadioGroup
        @name='medium-size'
        @label='Medium Size'
        @size='md'
        @value={{this.mediumValue}}
        @onChange={{this.updateMediumValue}}
        as |Radio|
      >
        <Radio @label='Option A' @value='a' />
        <Radio @label='Option B' @value='b' />
      </RadioGroup>

      <RadioGroup
        @name='large-size'
        @label='Large Size'
        @size='lg'
        @value={{this.largeValue}}
        @onChange={{this.updateLargeValue}}
        as |Radio|
      >
        <Radio @label='Option A' @value='a' />
        <Radio @label='Option B' @value='b' />
      </RadioGroup>
    </div>
  </template>
}
```

### Radio Options with Descriptions

Each radio option can include its own description text for additional context.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { RadioGroup } from '@frontile/forms';

export default class RadioWithDescriptions extends Component {
  @tracked plan = '';

  updatePlan = (value: string) => {
    this.plan = value;
  };

  <template>
    <RadioGroup
      @name='subscription-plan'
      @label='Choose your subscription plan'
      @value={{this.plan}}
      @onChange={{this.updatePlan}}
      as |Radio|
    >
      <Radio
        @label='Basic'
        @value='basic'
        @description='Perfect for individuals getting started. Includes basic features.'
      />
      <Radio
        @label='Pro'
        @value='pro'
        @description='Great for professionals. Includes advanced features and priority support.'
      />
      <Radio
        @label='Enterprise'
        @value='enterprise'
        @description='For large teams. Includes all features, dedicated support, and custom integrations.'
      />
    </RadioGroup>
  </template>
}
```

### Form Validation

The RadioGroup component integrates with form validation by displaying error messages and updating ARIA attributes accordingly.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { RadioGroup } from '@frontile/forms';
import { on } from '@ember/modifier';
import { Button } from '@frontile/buttons';

export default class ValidatedRadioGroup extends Component {
  @tracked selectedOption = '';
  @tracked errors: string[] = [];

  updateSelection = (value: string) => {
    this.selectedOption = value;
    // Clear errors when user makes a selection
    this.errors = [];
  };

  validateSelection = () => {
    if (!this.selectedOption) {
      this.errors = ['Please select an option'];
    } else {
      this.errors = [];
      console.log('Selection is valid:', this.selectedOption);
    }
  };

  <template>
    <div class='flex flex-col gap-4'>
      <RadioGroup
        @name='required-selection'
        @label='Choose your preferred method'
        @value={{this.selectedOption}}
        @onChange={{this.updateSelection}}
        @errors={{this.errors}}
        @isRequired={{true}}
        as |Radio|
      >
        <Radio @label='Email notification' @value='email' />
        <Radio @label='SMS notification' @value='sms' />
        <Radio @label='Push notification' @value='push' />
        <Radio @label='No notifications' @value='none' />
      </RadioGroup>

      <div>
        <Button {{on 'click' this.validateSelection}}>
          Validate Selection
        </Button>
      </div>
    </div>
  </template>
}
```

### With Description

Add helpful description text to the entire radio group that appears below the label.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { RadioGroup } from '@frontile/forms';

export default class RadioGroupWithDescription extends Component {
  @tracked theme = '';

  updateTheme = (value: string) => {
    this.theme = value;
  };

  <template>
    <RadioGroup
      @name='theme-preference'
      @label='Theme Preference'
      @description="Choose how you'd like the interface to appear. You can change this later in settings."
      @value={{this.theme}}
      @onChange={{this.updateTheme}}
      as |Radio|
    >
      <Radio @label='Light' @value='light' />
      <Radio @label='Dark' @value='dark' />
      <Radio @label='System' @value='system' />
    </RadioGroup>
  </template>
}
```

### Complete Form Example

Here's a comprehensive example showing a RadioGroup in a form context with other inputs:

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { RadioGroup } from '@frontile/forms';
import { Input } from '@frontile/forms';
import { on } from '@ember/modifier';
import { Button } from '@frontile/buttons';

export default class CompleteFormWithRadio extends Component {
  @tracked name = '';
  @tracked contactMethod = '';
  @tracked urgency = '';

  @tracked nameErrors: string[] = [];
  @tracked contactMethodErrors: string[] = [];
  @tracked urgencyErrors: string[] = [];

  updateName = (value: string) => {
    this.name = value;
    this.nameErrors = [];
  };

  updateContactMethod = (value: string) => {
    this.contactMethod = value;
    this.contactMethodErrors = [];
  };

  updateUrgency = (value: string) => {
    this.urgency = value;
    this.urgencyErrors = [];
  };

  handleSubmit = (event: Event) => {
    event.preventDefault();

    // Reset errors
    this.nameErrors = [];
    this.contactMethodErrors = [];
    this.urgencyErrors = [];

    // Validate form
    let hasErrors = false;

    if (!this.name.trim()) {
      this.nameErrors = ['Name is required'];
      hasErrors = true;
    }

    if (!this.contactMethod) {
      this.contactMethodErrors = ['Please select a contact method'];
      hasErrors = true;
    }

    if (!this.urgency) {
      this.urgencyErrors = ['Please select urgency level'];
      hasErrors = true;
    }

    if (!hasErrors) {
      console.log('Form submitted successfully!', {
        name: this.name,
        contactMethod: this.contactMethod,
        urgency: this.urgency
      });
    }
  };

  <template>
    <form {{on 'submit' this.handleSubmit}}>
      <div class='flex flex-col gap-4'>

        <Input
          @label='Full Name'
          @value={{this.name}}
          @onInput={{this.updateName}}
          @isRequired={{true}}
          @errors={{this.nameErrors}}
        />

        <RadioGroup
          @name='contact-method'
          @label='Preferred Contact Method'
          @value={{this.contactMethod}}
          @onChange={{this.updateContactMethod}}
          @errors={{this.contactMethodErrors}}
          @isRequired={{true}}
          @orientation='horizontal'
          as |Radio|
        >
          <Radio @label='Email' @value='email' />
          <Radio @label='Phone' @value='phone' />
          <Radio @label='Text' @value='text' />
        </RadioGroup>

        <RadioGroup
          @name='urgency'
          @label='Request Urgency'
          @description='Help us prioritize your request appropriately'
          @value={{this.urgency}}
          @onChange={{this.updateUrgency}}
          @errors={{this.urgencyErrors}}
          @isRequired={{true}}
          as |Radio|
        >
          <Radio
            @label='Low'
            @value='low'
            @description='Response within 3-5 business days'
          />
          <Radio
            @label='Medium'
            @value='medium'
            @description='Response within 1-2 business days'
          />
          <Radio
            @label='High'
            @value='high'
            @description='Response within 24 hours'
          />
          <Radio
            @label='Critical'
            @value='critical'
            @description='Immediate response required'
          />
        </RadioGroup>

        <div>
          <Button @class='mt-4'>
            Submit Request
          </Button>
        </div>

      </div>
    </form>
  </template>
}
```

### Custom Styling

You can customize the appearance of different parts of the radio group using the `@classes` argument.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { RadioGroup } from '@frontile/forms';
import { hash } from '@ember/helper';

export default class CustomStyledRadioGroup extends Component {
  @tracked customValue = '';

  updateCustomValue = (value: string) => {
    this.customValue = value;
  };

  <template>
    <RadioGroup
      @name='custom-styled'
      @label='Custom Styled Radio Group'
      @value={{this.customValue}}
      @onChange={{this.updateCustomValue}}
      @classes={{hash
        base='my-custom-radio-group'
        label='my-custom-label'
        optionsContainer='my-custom-options-container'
      }}
      as |Radio|
    >
      <Radio @label='Option 1' @value='option1' />
      <Radio @label='Option 2' @value='option2' />
      <Radio @label='Option 3' @value='option3' />
    </RadioGroup>
  </template>
}
```

## Accessibility

The RadioGroup component follows accessibility best practices:

- Proper grouping with fieldset/legend semantics via FormControl
- Unique `name` attribute ensures radio buttons work as a group
- Proper label association for each radio option
- ARIA attributes for invalid states (`aria-invalid`)
- Descriptive text association using `aria-describedby`
- Support for required field indication
- Keyboard navigation follows standard radio group patterns (arrow keys to navigate between options)
- Screen reader announcements for group label, individual option labels, and validation messages

## API

<Signature @package="forms" @component="RadioGroup" />
