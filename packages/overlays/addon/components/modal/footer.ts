import Component from '@glimmer/component';
import { ModalArgs } from '.';

export interface ModalFooterArgs extends Pick<ModalArgs, 'size'> {}

export interface ModalFooterSignature {
  Args: ModalFooterArgs;
  Element: HTMLDivElement;
}

export default class ModalFooter extends Component<ModalFooterSignature> {}
