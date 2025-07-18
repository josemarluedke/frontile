---
label: New
---
# Checkbox

The `Checkbox` component manages a boolean value and integrates with
`FormControl` to provide labels and error feedback.

## Import 

```js
import { Checkbox } from '@frontile/forms';
```

## Usage

```gts preview
import { Checkbox } from '@frontile/forms';

<template>
  <Checkbox @label='Accept terms' />
</template>
```

### Controlled checkbox

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Checkbox } from '@frontile/forms';

export default class ControlledCheckbox extends Component {
  @tracked agree = false;

  update = (val: boolean) => (this.agree = val);

  <template>
    <Checkbox
      @label='Accept terms'
      @checked={{this.agree}}
      @onChange={{this.update}}
    />
    <p class='mt-2'>Accepted: {{this.agree}}</p>
  </template>
}
```

## API

<Signature @package="forms" @component="Checkbox" />
