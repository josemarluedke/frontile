---
label: New
imports:
  - import Signature from 'site/components/signature';
---

# Input

A versatile input component that provides a clean interface for text input with support for labels, validation, start/end content, and a clearable option.

## Import

```js
import { Input } from '@frontile/forms';
```

## Usage

### Basic Input

The most basic usage of the Input component with only a label.

```gts preview
import { Input } from '@frontile/forms';
<template><Input @label='Full Name' /></template>
```

### Controlled Input

You can control the input value by providing `@value` and handling updates with `@onInput` or `@onChange`.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Input } from '@frontile/forms';

export default class ControlledInput extends Component {
  @tracked name = '';

  updateName = (value: string) => {
    this.name = value;
  };

  <template>
    <div class='flex flex-col gap-4'>
      <Input
        @label='Your Name'
        @value={{this.name}}
        @onInput={{this.updateName}}
      />
      <p>Current value: {{this.name}}</p>
    </div>
  </template>
}
```

### Input Types

The Input component supports different HTML input types through the `@type` argument.

```gts preview
import Component from '@glimmer/component';
import { Input } from '@frontile/forms';

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

### Sizes

Control the size of the input using the `@size` argument.

```gts preview
import Component from '@glimmer/component';
import { Input } from '@frontile/forms';

export default class InputSizes extends Component {
  <template>
    <div class='flex flex-col gap-4'>
      <Input @label='Small Input' @size='sm' />
      <Input @label='Medium Input' @size='md' />
      <Input @label='Large Input' @size='lg' />
    </div>
  </template>
}
```

### Start and End Content

You can add custom content at the beginning or end of the input using named blocks.

```gts preview
import Component from '@glimmer/component';
import { Input } from '@frontile/forms';

export default class InputWithContent extends Component {
  <template>
    <div class='flex flex-col gap-4'>
      <Input @label='Price'>
        <:startContent>
          <span class='text-default-500'>$</span>
        </:startContent>
        <:endContent>
          <span class='text-default-500'>USD</span>
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
const SearchIcon = <template>
  <svg
    xmlns='http://www.w3.org/2000/svg'
    fill='none'
    viewBox='0 0 24 24'
    stroke-width='1.5'
    stroke='currentColor'
    class='size-5'
  >
    <path
      stroke-linecap='round'
      stroke-linejoin='round'
      d='m21 21-5.197-5.197m0 0A7.5 7.5 0 1 0 5.196 5.196a7.5 7.5 0 0 0 10.607 10.607Z'
    />
  </svg>
</template>;
```

### Pointer Events Control

When using interactive content in start or end slots, you can control pointer events to ensure proper click handling.

```gts preview
import Component from '@glimmer/component';
import { Input } from '@frontile/forms';
import { on } from '@ember/modifier';

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

const SearchIcon = <template>
  <svg
    xmlns='http://www.w3.org/2000/svg'
    fill='none'
    viewBox='0 0 24 24'
    stroke-width='1.5'
    stroke='currentColor'
    class='size-5'
  >
    <path
      stroke-linecap='round'
      stroke-linejoin='round'
      d='m21 21-5.197-5.197m0 0A7.5 7.5 0 1 0 5.196 5.196a7.5 7.5 0 0 0 10.607 10.607Z'
    />
  </svg>
</template>;
```

### Clearable Input

Enable a clear button that appears when the input has a value by setting `@isClearable` to `true`.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Input } from '@frontile/forms';

export default class ClearableInput extends Component {
  @tracked searchQuery = '';

  updateSearchQuery = (value: string) => {
    this.searchQuery = value;
  };

  <template>
    <Input
      @label='Search Query'
      @value={{this.searchQuery}}
      @onInput={{this.updateSearchQuery}}
      @isClearable={{true}}
      placeholder='Type to search...'
    />
  </template>
}
```

### Form Validation

The Input component integrates with form validation by displaying error messages and updating ARIA attributes accordingly.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Input } from '@frontile/forms';
import { on } from '@ember/modifier';
import { Button } from '@frontile/buttons';

export default class ValidatedInput extends Component {
  @tracked email = '';
  @tracked emailErrors: string[] = [];

  updateEmail = (value: string) => {
    this.email = value;
    // Clear errors when user starts typing
    this.emailErrors = [];
  };

  validateEmail = () => {
    const email = this.email;
    const errors = [];

    if (!email) {
      errors.push('Email is required');
    } else if (!email.includes('@')) {
      errors.push('Please enter a valid email address');
    }

    this.emailErrors = errors;
  };

  <template>
    <div class='flex flex-col gap-4'>
      <Input
        @label='Email Address'
        @type='email'
        @value={{this.email}}
        @onInput={{this.updateEmail}}
        @errors={{this.emailErrors}}
        @isRequired={{true}}
      />

      <Button {{on 'click' this.validateEmail}}>
        Validate
      </Button>
    </div>
  </template>
}
```

