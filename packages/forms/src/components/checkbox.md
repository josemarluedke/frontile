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

## API

<Signature @package="forms" @component="Checkbox" />
