import Component from '@glimmer/component';

export interface DrawerFooterArgs {
  class?: string;
}

export interface DrawerFooterSignature {
  Args: DrawerFooterArgs;
  Element: HTMLDivElement;
  Blocks: {
    default: [];
  };
}

export default class DrawerFooter extends Component<DrawerFooterSignature> {
  <template>
    <div class={{@class}} ...attributes>
      {{yield}}
    </div>
  </template>
}
