---
label: New
imports:
  - import Signature from 'site/components/signature';
---
# Checkbox


## Import 

```js
import { Checkbox } from '@frontile/forms';
```

## Usage

Checkboxes represent a boolean choice. Use the `checked` argument to
control the state and `onChange` to be notified when it toggles.

### Controlled Checkbox

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Checkbox } from '@frontile/forms';

export default class CheckboxExample extends Component {
  @tracked accept = false;

  onChange = (v: boolean) => (this.accept = v);

  <template>
    <Checkbox
      @label='Accept Terms'
      @checked={{this.accept}}
      @onChange={{this.onChange}}
    />
    <p class='mt-4'>Accepted: {{this.accept}}</p>
  </template>
}
```

### With Description and Error

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Checkbox } from '@frontile/forms';

export default class CheckboxErrorExample extends Component {
  @tracked value = false;

  onChange = (v: boolean) => (this.value = v);

  <template>
    <Checkbox
      @label='I agree to the terms'
      @description='You must agree before continuing'
      @checked={{this.value}}
      @onChange={{this.onChange}}
      @errors={{unless this.value "You must accept"}}
      @isInvalid={{not this.value}}
    />
  </template>
}
```

### Sizes and Disabled State

```gts preview
import { Checkbox } from '@frontile/forms';

<template>
  <div class='flex gap-4'>
    <Checkbox @label='Small' @size='sm' />
    <Checkbox @label='Medium' />
    <Checkbox @label='Large' @size='lg' />
    <Checkbox @label='Disabled' @isDisabled={{true}} />
  </div>
</template>
```

## API

<Signature @package="forms" @component="Checkbox" />