### With Description

Add helpful description text that appears below the input.

```gts preview
import Component from '@glimmer/component';
import { Input } from '@frontile/forms';

export default class InputWithDescription extends Component {
  <template>
    <Input
      @label='Username'
      @description='Choose a unique username that will be visible to other users'
      placeholder='Enter your username'
    />
  </template>
}
```

### Complete Form Example

Here's a more comprehensive example showing multiple inputs in a form context:

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Input } from '@frontile/forms';
import { on } from '@ember/modifier';
import { Button } from '@frontile/buttons';

export default class CompleteForm extends Component {
  @tracked fullName = '';
  @tracked email = '';
  @tracked phone = '';

  @tracked fullNameErrors: string[] = [];
  @tracked emailErrors: string[] = [];

  updateFullName = (value: string) => {
    this.fullName = value;
    this.fullNameErrors = [];
  };

  updateEmail = (value: string) => {
    this.email = value;
    this.emailErrors = [];
  };

  updatePhone = (value: string) => {
    this.phone = value;
  };

  handleSubmit = (event: Event) => {
    event.preventDefault();

    // Basic validation
    const errors = [];

    if (!this.fullName) {
      this.fullNameErrors = ['Full name is required'];
      errors.push('fullName');
    }

    if (!this.email) {
      this.emailErrors = ['Email is required'];
      errors.push('email');
    } else if (!this.email.includes('@')) {
      this.emailErrors = ['Please enter a valid email address'];
      errors.push('email');
    }

    if (errors.length === 0) {
      console.log('Form submitted successfully!', {
        fullName: this.fullName,
        email: this.email,
        phone: this.phone
      });
    }
  };

  <template>
    <form {{on 'submit' this.handleSubmit}}>
      <div class='flex flex-col gap-6'>

        <Input
          @label='Full Name'
          @value={{this.fullName}}
          @onInput={{this.updateFullName}}
          @isRequired={{true}}
          @errors={{this.fullNameErrors}}
        />

        <Input
          @label='Email Address'
          @type='email'
          @value={{this.email}}
          @onInput={{this.updateEmail}}
          @isRequired={{true}}
          @errors={{this.emailErrors}}
          @description="We'll never share your email with anyone else"
        />

        <Input
          @label='Phone Number'
          @type='tel'
          @value={{this.phone}}
          @onInput={{this.updatePhone}}
        >
          <:startContent>
            +1
          </:startContent>
        </Input>

        <Button @class='mt-4'>
          Submit
        </Button>

      </div>
    </form>
  </template>
}
```

### Custom Styling

You can customize the appearance of different parts of the input using the `@classes` argument.

```gts preview
import Component from '@glimmer/component';
import { Input } from '@frontile/forms';
import { hash } from '@ember/helper';

export default class CustomStyledInput extends Component {
  <template>
    <Input
      @label='Custom Styled Input'
      @classes={{hash
        base='my-custom-form-control'
        input='my-custom-input-field'
        innerContainer='my-custom-container'
        startContent='my-start-content'
        endContent='my-end-content'
      }}
    >
      <:startContent>
        <SearchIcon />
      </:startContent>
    </Input>
  </template>
}
const SearchIcon = <template>
  <svg
    xmlns='http://www.w3.org/2000/svg'
    fill='none'
    viewBox='0 0 24 24'
    stroke-width='1.5'
    stroke='currentColor'
    class='size-5'
  >
    <path
      stroke-linecap='round'
      stroke-linejoin='round'
      d='m21 21-5.197-5.197m0 0A7.5 7.5 0 1 0 5.196 5.196a7.5 7.5 0 0 0 10.607 10.607Z'
    />
  </svg>
</template>;
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
