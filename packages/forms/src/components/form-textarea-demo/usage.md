---
order: 1
---

# Usage

```hbs template
<FormTextarea
  @label="Text"
  @value={{this.value}}
  @onInput={{this.setValue}}
  @errors={{this.validationErrors}}
/>

<p class="mt-4">
  You typed, "{{this.value}}"
</p>
```

```js component
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';

export default class DemoComponent extends Component {
  @tracked value = '';

  get validationErrors() {
    if (/^$/.test(this.value)) {
      return ['Please enter text'];
    } else {
      return [];
    }
  }

  @action setValue(value) {
    this.value = value;
  }
}
```
