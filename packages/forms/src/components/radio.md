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

## API

<Signature @package="forms" @component="Radio" />
