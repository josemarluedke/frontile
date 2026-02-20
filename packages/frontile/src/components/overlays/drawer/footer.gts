import Component from '@glimmer/component';
import { twMerge } from '@frontile/theme';

export interface DrawerFooterArgs {
  class?: string;
  /**
   * @internal
   */
  classFromParent?: string;
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
    <div class={{twMerge @classFromParent @class}} ...attributes>
      {{yield}}
    </div>
  </template>
}
