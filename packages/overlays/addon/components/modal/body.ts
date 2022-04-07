import Component from '@glimmer/component';
import { ModalArgs } from '.';

export interface ModalBodyArgs extends Pick<ModalArgs, 'size'> {}

export interface ModalBodySignature {
  Args: ModalBodyArgs;
  Element: HTMLDivElement;
}

export default class ModalBody extends Component<ModalBodySignature> {}
