import Component from '@glimmer/component';

interface ModalHeaderArgs {
  /**
   * The id used to reference labelledById in Modal component
   */
  labelledById: string;
}

export default class ModalHeader extends Component<ModalHeaderArgs> {}
