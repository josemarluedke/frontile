import Component from '@glimmer/component';
import { action } from '@ember/object';
import 'focus-visible/dist/focus-visible.js';

export interface CloseButtonArgs {
  /**
   * The title of the close button
   *
   * @defaultValue 'Close'
   */
  title?: string;

  /**
   * The icon size
   *
   * @defaultValue 'lg'
   */
  size?: 'xs' | 'sm' | 'md' | 'lg' | 'xl';

  /**
   * The function to call when button is clicked
   */
  onClick?: (event: Event) => void;

  /**
   * Additional class for close button element
   */
  class?: string;
}

export interface CloseButtonSignature {
  Args: CloseButtonArgs;
  Blocks: {
    default: [string | null];
  };
  Element: HTMLButtonElement;
}

export default class CloseButton extends Component<CloseButtonSignature> {
  @action handleClick(event: Event): void {
    if (typeof this.args.onClick === 'function') {
      this.args.onClick(event);
    }
  }
}
