import Component from '@glimmer/component';
import { action } from '@ember/object';
import { on } from '@ember/modifier';
import useFrontileClass from '@frontile/core/helpers/use-frontile-class';

export interface FormFieldTextareaArgs {
  id?: string;
  value?: string | number | boolean;
  size?: 'sm' | 'lg';

  // Callback when oninput is triggered
  onInput?: (value: string, event: InputEvent) => void;

  // Callback when onchange is triggered
  onChange?: (value: string, event: InputEvent) => void;
}

export interface FormFieldTextareaSignature {
  Args: FormFieldTextareaArgs;
  Element: HTMLTextAreaElement;
}

export default class FormFieldTextarea extends Component<FormFieldTextareaSignature> {
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
    <textarea
      {{on "input" this.handleOnInput}}
      {{on "change" this.handleOnChange}}
      id={{@id}}
      value={{@value}}
      class={{useFrontileClass "form-field-textarea" @size}}
      data-test-id="form-field-textarea"
      ...attributes
    >
    </textarea>
  </template>
}
