---
label: New
imports:
  - import Signature from 'site/components/signature';
---
# Checkbox Group


## Import 

```js
import { CheckboxGroup } from '@frontile/forms';
```

## Usage

A checkbox group manages multiple related checkboxes and keeps the
selected values in sync. The component yields a preconfigured
`<Checkbox>` that automatically wires the `name` and `onChange`
arguments.

```gts preview
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { CheckboxGroup } from '@frontile/forms';

export default class CheckboxGroupExample extends Component {
  @tracked music = false;
  @tracked iot = false;

  updateMusic = (v: boolean) => (this.music = v);
  updateIot = (v: boolean) => (this.iot = v);

  <template>
    <CheckboxGroup @label='Interests' @orientation='horizontal' as |Checkbox|>
      <Checkbox
        @name='music'
        @label='Music'
        @checked={{this.music}}
        @onChange={{this.updateMusic}}
      />
      <Checkbox
        @name='iot'
        @label='IoT'
        @checked={{this.iot}}
        @onChange={{this.updateIot}}
      />
    </CheckboxGroup>
    <p class='mt-4'>Music: {{this.music}}, IoT: {{this.iot}}</p>
  </template>
}
```

## API

<Signature @package="forms" @component="CheckboxGroup" />
