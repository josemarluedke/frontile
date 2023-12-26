import Component from '@glimmer/component';
import type { DrawerArgs } from '.';
import useFrontileClass from '@frontile/core/helpers/use-frontile-class';

export interface DrawerBodyArgs extends Pick<DrawerArgs, 'placement'> {
  size: string;
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
    <div
      class={{useFrontileClass "drawer" @placement @size part="body"}}
      ...attributes
    >
      {{yield}}
    </div>
  </template>
}
