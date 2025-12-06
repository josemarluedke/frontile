---
label: New
imports:
  - import Signature from 'site/components/signature';
---

# Checkbox Group

A flexible checkbox group component that allows users to select multiple options from a set of choices. It provides a clean interface with support for labels, validation, different orientations, and comprehensive accessibility features.

## Import

```js
import { CheckboxGroup } from 'frontile';
```

## Usage

### Basic Checkbox Group

The most basic usage of the CheckboxGroup component with a label and options.

```gts preview
import { CheckboxGroup } from 'frontile';

<template>
  <CheckboxGroup @label='Interests' as |Checkbox|>
    <Checkbox @label='Music' />
    <Checkbox @label='Sports' />
    <Checkbox @label='Technology' />
  </CheckboxGroup>
</template>
```

### Controlled Checkbox Group

You can control individual checkbox states by providing `@checked` and handling updates with `@onChange`. This example uses an array-based data structure with a single reusable handler.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { fn } from '@ember/helper';
import { CheckboxGroup } from 'frontile';

export default class ControlledCheckboxGroup extends Component {
  @tracked formData = {
    interests: [] as string[]
  };

  // Helper to check if a value is selected
  isChecked = (value: string) => {
    return this.formData.interests?.includes(value) ?? false;
  }

  isChecked(value: string) {
    return this.formData.interests?.includes(value) ?? false;
  }

  // Single reusable handler for checkbox changes
  @action
  handleCheckboxChange(value: string, checked: boolean) {
    const current = this.formData.interests || [];

    if (checked) {
      this.formData = { ...this.formData, interests: [...current, value] };
    } else {
      this.formData = { ...this.formData, interests: current.filter((v) => v !== value) };
    }
  }

  get selectedCount() {
    return this.formData.interests?.length ?? 0;
  }

  get selectedItems() {
    return this.formData.interests?.join(', ') ?? '';
  }

  <template>
    <div class='flex flex-col gap-4'>
      <CheckboxGroup @label='What are your interests?' as |Checkbox|>
        <Checkbox
          value='music'
          @label='Music'
          @checked={{this.isChecked 'music'}}
          @onChange={{fn this.handleCheckboxChange 'music'}}
        />
        <Checkbox
          value='sports'
          @label='Sports'
          @checked={{this.isChecked 'sports'}}
          @onChange={{fn this.handleCheckboxChange 'sports'}}
        />
        <Checkbox
          value='technology'
          @label='Technology'
          @checked={{this.isChecked 'technology'}}
          @onChange={{fn this.handleCheckboxChange 'technology'}}
        />
        <Checkbox
          value='art'
          @label='Art'
          @checked={{this.isChecked 'art'}}
          @onChange={{fn this.handleCheckboxChange 'art'}}
        />
      </CheckboxGroup>

      <div class='p-3 border border-neutral-soft rounded'>
        <p class='text-sm'>
          Selected ({{this.selectedCount}}):
          {{this.selectedItems}}
        </p>
      </div>

      <div class='p-4 bg-neutral-subtle rounded'>
        <h4 class='font-medium mb-2'>Current Selection:</h4>
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

### Form Validation

The CheckboxGroup component integrates with form validation by displaying error messages and updating ARIA attributes accordingly.

**Note:** CheckboxGroup currently supports validation on form submit, but does not support automatic field-level validation (change/blur/input events) when used with `form.Field`. This differs from `RadioGroup`, which does support field-level validation. For CheckboxGroup, validation errors will only appear after the form is submitted.

This example demonstrates the recommended pattern for using CheckboxGroup with the Form component's validation system. It uses an array-based data structure with a single reusable handler for managing checkbox state.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { fn } from '@ember/helper';
import { Form, CheckboxGroup, type FormResultData } from 'frontile';
import { Button } from 'frontile';
import * as v from 'valibot';

// Define validation schema with array of strings
const schema = v.object({
  notificationMethods: v.pipe(
    v.array(v.string()),
    v.minLength(1, 'Please select at least one notification method')
  )
});

type Schema = v.InferOutput<typeof schema>;

export default class ValidatedCheckboxGroup extends Component {
  @tracked formData: Schema = {
    notificationMethods: []
  };
  @tracked submitMessage = '';

  // Helper to check if a value is selected
  isChecked = (value: string) => {
    return this.formData.notificationMethods?.includes(value) ?? false;
  };

  // Single reusable handler for checkbox changes
  @action
  handleCheckboxChange(value: string, checked: boolean) {
    const current = this.formData.notificationMethods || [];

    if (checked) {
      this.formData.notificationMethods = [...current, value];
    } else {
      this.formData.notificationMethods = current.filter((v) => v !== value);
    }
  }

  @action
  handleFormChange(data: FormResultData<Schema>) {
    this.formData = data.data;
  }

