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

## API

<Signature @package="forms" @component="Input" />
