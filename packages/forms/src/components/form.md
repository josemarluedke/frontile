---
label: New
imports:
  - import Signature from 'site/components/signature';
---
# Form


## Import 

```js
import { Form } from '@frontile/forms';
```

## Usage

`<Form>` listens to `input` and `submit` events and passes a plain
object with all form values to the provided `onChange` callback.

```gts preview
import Component from '@glimmer/component';
import { Form, Input, Checkbox } from '@frontile/forms';

export default class SimpleForm extends Component {
  onChange = (data: FormResultData, type: 'input' | 'submit') => {
    console.log(type, data);
  };

  <template>
    <Form @onChange={{this.onChange}}>
      <Input @name='firstName' @label='First name' />
      <Checkbox @name='acceptTerms' @label='Accept terms' />
      <button type='submit'>Submit</button>
    </Form>
  </template>
}
```

## API

<Signature @package="forms" @component="Form" />
