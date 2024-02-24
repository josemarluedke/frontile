import Component from '@glimmer/component';
import { useStyles } from '@frontile/theme';

interface FormFeedbackSignature {
  Args: {
    id?: string;
    /*
     * The intent of the feedback
     * @defaultValue 'danger'
     */
    intent?: 'primary' | 'success' | 'danger' | 'warning';

    /*
     * A list of messages or a single message string
     */
    messages?: string[] | string;
    /*
     * @defaultValue 'md'
     */
    size?: 'sm' | 'md' | 'lg';
    class?: string;
  };
  Element: HTMLDivElement;
  Blocks: {
    default: [];
  };
}

class FormFeedback extends Component<FormFeedbackSignature> {
  get isError(): boolean {
    return (
      typeof this.args.messages !== 'undefined' ||
      this.args.intent === 'danger' ||
      typeof this.args.intent === 'undefined'
    );
  }

  get classes() {
    const { formFeedback } = useStyles();

    return formFeedback({
      size: this.args.size || 'md',
      intent: this.args.intent || 'danger',
      class: this.args.class
    });
  }

  get messageText(): string {
    if (!this.args.messages) return '';

    if (typeof this.args.messages === 'string') {
      return this.args.messages;
    } else {
      return this.args.messages.join('; ');
    }
  }

  <template>
    <div
      id={{@id}}
      class={{this.classes}}
      data-component="form-feedback"
      aria-live={{if this.isError "assertive" "polite"}}
      ...attributes
    >
      {{this.messageText}}
      {{yield}}
    </div>
  </template>
}

export { FormFeedback, type FormFeedbackSignature };
export default FormFeedback;
