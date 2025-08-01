---
label: New
imports:
  - import Signature from 'site/components/signature';
---

# Textarea

A versatile textarea component that provides a clean interface for multi-line text input with support for labels, validation, different sizes, and comprehensive accessibility features.

## Import

```js
import { Textarea } from '@frontile/forms';
```

## Usage

### Basic Textarea

The most basic usage of the Textarea component with only a label.

```gts preview
import { Textarea } from '@frontile/forms';

<template><Textarea @label='Message' /></template>
```

### Controlled Textarea

You can control the textarea value by providing `@value` and handling updates with `@onInput` or `@onChange`.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Textarea } from '@frontile/forms';

export default class ControlledTextarea extends Component {
  @tracked message = '';

  updateMessage = (value: string) => {
    this.message = value;
  };

  <template>
    <div class='flex flex-col gap-4'>
      <Textarea
        @label='Your Message'
        @value={{this.message}}
        @onInput={{this.updateMessage}}
        placeholder='Enter your message here...'
      />
      <div class='p-3 border border-default-300 rounded'>
        <p class='text-sm text-default-600'>Character count:
          {{this.message.length}}</p>
        <p class='text-sm'>Current message: {{this.message}}</p>
      </div>
    </div>
  </template>
}
```

### Sizes

Control the size of the textarea using the `@size` argument.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Textarea } from '@frontile/forms';

export default class TextareaSizes extends Component {
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
      <Textarea
        @label='Small Textarea'
        @size='sm'
        @value={{this.smallValue}}
        @onInput={{this.updateSmallValue}}
        placeholder='Small size textarea'
      />
      <Textarea
        @label='Medium Textarea'
        @size='md'
        @value={{this.mediumValue}}
        @onInput={{this.updateMediumValue}}
        placeholder='Medium size textarea'
      />
      <Textarea
        @label='Large Textarea'
        @size='lg'
        @value={{this.largeValue}}
        @onInput={{this.updateLargeValue}}
        placeholder='Large size textarea'
      />
    </div>
  </template>
}
```

### Disabled State

Textarea fields can be disabled to prevent user interaction while maintaining their visual presence and current value.

```gts preview
import Component from '@glimmer/component';
import { Textarea } from '@frontile/forms';

export default class DisabledTextarea extends Component {
  <template>
    <div class='flex flex-col gap-4'>
      <Textarea
        @label='Disabled Basic Textarea'
        @value='This text cannot be edited or modified. The textarea is in a disabled state.'
        disabled={{true}}
        rows='3'
      />

      <Textarea
        @label='Disabled Textarea with Description'
        @description='This textarea is disabled and shows how the component appears when not interactive'
        @value='Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.'
        disabled={{true}}
        rows='4'
      />
    </div>
  </template>
}
```

### Rows and Resize Behavior

Control the initial height and resize behavior using standard HTML attributes.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Textarea } from '@frontile/forms';

export default class TextareaRowsExample extends Component {
  @tracked fixedMessage = '';
  @tracked verticalMessage = '';
  @tracked tallMessage = '';

  updateFixedMessage = (value: string) => {
    this.fixedMessage = value;
  };

  updateVerticalMessage = (value: string) => {
    this.verticalMessage = value;
  };

  updateTallMessage = (value: string) => {
    this.tallMessage = value;
  };

  <template>
    <div class='flex flex-col gap-4'>
      <Textarea
        @label='Fixed Height (No Resize)'
        @value={{this.fixedMessage}}
        @onInput={{this.updateFixedMessage}}
        rows='3'
        style='resize: none;'
        placeholder='This textarea cannot be resized'
      />

      <Textarea
        @label='Vertical Resize Only'
        @value={{this.verticalMessage}}
        @onInput={{this.updateVerticalMessage}}
        rows='4'
        style='resize: vertical;'
        placeholder='This textarea can only be resized vertically'
      />

      <Textarea
        @label='Tall Textarea'
        @value={{this.tallMessage}}
        @onInput={{this.updateTallMessage}}
        rows='8'
        placeholder='This is a taller textarea with 8 rows by default'
      />
    </div>
  </template>
}
```

### OnInput vs OnChange

The Textarea component supports both `@onInput` and `@onChange` callbacks with different triggering behaviors.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Textarea } from '@frontile/forms';

export default class TextareaEvents extends Component {
  @tracked text = '';
  @tracked inputEvents = 0;
  @tracked changeEvents = 0;

  handleInput = (value: string) => {
    this.text = value;
    this.inputEvents += 1;
  };

  handleChange = () => {
    this.changeEvents += 1;
  };

  <template>
    <div class='flex flex-col gap-4'>
      <Textarea
        @label='Event Demonstration'
        @value={{this.text}}
        @onInput={{this.handleInput}}
        @onChange={{this.handleChange}}
        placeholder='Type something and then click outside to see the difference between onInput and onChange'
      />

      <div class='p-4 bg-gray-50 rounded'>
        <div class='grid grid-cols-2 gap-4 text-sm'>
          <div>
            <strong>onInput events:</strong>
            {{this.inputEvents}}
            <p class='text-gray-600'>Fires on every keystroke</p>
          </div>
          <div>
            <strong>onChange events:</strong>
            {{this.changeEvents}}
            <p class='text-gray-600'>Fires when focus is lost</p>
          </div>
        </div>
      </div>
    </div>
  </template>
}
```

### Form Validation

The Textarea component integrates with form validation by displaying error messages and updating ARIA attributes accordingly.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Textarea } from '@frontile/forms';
import { Button } from '@frontile/buttons';

export default class ValidatedTextarea extends Component {
  @tracked feedback = '';
  @tracked feedbackErrors: string[] = [];

