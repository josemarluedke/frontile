import Component from '@glimmer/component';
import { DrawerArgs } from '.';

interface DrawerBodyArgs extends Pick<DrawerArgs, 'size' | 'placement'> {}

interface DrawerBodySignature {
  Args: DrawerBodyArgs;
  Element: HTMLDivElement | null;
}

export default class DrawerBody extends Component<DrawerBodySignature> {}
