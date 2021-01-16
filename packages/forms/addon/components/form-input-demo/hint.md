---
order: 3
---

# Input with Hint

You can pass `@hint` to the component to add hint content.


```hbs template
<FormInput
  @label="I have Hint"
  @hint="InputText support optional hints"
  @value={{this.value}}
  @onInput={{this.setValue}}
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
