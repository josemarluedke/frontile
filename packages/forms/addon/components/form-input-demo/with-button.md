---
order: 4
---

# Input with Button

This is an example of how to implement an input with a button next to it.


```hbs template
<FormInput
  @value={{this.value}}
  @onInput={{this.setValue}}
  @label="Referral Code"
  @errors={{this.validationErrors}}
  @onChange={{this.validate}}
  placeholder="Input your URL or 6 Digit referral code"
  class="rounded-r-none"
>
  <button
    type="button"
    {{on "click" this.validate}}
    class="px-4 py-2 border text-gray-100 rounded-r
    {{if this.isValid "bg-green-800 border-green-800 hover:bg-green-700" "bg-teal-600 border-teal-600 hover:bg-teal-700"}}"
  >
    {{#if this.isValid}}
      <span>
        Code Applied
      </span>
    {{else}}
      Apply
    {{/if}}
  </button>
</FormInput>
```


```js component
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';

export default class DemoComponent extends Component {
  @tracked value = '';
  @tracked validationErrors = [];
  @tracked isValid = false;

  @action setValue(value) {
    this.value = value;
  }

  @action validate() {
    if (/^$/.test(this.value)) {
      this.validationErrors = ['Incorrect Code Applied'];
      this.isValid = false;
    } else {
      this.validationErrors = [];
      this.isValid = true;
    }
  }
}
```
