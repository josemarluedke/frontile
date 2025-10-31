---
label: New
imports:
  - import Signature from 'site/components/signature';
---

# Radio Group

A radio group component that allows users to select a single option from a group of choices. RadioGroup integrates seamlessly with the Form and Field components for automatic data binding and validation. Unlike CheckboxGroup, RadioGroup supports field-level validation (validates on change/blur/input events), providing immediate feedback to users.

## Import

```js
import { RadioGroup } from 'frontile';
```

## Usage

### Basic Radio Group

The most basic usage of the RadioGroup component with a label and options.

```gts preview
import { RadioGroup } from 'frontile';

<template>
  <RadioGroup @name='interests' @label='Interests' as |Radio|>
    <Radio @label='Music' @value='music' />
    <Radio @label='Sports' @value='sports' />
    <Radio @label='Technology' @value='technology' />
  </RadioGroup>
</template>
```

> **Modern Usage:** For most use cases, prefer using RadioGroup with the Form and Field components. This provides automatic data binding, validation, and state management without manual `@onChange` handlers.

> **Field-Level Validation:** RadioGroup supports field-level validation that runs on change/blur/input events based on the Form's `@validateOn` setting. This provides immediate feedback as users make selections. This differs from CheckboxGroup, which only validates on form submit.

### Controlled with Form/Field

The recommended pattern for using RadioGroup is with Form and Field components, which provides automatic data binding and state management.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Form, type FormResultData } from 'frontile';

export default class ControlledRadioGroup extends Component {
  @tracked formData = { theme: '' };

  handleFormChange = (result: FormResultData) => {
    this.formData = result.data;
  };

  <template>
    <div class='flex flex-col gap-4'>
      <Form @data={{this.formData}} @onChange={{this.handleFormChange}} as |form|>
        <form.Field @name='theme' as |field|>
          <field.RadioGroup @label='Theme Preference' as |Radio|>
            <Radio @label='Light Mode' @value='light' />
            <Radio @label='Dark Mode' @value='dark' />
            <Radio @label='System Default' @value='system' />
          </field.RadioGroup>
        </form.Field>
      </Form>

      <div class='p-3 border border-default-300 rounded'>
        <p class='text-sm'>Selected theme: <strong>{{this.formData.theme}}</strong></p>
      </div>
    </div>
  </template>
}
```


### Form Validation

RadioGroup integrates seamlessly with Form validation through Valibot schemas.  RadioGroup supports field-level validation that runs on change events based on the `@validateOn` setting, providing feedback as users make selections.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { array } from '@ember/helper';
import { Form, type FormResultData } from 'frontile';
import { Button } from 'frontile';
import * as v from 'valibot';

const schema = v.object({
  fullName: v.pipe(
    v.string(),
    v.nonEmpty('Full name is required'),
    v.minLength(2, 'Name must be at least 2 characters')
  ),
  experience: v.pipe(
    v.fallback(v.string(), ''),
    v.string(),
    v.nonEmpty('Please select your experience level')
  ),
  newsletter: v.boolean()
});

type Schema = v.InferOutput<typeof schema>;

export default class FormValidation extends Component {
  @tracked formData: Schema = {
    fullName: '',
    experience: '',
    newsletter: false
  };

  handleFormChange = (result: FormResultData<Schema>) => {
    this.formData = result.data;
  };

  handleSubmit = (result: FormResultData<Schema>) => {
    console.log('Form submitted successfully:', result.data);
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
      <form.Field @name='fullName' as |field|>
        <field.Input @label='Full Name' @isRequired={{true}} />
      </form.Field>

      <form.Field @name='experience' as |field|>
        <field.RadioGroup
          @label='Experience Level'
          @isRequired={{true}}
          as |Radio|
        >
          <Radio
            @label='Junior'
            @value='junior'
            @description='0-2 years of experience'
          />
          <Radio
            @label='Mid-level'
            @value='mid'
            @description='3-5 years of experience'
          />
          <Radio
            @label='Senior'
            @value='senior'
            @description='5+ years of experience'
          />
        </field.RadioGroup>
      </form.Field>

      <form.Field @name='newsletter' as |field|>
        <field.Checkbox @label='Subscribe to our newsletter' />
      </form.Field>

      <Button type='submit'>Submit Application</Button>
    </Form>
  </template>
}
```

### Additional Features and Styling

The RadioGroup component supports various optional configurations for layout, sizing, descriptions, and custom styling.

```gts preview
import { RadioGroup } from 'frontile';
import { hash } from '@ember/helper';

<template>
  <div class='flex flex-col gap-6'>
    {{! Orientation }}
    <div>
      <h4 class='text-sm font-medium mb-2'>Orientation</h4>
      <p class='text-sm text-default-600 mb-3'>
        RadioGroup supports vertical (default) and horizontal orientations. This is a RadioGroup-specific feature.
      </p>
      <div class='flex flex-col gap-3'>
        <RadioGroup
          @name='orientation-vertical'
          @label='Vertical Layout (Default)'
          @orientation='vertical'
          as |Radio|
        >
          <Radio @label='Option 1' @value='option1' />
          <Radio @label='Option 2' @value='option2' />
          <Radio @label='Option 3' @value='option3' />
        </RadioGroup>

        <RadioGroup
          @name='orientation-horizontal'
          @label='Horizontal Layout'
          @orientation='horizontal'
          as |Radio|
        >
          <Radio @label='Small' @value='sm' />
          <Radio @label='Medium' @value='md' />
          <Radio @label='Large' @value='lg' />
          <Radio @label='Extra Large' @value='xl' />
        </RadioGroup>
      </div>
    </div>

    {{! Size variants }}
    <div>
      <h4 class='text-sm font-medium mb-2'>Size Variants</h4>
      <div class='flex flex-col gap-3'>
        <RadioGroup @name='size-small' @label='Small Size' @size='sm' as |Radio|>
          <Radio @label='Option A' @value='a' />
          <Radio @label='Option B' @value='b' />
        </RadioGroup>

        <RadioGroup @name='size-medium' @label='Medium Size' @size='md' as |Radio|>
          <Radio @label='Option A' @value='a' />
          <Radio @label='Option B' @value='b' />
        </RadioGroup>

        <RadioGroup @name='size-large' @label='Large Size' @size='lg' as |Radio|>
          <Radio @label='Option A' @value='a' />
          <Radio @label='Option B' @value='b' />
        </RadioGroup>
      </div>
    </div>

    {{! Descriptions }}
    <div>
      <h4 class='text-sm font-medium mb-2'>Descriptions</h4>
      <p class='text-sm text-default-600 mb-3'>
        RadioGroup supports descriptions at both the group and individual radio level.
      </p>
      <div class='flex flex-col gap-3'>
        <RadioGroup
          @name='theme-preference'
          @label='Theme Preference'
          @description="Choose how you'd like the interface to appear. You can change this later in settings."
          as |Radio|
        >
          <Radio @label='Light' @value='light' />
          <Radio @label='Dark' @value='dark' />
          <Radio @label='System' @value='system' />
        </RadioGroup>

        <RadioGroup @name='subscription-plan' @label='Choose your subscription plan' as |Radio|>
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
    </div>

    {{! Custom styling }}
    <div>
      <h4 class='text-sm font-medium mb-2'>Custom Styling</h4>
      <RadioGroup
        @name='custom-styled'
        @label='Custom Styled Radio Group'
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
    </div>
  </div>
</template>
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
