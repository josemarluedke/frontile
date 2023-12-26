import Component from '@glimmer/component';
import type { ModalArgs } from '../modal';
import useFrontileClass from '@frontile/core/helpers/use-frontile-class';

export interface ModalHeaderArgs extends Pick<ModalArgs, 'size'> {
  /**
   * The id used to reference labelledById in Modal component
   */
  labelledById: string;
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
      class={{useFrontileClass "modal" @size part="header"}}
      ...attributes
    >
      {{yield}}
    </div>
  </template>
}
