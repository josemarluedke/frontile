import Component from '@glimmer/component';
import { guidFor } from '@ember/object/internals';
import { OverlaySignature } from '../overlay';
import DrawerBody from './body';
import DrawerFooter from './footer';
import DrawerHeader from './header';
import CloseButton from '@frontile/core/addon/components/close-button';

export interface DrawerArgs
  extends Omit<OverlaySignature['Args'], 'contentTransitionName'> {
  /**
   * The name of the transition to be used in the Drawer.
   *
   * @defaultValue 'overlay-transition--slide-from-[placement]'
   */
  transitionName?: string;

  /**
   * If set to false, the close button will not be displayed,
   * closeOnOutsideClick will be set to false, and closeOnEscapeKey will also be set
   * to false.
   *
   * @defaultValue true
   */
  allowClosing?: boolean;

  /**
   * If set to false, the close button will not be displayed.
   *
   * @defaultValue true
   */
  allowCloseButton?: boolean;

  /**
   * The Close Button size.
   */
  closeButtonSize?: 'xs' | 'sm' | 'md' | 'lg' | 'xl';

  /**
   * The Drawer can appear from any side of the screen. The 'placement'
   * option allows to choose where it appears from.
   *
   * @defaultValue 'right'
   */
  placement?: 'top' | 'bottom' | 'left' | 'right';

  /**
   * The Drawer size.
   *
   * @defaultValue 'md'
   */
  size?: 'xs' | 'sm' | 'md' | 'lg' | 'xl' | 'full';
}

interface DrawerBlocks {
  default: [
    {
      CloseButton: CloseButton;
      Header: DrawerHeader;
      Body: DrawerBody;
      Footer: DrawerFooter;
      headerId: string;
    }
  ];
}

interface DrawerSignature {
  Args: DrawerArgs;
  Blocks: DrawerBlocks;
  Element: HTMLDivElement | null;
}

export default class Drawer extends Component<DrawerSignature> {
  headerId = `${guidFor(this)}-header`;

  get preventClosing(): boolean {
    return this.args.allowClosing === false;
  }

  get showCloseButton(): boolean {
    return (
      this.args.allowClosing !== false && this.args.allowCloseButton !== false
    );
  }

  get placement(): string {
    return this.args.placement || 'right';
  }

  get size(): string {
    const dir = ['top', 'bottom'].includes(this.placement)
      ? 'vertical'
      : 'horizontal';

    return `${this.args.size || 'md'}-${dir}`;
  }
}
