import Component from '@glimmer/component';
import { action } from '@ember/object';

interface FormFieldTextareaArgs {
  id?: string;
  size?: 'sm' | 'lg';

  // Callback when oninput is triggered
  onInput?: (value: string, event: InputEvent) => void;

  // Callback when onchange is triggered
  onChange?: (value: string, event: InputEvent) => void;
}

export default class FormFieldTextarea extends Component<FormFieldTextareaArgs> {
  @action handleOnInput(event: InputEvent): void {
    if (typeof this.args.onInput === 'function') {
      this.args.onInput((event.target as HTMLInputElement).value, event);
    }
  }

  @action handleOnChange(event: InputEvent): void {
    if (typeof this.args.onChange === 'function') {
      this.args.onChange((event.target as HTMLInputElement).value, event);
    }
  }
}
