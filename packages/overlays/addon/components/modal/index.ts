import Component from '@glimmer/component';
import { action } from '@ember/object';
import { guidFor } from '@ember/object/internals';
import { OverlayArgs } from '../overlay';

interface ModalArgs extends Omit<OverlayArgs, 'contentTransitionName'> {
  /*
   * The name of the transition to be used in the modal.
   * @defaultValue `overlay--transition--zoom`
   */
  transitionName?: string;
}

export default class Modal extends Component<ModalArgs> {
  headerId = `${guidFor(this)}-header`;

  @action handleClose(): void {
    if (typeof this.args.onClose === 'function') {
      this.args.onClose();
    }
  }
}
