import Component from '@glimmer/component';
import { action } from '@ember/object';
import { on } from '@ember/modifier';
import { useStyles } from '@frontile/theme';

export interface FormFieldTextareaArgs {
  id?: string;
  value?: string | number | boolean;
  size?: 'sm' | 'md' | 'lg';
  class?: string;

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

  get classes() {
    const { textarea } = useStyles();

    return textarea({
      size: this.args.size
    }).input({
      class: this.args.class
    });
  }

  <template>
    <textarea
      {{on "input" this.handleOnInput}}
      {{on "change" this.handleOnChange}}
      id={{@id}}
      value={{@value}}
      class={{this.classes}}
      data-test-id="form-field-textarea"
      ...attributes
    >
    </textarea>
  </template>
}
