import Component from '@glimmer/component';
import { guidFor } from '@ember/object/internals';
import { OverlayArgs } from '../overlay';
import ModalFooter from './footer';
import ModalBody from './body';
import ModalHeader from './header';
import CloseButton from '@frontile/core/addon/components/close-button';

export interface ModalArgs extends Omit<OverlayArgs, 'contentTransitionName'> {
  /**
   * The name of the transition to be used in the modal.
   * @defaultValue 'overlay-transition--zoom'
   */
  transitionName?: string;

  /**
   * If set to false, the close button will not be displayed,
   * closeOnOutsideClick will be set to false, and closeOnEscapeKey will also be set
   * to false.
   *
   * @defaultValue true
   */
  allowClosing?: boolean;

  /**
   * If set to false, the close button will not be displayed.
   *
   * @defaultValue true
   */
  allowCloseButton?: boolean;

  /**
   * The Close Button size.
   */
  closeButtonSize?: 'xs' | 'sm' | 'md' | 'lg' | 'xl';

  /**
   * If set to true, the modal will be vertically centered
   *
   * @defaultValue false
   */
  isCentered?: boolean;

  /**
   * The Modal size.
   *
   * @defaultValue 'lg'
   */
  size?: 'xs' | 'sm' | 'md' | 'lg' | 'xl' | 'full';
}

export interface ModalSignature {
  Args: ModalArgs;
  Blocks: {
    default: [
      {
        CloseButton: CloseButton;
        Header: ModalHeader;
        Body: ModalBody;
        Footer: ModalFooter;
        headerId: string;
      }
    ];
  };
  Element: HTMLDivElement | null;
}

export default class Modal extends Component<ModalSignature> {
  headerId = `${guidFor(this)}-header`;

  get preventClosing(): boolean {
    return this.args.allowClosing === false;
  }

  get showCloseButton(): boolean {
    return (
      this.args.allowClosing !== false && this.args.allowCloseButton !== false
    );
  }

  get size(): string {
    return this.args.size || 'lg';
  }
}
