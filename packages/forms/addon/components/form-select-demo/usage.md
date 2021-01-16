---
order: 1
---

# Usage

Single Select.

```hbs template
<FormSelect
  @hint="Select your country of residence"
  @errors={{this.countryErrors}}
  @allowClear={{true}}
  @label="Country"
  @searchEnabled={{true}}
  @searchField="name"
  @options={{this.countries}}
  @selected={{this.country}}
  @onChange={{this.setCountry}}
  as |country|
>
  {{country.name}}
</FormSelect>

<p class="mt-4">
  You selected, "{{this.country.name}}"
</p>
```

```js component
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';

export default class DemoComponent extends Component {
  @tracked country;

  countries = [
    { name: 'United States', code: 'US' },
    { name: 'Spain', code: 'ES' },
    { name: 'Portugal', code: 'PT', disabled: true },
    { name: 'Russia', code: 'RU', disabled: true },
    { name: 'Latvia', code: 'LV' },
    { name: 'Brazil', code: 'BR' },
    { name: 'United Kingdom', code: 'GB' }
  ];

  get countryErrors() {
    if (this.country) {
      return [];
    } else {
      return ["Country can't be blank"];
    }
  }

  @action setCountry(value) {
    this.country = value;
  }
}
```
