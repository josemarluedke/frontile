import Component from '@glimmer/component';
import { twMerge } from '@frontile/theme';

export interface DrawerBodyArgs {
  class?: string;
  /**
   * @internal
   */
  classFromParent?: string;
}

export interface DrawerBodySignature {
  Args: DrawerBodyArgs;
  Element: HTMLDivElement;
  Blocks: {
    default: [];
  };
}

export default class DrawerBody extends Component<DrawerBodySignature> {
  <template>
    <div class={{twMerge @classFromParent @class}} ...attributes>
      {{yield}}
    </div>
  </template>
}
