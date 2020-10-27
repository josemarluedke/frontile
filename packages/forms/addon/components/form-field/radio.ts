import Component from '@glimmer/component';
import { action } from '@ember/object';

interface FormFieldRadioArgs {
  value?: unknown;
  checked?: unknown;
  name?: string;
  size?: 'sm' | 'lg';

  // Callback when onchange is triggered
  onChange?: (value: unknown, event: Event) => void;
}

export default class FormFieldRadio extends Component<FormFieldRadioArgs> {
  get isChecked(): boolean {
    return this.args.checked === this.args.value;
  }

  @action handleChange(event: Event): void {
    event.preventDefault();

    if (typeof this.args.onChange === 'function') {
      this.args.onChange(this.args.value, event);
    }
  }
}
