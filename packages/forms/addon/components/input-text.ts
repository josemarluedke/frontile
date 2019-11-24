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

export class InputTextBase extends Component<InputTextArgs> {
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
}

export default class InputText extends InputTextBase {}
