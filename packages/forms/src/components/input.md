---
label: New
imports:
  - import Signature from 'site/components/signature';
---

# Input

A versatile input component that provides a clean interface for text input with support for labels, validation, start/end content, and a clearable option.

## Import

```js
import { Input } from 'frontile';
```

## Usage

### Basic Input

The most basic usage of the Input component with only a label.

```gts preview
import { Input } from 'frontile';
<template><Input @label='Full Name' /></template>
```

### Controlled Input

You can control the input value using the Form component's data binding pattern. The Form automatically manages the input's value and updates.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Form, type FormResultData } from 'frontile';

export default class ControlledInput extends Component {
  @tracked formData = { name: '' };

  handleFormChange = (result: FormResultData) => {
    this.formData = result.data;
  };

  <template>
    <div class='flex flex-col gap-4'>
      <Form @data={{this.formData}} @onChange={{this.handleFormChange}} as |form|>
        <form.Field @name='name' as |field|>
          <field.Input @label='Your Name' />
        </form.Field>
      </Form>
      <p>Current value: {{this.formData.name}}</p>
    </div>
  </template>
}
```

### Input Types

The Input component supports different HTML input types through the `@type` argument.

```gts preview
import Component from '@glimmer/component';
import { Input } from 'frontile';

export default class InputTypes extends Component {
  <template>
    <div class='flex flex-col gap-4'>
      <Input @label='Email' @type='email' />
      <Input @label='Password' @type='password' />
      <Input @label='Phone Number' @type='tel' />
      <Input @label='Age' @type='number' />
      <Input @label='Website' @type='url' />
    </div>
  </template>
}
```


### Start and End Content

You can add custom content at the beginning or end of the input using named blocks.

```gts preview
import Component from '@glimmer/component';
import { Input } from 'frontile';
import { SearchIcon } from 'site/components/icons';

export default class InputWithContent extends Component {
  <template>
    <div class='flex flex-col gap-4'>
      <Input @label='Price'>
        <:startContent>
          <span class='text-neutral-soft'>$</span>
        </:startContent>
        <:endContent>
          <span class='text-neutral-soft'>USD</span>
        </:endContent>
      </Input>

      <Input @label='Search'>
        <:startContent>
          <SearchIcon />
        </:startContent>
        <:endContent>
          <button type='button'>Go</button>
        </:endContent>
      </Input>
    </div>
  </template>
}
```

### Pointer Events Control

When using interactive content in start or end slots, you can control pointer events to ensure proper click handling.

```gts preview
import Component from '@glimmer/component';
import { Input } from 'frontile';
import { on } from '@ember/modifier';
import { SearchIcon } from 'site/components/icons';

export default class SearchInput extends Component {
  handleSearch = () => {
    console.log('Search clicked');
  };

  <template>
    <Input
      @label='Search with Button'
      @startContentPointerEvents='none'
      @endContentPointerEvents='auto'
    >
      <:startContent>
        <SearchIcon />
      </:startContent>
      <:endContent>
        <button type='button' {{on 'click' this.handleSearch}}>
          Search
        </button>
      </:endContent>
    </Input>
  </template>
}
```

### Clearable Input

Enable a clear button that appears when the input has a value by setting `@isClearable` to `true`.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Form, type FormResultData } from 'frontile';

export default class ClearableInput extends Component {
  @tracked formData = { searchQuery: '' };

  handleFormChange = (result: FormResultData) => {
    this.formData = result.data;
  };

  <template>
    <Form @data={{this.formData}} @onChange={{this.handleFormChange}} as |form|>
      <form.Field @name='searchQuery' as |field|>
        <field.Input
          @label='Search Query'
          @isClearable={{true}}
          placeholder='Type to search...'
        />
      </form.Field>
    </Form>
  </template>
}
```

### Form Validation

The Input component integrates with form validation by displaying error messages and updating ARIA attributes accordingly. This example demonstrates validation using Valibot schema with the Form/Field components.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Form, type FormResultData, type FormErrors } from 'frontile';
import { Button } from 'frontile';
import * as v from 'valibot';

// Define validation schema
const schema = v.object({
  name: v.pipe(
    v.string(),
    v.nonEmpty('Name is required'),
    v.minLength(2, 'Name must be at least 2 characters')
  ),
  email: v.pipe(
    v.string(),
    v.nonEmpty('Email is required'),
    v.email('Please enter a valid email address')
  )
});

type Schema = v.InferOutput<typeof schema>;

export default class ValidatedInput extends Component {
  @tracked formData: Schema = {
    name: '',
    email: ''
  };

  handleFormChange = (result: FormResultData<Schema>) => {
    this.formData = result.data;
  };

  handleFormSubmit = (result: FormResultData<Schema>) => {
    console.log('Form submitted:', result.data);
  };

  handleFormError = (errors: FormErrors) => {
    console.log('Validation errors:', errors);
  };

  <template>
    <Form
      @data={{this.formData}}
      @schema={{schema}}
      @onChange={{this.handleFormChange}}
      @onSubmit={{this.handleFormSubmit}}
      @onError={{this.handleFormError}}
      as |form|
    >
      <form.Field @name='name' as |field|>
        <field.Input @label='Name' @isRequired={{true}} />
      </form.Field>

      <form.Field @name='email' as |field|>
        <field.Input
          @label='Email Address'
          @type='email'
          @isRequired={{true}}
        />
      </form.Field>

      <Button type='submit'>Submit</Button>
    </Form>
  </template>
}
```

### Miscellaneous Options

The Input component supports various optional configurations for sizing, states, and styling.

```gts preview
import { Input } from 'frontile';
import { hash } from '@ember/helper';

<template>
  <div class='flex flex-col gap-6'>
    {{! Size variants }}
    <div>
      <h4 class='text-sm font-medium mb-2'>Size Variants</h4>
      <div class='flex flex-col gap-3'>
        <Input @label='Small Input' @size='sm' />
        <Input @label='Medium Input' @size='md' />
        <Input @label='Large Input' @size='lg' />
      </div>
    </div>

    {{! Disabled state }}
    <div>
      <h4 class='text-sm font-medium mb-2'>Disabled State</h4>
      <div class='flex flex-col gap-3'>
        <Input
          @label='Disabled Input'
          @value='Cannot edit this text'
          disabled={{true}}
        />
        <Input
          @label='Disabled with Description'
          @description='This input is disabled'
          @value='Sample value'
          disabled={{true}}
        />
      </div>
    </div>

    {{! With description }}
    <div>
      <h4 class='text-sm font-medium mb-2'>With Description</h4>
      <Input
        @label='Username'
        @description='Choose a unique username'
      />
    </div>

    {{! Custom styling }}
    <div>
      <h4 class='text-sm font-medium mb-2'>Custom Styling</h4>
      <Input
        @label='Custom Classes'
        @classes={{hash
          base='my-custom-form-control'
          input='my-custom-input-field'
        }}
      />
    </div>
  </div>
</template>
```

## Accessibility

The Input component follows accessibility best practices:

- Proper label association using `for` and `id` attributes
- ARIA attributes for invalid states (`aria-invalid`)
- Descriptive text association using `aria-describedby`
- Support for required field indication
- Keyboard navigation support for all interactive elements

## API

<Signature @package="forms" @component="Input" />