  @action
  handleFormSubmit(data: FormResultData<Schema>) {
    this.submitMessage = 'Preferences saved successfully!';
    console.log('Submitted data:', data.data);
  }

  <template>
    <div class='flex flex-col gap-4'>
      <Form
        @data={{this.formData}}
        @schema={{schema}}
        @onChange={{this.handleFormChange}}
        @onSubmit={{this.handleFormSubmit}}
        as |form|
      >
        <form.Field @name='notificationMethods' as |field|>
          <field.CheckboxGroup
            @label='Notification Preferences'
            @description='Choose how you would like to receive notifications'
            @isRequired={{true}}
            as |Checkbox|
          >
            <Checkbox
              value='email'
              @label='Email notifications'
              @checked={{this.isChecked 'email'}}
              @onChange={{fn this.handleCheckboxChange 'email'}}
            />
            <Checkbox
              value='sms'
              @label='SMS notifications'
              @checked={{this.isChecked 'sms'}}
              @onChange={{fn this.handleCheckboxChange 'sms'}}
            />
            <Checkbox
              value='push'
              @label='Push notifications'
              @checked={{this.isChecked 'push'}}
              @onChange={{fn this.handleCheckboxChange 'push'}}
            />
          </field.CheckboxGroup>
        </form.Field>

        <div>
          <Button type='submit'>
            Save Preferences
          </Button>
        </div>
      </Form>

