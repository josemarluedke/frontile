import Component from '@glimmer/component';
import { action } from '@ember/object';
import { tracked } from '@glimmer/tracking';

interface InputCheckboxArgs {
  label?: string;
  hint?: string;
  checked?: unknown;
  name?: string;
  hasMargin?: boolean;
  isSmall?: boolean;

  // Callback when onchange is triggered
  onChange?: (value: unknown, event: Event) => void;

  // internal function for InputRadioGroup
  _parentOnChange?: (value: unknown, event: Event) => void;
}

export default class InputCheckbox extends Component<InputCheckboxArgs> {
  @tracked isFocused = false;

  get isChecked(): boolean {
    return !!this.args.checked;
  }

  @action handleChange(event: Event): void {
    event.preventDefault();

    const value = !this.args.checked;

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
