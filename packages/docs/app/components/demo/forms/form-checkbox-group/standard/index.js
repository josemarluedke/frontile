// BEGIN-SNIPPET demo-forms-form-checkbox-group-standard-index.js
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';

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

  @action setIsChecked(value) {
    this.isChecked = value;
  }

  @action setIsChecked2(value) {
    this.isChecked2 = value;
  }
}
// END-SNIPPET
