import Component from '@glimmer/component';

export interface ModalBodyArgs {
  class?: string;
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
    <div class={{@class}} ...attributes>
      {{yield}}
    </div>
  </template>
}
