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

### Basic Usage

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

### Displaying Form Data

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Form, Input } from '@frontile/forms';

export default class ShowDataForm extends Component {
  @tracked data: FormResultData | undefined;

  onChange = (d: FormResultData) => {
    this.data = d;
  };

  <template>
    <Form @onChange={{this.onChange}}>
      <Input @name='email' @label='Email' />
      <button type='submit'>Save</button>
    </Form>
    {{#if this.data}}
      <pre class='mt-4'>{{JSON.stringify(this.data, null, 2)}}</pre>
    {{/if}}
  </template>
}
```

## API

<Signature @package="forms" @component="Form" />
