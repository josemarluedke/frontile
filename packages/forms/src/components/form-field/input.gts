import Component from '@glimmer/component';
import { action } from '@ember/object';
import { on } from '@ember/modifier';
import useFrontileClass from '@frontile/core/helpers/use-frontile-class';

export interface FormFieldInputArgs {
  id?: string;
  type?: string;
  size?: 'sm' | 'lg';
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

  <template>
    <input
      {{on "input" this.handleOnInput}}
      {{on "change" this.handleOnChange}}
      id={{@id}}
      value={{@value}}
      type={{this.type}}
      class={{useFrontileClass "form-field-input" @size}}
      data-test-id="form-field-input"
      ...attributes
    />
  </template>
}
