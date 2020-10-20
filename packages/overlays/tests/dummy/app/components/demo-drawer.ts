import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { later } from '@ember/runloop';

export default class DemoDrawer extends Component {
  @tracked isOpen = false;
  @tracked isLoading = false;
  @tracked isInPlaceOpen = false;

  @action toggleIsOpen(): void {
    this.isOpen = !this.isOpen;
  }

  @action toggleIsInPlaceOpen(): void {
    this.isInPlaceOpen = !this.isInPlaceOpen;
  }

  @action save(): void {
    this.isLoading = true;

    later(
      this,
      () => {
        this.isLoading = false;
        this.isOpen = false;
        this.isInPlaceOpen = false;
      },
      1000
    );
  }
}
