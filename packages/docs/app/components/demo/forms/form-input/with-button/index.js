// BEGIN-SNIPPET demo-forms-form-input-with-button-index.js
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
// END-SNIPPET
