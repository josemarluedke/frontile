---
order: 2
---

# Multiple Select

In example you can select multiple options. To enable multiple select,
just pass `@isMultiple={{true}}` to the component.

```hbs template
<FormSelect
  @isMultiple={{true}}
  @hint="Select all countries you have lived"
  @errors={{this.countryErrors}}
  @allowClear={{true}}
  @label="Countries"
  @options={{this.countries}}
  @selected={{this.selectedCountries}}
  @onChange={{this.setCountry}}
  as |country|
>
  {{country}}
</FormSelect>

<p class="mt-4">
  You selected, "{{this.selectedCountries}}"
</p>
```

```js component
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';

export default class DemoComponent extends Component {
  @tracked selectedCountries;

  countries = [
    'United States',
    'Spain',
    'Portugal',
    'Russia',
    'Latvia',
    'Brazil',
    'United Kingdom'
  ];

  get countryErrors() {
    if (this.selectedCountries && this.selectedCountries.length > 0) {
      return [];
    } else {
      return ["Countries can't be blank"];
    }
  }

  @action setCountry(value) {
    this.selectedCountries = value;
  }
}
```
