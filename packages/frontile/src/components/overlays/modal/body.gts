import Component from '@glimmer/component';
import { twMerge } from '@frontile/theme';

export interface ModalBodyArgs {
  class?: string;

  /**
   * @internal
   */
  classFromParent?: string;
}

export interface ModalBodySignature {
  Args: ModalBodyArgs;
  Element: HTMLDivElement;
  Blocks: {
    default: [];
  };
}

export default class ModalBody extends Component<ModalBodySignature> {
  <template>
    <div class={{twMerge @classFromParent @class}} ...attributes>
      {{yield}}
    </div>
  </template>
}
