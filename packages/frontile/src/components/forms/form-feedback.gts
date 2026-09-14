import Component from '@glimmer/component';
import { cached } from '@glimmer/tracking';
import { useStyles, type FormFeedbackVariants } from '@frontile/theme';
import { renamedArgValue } from '../../-private/deprecated-args';

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
     * The status of the feedback, which also decides whether it is announced
     * assertively (`danger`) or politely.
     *
     * @defaultValue 'danger'
     */
    status?: FormFeedbackVariants['status'];

    /**
     * @deprecated Use `status`. The name changed because this value also
     * decides whether the message is announced assertively.
     */
    intent?: FormFeedbackVariants['status'];

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
  /**
   * Resolved once so `isError` and `classes` agree, and so the deprecation
   * fires once per render rather than per reader.
   */
  @cached
  get status(): FormFeedbackVariants['status'] {
    return renamedArgValue(this.args.status, this.args.intent, {} as const, {
      component: 'FormFeedback',
      from: 'intent',
      to: 'status',
      id: 'frontile.form-feedback.intent'
    });
  }

  /**
   * Drives `aria-live="assertive"`. The default is `danger`, so the ABSENCE
   * of the arg must stay assertive -- a missing value must never quietly
   * downgrade an error announcement to polite.
   */
  get isError(): boolean {
    return (
      typeof this.args.messages !== 'undefined' &&
      (this.status === 'danger' || typeof this.status === 'undefined')
    );
  }

  get classes() {
    const { formFeedback } = useStyles();

    return formFeedback({
      size: this.args.size || 'md',
      status: this.status || 'danger',
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
      data-part="base"
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
