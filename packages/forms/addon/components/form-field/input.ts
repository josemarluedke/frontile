import Component from '@glimmer/component';
import { action } from '@ember/object';

interface FormFieldInputSignature {
  Args: {
    id?: string;
    type?: string;
    size?: 'sm' | 'lg';

    // Callback when oninput is triggered
    onInput?: (value: string, event: InputEvent) => void;

    // Callback when onchange is triggered
    onChange?: (value: string, event: InputEvent) => void;
  };
  Element: HTMLInputElement;
}

export default class FormFieldInput extends Component<FormFieldInputSignature> {
  get type(): string {
    if (typeof this.args.type === 'string') {
      return this.args.type;
    }
    return 'text';
  }

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
