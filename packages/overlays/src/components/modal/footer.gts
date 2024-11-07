import Component from '@glimmer/component';
import { twMerge } from '@frontile/theme';

export interface ModalFooterArgs {
  class?: string;

  /**
   * @internal
   */
  classFromParent?: string;
}

export interface ModalFooterSignature {
  Args: ModalFooterArgs;
  Element: HTMLDivElement;
  Blocks: {
    default: [];
  };
}

export default class ModalFooter extends Component<ModalFooterSignature> {
  <template>
    <div class={{twMerge @classFromParent @class}} ...attributes>
      {{yield}}
    </div>
  </template>
}
