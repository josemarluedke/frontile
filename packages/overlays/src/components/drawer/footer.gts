import Component from '@glimmer/component';
import type { DrawerArgs } from '.';
import useFrontileClass from '@frontile/core/helpers/use-frontile-class';

export interface DrawerFooterArgs extends Pick<DrawerArgs, 'placement'> {
  size: string;
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
    <div
      class={{useFrontileClass "drawer" @placement @size part="footer"}}
      ...attributes
    >
      {{yield}}
    </div>
  </template>
}
