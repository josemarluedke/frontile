import Component from '@glimmer/component';

export interface ModalFooterArgs {
  class?: string;
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
    <div class={{@class}} ...attributes>
      {{yield}}
    </div>
  </template>
}
