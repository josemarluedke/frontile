import Component from '@glimmer/component';
import { ModalArgs } from '.';

export interface ModalHeaderArgs extends Pick<ModalArgs, 'size'> {
  /**
   * The id used to reference labelledById in Modal component
   */
  labelledById: string;
}

export interface ModalHeaderSignature {
  Args: ModalHeaderArgs;
  Element: HTMLDivElement;
}

export default class ModalHeader extends Component<ModalHeaderSignature> {}
