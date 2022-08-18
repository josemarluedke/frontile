import Component from '@glimmer/component';
import { action } from '@ember/object';
import { tracked } from '@glimmer/tracking';
import FormRadio from './form-radio';

export interface FormRadioGroupArgs {
  value: unknown;
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
  /** If the Checkbox should be in one line */
  isInline?: boolean;

  /** Default callback added to the yielded FormRadio component, called when onchange is triggered */
  onChange?: (value: unknown, event: Event) => void;
}

export interface FormRadioGroupSignature {
  Args: FormRadioGroupArgs;
  Blocks: {
    default: [radio: FormRadio];
  };
  Element: HTMLDivElement;
}

export default class FormRadioGroup extends Component<FormRadioGroupSignature> {
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

  @action handleChange(value: unknown, event: Event): void {
    this.shouldShowErrorFeedback = true;

    if (typeof this.args.onChange === 'function') {
      this.args.onChange(value, event);
    }
  }
}
