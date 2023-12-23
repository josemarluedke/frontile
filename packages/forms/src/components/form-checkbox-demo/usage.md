---
order: 1
---

# Usage

```hbs template
<FormCheckbox
  name="isChecked"
  @label="Checkbox"
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
  @tracked value = false;

  @action setValue(value) {
    this.value = value;
  }
}
```
