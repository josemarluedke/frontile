---
label: New
imports:
  - import Signature from 'site/components/signature';
---
# Radio


## Import 

```js
import { Radio } from '@frontile/forms';
```

## Usage

Radios represent a single choice within a group. They are typically
used inside `<RadioGroup>` but can also be used standalone.

### Standalone Radio

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Radio } from '@frontile/forms';

export default class RadioExample extends Component {
  @tracked selected: string | undefined;

  onChange = (v: string) => (this.selected = v);

  <template>
    <Radio
      @label='Option'
      @value='option'
      @checkedValue={{this.selected}}
      @onChange={{this.onChange}}
    />
    <p class='mt-4'>Selected: {{this.selected}}</p>
  </template>
}
```

### With Description and Error

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Radio } from '@frontile/forms';

export default class RadioErrorExample extends Component {
  @tracked value: string | undefined;

  onChange = (v: string) => (this.value = v);

  <template>
    <Radio
      @label='Subscribe'
      @description='Choose yes to receive updates'
      @value='yes'
      @checkedValue={{this.value}}
      @onChange={{this.onChange}}
      @errors={{unless this.value "Please select yes"}}
      @isInvalid={{not this.value}}
    />
  </template>
}
```

### Sizes

```gts preview
import { Radio } from '@frontile/forms';

<template>
  <div class='flex gap-4'>
    <Radio @label='Small' @value='sm' @size='sm' />
    <Radio @label='Medium' @value='md' />
    <Radio @label='Large' @value='lg' @size='lg' />
  </div>
</template>
```

## API

<Signature @package="forms" @component="Radio" />
