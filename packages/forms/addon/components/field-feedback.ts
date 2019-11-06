import Component from '@glimmer/component';

interface FieldFeedbackArgs {
  isError?: boolean;
  errors?: string[] | string;
}

export default class FieldFeedback extends Component<FieldFeedbackArgs> {
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
