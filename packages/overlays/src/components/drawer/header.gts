import Component from '@glimmer/component';

export interface DrawerHeaderArgs {
  /**
   * The id used to reference labelledById in Drawer component
   */
  labelledById: string;

  class?: string;
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
    <div id={{@labelledById}} class={{@class}} ...attributes>
      {{yield}}
    </div>
  </template>
}
