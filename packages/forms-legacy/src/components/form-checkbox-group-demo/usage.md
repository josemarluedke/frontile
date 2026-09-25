---
order: 1
---

# Usage

```hbs template
<FormCheckboxGroup
  @errors={{this.validationErrors}}
  @label="Checkbox group"
  as |Checkbox|
>
  <Checkbox
    @name="isChecked"
    @label="Checkbox"
    @checked={{this.isChecked}}
    @onChange={{this.setIsChecked}}
  />

  <Checkbox
    @name="isChecked2"
    @label="Checkbox 2"
    @checked={{this.isChecked2}}
    @onChange={{this.setIsChecked2}}
  />
</FormCheckboxGroup>
```

```js component
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';

export default class DemoComponent extends Component {
  @tracked isChecked = false;
  @tracked isChecked2 = false;

  get validationErrors() {
    if (!(this.isChecked || this.isChecked2)) {
      return ['You must select at least one option'];
    } else {
      return [];
    }
  }

  setIsChecked = (value) => {
    this.isChecked = value;
  };

  setIsChecked2 = (value) => {
    this.isChecked2 = value;
  };
}
```
