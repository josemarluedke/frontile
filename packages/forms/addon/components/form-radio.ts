import Component from '@glimmer/component';
import { action } from '@ember/object';

interface FormRadioArgs {
  label?: string;
  hint?: string;
  value?: unknown;
  checked?: unknown;
  name?: string;
  containerClass?: string;
  size?: 'sm' | 'lg';

  // Callback when onchange is triggered
  onChange?: (value: unknown, event: Event) => void;

  // internal function for FormRadioGroup
  _parentOnChange?: (value: unknown, event: Event) => void;
}

export default class FormRadio extends Component<FormRadioArgs> {
  @action handleChange(value: unknown, event: Event): void {
    event.preventDefault();

    if (typeof this.args.onChange === 'function') {
      this.args.onChange(value, event);
    }

    if (typeof this.args._parentOnChange === 'function') {
      this.args._parentOnChange(value, event);
    }
  }
}
