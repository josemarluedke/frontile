import Component from '@glimmer/component';

interface ButtonArgs {
  appearance?: 'default' | 'outlined' | 'minimal';
  intent?: 'primary' | 'success' | 'warning' | 'danger';
  isActive?: boolean;
}

export default class Button extends Component<ButtonArgs> {
  get classNames(): string {
    const names = [];

    if (this.args.appearance === 'outlined') {
      names.push('btn-outlined');
    } else if (this.args.appearance === 'minimal') {
      names.push('btn-minimal');
    } else {
      names.push('btn');
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
