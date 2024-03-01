import Component from '@glimmer/component';
import { action } from '@ember/object';
import { on } from '@ember/modifier';
import { useStyles } from '@frontile/theme';

export interface FormFieldInputArgs {
  id?: string;
  type?: string;
  size?: 'sm' | 'md' | 'lg';
  class?: string;
  value?: string;

  // Callback when oninput is triggered
  onInput?: (value: string, event: InputEvent) => void;

  // Callback when onchange is triggered
  onChange?: (value: string, event: InputEvent) => void;
}

export interface FormFieldInputSignature {
  Args: FormFieldInputArgs;
  Element: HTMLInputElement;
}

export default class FormFieldInput extends Component<FormFieldInputSignature> {
  get type(): string {
    if (typeof this.args.type === 'string') {
      return this.args.type;
    }
    return 'text';
  }

  @action handleOnInput(event: Event): void {
    if (typeof this.args.onInput === 'function') {
      this.args.onInput(
        (event.target as HTMLInputElement).value,
        event as InputEvent
      );
    }
  }

  @action handleOnChange(event: Event): void {
    if (typeof this.args.onChange === 'function') {
      this.args.onChange(
        (event.target as HTMLInputElement).value,
        event as InputEvent
      );
    }
  }

  get classes() {
    const { input } = useStyles();

    return input({
      size: this.args.size
    }).input({
      class: this.args.class
    });
  }

  <template>
    <input
      {{on "input" this.handleOnInput}}
      {{on "change" this.handleOnChange}}
      id={{@id}}
      value={{@value}}
      type={{this.type}}
      class={{this.classes}}
      data-test-id="form-field-input"
      ...attributes
    />
  </template>
}
