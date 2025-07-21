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

### Controlled Group

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

### Horizontal Layout

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { RadioGroup } from '@frontile/forms';

const options = ['Small', 'Medium', 'Large'];

export default class HorizontalRadioGroup extends Component {
  @tracked size = 'Medium';

  onChange = (v: string) => (this.size = v);

  <template>
    <RadioGroup
      @label='T-Shirt Size'
      @orientation='horizontal'
      @value={{this.size}}
      @onChange={{this.onChange}}
      as |Radio|
    >
      {{#each options as |o|}}
        <Radio @value={{o}} @label={{o}} />
      {{/each}}
    </RadioGroup>
    <p class='mt-4'>Size: {{this.size}}</p>
  </template>
}
```

## API

<Signature @package="forms" @component="RadioGroup" />
