import Component from '@glimmer/component';
import { action } from '@ember/object';

export interface FormFieldCheckboxArgs {
  checked?: boolean;
  name?: string;
  size?: 'sm' | 'lg';

  // Callback when onchange is triggered
  onChange?: (value: boolean, event: Event) => void;
}

export interface FormFieldCheckboxSignature {
  Args: FormFieldCheckboxArgs;
  Element: HTMLInputElement;
}

export default class FormFieldCheckbox extends Component<FormFieldCheckboxSignature> {
  get isChecked(): boolean {
    return !!this.args.checked;
  }

  @action handleChange(event: Event): void {
    event.preventDefault();

    const value = !this.args.checked;

    if (typeof this.args.onChange === 'function') {
      this.args.onChange(value, event);
    }
  }
}
