---
order: 2
---

# No Label

If you don't want the label then simply leave it out of the component tag:


```hbs template
<FormInput
  @value={{this.value}}
  @onInput={{this.setValue}}
  placeholder="I have no label"
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

  @action setValue(value) {
    this.value = value;
  }
}
```