  updateFeedback = (value: string) => {
    this.feedback = value;
    // Clear errors when user starts typing
    this.feedbackErrors = [];
  };

  validateFeedback = () => {
    const feedback = this.feedback;
    const errors = [];

    if (!feedback.trim()) {
      errors.push('Feedback is required');
    } else if (feedback.trim().length < 10) {
      errors.push('Feedback must be at least 10 characters long');
    } else if (feedback.trim().length > 500) {
      errors.push('Feedback must be less than 500 characters');
    }

    this.feedbackErrors = errors;
  };

  <template>
    <div class='flex flex-col gap-4'>
      <Textarea
        @label='Your Feedback'
        @value={{this.feedback}}
        @onInput={{this.updateFeedback}}
        @errors={{this.feedbackErrors}}
        @isRequired={{true}}
        rows='5'
        placeholder='Please share your thoughts...'
      />

      <div class='flex justify-between items-center text-sm text-gray-600'>
        <span>{{this.feedback.length}}/500 characters</span>
        <Button @onPress={{this.validateFeedback}}>
          Validate
        </Button>
      </div>
    </div>
  </template>
}
```

### With Description

Add helpful description text that appears below the textarea.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Textarea } from '@frontile/forms';

export default class TextareaWithDescription extends Component {
  @tracked bio = '';

  updateBio = (value: string) => {
    this.bio = value;
  };

  <template>
    <Textarea
      @label='Biography'
      @description='Tell us about yourself. This will be visible on your public profile.'
      @value={{this.bio}}
      @onInput={{this.updateBio}}
      rows='6'
      placeholder='Write a brief description about yourself...'
    />
  </template>
}
```

### Complete Form Example

Here's a comprehensive example showing a Textarea in a form context with other inputs:

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Textarea } from '@frontile/forms';
import { Input } from '@frontile/forms';
import { on } from '@ember/modifier';
import { Button } from '@frontile/buttons';

export default class CompleteFormWithTextarea extends Component {
  @tracked subject = '';
  @tracked message = '';
  @tracked email = '';

  @tracked subjectErrors: string[] = [];
  @tracked messageErrors: string[] = [];
  @tracked emailErrors: string[] = [];

  updateSubject = (value: string) => {
    this.subject = value;
    this.subjectErrors = [];
  };

  updateMessage = (value: string) => {
    this.message = value;
    this.messageErrors = [];
  };

  updateEmail = (value: string) => {
    this.email = value;
    this.emailErrors = [];
  };

  handleSubmit = (event: Event) => {
    event.preventDefault();

    // Reset errors
    this.subjectErrors = [];
    this.messageErrors = [];
    this.emailErrors = [];

    // Validate form
    let hasErrors = false;

    if (!this.subject.trim()) {
      this.subjectErrors = ['Subject is required'];
      hasErrors = true;
    }

    if (!this.message.trim()) {
      this.messageErrors = ['Message is required'];
      hasErrors = true;
    } else if (this.message.trim().length < 20) {
      this.messageErrors = ['Message must be at least 20 characters long'];
      hasErrors = true;
    }

    if (!this.email.trim()) {
      this.emailErrors = ['Email is required'];
      hasErrors = true;
    } else if (!this.email.includes('@')) {
      this.emailErrors = ['Please enter a valid email address'];
      hasErrors = true;
    }

    if (!hasErrors) {
      console.log('Form submitted successfully!', {
        subject: this.subject,
        message: this.message,
        email: this.email
      });
    }
  };

  <template>
    <form {{on 'submit' this.handleSubmit}}>
      <div class='flex flex-col gap-4'>

        <Input
          @label='Email Address'
          @type='email'
          @value={{this.email}}
          @onInput={{this.updateEmail}}
          @isRequired={{true}}
          @errors={{this.emailErrors}}
        />

        <Input
          @label='Subject'
          @value={{this.subject}}
          @onInput={{this.updateSubject}}
          @isRequired={{true}}
          @errors={{this.subjectErrors}}
          placeholder='Brief description of your inquiry'
        />

        <Textarea
          @label='Message'
          @value={{this.message}}
          @onInput={{this.updateMessage}}
          @isRequired={{true}}
          @errors={{this.messageErrors}}
          @description='Please provide detailed information about your inquiry'
          rows='6'
          placeholder='Describe your question or concern in detail...'
        />

        <div class='flex justify-between items-center text-sm text-gray-600'>
          <span>{{this.message.length}} characters</span>
        </div>

        <div>
          <Button @class='mt-4'>
            Send Message
          </Button>
        </div>

      </div>
    </form>
  </template>
}
```

### Custom Styling

You can customize the appearance of different parts of the textarea using the `@classes` argument.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Textarea } from '@frontile/forms';
import { hash } from '@ember/helper';

export default class CustomStyledTextarea extends Component {
  @tracked customValue = '';

  updateCustomValue = (value: string) => {
    this.customValue = value;
  };

  <template>
    <Textarea
      @label='Custom Styled Textarea'
      @value={{this.customValue}}
      @onInput={{this.updateCustomValue}}
      @classes={{hash
        base='my-custom-form-control'
        input='my-custom-textarea-field'
      }}
      rows='4'
      placeholder='This textarea has custom styling'
    />
  </template>
}
```

## Accessibility

The Textarea component follows accessibility best practices:

- Proper label association using `for` and `id` attributes
- ARIA attributes for invalid states (`aria-invalid`)
- Descriptive text association using `aria-describedby`
- Support for required field indication
- Keyboard navigation support follows standard textarea behavior
- Screen reader announcements for validation messages and descriptions
- Maintains proper focus management

## API

<Signature @package="forms" @component="Textarea" />
