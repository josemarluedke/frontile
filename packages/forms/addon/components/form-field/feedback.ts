import Component from '@glimmer/component';

interface FormFieldFeedbackArgs {
  isError?: boolean;
  errors?: string[] | string;
  size?: 'sm' | 'lg';
}

export default class FormFieldFeedback extends Component<FormFieldFeedbackArgs> {
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
}
