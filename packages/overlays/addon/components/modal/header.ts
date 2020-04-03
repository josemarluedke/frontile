import Component from '@glimmer/component';

interface ModalHeaderArgs {
  labelledById: string;
  onClose: () => void;
}

export default class ModalHeader extends Component<ModalHeaderArgs> {}
