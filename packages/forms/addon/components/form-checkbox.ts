import Component from '@glimmer/component';
import { action } from '@ember/object';
import { tracked } from '@glimmer/tracking';

interface FormCheckboxArgs {
  label?: string;
  hint?: string;
  checked?: boolean;
  name?: string;
  containerClass?: string;
  isSmall?: boolean;

  // Callback when onchange is triggered
  onChange?: (value: boolean, event: Event) => void;

  // internal function for InputRadioGroup
  _parentOnChange?: (value: boolean, event: Event) => void;
}

export default class FormCheckbox extends Component<FormCheckboxArgs> {
  @tracked isFocused = false;

  @action handleChange(value: boolean, event: Event): void {
    if (typeof this.args.onChange === 'function') {
      this.args.onChange(value, event);
    }

    if (typeof this.args._parentOnChange === 'function') {
      this.args._parentOnChange(value, event);
    }
  }

  @action handleFocusIn(event: FocusEvent): void {
    if (event.relatedTarget !== null) {
      this.isFocused = true;
    }
  }

  @action handleFocusOut(_: FocusEvent): void {
    this.isFocused = false;
  }
}
