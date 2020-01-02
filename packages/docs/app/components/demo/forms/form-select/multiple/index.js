// BEGIN-SNIPPET demo-forms-form-select-multiple-index.js
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
// END-SNIPPET
