import Component from '@glimmer/component';

interface ButtonArgs {
  /**
   * The HTML type of the button
   *
   * @defaultValue 'button'
   */
  type?: 'button' | 'submit' | 'reset';

  /**
   * The button appearance
   *
   * @defaultValue 'default'
   */
  appearance?: 'default' | 'outlined' | 'minimal' | 'custom';

  /**
   * The intent of the button
   */
  intent?: 'primary' | 'success' | 'warning' | 'danger';

  /**
   * The size of the button
   */
  size?: 'xs' | 'sm' | 'lg' | 'xl';

  /**
   * Disable rendering the button element. It yields an object with classNames instead.
   */
  isRenderless?: boolean;
}

export default class Button extends Component<ButtonArgs> {
  get type(): string {
    if (this.args.type) {
      return this.args.type;
    }
    return 'button';
  }

  get classNames(): string {
    const names = [];

    if (this.args.appearance === 'outlined') {
      names.push('btn-outlined');
    } else if (this.args.appearance === 'minimal') {
      names.push('btn-minimal');
    } else if (this.args.appearance === 'custom') {
      names.push('btn-custom');
    } else {
      names.push('btn');
    }

    if (this.args.size) {
      names.push(`${names[0]}--${this.args.size}`);
    }

    if (this.args.intent) {
      names.push(`${names[0]}--${this.args.intent}`);
    }

    return names.join(' ');
  }
}
