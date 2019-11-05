// BEGIN-SNIPPET demo-forms-input-text-no-label-index.js
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';

export default class DemoComponent extends Component {
  @tracked value = '';

  @action setValue(value) {
    this.value = value;
  }
}
// END-SNIPPET
