import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { hash } from '@ember/helper';
import { on } from '@ember/modifier';
import { dataFrom } from 'form-data-utils';
import { StandardValidator } from '../utils/standard-validator';
import { Field } from './field';

import type { WithBoundArgs } from '@glint/template';
import type { StandardSchemaV1 } from '@standard-schema/spec';
import type { Issues, CustomValidatorFn } from '../utils/standard-validator';

/** The form data as key/value pairs. */
type FormData = ReturnType<typeof dataFrom>;
/** The validation errors for the form, keyed by field name. */
type FormErrors = Record<string, string | string[] | undefined>;

/**
 * The data passed to `onChange` and `onSubmit` callbacks, which is similar
 * to `FormContext` but also includes the form data.
 */
type FormResultData = {
  /** The form data as key/value pairs. */
  data: FormData;
  /** Whether the form is valid (i.e. has no validation errors). */
  isValid: boolean;
  /** Whether the form is invalid (i.e. has validation errors). */
  isInvalid: boolean;
  /** The current form validation errors. */
  errors: FormErrors;
};

/**
 * The context yielded to the default block of the `Form` component.
 */
interface FormContext {
  /** Whether the form is currently submitting. */
  isLoading: boolean;
  /** Whether the form is valid (i.e. has no validation errors). */
  isValid: boolean;
  /** Whether the form is invalid (i.e. has validation errors). */
  isInvalid: boolean;
  /** The current form validation errors. */
  errors: FormErrors;
  /** The `Field` component, with `errors` args bound. */
  Field: WithBoundArgs<typeof Field, 'errors'>;
}

interface FormSignature {
  Element: HTMLFormElement;
  Args: {
    /**
     * The standard schema to validate form data against.
     */
    schema?: StandardSchemaV1<FormData>;
    /**
     * Optional custom validation function.  A custom validator should return
     * an array of Standard Schema issues, or `undefined` if there are none.
     * This function may be async or sync.
     */
    validate?: CustomValidatorFn<FormData>;
    /**
     * Optional callback invoked on input changes within the form.
     * @param result - The current form result data.
     * @param event - The input event that triggered the change.
     * @returns A promise or void.
     */
    onChange?: (result: FormResultData, event: Event) => Promise<void> | void;
    /**
     * Callback invoked on form submission.  If `onSubmit` returns a promise,
     * the form will be marked as `isLoading` until the promise resolves.
     * @param result - The current form result data.
     * @param event - The submit event that triggered the submission.
     * @returns A promise or void.
     */
    onSubmit: (
      result: FormResultData,
      event: SubmitEvent
    ) => Promise<void> | void;
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
 *   @schema={{this.schema}}
 *   @validate={{this.customValidator}}
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

  /** The current form validation errors. */
  @tracked errors: FormErrors = {};

  /** Whether the form is valid (i.e. has no validation errors). */
  get isValid() {
    return Object.keys(this.errors).length === 0;
  }

  /** Whether the form is invalid (i.e. has validation errors). */
  get isInvalid() {
    return !this.isValid;
  }

  /**
   * Validates data against the provided schema using StandardValidator.
   * Updates the `errors` property with any validation errors found.
   *
   * @param data - The form data to validate.
   * @returns A promise that resolves to the validation errors, if any.
   */
  async validate(data: FormData): Promise<FormErrors | undefined> {
    // Run validator and get issues
    const errors = await StandardValidator.validateAll(
      data,
      this.args.schema,
      this.args.validate
    );
    // Convert validator errors to FormErrors
    if (errors) {
      const formErrors = validatorToFormErrors(errors);
      this.errors = formErrors;
      return formErrors;
    }
    // Clear errors if no issues
    this.errors = {};
  }

  buildFormResultData(data: FormData): FormResultData {
    const { isValid, isInvalid, errors } = this;
    return {
      data,
      isValid,
      isInvalid,
      errors
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
      const resultData = this.buildFormResultData(data);
      this.args.onChange(resultData, event);
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
      this.isLoading = true;
      const data = dataFrom(event);
      const errors = await this.validate(data);
      const resultData = this.buildFormResultData(data);
      try {
        if (!errors) {
          // Run `onSubmit` only if there are no validation errors
          await this.args.onSubmit(resultData, event);
        }
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
      {{yield
        (hash
          isLoading=this.isLoading
          isValid=this.isValid
          isInvalid=this.isInvalid
          errors=this.errors
          Field=(component Field errors=this.errors)
        )
        to="default"
      }}
    </form>
  </template>
}

/**
 * Helper function.
 * Converts validation type `Issues` from StandardValidator into a format
 * suitable for the form component, type `FormErrors`.
 *
 * For example, an issue with path `['email']` will be converted
 * to a form error for the field `email`, `{"email": "error message" }`.
 *
 * @param errors - The validation issues to convert.
 * @returns A mapping of field names to their validation error messages.
 */
function validatorToFormErrors(errors: Issues): FormErrors {
  const formErrors: FormErrors = {};

  for (const issue of errors) {
    if (!issue.path || issue.path.length === 0) continue;

    // Extract keys from path segments to build field name
    const pathKeys = issue.path
      .map((s) => (typeof s === 'object' && 'key' in s ? s.key : s))
      .filter(Boolean) as string[];

    const fieldName = pathKeys.join('.');
    const message = issue.message;

    // Add message to the field's errors
    const existing = formErrors[fieldName];
    if (existing === undefined) {
      formErrors[fieldName] = message;
    } else if (Array.isArray(existing)) {
      existing.push(message);
    } else {
      formErrors[fieldName] = [existing, message];
    }
  }

  return formErrors;
}

export {
  Form,
  type FormContext,
  type FormSignature,
  type FormData,
  type FormResultData,
  type FormErrors
};
export default Form;
