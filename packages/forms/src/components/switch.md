---
label: New
imports:
  - import Signature from 'site/components/signature';
---

# Switch

A customizable toggle control that allows users to switch between two states (on/off, enabled/disabled). The Switch component integrates seamlessly with the Form and Field components for automatic data binding and validation, providing a consistent and accessible experience. It supports custom content blocks for icons and labels.

> **Modern Usage:** For most use cases, prefer using Switch with the Form and Field components. This provides automatic data binding, validation, and state management without manual `@onChange` handlers.

> **Field-Level Validation:** Switch supports field-level validation that runs on change/blur events based on the Form's `@validateOn` setting, providing immediate feedback as users toggle the switch.

## Import

```js
import { Switch } from 'frontile';
```

## Usage

### Basic Switch

The most basic usage of a Switch component with a label.

```gts preview
import { Switch } from 'frontile';

<template><Switch @label='Enable Notifications' /></template>
```

### Controlled with Form/Field

The recommended pattern for using Switch is with Form and Field components, which provides automatic data binding and state management without manual onChange handlers.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Form, type FormResultData } from 'frontile';

export default class ControlledSwitch extends Component {
  @tracked formData = { notifications: false };

  handleFormChange = (result: FormResultData) => {
    this.formData = result.data;
  };

  <template>
    <div class='flex flex-col gap-4'>
      <Form @data={{this.formData}} @onChange={{this.handleFormChange}} as |form|>
        <form.Field @name='notifications' as |field|>
          <field.Switch @label='Enable Email Notifications' />
        </form.Field>
      </Form>

      <div class='p-3 border border-default-300 rounded'>
        <p class='text-sm'>
          Notifications are
          <strong>{{if this.formData.notifications 'enabled' 'disabled'}}</strong>
        </p>
      </div>
    </div>
  </template>
}
```

### Form Validation

**Note:** Switch supports field-level validation that runs on change/blur/input events based on the Form's `@validateOn` setting, providing immediate feedback as users interact with the switch.

The Switch component integrates with the Form validation system, providing automatic error display and field-level validation. This example demonstrates using Valibot schema validation with the Form/Field components.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { Form, type FormResultData } from 'frontile';
import { Button } from 'frontile';
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
  notifications: v.boolean()
});

type Schema = v.InferOutput<typeof schema>;

export default class ValidatedSwitch extends Component {
  @tracked formData: Schema = {
    email: '',
    termsAccepted: false,
    notifications: true
  };
  @tracked submitMessage = '';

  @action
  handleFormChange(data: FormResultData<Schema>) {
    this.formData = data.data;
  }

  @action
  handleFormSubmit(data: FormResultData<Schema>) {
    this.submitMessage = 'Registration successful!';
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
            <field.Switch
              @label='I accept the terms and conditions'
              @description='You must accept our terms to continue'
              @isRequired={{true}}
            />
          </form.Field>

          <form.Field @name='notifications' as |field|>
            <field.Switch
              @label='Send me email notifications'
              @description='Optional: Receive updates about new features'
            />
          </form.Field>

          <Button type='submit'>
            Register
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

### With Icons

Customize the switch appearance by using content blocks:

- `startContent`: Renders before the switch thumb.
- `thumbContent`: Renders inside the switch thumb. It receives an object with `isSelected` to reflect the current state.
- `endContent`: Renders after the switch thumb.

```gts preview
import Component from '@glimmer/component';
import { Switch } from 'frontile';

export default class CustomContentSwitchExample extends Component {
  <template>
    <Switch @label='Dark Mode'>
      <:startContent>
        <Sun />
      </:startContent>
      <:endContent>
        <Moon />
      </:endContent>
    </Switch>
  </template>
}

