import Component from '@glimmer/component';
import { action } from '@ember/object';
import { tracked } from '@glimmer/tracking';

interface FormInputArgs {
  /**
   * The value to be used in the input.
   * You must also pass `onChange` or `onInput` to update its value.
   */
  value: unknown;

  /**
   * The input type
   * @defaultValue 'text'
   */
  type?: string;

  /** The group label */
  label?: string;
  /** A help text to be displayed */
  hint?: string;
  /** If the form has been submitted, used to force displaying errors */
  hasSubmitted?: boolean;
  /** If has errors */
  hasError?: boolean;
  /** Force displaying errors */
  showError?: boolean;
  /** A list of errors or a single text describing the error */
  errors?: string[] | string;
  /** CSS classes to be added in the container element */
  containerClass?: string;
  /** The size */
  size?: 'sm' | 'lg';

  /** Callback when oninput is triggered */
  onInput?: (value: string, event: InputEvent) => void;

  /** Callback when onchange is triggered */
  onChange?: (value: string, event: InputEvent) => void;

  /** Callback when onfocus is triggered */
  onFocusIn?: (event: FocusEvent) => void;

  /** Callback when onblur is triggered */
  onFocusOut?: (event: FocusEvent) => void;
}

export class FormInputBase extends Component<FormInputArgs> {
  @tracked shouldShowErrorFeedback = false;

  get showErrorFeedback(): boolean {
    if (this.args.hasError === false) {
      return false;
    }

    if (
      (this.args.showError ||
        this.args.hasSubmitted ||
        this.shouldShowErrorFeedback) &&
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

export default class FormInput extends FormInputBase {}
