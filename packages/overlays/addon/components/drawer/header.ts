import Component from '@glimmer/component';
import { DrawerArgs } from '.';

interface DrawerHeaderArgs extends Pick<DrawerArgs, 'size' | 'placement'> {
  /**
   * The id used to reference labelledById in Drawer component
   */
  labelledById: string;
}

interface DrawerHeaderSignature {
  Args: DrawerHeaderArgs;
  Element: HTMLDivElement;
}
export default class DrawerHeader extends Component<DrawerHeaderSignature> {}
