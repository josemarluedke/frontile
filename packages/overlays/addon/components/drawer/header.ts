import Component from '@glimmer/component';

interface DrawerHeaderArgs {
  /**
   * The id used to reference labelledById in Drawer component
   */
  labelledById: string;
}

export default class DrawerHeader extends Component<DrawerHeaderArgs> {}
