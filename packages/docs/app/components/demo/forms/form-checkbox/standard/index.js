// BEGIN-SNIPPET demo-forms-form-checkbox-standard-index.js
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';

export default class DemoComponent extends Component {
  @tracked value = false;

  @action setValue(value) {
    this.value = value;
  }
}
// END-SNIPPET
