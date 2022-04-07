import Component from '@glimmer/component';
import { DrawerArgs } from '.';

export interface DrawerBodyArgs
  extends Pick<DrawerArgs, 'size' | 'placement'> {}

export interface DrawerBodySignature {
  Args: DrawerBodyArgs;
  Element: HTMLDivElement | null;
}

export default class DrawerBody extends Component<DrawerBodySignature> {}
