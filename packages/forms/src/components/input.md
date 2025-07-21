---
label: New
imports:
  - import Signature from 'site/components/signature';
---
# Input


## Import 

```js
import { Input } from '@frontile/forms';
```

## Usage

Inputs can be used in a controlled or uncontrolled way. They also
support `startContent`, `endContent`, and an optional clear button.

### Controlled Input

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Input } from '@frontile/forms';

export default class InputExample extends Component {
  @tracked name = '';

  onInput = (v: string) => (this.name = v);

  <template>
    <Input
      @label='Name'
      @value={{this.name}}
      @onInput={{this.onInput}}
      @isClearable={{true}}
    >
      <:startContent>@</:startContent>
    </Input>
    <p class='mt-4'>{{this.name}}</p>
  </template>
}
```

### Uncontrolled Input

```gts preview
import { Input } from '@frontile/forms';

<template>
  <Input @label='Search' placeholder='Type to search...' />
</template>
```

### Sizes and Custom Content

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Input } from '@frontile/forms';

export default class InputSizes extends Component {
  @tracked value = '';

  onInput = (v: string) => (this.value = v);

  <template>
    <div class='space-y-4'>
      <Input @label='Small' @size='sm' />
      <Input
        @label='With end icon'
        @value={{this.value}}
        @onInput={{this.onInput}}
      >
        <:endContent>
          <svg
            xmlns='http://www.w3.org/2000/svg'
            fill='none'
            viewBox='0 0 24 24'
            stroke-width='1.5'
            stroke='currentColor'
            class='w-4 h-4'
          >
            <path
              stroke-linecap='round'
              stroke-linejoin='round'
              d='M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z'
            />
          </svg>
        </:endContent>
      </Input>
      <Input @label='Large' @size='lg' />
    </div>
  </template>
}
```

## API

<Signature @package="forms" @component="Input" />
