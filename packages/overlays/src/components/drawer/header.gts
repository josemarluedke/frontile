import Component from '@glimmer/component';
import type { DrawerArgs } from '../drawer';
import useFrontileClass from '@frontile/core/helpers/use-frontile-class';

export interface DrawerHeaderArgs extends Pick<DrawerArgs, 'placement'> {
  size: string;
  /**
   * The id used to reference labelledById in Drawer component
   */
  labelledById: string;
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
      class={{useFrontileClass "drawer" @placement @size part="header"}}
      ...attributes
    >
      {{yield}}
    </div>
  </template>
}
