import Component from '@glimmer/component';
import { action } from '@ember/object';

interface FormCheckboxArgs {
  /** The input field label */
  label?: string;
  /** A help text to be displayed */
  hint?: string;
  /**
   * If the checkbox is checked.
   * You must also pass `onChange` to update its value.
   */
  checked: boolean;
  /** The name of the checkbox */
  name?: string;
  /** CSS classes to be added in the container element */
  containerClass?: string;
  /** The size */
  size?: 'sm' | 'lg';
  /** Callback when onchange is triggered */
  onChange: (value: boolean, event: Event) => void;

  /**
   * Internal function for InputCheckboxGroup
   * @ignore
   **/
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
