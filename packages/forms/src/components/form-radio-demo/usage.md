---
order: 1
---

# Usage

```hbs template
<FormRadio
  name="my-radio-input"
  @label="Yes"
  @value={{true}}
  @checked={{this.value}}
  @onChange={{this.setValue}}
/>

<FormRadio
  name="my-radio-input"
  @label="No"
  @value={{false}}
  @checked={{this.value}}
  @onChange={{this.setValue}}
/>

<p class="mt-4">Selected Value: "{{this.value}}"</p>
```

```js component
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';

export default class DemoComponent extends Component {
  @tracked value = '';

  @action setValue(value) {
    this.value = value;
  }
}
```