      {{#if this.submitMessage}}
        <div class='p-3 bg-success-50 text-success-strong rounded'>
          {{this.submitMessage}}
        </div>
      {{/if}}

      <div class='p-4 bg-neutral-subtle rounded'>
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

### Complete Form Example

Here's a comprehensive example showing CheckboxGroup with the modern Form validation system, combining multiple CheckboxGroups with other input types. This example demonstrates array-based checkbox data and schema validation with both required and optional checkbox groups.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { fn } from '@ember/helper';
import { Form, CheckboxGroup, type FormResultData } from 'frontile';
import { Button } from 'frontile';
import * as v from 'valibot';

// Define validation schema
const schema = v.object({
  name: v.pipe(
    v.string(),
    v.nonEmpty('Name is required'),
    v.minLength(2, 'Name must be at least 2 characters')
  ),
  interests: v.pipe(
    v.array(v.string()),
    v.minLength(1, 'Please select at least one interest')
  ),
  newsletters: v.array(v.string()) // Optional - no minimum required
});

type Schema = v.InferOutput<typeof schema>;

export default class CompleteFormWithCheckbox extends Component {
  @tracked formData: Schema = {
    name: '',
    interests: [],
    newsletters: []
  };
  @tracked submitMessage = '';

  // Helper to check if a value is selected in a field
  isChecked = (field: 'interests' | 'newsletters', value: string) => {
    return this.formData[field]?.includes(value) ?? false;
  };

  // Single reusable handler for any checkbox group
  @action
  handleCheckboxChange(field: 'interests' | 'newsletters', value: string, checked: boolean) {
    const current = this.formData[field] || [];

    if (checked) {
      this.formData[field] = [...current, value];
    } else {
      this.formData[field] = current.filter((v) => v !== value);
    }
  }

  @action
  handleFormChange(data: FormResultData<Schema>) {
    this.formData = data.data;
  }

  @action
  handleFormSubmit(data: FormResultData<Schema>) {
    this.submitMessage = 'Registration submitted successfully!';
    console.log('Form submitted:', data.data);
  }

  <template>
    <div class='flex flex-col gap-4'>
      <Form
        @data={{this.formData}}
        @schema={{schema}}
        @onChange={{this.handleFormChange}}
        @onSubmit={{this.handleFormSubmit}}
        as |form|
      >
        <div class='flex flex-col gap-4'>
          <form.Field @name='name' as |field|>
            <field.Input
              @label='Full Name'
              @isRequired={{true}}
            />
          </form.Field>

          <form.Field @name='interests' as |field|>
            <field.CheckboxGroup
              @label='Areas of Interest'
              @description='Select topics you would like to hear about'
              @isRequired={{true}}
              @orientation='horizontal'
              as |Checkbox|
            >
              <Checkbox
                value='technology'
                @label='Technology'
                @checked={{this.isChecked 'interests' 'technology'}}
                @onChange={{fn this.handleCheckboxChange 'interests' 'technology'}}
              />
              <Checkbox
                value='sports'
                @label='Sports'
                @checked={{this.isChecked 'interests' 'sports'}}
                @onChange={{fn this.handleCheckboxChange 'interests' 'sports'}}
              />
              <Checkbox
                value='music'
                @label='Music'
                @checked={{this.isChecked 'interests' 'music'}}
                @onChange={{fn this.handleCheckboxChange 'interests' 'music'}}
              />
              <Checkbox
                value='travel'
                @label='Travel'
                @checked={{this.isChecked 'interests' 'travel'}}
                @onChange={{fn this.handleCheckboxChange 'interests' 'travel'}}
              />
            </field.CheckboxGroup>
          </form.Field>

          <form.Field @name='newsletters' as |field|>
            <field.CheckboxGroup
              @label='Newsletter Subscriptions'
              @description='Optional newsletters you can subscribe to'
              as |Checkbox|
            >
              <Checkbox
                value='weekly'
                @label='Weekly Newsletter'
                @description='Get the latest updates every week'
                @checked={{this.isChecked 'newsletters' 'weekly'}}
                @onChange={{fn this.handleCheckboxChange 'newsletters' 'weekly'}}
              />
              <Checkbox
                value='monthly'
                @label='Monthly Digest'
                @description='Monthly summary of important news and updates'
                @checked={{this.isChecked 'newsletters' 'monthly'}}
                @onChange={{fn this.handleCheckboxChange 'newsletters' 'monthly'}}
              />
            </field.CheckboxGroup>
          </form.Field>

          <div>
            <Button type='submit'>
              Submit Registration
            </Button>
          </div>
        </div>
      </Form>

      {{#if this.submitMessage}}
        <div class='p-3 bg-success-50 text-success-strong rounded'>
          {{this.submitMessage}}
        </div>
      {{/if}}

      <div class='p-4 bg-neutral-subtle rounded'>
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

### Miscellaneous Options

This example demonstrates various optional arguments and configurations available for CheckboxGroup:

- **Orientation**: Use `@orientation='horizontal'` to arrange checkboxes horizontally (default is vertical)
- **Size**: Control checkbox size with `@size='sm'`, `@size='md'`, or `@size='lg'`
- **Description**: Add helpful text to the group with `@description`, and to individual checkboxes with `@description` on each Checkbox
- **Custom Styling**: Customize appearance with `@classes` argument

```gts preview
import { CheckboxGroup } from 'frontile';
import { hash } from '@ember/helper';

<template>
  <div class='flex flex-col gap-6'>
    {{! Horizontal Orientation }}
    <CheckboxGroup
      @label='Horizontal Layout'
      @orientation='horizontal'
      as |Checkbox|
    >
      <Checkbox @label='Option A' @description='First option in horizontal layout' />
      <Checkbox @label='Option B' @description='Second option in horizontal layout' />
      <Checkbox @label='Option C' @description='Third option in horizontal layout' />
    </CheckboxGroup>

    {{! Different Sizes }}
    <div class='flex flex-col gap-4'>
      <CheckboxGroup @label='Small Size' @size='sm' as |Checkbox|>
        <Checkbox @label='Small Option A' @description='Compact checkbox size' />
        <Checkbox @label='Small Option B' @description='Another compact size' />
      </CheckboxGroup>

      <CheckboxGroup @label='Medium Size' @size='md' as |Checkbox|>
        <Checkbox @label='Medium Option A' @description='Standard checkbox size' />
        <Checkbox @label='Medium Option B' @description='Another standard size' />
      </CheckboxGroup>

      <CheckboxGroup @label='Large Size' @size='lg' as |Checkbox|>
        <Checkbox @label='Large Option A' @description='Spacious checkbox size' />
        <Checkbox @label='Large Option B' @description='Another spacious size' />
      </CheckboxGroup>
    </div>

    {{! With Group Description }}
    <CheckboxGroup
      @label='User Permissions'
      @description='Select the permissions this user should have. You can modify these later.'
      as |Checkbox|
    >
      <Checkbox @label='Read access' @description='View files and data' />
      <Checkbox @label='Write access' @description='Create and edit content' />
      <Checkbox @label='Delete access' @description='Remove files permanently' />
    </CheckboxGroup>

    {{! Custom Styling }}
    <CheckboxGroup
      @label='Custom Styled Group'
      @classes={{hash
        base='my-custom-checkbox-group'
        label='my-custom-label'
        optionsContainer='my-custom-options-container'
      }}
      as |Checkbox|
    >
      <Checkbox @label='Styled Option 1' @description='First custom styled option' />
      <Checkbox @label='Styled Option 2' @description='Second custom styled option' />
      <Checkbox @label='Styled Option 3' @description='Third custom styled option' />
    </CheckboxGroup>
  </div>
</template>
```

## Accessibility

The CheckboxGroup component follows accessibility best practices:

- Proper grouping with fieldset/legend semantics via FormControl
- Proper label association for each checkbox option
- ARIA attributes for invalid states (`aria-invalid`)
- Descriptive text association using `aria-describedby`
- Support for required field indication
- Keyboard navigation follows standard checkbox patterns (space to toggle)
- Screen reader announcements for group label, individual option labels, and validation messages

## API

<Signature @package="forms" @component="CheckboxGroup" />
