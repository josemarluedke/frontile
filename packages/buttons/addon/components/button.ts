import Component from '@glimmer/component';

interface ButtonArgs {
  type?: 'button' | 'submit' | 'reset';
  appearance?: 'default' | 'outlined' | 'minimal';
  intent?: 'primary' | 'success' | 'warning' | 'danger';
  isActive?: boolean;
  isXSmall?: boolean;
  isSmall?: boolean;
  isLarge?: boolean;
  isXLarge?: boolean;
}

export default class Button extends Component<ButtonArgs> {
  get type(): string {
    if (this.args.type) {
      return this.args.type;
    }
    return 'button';
  }

  get size(): string | undefined {
    const sizes: { [key: string]: boolean | undefined } = {
      xs: this.args.isXSmall,
      sm: this.args.isSmall,
      lg: this.args.isLarge,
      xl: this.args.isXLarge
    };

    return Object.keys(sizes).find((key: string) => sizes[key] === true);
  }

  get classNames(): string {
    const names = [];

    if (this.args.appearance === 'outlined') {
      names.push('btn-outlined');
    } else if (this.args.appearance === 'minimal') {
      names.push('btn-minimal');
    } else {
      names.push('btn');
    }

    if (this.size) {
      names.push(`${names[0]}-${this.size}`);
    }

    if (this.args.intent) {
      names.push(`${names[0]}-${this.args.intent}`);
    }

    if (this.args.isActive) {
      names.push('is-active');
    }

    return names.join(' ');
  }
}
