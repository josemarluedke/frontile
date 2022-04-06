import Component from '@glimmer/component';
import { DrawerArgs } from '.';

interface DrawerFooterArgs extends Pick<DrawerArgs, 'size' | 'placement'> {}

interface DrawerFooterSignature {
  Args: DrawerFooterArgs;
  Element: HTMLDivElement | null;
}

export default class DrawerFooter extends Component<DrawerFooterSignature> {}
