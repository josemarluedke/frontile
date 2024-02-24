import Component from '@glimmer/component';
import { useStyles } from '@frontile/theme';

export interface FormFieldFeedbackArgs {
  id?: string;
  isError?: boolean;
  errors?: string[] | string;
  size?: 'sm' | 'md' | 'lg';
  class?: string;
}

export interface FormFieldFeedbackSignature {
  Args: FormFieldFeedbackArgs;
  Element: HTMLDivElement;
  Blocks: {
    default: [];
  };
}

export default class FormFieldFeedback extends Component<FormFieldFeedbackSignature> {
  get isError(): boolean {
    return (
      typeof this.args.errors !== 'undefined' || this.args.isError === true
    );
  }

  get classes() {
    const { formFeedback } = useStyles();

    return formFeedback({
      size: this.args.size,
      intent: this.isError ? 'danger' : 'primary',
      class: this.args.class
    });
  }

  get errorMessage(): string {
    if (!this.args.errors) return '';

    if (typeof this.args.errors === 'string') {
      return this.args.errors;
    } else {
      return this.args.errors.join('; ');
    }
  }

  <template>
    <div
      id={{@id}}
      class={{this.classes}}
      data-test-id="form-field-feedback"
      aria-live={{if this.isError "assertive" "polite"}}
      ...attributes
    >
      {{this.errorMessage}}
      {{yield}}
    </div>
  </template>
}
