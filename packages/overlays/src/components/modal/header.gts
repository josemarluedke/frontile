import Component from '@glimmer/component';

export interface ModalHeaderArgs {
  class?: string;
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
    <div id={{@labelledById}} class={{@class}} ...attributes>
      {{yield}}
    </div>
  </template>
}
