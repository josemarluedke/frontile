---
label: New
imports:
  - import Signature from 'site/components/signature';
---
# Textarea


## Import 

```js
import { Textarea } from '@frontile/forms';
```

## Usage

`<Textarea>` behaves similarly to `<Input>` but allows multiline text.
Use `onInput` or `onChange` to control the value.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Textarea } from '@frontile/forms';

export default class TextareaExample extends Component {
  @tracked bio = '';

  onInput = (v: string) => (this.bio = v);

  <template>
    <Textarea
      @label='Bio'
      @value={{this.bio}}
      @onInput={{this.onInput}}
    />
    <p class='mt-4'>{{this.bio}}</p>
  </template>
}
```

## API

<Signature @package="forms" @component="Textarea" />
