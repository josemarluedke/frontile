import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { on } from '@ember/modifier';
import { dataFrom } from 'form-data-utils';

type FormResultData = ReturnType<typeof dataFrom>;

/**
 * The context yielded to the default block of the `Form` component.
 */
interface FormContext {
  /** Whether the form is currently submitting. */
  isLoading: boolean;
}

interface FormSignature {
  Element: HTMLFormElement;
  Args: {
    /**
     * Optional callback invoked on input changes within the form.
     */
    onChange?: (data: FormResultData, event: Event) => void;
    /**
     * Callback invoked on form submission.
     */
    onSubmit: (
      data: FormResultData,
      event: SubmitEvent
    ) => void | Promise<void>;
  };
  Blocks: {
    default: [FormContext];
  };
}

/**
 * A form component that handles form submissions and input changes.
 *
 * @example
 * ```hbs
 * <Form
 *   @onSubmit={{this.onSubmit}}
 *   @onChange={{this.onChange}}
 * as |form|
 * >
 *   <input name="firstName" />
 *   <input name="lastName" />
 *   <button type="submit" disabled={{form.isLoading}}>
 *     {{#if form.isLoading}}Submitting...{{else}}Submit{{/if}}
 *   </button>
 * </Form>
 * ```
 */
class Form extends Component<FormSignature> {
  /** Whether the form is currently submitting. */
  @tracked isLoading = false;

  /**
   * The context yielded to the default block of the `Form` component.
   */
  get context(): FormContext {
    return {
      isLoading: this.isLoading
    };
  }

  /**
   * Handles the `input` event on the form element.
   * Calls the `onChange` callback with the current form data if provided.
   */
  @action
  handleInput(event: Event) {
    const form = event.currentTarget;
    if (form instanceof HTMLFormElement && this.args.onChange) {
      const data = dataFrom(event);
      this.args.onChange(data, event);
    }
  }

  /**
   * Handles the `submit` event on the form element.
   * Prevents the default form submission and calls the `onSubmit` callback
   * with the current form data. Manages the `isLoading` state during the
   * submission process.
   */
  @action
  async handleSubmit(event: SubmitEvent) {
    event.preventDefault();
    const form = event.currentTarget;
    if (form instanceof HTMLFormElement && this.args.onSubmit) {
      const data = dataFrom(event);
      this.isLoading = true;
      try {
        await this.args.onSubmit(data, event);
      } finally {
        this.isLoading = false;
      }
    }
  }

  <template>
    <form
      {{on "input" this.handleInput}}
      {{on "submit" this.handleSubmit}}
      ...attributes
    >
      {{yield this.context}}
    </form>
  </template>
}

export { Form, type FormContext, type FormSignature, type FormResultData };
export default Form;
