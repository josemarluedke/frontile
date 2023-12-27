import Component from '@glimmer/component';
import type { ModalArgs } from '../modal';
import useFrontileClass from '@frontile/core/helpers/use-frontile-class';

export interface ModalFooterArgs extends Pick<ModalArgs, 'size'> {}

export interface ModalFooterSignature {
  Args: ModalFooterArgs;
  Element: HTMLDivElement;
  Blocks: {
    default: [];
  };
}

export default class ModalFooter extends Component<ModalFooterSignature> {
  <template>
    <div class={{useFrontileClass "modal" @size part="footer"}} ...attributes>
      {{yield}}
    </div>
  </template>
}
