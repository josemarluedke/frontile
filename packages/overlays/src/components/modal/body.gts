import Component from '@glimmer/component';
import type { ModalArgs } from '.';
import useFrontileClass from '@frontile/core/helpers/use-frontile-class';

export interface ModalBodyArgs extends Pick<ModalArgs, 'size'> {}

export interface ModalBodySignature {
  Args: ModalBodyArgs;
  Element: HTMLDivElement;
  Blocks: {
    default: [];
  };
}

export default class ModalBody extends Component<ModalBodySignature> {
  <template>
    <div class={{useFrontileClass "modal" @size part="body"}} ...attributes>
      {{yield}}
    </div>
  </template>
}