const Moon = <template>
  <svg
    xmlns='http://www.w3.org/2000/svg'
    viewBox='0 0 24 24'
    fill='currentColor'
    class='size-4'
  >
    <path
      fill-rule='evenodd'
      d='M9.528 1.718a.75.75 0 0 1 .162.819A8.97 8.97 0 0 0 9 6a9 9 0 0 0 9 9 8.97 8.97 0 0 0 3.463-.69.75.75 0 0 1 .981.98 10.503 10.503 0 0 1-9.694 6.46c-5.799 0-10.5-4.7-10.5-10.5 0-4.368 2.667-8.112 6.46-9.694a.75.75 0 0 1 .818.162Z'
      clip-rule='evenodd'
    />
  </svg>
</template>;

const Sun = <template>
  <svg
    xmlns='http://www.w3.org/2000/svg'
    viewBox='0 0 24 24'
    fill='currentColor'
    class='size-4'
  >
    <path
      d='M12 2.25a.75.75 0 0 1 .75.75v2.25a.75.75 0 0 1-1.5 0V3a.75.75 0 0 1 .75-.75ZM7.5 12a4.5 4.5 0 1 1 9 0 4.5 4.5 0 0 1-9 0ZM18.894 6.166a.75.75 0 0 0-1.06-1.06l-1.591 1.59a.75.75 0 1 0 1.06 1.061l1.591-1.59ZM21.75 12a.75.75 0 0 1-.75.75h-2.25a.75.75 0 0 1 0-1.5H21a.75.75 0 0 1 .75.75ZM17.834 18.894a.75.75 0 0 0 1.06-1.06l-1.59-1.591a.75.75 0 1 0-1.061 1.06l1.59 1.591ZM12 18a.75.75 0 0 1 .75.75V21a.75.75 0 0 1-1.5 0v-2.25A.75.75 0 0 1 12 18ZM7.758 17.303a.75.75 0 0 0-1.061-1.06l-1.591 1.59a.75.75 0 0 0 1.06 1.061l1.591-1.59ZM6 12a.75.75 0 0 1-.75.75H3a.75.75 0 0 1 0-1.5h2.25A.75.75 0 0 1 6 12ZM6.697 7.757a.75.75 0 0 0 1.06-1.06l-1.59-1.591a.75.75 0 0 0-1.061 1.06l1.59 1.591Z'
    />
  </svg>
</template>;
```

```gts preview
import Component from '@glimmer/component';
import { Switch } from 'frontile';

