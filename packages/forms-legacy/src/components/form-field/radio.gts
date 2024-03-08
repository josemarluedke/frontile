import Component from '@glimmer/component';
import { action } from '@ember/object';
import { on } from '@ember/modifier';
import { useStyles } from '@frontile/theme';

export interface FormFieldRadioArgs {
  id?: string;
  value?: string | number | boolean;
  checked?: unknown;
  name?: string;
  size?: 'sm' | 'md' | 'lg';
  class?: string;

  // Callback when onchange is triggered
  onChange?: (value: unknown, event: Event) => void;
}

export interface FormFieldRadioSignature {
  Args: FormFieldRadioArgs;
  Element: HTMLInputElement;
}

export default class FormFieldRadio extends Component<FormFieldRadioSignature> {
  get isChecked(): boolean {
    return this.args.checked === this.args.value;
  }

  @action handleChange(event: Event): void {
    event.preventDefault();

    if (typeof this.args.onChange === 'function') {
      this.args.onChange(this.args.value, event);
    }
  }

  get classes() {
    const { radio } = useStyles();

    return radio({
      size: this.args.size
    }).input({
      class: this.args.class
    });
  }

  <template>
    <input
      {{on "change" this.handleChange}}
      id={{@id}}
      name={{@name}}
      value={{@value}}
      checked={{this.isChecked}}
      type="radio"
      class={{this.classes}}
      data-test-id="form-field-radio"
      ...attributes
    />
  </template>
}
