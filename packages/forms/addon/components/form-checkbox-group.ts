import Component from '@glimmer/component';
import { action } from '@ember/object';
import { tracked } from '@glimmer/tracking';

interface FormCheckboxGroupArgs {
  label?: string;
  hint?: string;
  hasSubmitted?: boolean;
  hasError?: boolean;
  errors?: string[] | string;
  containerClass?: string;
  isSmall?: boolean;
  isLarge?: boolean;
  isInline?: boolean;

  // Callback when onchange is triggered
  onChange?: (value: unknown, event: Event) => void;
}

export default class FormCheckboxGroup extends Component<
  FormCheckboxGroupArgs
> {
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

  @action handleChange(value: unknown, event: Event): void {
    this.shouldShowErrorFeedback = true;

    if (typeof this.args.onChange === 'function') {
      this.args.onChange(value, event);
    }
  }
}
