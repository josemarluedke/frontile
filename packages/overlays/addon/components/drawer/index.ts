import Component from '@glimmer/component';
import { action } from '@ember/object';
import { guidFor } from '@ember/object/internals';
import { OverlayArgs } from '../overlay';

interface DrawerArgs extends Omit<OverlayArgs, 'contentTransitionName'> {
  /**
   * The name of the transition to be used in the modal.
   * @defaultValue `overlay-transition--slide-from-[placement]`
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
   *
   * @defaultValue true
   */
  allowCloseButton?: boolean;

  /*
   * The Close Button size.
   */
  closeButtonSize?: 'xs' | 'sm' | 'md' | 'lg' | 'xl';

  /**
   * The Drawer can appear from any side of the screen. The 'placement'
   * option allows to choose where it appears from.
   *
   * @defaultValue `right`
   */
  placement?: 'top' | 'bottom' | 'left' | 'right';

  /**
   * The Drawer size.
   *
   * @defaultValue `md`
   */
  size: 'xs' | 'sm' | 'md' | 'lg' | 'xl' | 'full';
}

export default class Drawer extends Component<DrawerArgs> {
  headerId = `${guidFor(this)}-header`;

  get preventClosing(): boolean {
    return this.args.allowClosing === false;
  }

  get showCloseButton(): boolean {
    return (
      this.args.allowClosing !== false && this.args.allowCloseButton !== false
    );
  }

  @action handleClose(): void {
    if (typeof this.args.onClose === 'function') {
      this.args.onClose();
    }
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
