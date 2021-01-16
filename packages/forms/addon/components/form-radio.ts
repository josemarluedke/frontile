import Component from '@glimmer/component';
import { action } from '@ember/object';

interface FormRadioArgs {
  /** The input field label */
  label?: string;
  /** A help text to be displayed */
  hint?: string;
  /**
   * The value to be used in the radio button.
   * You must also pass `onChange` to update its value.
   */
  value: unknown;
  /**
   * The current checked value.
   * This will be used to compare against the `value` argument,
   * if equal, the radio will me marked as checked.
   */
  checked: unknown;
  /** The name of the checkbox */
  name?: string;
  /** CSS classes to be added in the container element */
  containerClass?: string;
  /** The size */
  size?: 'sm' | 'lg';
  /** Callback when onchange is triggered */
  onChange: (value: unknown, event: Event) => void;

  /**
   * Internal function for InputRadioGroup
   * @ignore
   **/
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
