import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';

interface CollapsibleDemoArgs {}

export default class CollapsibleDemo extends Component<CollapsibleDemoArgs> {
  @tracked isOpen = false;

  @action toggle(): void {
    this.isOpen = !this.isOpen;
  }
}
