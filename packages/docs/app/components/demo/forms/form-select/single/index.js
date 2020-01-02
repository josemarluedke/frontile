// BEGIN-SNIPPET demo-forms-form-select-single-index.js
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
// END-SNIPPET
