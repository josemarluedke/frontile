import Component from '@glimmer/component';
import { action } from '@ember/object';
import { tracked } from '@glimmer/tracking';

interface InputTextArgs {
  value: unknown;
  type?: string;
  label?: string;
  hasSubmitted?: boolean;
  hasError?: boolean;
  errors?: string[] | string;
  hasMargin?: boolean;
  isSmall?: boolean;

  // Callback when oninput is triggered
  onInput?: (value: string, event: InputEvent) => void;

  // Callback when onchange is triggered
  onChange?: (value: string, event: InputEvent) => void;

  // Callback when onfocus is triggered
  onFocusIn?: (event: FocusEvent) => void;

  // Callback when onblur is triggered
  onFocusOut?: (event: FocusEvent) => void;
}

export default class InputText extends Component<InputTextArgs> {
  @tracked shouldShowErrorFeedback = false;

  get showErrorFeedback(): boolean {
    if (this.args.hasError === false) {
      return false;
    }

    if (
      (this.args.hasSubmitted || this.shouldShowErrorFeedback) &&
      this.args.errors &&
      this.args.errors.length > 0
    ) {
      return true;
    } else {
      return false;
    }
  }

  get type(): string {
    if (typeof this.args.type === 'string') {
      return this.args.type;
    }
    return 'text';
  }

  @action handleFocusIn(event: FocusEvent): void {
    this.shouldShowErrorFeedback = false;

    if (typeof this.args.onFocusIn === 'function') {
      this.args.onFocusIn(event);
    }
  }

  @action handleFocusOut(event: FocusEvent): void {
    this.shouldShowErrorFeedback = true;

    if (typeof this.args.onFocusOut === 'function') {
      this.args.onFocusOut(event);
    }
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
