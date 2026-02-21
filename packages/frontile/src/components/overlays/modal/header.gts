import Component from '@glimmer/component';
import { twMerge } from '@frontile/theme';

export interface ModalHeaderArgs {
  class?: string;
  /**
   * The id used to reference labelledById in Modal component
   */
  labelledById: string;

  /**
   * @internal
   */
  classFromParent?: string;
}

export interface ModalHeaderSignature {
  Args: ModalHeaderArgs;
  Element: HTMLDivElement;
  Blocks: {
    default: [];
  };
}

export default class ModalHeader extends Component<ModalHeaderSignature> {
  <template>
    <div
      id={{@labelledById}}
      class={{twMerge @classFromParent @class}}
      ...attributes
    >
      {{yield}}
    </div>
  </template>
}
