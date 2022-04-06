import Component from '@glimmer/component';
import { action } from '@ember/object';

export interface Signature {
  Args: {
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
  };
  Blocks: {
    default: [string | null];
  };
  Element: HTMLButtonElement;
}

export default class CloseButton extends Component<Signature> {
  @action handleClick(event: Event): void {
    if (typeof this.args.onClick === 'function') {
      this.args.onClick(event);
    }
  }
}
