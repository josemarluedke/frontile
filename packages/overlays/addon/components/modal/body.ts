import Component from '@glimmer/component';
import { ModalArgs } from '.';

interface ModalBodyArgs extends Pick<ModalArgs, 'size'> {}

interface ModalBodySignature {
  Args: ModalBodyArgs;
  Element: HTMLDivElement;
}

export default class ModalBody extends Component<ModalBodySignature> {}
