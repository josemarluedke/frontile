import Component from '@glimmer/component';
import useFrontileClass from '@frontile/core/helpers/use-frontile-class';

export interface FormFieldFeedbackArgs {
  id?: string;
  isError?: boolean;
  errors?: string[] | string;
  size?: 'sm' | 'lg';
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
      class={{useFrontileClass
        "form-field-feedback"
        @size
        (if this.isError "error")
      }}
      data-test-id="form-field-feedback"
      aria-live={{if this.isError "assertive" "polite"}}
      ...attributes
    >
      {{this.errorMessage}}
      {{yield}}
    </div>
  </template>
}
