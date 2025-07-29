---
label: New
imports:
  - import Signature from 'site/components/signature';
---

# Checkbox

The `Checkbox` component renders a styled checkbox input with built-in support for labels, descriptions, and error feedback via Frontile’s `FormControl` wrapper. It is a **controlled** component—pass `@checked` and `@onChange` to manage its state externally.

## Import

```js
import { Checkbox } from '@frontile/forms';
```

## Usage

### Basic Controlled Checkbox

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Checkbox } from '@frontile/forms';

export default class BasicCheckbox extends Component {
  @tracked isSubscribed = false;

  onChange = (value: boolean) => {
    this.isSubscribed = value;
  };

  <template>
    <Checkbox
      @label='Subscribe to newsletter'
      @checked={{this.isSubscribed}}
      @onChange={{this.onChange}}
    />
    <p>Subscribed? {{if this.isSubscribed 'Yes' 'No'}}</p>
  </template>
}
```

### With Description and Error Feedback

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Checkbox } from '@frontile/forms';

export default class ValidatedCheckbox extends Component {
  @tracked agreeTerms = false;
  @tracked errors: string[] = [];

  onChange = (value: boolean) => {
    this.agreeTerms = value;
    this.errors = value ? [] : ['You must agree to continue.'];
  };

  <template>
    <Checkbox
      @label='I agree to the terms and conditions'
      @description='Please read carefully before agreeing.'
      @checked={{this.agreeTerms}}
      @onChange={{this.onChange}}
      @errors={{this.errors}}
    />
  </template>
}
```

### Custom Styling

Override internal classes via the @classes argument:

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { Checkbox } from '@frontile/forms';

const classes = {
  base: 'p-4 bg-gray-50 rounded',
  input: 'h-6 w-6 text-green-600',
  labelContainer: 'ml-3',
  label: 'font-semibold text-gray-800'
};

export default class StyledCheckbox extends Component {
  @tracked checked = true;

  onChange = (value: boolean) => {
    this.checked = value;
  };

  <template>
    <Checkbox
      @label='Enable feature'
      @classes={{classes}}
      @checked={{this.checked}}
      @onChange={{this.onChange}}
    />
  </template>
}
```

## API

<Signature @package="forms" @component="Checkbox" />
