---
label: New
imports:
  - import Signature from 'site/components/signature';
---
# Radio Group


## Import 

```js
import { RadioGroup } from '@frontile/forms';
```

## Usage

`<RadioGroup>` coordinates a set of radio buttons. The yielded
`<Radio>` component already has the group `name` and change handler
bound for you.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { RadioGroup } from '@frontile/forms';

export default class RadioGroupExample extends Component {
  @tracked value = 'music';

  onChange = (v: string) => (this.value = v);

  <template>
    <RadioGroup
      @label='Interests'
      @value={{this.value}}
      @onChange={{this.onChange}}
      as |Radio|
    >
      <Radio @value='music' @label='Music' />
      <Radio @value='iot' @label='IoT' />
    </RadioGroup>
    <p class='mt-4'>Selected: {{this.value}}</p>
  </template>
}
```

## API

<Signature @package="forms" @component="RadioGroup" />
