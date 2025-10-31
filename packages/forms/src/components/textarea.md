---
label: New
imports:
  - import Signature from 'site/components/signature';
---

# Textarea

A versatile textarea component that provides a clean interface for multi-line text input with support for labels, validation, different sizes, and comprehensive accessibility features.

## Import

```js
import { Textarea } from 'frontile';
```

## Usage

### Basic Textarea

The most basic usage of the Textarea component with only a label.

```gts preview
import { Textarea } from 'frontile';

<template><Textarea @label='Message' /></template>
```

### Controlled Textarea

You can control the textarea value using the Form component's data binding system.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Form, type FormResultData } from 'frontile';

export default class ControlledTextarea extends Component {
  @tracked formData = {
    message: ''
  };

  handleFormChange = (result: FormResultData) => {
    this.formData = result.data;
  };

  <template>
    <div class='flex flex-col gap-4'>
      <Form
        @data={{this.formData}}
        @onChange={{this.handleFormChange}}
        as |form|
      >
        <form.Field @name='message' as |field|>
          <field.Textarea
            @label='Your Message'
            placeholder='Enter your message here...'
          />
        </form.Field>
      </Form>

      <div class='p-3 border border-default-300 rounded'>
        <p class='text-sm text-default-600'>Character count:
          {{this.formData.message.length}}</p>
        <p class='text-sm'>Current message: {{this.formData.message}}</p>
      </div>
    </div>
  </template>
}
```

### Disabled State

Textarea fields can be disabled to prevent user interaction while maintaining their visual presence and current value.

```gts preview
import Component from '@glimmer/component';
import { Textarea } from 'frontile';

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

### Form-Level Change Handling

When using Form and Field components, all change events are handled centrally by the Form component via its `@onChange` callback. This demonstrates how Form automatically captures all field updates in real-time as the user types.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Form, type FormResultData } from 'frontile';

export default class TextareaWithFormChange extends Component {
  @tracked formData = { text: '' };
  @tracked changeEventCount = 0;

  handleFormChange = (data: FormResultData) => {
    this.formData = data.data;
    this.changeEventCount += 1;
  };

  <template>
    <div class='flex flex-col gap-4'>
      <Form
        @data={{this.formData}}
        @onChange={{this.handleFormChange}}
        as |form|
      >
        <form.Field @name='text' as |field|>
          <field.Textarea
            @label='Message'
            @description='Form-level @onChange fires on every keystroke, providing real-time data updates'
            rows='4'
            placeholder='Type something to see form-level change events...'
          />
        </form.Field>
      </Form>

      <div class='p-4 bg-default-50 rounded'>
        <div class='space-y-2 text-sm'>
          <div>
            <strong>Form @onChange events:</strong>
            <span class='ml-2'>{{this.changeEventCount}}</span>
            <p class='text-default-600 mt-1'>
              Fires on every keystroke, providing complete form data
            </p>
          </div>
          <div class='pt-2 border-t border-default-200'>
            <strong>Current value length:</strong>
            <span class='ml-2'>{{this.formData.text.length}} characters</span>
          </div>
          <div>
            <strong>Current value:</strong>
            <p class='mt-1 p-2 bg-white rounded border border-default-200 break-words'>
              {{if this.formData.text this.formData.text '(empty)'}}
            </p>
          </div>
        </div>
      </div>
    </div>
  </template>
}
```

### Form Validation

The Textarea component integrates with the Form validation system, providing automatic error display and field-level validation using Valibot schema.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { array } from '@ember/helper';
import { Form, type FormResultData, type FormErrors } from 'frontile';
import { Button } from 'frontile';
import * as v from 'valibot';

// Define validation schema
const schema = v.object({
  feedback: v.pipe(
    v.string(),
    v.nonEmpty('Feedback is required'),
    v.minLength(10, 'Feedback must be at least 10 characters long'),
    v.maxLength(500, 'Feedback must be less than 500 characters')
  )
});

type Schema = v.InferOutput<typeof schema>;

export default class ValidatedTextarea extends Component {
  @tracked formData: Schema = {
    feedback: ''
  };
  @tracked submitMessage = '';

  handleFormChange = (result: FormResultData<Schema>) => {
    this.formData = result.data;
  };

  handleFormSubmit = async (result: FormResultData<Schema>) => {
    this.submitMessage = 'Feedback submitted successfully!';
    console.log('Form submitted:', result.data);
  };

  handleFormError = (errors: FormErrors) => {
    console.log('Validation errors:', errors);
  };

  <template>
    <div class='flex flex-col gap-4'>
      <Form
        @data={{this.formData}}
        @schema={{schema}}
        @onChange={{this.handleFormChange}}
        @onSubmit={{this.handleFormSubmit}}
        @onError={{this.handleFormError}}
        @validateOn={{array 'change' 'submit'}}
        as |form|
      >
        <form.Field @name='feedback' as |field|>
          <field.Textarea
            @label='Your Feedback'
            @isRequired={{true}}
            rows='5'
            placeholder='Please share your thoughts...'
          />
        </form.Field>

        <div class='flex justify-between items-center text-sm text-gray-600'>
          <span>{{this.formData.feedback.length}}/500 characters</span>
          <Button type='submit' disabled={{form.isLoading}}>
            {{if form.isLoading 'Submitting...' 'Submit Feedback'}}
          </Button>
        </div>
      </Form>

      {{#if this.submitMessage}}
        <div class='p-3 bg-success-50 text-success-800 rounded'>
          {{this.submitMessage}}
        </div>
      {{/if}}
    </div>
  </template>
}
```