export default class CustomContentSwitchExample extends Component {
  <template>
    <Switch @label='Dark Mode'>
      <:thumbContent as |o|>
        {{#if o.isSelected}}
          <Moon />
        {{else}}
          <Sun />
        {{/if}}
      </:thumbContent>
    </Switch>
  </template>
}
const Moon = <template>
  <svg
    xmlns='http://www.w3.org/2000/svg'
    viewBox='0 0 24 24'
    fill='currentColor'
    class='size-3'
  >
    <path
      fill-rule='evenodd'
      d='M9.528 1.718a.75.75 0 0 1 .162.819A8.97 8.97 0 0 0 9 6a9 9 0 0 0 9 9 8.97 8.97 0 0 0 3.463-.69.75.75 0 0 1 .981.98 10.503 10.503 0 0 1-9.694 6.46c-5.799 0-10.5-4.7-10.5-10.5 0-4.368 2.667-8.112 6.46-9.694a.75.75 0 0 1 .818.162Z'
      clip-rule='evenodd'
    />
  </svg>
</template>;

const Sun = <template>
  <svg
    xmlns='http://www.w3.org/2000/svg'
    viewBox='0 0 24 24'
    fill='currentColor'
    class='size-3'
  >
    <path
      d='M12 2.25a.75.75 0 0 1 .75.75v2.25a.75.75 0 0 1-1.5 0V3a.75.75 0 0 1 .75-.75ZM7.5 12a4.5 4.5 0 1 1 9 0 4.5 4.5 0 0 1-9 0ZM18.894 6.166a.75.75 0 0 0-1.06-1.06l-1.591 1.59a.75.75 0 1 0 1.06 1.061l1.591-1.59ZM21.75 12a.75.75 0 0 1-.75.75h-2.25a.75.75 0 0 1 0-1.5H21a.75.75 0 0 1 .75.75ZM17.834 18.894a.75.75 0 0 0 1.06-1.06l-1.59-1.591a.75.75 0 1 0-1.061 1.06l1.59 1.591ZM12 18a.75.75 0 0 1 .75.75V21a.75.75 0 0 1-1.5 0v-2.25A.75.75 0 0 1 12 18ZM7.758 17.303a.75.75 0 0 0-1.061-1.06l-1.591 1.59a.75.75 0 0 0 1.06 1.061l1.591-1.59ZM6 12a.75.75 0 0 1-.75.75H3a.75.75 0 0 1 0-1.5h2.25A.75.75 0 0 1 6 12ZM6.697 7.757a.75.75 0 0 0 1.06-1.06l-1.59-1.591a.75.75 0 0 0-1.061 1.06l1.59 1.591Z'
    />
  </svg>
</template>;
```

### Miscellaneous Options

The Switch component supports various optional configurations for sizing, visual styling, states, and custom classes.

```gts preview
import { Switch } from 'frontile';
import { hash } from '@ember/helper';

<template>
  <div class='flex flex-col gap-6'>
    {{! Size variants }}
    <div>
      <h4 class='text-sm font-medium mb-2'>Size Variants</h4>
      <div class='flex gap-4'>
        <Switch @size='sm' @label='Small' />
        <Switch @size='md' @label='Medium' />
        <Switch @size='lg' @label='Large' />
      </div>
    </div>

    {{! Intent variants }}
    <div>
      <h4 class='text-sm font-medium mb-2'>Intent Variants</h4>
      <div class='flex gap-4'>
        <Switch @intent='default' @label='Default' @defaultSelected={{true}} />
        <Switch @intent='primary' @label='Primary' @defaultSelected={{true}} />
        <Switch @intent='success' @label='Success' @defaultSelected={{true}} />
        <Switch @intent='warning' @label='Warning' @defaultSelected={{true}} />
        <Switch @intent='danger' @label='Danger' @defaultSelected={{true}} />
      </div>
    </div>

    {{! Disabled state }}
    <div>
      <h4 class='text-sm font-medium mb-2'>Disabled State</h4>
      <div class='flex flex-col gap-3'>
        <Switch
          @label='Disabled Switch (Off)'
          @defaultSelected={{false}}
          @isDisabled={{true}}
        />
        <Switch
          @label='Disabled Switch (On)'
          @defaultSelected={{true}}
          @isDisabled={{true}}
        />
        <Switch
          @label='Disabled with Description'
          @description='This switch is disabled and cannot be toggled'
          @defaultSelected={{true}}
          @isDisabled={{true}}
        />
      </div>
    </div>

    {{! Custom styling }}
    <div>
      <h4 class='text-sm font-medium mb-2'>Custom Styling</h4>
      <Switch
        @label='Custom Styled Switch'
        @description='This switch has custom styling applied'
        @classes={{hash
          base='my-custom-switch-base'
          wrapper='my-custom-switch-wrapper'
          thumb='my-custom-switch-thumb'
          label='my-custom-switch-label'
        }}
      />
    </div>
  </div>
</template>
```

## Accessibility

The Switch component follows accessibility best practices:

- Uses semantic checkbox input with `role="switch"` behavior
- Proper label association using `for` and `id` attributes
- ARIA attributes for invalid states (`aria-invalid`)
- Descriptive text association using `aria-describedby`
- Support for required field indication
- Keyboard navigation (Space to toggle, Tab to focus)
- Screen reader announcements for labels, descriptions, and validation messages
- Visual focus indicators
- Disabled state properly communicated to assistive technologies

## API

<Signature @package="forms" @component="Switch" />
