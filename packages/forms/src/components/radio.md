---
label: New
imports:
  - import Signature from 'site/components/signature';
---

# Radio

A radio button component that allows users to select a single option from a group of choices. Radio components integrate seamlessly with the Form and Field components for automatic data binding and validation. For grouped radio buttons, use RadioGroup which provides built-in grouping and state management.

## Import

```js
import { Radio } from 'frontile';
```

## Usage

### Basic Radio

The most basic usage of a Radio component with a label and value.

```gts preview
import { Radio } from 'frontile';

<template><Radio @name='terms' @label='Accept Terms' @value='accepted' /></template>
```

> **Modern Usage:** For most use cases, prefer using Radio components with the Form and Field components. This provides automatic data binding, validation, and state management without manual `@onChange` handlers. See the "Controlled with Form/Field" example below.

> **RadioGroup vs Individual Radio:** When you have multiple related radio options, use `field.RadioGroup` which automatically manages the grouping and state. Individual `field.Radio` components require manual `@value` specification on each radio button.

### Controlled with Form/Field

You can control the radio state using the Form component's data binding system. The Form automatically manages the radio value and updates.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Form, type FormResultData } from 'frontile';

export default class ControlledRadio extends Component {
  @tracked formData = { newsletter: '' };

  handleFormChange = (result: FormResultData) => {
    this.formData = result.data;
  };

  <template>
    <div class='flex flex-col gap-4'>
      <Form @data={{this.formData}} @onChange={{this.handleFormChange}} as |form|>
        <form.Field @name='newsletter' as |field|>
          <field.RadioGroup @label='Newsletter Preference' as |Radio|>
            <Radio @label='Daily Digest' @value='daily' />
            <Radio @label='Weekly Summary' @value='weekly' />
            <Radio @label='No Newsletter' @value='none' />
          </field.RadioGroup>
        </form.Field>
      </Form>

      <div class='p-3 border border-neutral-soft rounded'>
        <p class='text-sm'>Selected: {{this.formData.newsletter}}</p>
      </div>
    </div>
  </template>
}
```

### Form Validation

> **Field-Level Validation:** RadioGroup supports field-level validation that runs on change events based on the Form's `@validateOn` setting, providing immediate feedback.

RadioGroup integrates with Form validation through Valibot schemas. The Form component handles validation automatically and displays errors through the Field component. Here's a comprehensive example showing RadioGroup with other form fields:

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Form, type FormResultData } from 'frontile';
import { Button } from 'frontile';
import { array } from '@ember/helper';
import * as v from 'valibot';

const schema = v.object({
  fullName: v.pipe(
    v.string(),
    v.nonEmpty('Full name is required'),
    v.minLength(2, 'Name must be at least 2 characters')
  ),
  email: v.pipe(
    v.string(),
    v.nonEmpty('Email is required'),
    v.email('Please enter a valid email address')
  ),
  experience: v.pipe(
    v.fallback(v.string(), ''),
    v.string(),
    v.nonEmpty('Please select your experience level')
  ),
  remoteWork: v.boolean()
});

type Schema = v.InferOutput<typeof schema>;

export default class FormValidationExample extends Component {
  @tracked formData: Schema = {
    fullName: '',
    email: '',
    experience: '',
    remoteWork: false
  };

  handleFormChange = (result: FormResultData<Schema>) => {
    this.formData = result.data;
  };

  handleSubmit = (result: FormResultData<Schema>) => {
    console.log('Application submitted successfully:', result.data);
  };

  <template>
    <Form
      @data={{this.formData}}
      @schema={{schema}}
      @onChange={{this.handleFormChange}}
      @onSubmit={{this.handleSubmit}}
      @validateOn={{array 'change' 'submit'}}
      as |form|
    >
      <div class='flex flex-col gap-4'>
        <form.Field @name='fullName' as |field|>
          <field.Input @label='Full Name' @isRequired={{true}} />
        </form.Field>

        <form.Field @name='email' as |field|>
          <field.Input
            @label='Email Address'
            @type='email'
            @isRequired={{true}}
          />
        </form.Field>

        <form.Field @name='experience' as |field|>
          <field.RadioGroup @label='Experience Level' @isRequired={{true}} as |Radio|>
            <Radio @label='Junior (0-2 years)' @value='junior' />
            <Radio @label='Mid-level (3-5 years)' @value='mid' />
            <Radio @label='Senior (5+ years)' @value='senior' />
          </field.RadioGroup>
        </form.Field>

        <form.Field @name='remoteWork' as |field|>
          <field.Checkbox @label='Open to remote work' />
        </form.Field>

        <div>
          <Button type='submit'>Submit Application</Button>
        </div>
      </div>
    </Form>
  </template>
}
```

### Miscellaneous Options

The Radio component supports various optional configurations for sizing, states, descriptions, layout, and styling.

```gts preview
import { Radio, RadioGroup } from 'frontile';
import { hash } from '@ember/helper';

<template>
  <div class='flex flex-col gap-6'>
    {{! Size variants }}
    <div>
      <h4 class='text-sm font-medium mb-2'>Size Variants</h4>
      <div class='flex flex-col gap-3'>
        <RadioGroup @name='sizeSmall' @label='Small Size' @size='sm' as |Radio|>
          <Radio @label='Option A' @value='a' />
          <Radio @label='Option B' @value='b' />
        </RadioGroup>
        <RadioGroup @name='sizeMedium' @label='Medium Size' @size='md' as |Radio|>
          <Radio @label='Option A' @value='a' />
          <Radio @label='Option B' @value='b' />
        </RadioGroup>
        <RadioGroup @name='sizeLarge' @label='Large Size' @size='lg' as |Radio|>
          <Radio @label='Option A' @value='a' />
          <Radio @label='Option B' @value='b' />
        </RadioGroup>
      </div>
    </div>

    {{! Disabled state }}
    <div>
      <h4 class='text-sm font-medium mb-2'>Disabled State</h4>
      <RadioGroup @name='subscription' @label='Subscription Plan' @value='basic' disabled={{true}} as |Radio|>
        <Radio @label='Basic Plan - $9/month' @value='basic' />
        <Radio @label='Pro Plan - $19/month' @value='pro' />
        <Radio @label='Enterprise Plan - $49/month' @value='enterprise' />
      </RadioGroup>
    </div>

    {{! With description }}
    <div>
      <h4 class='text-sm font-medium mb-2'>With Description</h4>
      <RadioGroup @name='plan' @label='Choose your subscription plan' as |Radio|>
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
    </div>

    {{! Horizontal layout }}
    <div>
      <h4 class='text-sm font-medium mb-2'>Horizontal Layout</h4>
      <RadioGroup @name='rating' @label='Rating' @orientation='horizontal' as |Radio|>
        <Radio @label='Poor' @value='poor' />
        <Radio @label='Fair' @value='fair' />
        <Radio @label='Good' @value='good' />
        <Radio @label='Excellent' @value='excellent' />
      </RadioGroup>
    </div>

    {{! Custom styling }}
    <div>
      <h4 class='text-sm font-medium mb-2'>Custom Styling</h4>
      <Radio
        @name='custom-styled'
        @label='Custom Styled Radio'
        @value='custom'
        @classes={{hash
          base='my-custom-radio-base'
          input='my-custom-radio-input'
          labelContainer='my-custom-label-container'
          label='my-custom-radio-label'
        }}
      />
    </div>
  </div>
</template>
```

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
