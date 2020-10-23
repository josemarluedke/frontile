import Component from '@glimmer/component';
import { action } from '@ember/object';

interface CloseButtonArgs {
  size?: 'xs' | 'sm' | 'md' | 'lg' | 'xl';
  onClick?: (event: Event) => void;
}

export default class CloseButton extends Component<CloseButtonArgs> {
  @action handleClick(event: Event): void {
    this.args.onClick?.(event);
  }

  get sizeClass(): string {
    return `close-button--${this.args.size || 'sm'}`;
  }
}
