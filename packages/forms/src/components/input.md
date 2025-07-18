---
label: New
---
# Input

The `Input` component wraps a native `<input>` element with a label and
error feedback support. It can be used in controlled or uncontrolled modes
and exposes slots to prepend or append custom content.

## Import 

```js
import { Input } from '@frontile/forms';
```

## Usage

```gts preview
import { Input } from '@frontile/forms';

<template>
  <Input @label='Name' />
</template>
```

### Controlled value

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Input } from '@frontile/forms';

export default class ControlledExample extends Component {
  @tracked name = '';

  update = (val: string) => (this.name = val);

  <template>
    <Input @label='Name' @value={{this.name}} @onInput={{this.update}} />
    <p class='mt-2'>{{this.name}}</p>
  </template>
}
```

### With start and end content

```gts preview
import { Input } from '@frontile/forms';

<template>
  <Input @label='Search'>
    <:startContent>
      <span class='mr-2'>🔍</span>
    </:startContent>
    <:endContent>
      <span class='ml-2'>⌧</span>
    </:endContent>
  </Input>
</template>
```

## API

<Signature @package="forms" @component="Input" />
