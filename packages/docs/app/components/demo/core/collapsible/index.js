// BEGIN-SNIPPET demo-core-collapsible-index.js
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';

export default class CollapsibleDemo extends Component {
  @tracked isOpen = false;

  @action toggle() {
    this.isOpen = !this.isOpen;
  }
}
// END-SNIPPET
