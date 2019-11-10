// BEGIN-SNIPPET demo-forms-input-radio-group-standard-index.js
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';

export default class DemoComponent extends Component {
  @tracked value = '';

  get validationErrors() {
    if (this.value === 'maybe') {
      return ['You cannot select maybe as an option'];
    } else {
      return [];
    }
  }

  @action setValue(value) {
    this.value = value;
  }
}
// END-SNIPPET