### Complete Form Example

Here's a comprehensive example showing a Textarea integrated with the Form validation system, combining Input and Textarea fields with Valibot schema validation.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { array } from '@ember/helper';
import { Form, type FormResultData, type FormErrors } from 'frontile';
import { Button } from 'frontile';
import * as v from 'valibot';

const schema = v.object({
  email: v.pipe(
    v.string(),
    v.nonEmpty('Email is required'),
    v.email('Please enter a valid email address')
  ),
  subject: v.pipe(
    v.string(),
    v.nonEmpty('Subject is required'),
    v.minLength(5, 'Subject must be at least 5 characters')
  ),
  message: v.pipe(
    v.string(),
    v.nonEmpty('Message is required'),
    v.minLength(20, 'Message must be at least 20 characters long'),
    v.maxLength(1000, 'Message must be less than 1000 characters')
  )
});

type Schema = v.InferOutput<typeof schema>;

export default class CompleteFormWithTextarea extends Component {
  @tracked formData: Schema = {
    email: '',
    subject: '',
    message: ''
  };

  handleFormChange = (result: FormResultData<Schema>) => {
    this.formData = result.data;
  };

  handleFormSubmit = (result: FormResultData<Schema>) => {
    console.log('Form submitted:', result.data);
  };

  <template>
    <Form
      @data={{this.formData}}
      @schema={{schema}}
      @onChange={{this.handleFormChange}}
      @onSubmit={{this.handleFormSubmit}}
      @validateOn={{array 'change' 'submit'}}
      as |form|
    >
      <form.Field @name='email' as |field|>
        <field.Input
          @label='Email Address'
          @type='email'
          @isRequired={{true}}
        />
      </form.Field>

      <form.Field @name='subject' as |field|>
        <field.Input
          @label='Subject'
          @isRequired={{true}}
        />
      </form.Field>

      <form.Field @name='message' as |field|>
        <field.Textarea
          @label='Message'
          @isRequired={{true}}
          rows='6'
        />
      </form.Field>

      <Button type='submit'>
        Send Message
      </Button>
    </Form>
  </template>
}
```

### Miscellaneous Options

The Textarea component supports various optional configurations for sizing, layout, and styling.

```gts preview
import { Textarea } from 'frontile';
import { hash } from '@ember/helper';

<template>
  <div class='flex flex-col gap-6'>
    {{! Size variants }}
    <div>
      <h4 class='text-sm font-medium mb-2'>Size Variants</h4>
      <div class='flex flex-col gap-3'>
        <Textarea @label='Small' @size='sm' rows='3' />
        <Textarea @label='Medium' @size='md' rows='3' />
        <Textarea @label='Large' @size='lg' rows='3' />
      </div>
    </div>

    {{! Rows and resize behavior }}
    <div>
      <h4 class='text-sm font-medium mb-2'>Rows and Resize Behavior</h4>
      <div class='flex flex-col gap-3'>
        <Textarea @label='Fixed (No Resize)' rows='3' style='resize: none;' />
        <Textarea @label='Vertical Resize' rows='4' style='resize: vertical;' />
        <Textarea @label='Tall (8 rows)' rows='8' />
      </div>
    </div>

    {{! With description }}
    <div>
      <h4 class='text-sm font-medium mb-2'>With Description</h4>
      <Textarea
        @label='Biography'
        @description='Tell us about yourself'
        rows='4'
      />
    </div>

    {{! Custom styling }}
    <div>
      <h4 class='text-sm font-medium mb-2'>Custom Styling</h4>
      <Textarea
        @label='Custom Classes'
        @classes={{hash
          base='my-custom-form-control'
          input='my-custom-textarea-field'
        }}
        rows='3'
      />
    </div>
  </div>
</template>
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
