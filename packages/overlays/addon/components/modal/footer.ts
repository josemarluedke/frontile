import Component from '@glimmer/component';
import { ModalArgs } from '.';

interface ModalFooterArgs extends Pick<ModalArgs, 'size'> {}

interface ModalFooterSignature {
  Args: ModalFooterArgs;
  Element: HTMLDivElement;
}

export default class ModalFooter extends Component<ModalFooterSignature> {}
