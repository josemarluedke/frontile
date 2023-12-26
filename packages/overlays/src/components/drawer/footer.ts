import Component from '@glimmer/component';
import { DrawerArgs } from '.';

export interface DrawerFooterArgs
  extends Pick<DrawerArgs, 'size' | 'placement'> {}

export interface DrawerFooterSignature {
  Args: DrawerFooterArgs;
  Element: HTMLDivElement;
}

export default class DrawerFooter extends Component<DrawerFooterSignature> {}
