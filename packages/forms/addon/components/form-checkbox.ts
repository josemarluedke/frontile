import Component from '@glimmer/component';
import { action } from '@ember/object';

interface FormCheckboxArgs {
  label?: string;
  hint?: string;
  checked?: boolean;
  name?: string;
  containerClass?: string;
  isSmall?: boolean;
  isLarge?: boolean;

  // Callback when onchange is triggered
  onChange?: (value: boolean, event: Event) => void;

  // internal function for InputRadioGroup
  _parentOnChange?: (value: boolean, event: Event) => void;
}

export default class FormCheckbox extends Component<FormCheckboxArgs> {
  @action handleChange(value: boolean, event: Event): void {
    if (typeof this.args.onChange === 'function') {
      this.args.onChange(value, event);
    }

    if (typeof this.args._parentOnChange === 'function') {
      this.args._parentOnChange(value, event);
    }
  }
}
