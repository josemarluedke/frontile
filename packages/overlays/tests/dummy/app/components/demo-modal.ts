import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';

interface DemoModalArgs {}

export default class DemoModal extends Component<DemoModalArgs> {
  @tracked isOpen = false;

  @action toggleModal(): void {
    this.isOpen = !this.isOpen;
  }
}
