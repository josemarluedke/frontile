import Component from '@glimmer/component';
import { useStyles, type FormFeedbackVariants } from '@frontile/theme';

interface FormFeedbackSignature {
  Args: {
    /**
     * The id of the feedback element, referenced by the control's
     * `aria-describedby`.
     */
    id?: string;

    /**
     * A list of messages or a single message string. An array is joined with `; `.
     */
    messages?: string[] | string;

    /**
     * The intent of the feedback, which also decides whether it is announced
     * assertively (`danger`) or politely.
     *
     * @defaultValue 'danger'
     */
    intent?: FormFeedbackVariants['intent'];

    /**
     * The size of the feedback text.
     *
     * @defaultValue 'md'
     */
    size?: FormFeedbackVariants['size'];

    /**
     * Whether the element is itself an `aria-live` region. Set this to `false`
     * when something else (such as `FormControl`, which keeps a persistent
     * live region in the DOM) already announces the messages, so they are not
     * announced twice.
     *
     * @defaultValue true
     */
    announce?: boolean;

    /**
     * Class names for the feedback element, merged with the theme's.
     */
    class?: string;
  };
  Element: HTMLDivElement;
  Blocks: {
    default: [];
  };
}

/**
 * Renders feedback messages as a single string. An array is joined with `; `.
 *
 * Shared with `FormControl`, whose persistent live region announces the same
 * text, so both render an identical separator.
 *
 * @param messages A list of messages or a single message string.
 * @returns The messages as one string, or an empty string when there are none.
 */
function feedbackMessageText(messages: string[] | string | undefined): string {
  if (!messages) return '';

  return typeof messages === 'string' ? messages : messages.join('; ');
}

class FormFeedback extends Component<FormFeedbackSignature> {
  get isError(): boolean {
    return (
      typeof this.args.messages !== 'undefined' &&
      (this.args.intent === 'danger' || typeof this.args.intent === 'undefined')
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

  get announce(): boolean {
    return this.args.announce !== false;
  }

  get ariaLive(): string | undefined {
    if (!this.announce) {
      return undefined;
    }
    return this.isError ? 'assertive' : 'polite';
  }

  get messageText(): string {
    return feedbackMessageText(this.args.messages);
  }

  <template>
    <div
      id={{@id}}
      class={{this.classes}}
      data-component="form-feedback"
      aria-live={{this.ariaLive}}
      ...attributes
    >
      {{this.messageText}}
      {{yield}}
    </div>
  </template>
}

export { FormFeedback, feedbackMessageText, type FormFeedbackSignature };
export default FormFeedback;
