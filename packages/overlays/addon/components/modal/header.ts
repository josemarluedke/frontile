import Component from '@glimmer/component';
import { ModalArgs } from '.';

interface ModalHeaderArgs extends Pick<ModalArgs, 'size'> {
  /**
   * The id used to reference labelledById in Modal component
   */
  labelledById: string;
}

interface ModalHeaderSignature {
  Args: ModalHeaderArgs;
  Element: HTMLDivElement | null;
}

export default class ModalHeader extends Component<ModalHeaderSignature> {}
