import Component from '@glimmer/component';
import { action } from '@ember/object';
import { tracked } from '@glimmer/tracking';

interface InputRadioArgs {
  label?: string;
  hint?: string;
  value?: unknown;
  checked?: unknown;
  name?: string;
  hasMargin?: boolean;
  isSmall?: boolean;

  // Callback when onchange is triggered
  onChange?: (value: unknown, event: Event) => void;

  // internal function for InputRadioGroup
  _parentOnChange?: (value: unknown, event: Event) => void;
}

export default class InputRadio extends Component<InputRadioArgs> {
  @tracked isFocused = false;

  get isChecked(): boolean {
    return this.args.checked === this.args.value;
  }

  @action handleChange(this: InputRadio, event: Event): void {
    event.preventDefault();

    if (typeof this.args.onChange === 'function') {
      this.args.onChange(this.args.value, event);
    }

    if (typeof this.args._parentOnChange === 'function') {
      this.args._parentOnChange(this.args.value, event);
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
