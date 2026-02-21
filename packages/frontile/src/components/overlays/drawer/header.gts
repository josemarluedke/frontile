import Component from '@glimmer/component';
import { twMerge } from '@frontile/theme';

export interface DrawerHeaderArgs {
  /**
   * The id used to reference labelledById in Drawer component
   */
  labelledById: string;

  class?: string;

  /**
   * @internal
   */
  classFromParent?: string;
}

export interface DrawerHeaderSignature {
  Args: DrawerHeaderArgs;
  Element: HTMLDivElement;
  Blocks: {
    default: [];
  };
}
export default class DrawerHeader extends Component<DrawerHeaderSignature> {
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
