---
order: 1
---

# Usage

```hbs template
<FormRadioGroup
  @label="Grouped radio buttons"
  @value={{this.value}}
  @onChange={{this.setValue}}
  @errors={{this.validationErrors}}
  as |Radio|
>
  <Radio @value={{true}} @label="Yes" />
  <Radio @value={{false}} @label="No" />
  <Radio @value="maybe" @label="Maybe" />
</FormRadioGroup>

<p class="mt-4">Selected Value: "{{this.value}}"</p>
```

```js component
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';

export default class DemoComponent extends Component {
  @tracked value = '';

  get validationErrors() {
    if (this.value === 'maybe') {
      return ['You cannot select maybe as an option'];
    } else {
      return [];
    }
  }

  @action setValue(value) {
    this.value = value;
  }
}
```
