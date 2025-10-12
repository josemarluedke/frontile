import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { hash } from '@ember/helper';
import { on } from '@ember/modifier';
import { modifier } from 'ember-modifier';
import { dataFrom } from 'form-data-utils';
import { StandardValidator } from '../utils/standard-validator';
import {
  flattenData,
  unflattenData,
  hasNestedData,
  deepEqual
} from '../utils/nested-data';
import { Field } from './field';

import type { WithBoundArgs } from '@glint/template';
import type { StandardSchemaV1 } from '@standard-schema/spec';
import type { Issues, CustomValidatorFn } from '../utils/standard-validator';
import type Owner from '@ember/owner';

/** The form data as key/value pairs. */
type FormDataCompiled = ReturnType<typeof dataFrom>;
/** The validation errors for the form, keyed by field name. */
type FormErrors = Record<string, string | string[] | undefined>;

/**
 * The data passed to `onChange` and `onSubmit` callbacks, which is similar
 * to `FormContext` but also includes the form data.
 */
type FormResultData<T = FormDataCompiled> = {
  /** The form data as key/value pairs. */
  data: T;
  /** Whether the form is valid (i.e. has no validation errors). */
  isValid: boolean;
  /** Whether the form is invalid (i.e. has validation errors). */
  isInvalid: boolean;
  /** The current form validation errors. */
  errors: FormErrors;
  /**
   * The set of fields that have changed from their initial values.
   * For flat data structures: contains top-level keys (e.g., "firstName", "email")
   * For nested data structures: contains dotted paths (e.g., "user.name.first", "profile.email")
   */
  dirty: Set<string>;
};

/**
 * The context yielded to the default block of the `Form` component.
 */
interface FormContext<T = FormDataCompiled> {
  /** The form data as key/value pairs. */
  data?: T;
  /** Whether the form is currently submitting. */
  isLoading: boolean;
  /** Whether the form is valid (i.e. has no validation errors). */
  isValid: boolean;
  /** Whether the form is invalid (i.e. has validation errors). */
  isInvalid: boolean;
  /** The current form validation errors. */
  errors: FormErrors;
  /**
   * The set of fields that have changed from their initial values.
   * For flat data structures: contains top-level keys (e.g., "firstName", "email")
   * For nested data structures: contains dotted paths (e.g., "user.name.first", "profile.email")
   */
  dirty: Set<string>;
  /**
   * Resets the form to its initial state.
   * Clears all form fields, validation errors, and dirty tracking.
   */
  reset: () => void;
  /** The `Field` component, with args bound. */
  Field: WithBoundArgs<
    typeof Field,
    'errors' | 'formData' | 'disabled' | 'validateOn' | 'validateField'
  >;
}

interface FormSignature<T = FormDataCompiled> {
  Element: HTMLFormElement;
  Args: {
    /**
     * The standard schema to validate form data against.
     */
    schema?: StandardSchemaV1<T>;
    /**
     * Optional custom validation function.  A custom validator should return
     * an array of Standard Schema issues, or `undefined` if there are none.
     * This function may be async or sync.
     */
    validate?: CustomValidatorFn<T>;
    /**
     * When to run validation.
     */
    validateOn?: ('change' | 'submit')[];
    /**
     * The initial form data as key/value pairs.
     * This is primarily useful for setting default values in the form.
     * This object receives changes as the user interacts with the form.
     */
    data?: T;
    /**
     * Whether the entire form and all its fields should be disabled.  This only
     * applies when using the yielded `Field` component.
     */
    disabled?: boolean;
    /**
     * Optional callback invoked on input changes within the form.
     * @param result - The current form result data.
     * @param event - The input event that triggered the change.
     * @returns A promise or void.
     */
    onChange?: (
      result: FormResultData<T>,
      event: Event
    ) => Promise<void> | void;
    /**
     * Callback invoked on form submission.  If `onSubmit` returns a promise,
     * the form will be marked as `isLoading` until the promise resolves.
     * @param result - The current form result data.
     * @param event - The submit event that triggered the submission.
     * @returns A promise or void.
     */
    onSubmit: (
      result: FormResultData<T>,
      event: SubmitEvent
    ) => Promise<void> | void;
    /**
     * Optional callback invoked when validation errors occur on form submission.
     * @param errors - The validation errors found.
     * @param data - The form data that was validated.
     * @param event - The submit event that triggered the validation.
     * @returns A promise or void.
     */
    onError?: (
      errors: FormErrors,
      data: T,
      event: SubmitEvent
    ) => Promise<void> | void;
  };
  Blocks: {
    default: [FormContext<T>];
  };
}

/**
 * A form component that handles form submissions and input changes.
 *
 * @example
 * ```hbs
 * <Form
 *   @data={{this.formData}}
 *   @schema={{this.schema}}
 *   @validate={{this.customValidator}}
 *   @onSubmit={{this.onSubmit}}
 *   @onChange={{this.onChange}}
 * as |form|
 * >
 *   <form.Field name="firstName" as |field|>
 *     <field.Input />
 *   </form.Field>
 *   <form.Field name="lastName" as |field|>
 *     <field.Input />
 *   </form.Field>
 *   <button type="submit" disabled={{form.isLoading}}>
 *     {{#if form.isLoading}}Submitting...{{else}}Submit{{/if}}
 *   </button>
 * </Form>
 * ```
 */
class Form<T = FormDataCompiled> extends Component<FormSignature<T>> {
  /** Whether the form is currently submitting. */
  @tracked isLoading = false;

  /** The current form validation errors. */
  @tracked errors: FormErrors = {};

  /** The current uncontrolled form data. */
  @tracked uncontrolledData?: T;

  /**
   * Flattened snapshot of initial data for dirty field comparison.
   * Stored in flattened form regardless of whether source data is nested or flat.
   */
  @tracked initialDataSnapshot?: Record<string, unknown>;

  /**
   * Flag indicating whether the form data has a nested structure.
   * Set once in constructor based on initial data.
   */
  isNestedStructure = false;

  /**
   * The set of fields that have changed from their initial values.
   * For flat data structures: contains top-level keys (e.g., "firstName", "email")
   * For nested data structures: contains dotted paths (e.g., "user.name.first", "profile.email")
   */
  @tracked dirty: Set<string> = new Set();

  /** Reference to the form element. */
  element?: HTMLFormElement;

  /**
   * Creates a new instance of the Form component.
   * Initializes internal state based on provided args.
   * @param owner - The owner of the component.
   * @param args - The arguments passed to the component.
   */
  constructor(owner: Owner, args: FormSignature<T>['Args']) {
    super(owner, args);
    // Create copy of initial data
    if (args.data) {
      // Determine structure type once
      this.isNestedStructure = hasNestedData(
        args.data as Record<string, unknown>
      );

      // Store flattened snapshot for dirty tracking
      this.initialDataSnapshot = this.isNestedStructure
        ? flattenData(args.data as Record<string, unknown>)
        : { ...(args.data as Record<string, unknown>) };

      // Keep uncontrolled data in original structure
      this.uncontrolledData = { ...args.data };
    }
  }

  /** Whether the form is valid (i.e. has no validation errors). */
  get isValid() {
    return Object.keys(this.errors).length === 0;
  }

  /** Whether the form is invalid (i.e. has validation errors). */
  get isInvalid() {
    return !this.isValid;
  }

  /** Whether the form is controlled (`onChange` is provided). */
  get isControlled(): boolean {
    return !!this.args.onChange;
  }

  /** The events on which validation should run. */
  get validateOn(): ('change' | 'submit')[] {
    return this.args.validateOn ?? ['change', 'submit'];
  }

  /** Whether validation should run on field change. */
  get validateOnChange(): boolean {
    return this.validateOn.includes('change');
  }

  /** Whether validation should run on form submission. */
  get validateOnSubmit(): boolean {
    return this.validateOn.includes('submit');
  }

  get fieldValidateOn(): 'change'[] {
    const v: 'change'[] = [];
    if (this.validateOnChange) {
      v.push('change');
    }
    return v;
  }

  /** The current form data, from args if controlled, or internal state if uncontrolled. */
  get currentData(): T | undefined {
    if (this.isControlled) {
      return this.args.data;
    }
    return this.uncontrolledData;
  }

  /**
   * Flattens data if the form has nested structure, otherwise returns as-is.
   * Helper method to consolidate flatten logic.
   *
   * @param data - The form data to flatten if needed.
   * @returns Flattened data if nested, otherwise the data as-is.
   */
  private flattenIfNeeded(data: T): Record<string, unknown> {
    return this.isNestedStructure
      ? flattenData(data as Record<string, unknown>)
      : (data as Record<string, unknown>);
  }

  /**
   * Validates data against the provided schema using StandardValidator.
   * Updates the `errors` property with any validation errors found.
   *
   * @param data - The form data to validate.
   * @returns A promise that resolves to the validation errors, if any.
   */
  async validate(data: T): Promise<FormErrors | undefined> {
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

  /**
   * Validates a single field against the provided schema using
   * StandardValidator.  Updates the `errors` property with any validation
   * errors found for the field.  If the field had previous errors but
   * is now valid, those errors are cleared.
   *
   * @param data - The form data to validate against.
   * @param name - The name of the field to validate.
   * @returns A promise that resolves to errors for the field, if any.
   */
  @action
  async validateField(data: T, name: string): Promise<FormErrors | undefined> {
    if (!this.args.schema && !this.args.validate) {
      return;
    }
    // Run validator and get issues
    const errors = await StandardValidator.validateFieldAll(
      data,
      name,
      this.args.schema,
      this.args.validate
    );
    // Convert validator errors to FormErrors
    if (errors) {
      const formErrors = validatorToFormErrors(errors);
      if (formErrors[name]) {
        // Merge with existing errors immutably
        this.errors = { ...this.errors, [name]: formErrors[name] };
      }
      return { [name]: formErrors[name] };
    }
    // Clear field error if no issues
    // Remove field error using immutable pattern:
    // 1. Use destructuring to extract the field we want to remove
    //    (assigned to '_' since unused)
    // 2. Capture all remaining fields in 'rest' using the spread operator
    // 3. Reassign this.errors to the 'rest' object, effectively removing
    //    the field
    // This approach maintains immutability by creating a new object rather than
    // mutating the existing errors object with 'delete'
    if (this.errors[name]) {
      const { [name]: _, ...rest } = this.errors;
      this.errors = rest;
    }
  }

  /**
   * Computes which fields have changed from their initial values.
   * Uses deep comparison for consistency across flat and nested structures.
   * This is a pure function with no side effects.
   *
   * @param data - The current form data.
   * @returns A set of field names that have changed.
   */
  computeDirtyFields(data: T): Set<string> {
    const dirty = new Set<string>();

    if (!this.initialDataSnapshot) {
      return dirty;
    }

    // Flatten current data to same representation as snapshot
    const currentFlat = this.flattenIfNeeded(data);

    // Compare all keys in current data
    for (const key in currentFlat) {
      if (!deepEqual(currentFlat[key], this.initialDataSnapshot[key])) {
        dirty.add(key);
      }
    }

    // Check for keys in initial data that are missing in current data
    for (const key in this.initialDataSnapshot) {
      if (
        !(key in currentFlat) &&
        this.initialDataSnapshot[key] !== undefined
      ) {
        dirty.add(key);
      }
    }

    return dirty;
  }

  /**
   * Builds the form result data object to pass to callbacks.
   * Also updates the dirty state as a side effect.
   *
   * @param data - The current form data.
   * @returns The form result data object.
   */
  buildFormResultData(data: T): FormResultData<T> {
    const { isValid, isInvalid, errors } = this;
    const dirty = this.computeDirtyFields(data);
    this.dirty = dirty; // Update tracked state
    return {
      data,
      isValid,
      isInvalid,
      errors,
      dirty
    };
  }

  /**
   * Handles the `input` event on the form element.
   * Calls the `onChange` callback with the current form data if provided.
   * Handles nested data by unflattening dotted field names.
   */
  @action
  handleInput(event: Event) {
    const form = event.currentTarget;
    if (form instanceof HTMLFormElement) {
      let data = dataFrom(event) as T;

      // If initial data had nested structure, unflatten the form data
      if (this.isNestedStructure) {
        data = unflattenData(data as Record<string, unknown>) as T;
      }

      const resultData = this.buildFormResultData(data);
      this.uncontrolledData = data;
      this.args.onChange?.(resultData, event);
    }
  }

  /**
   * Handles the `submit` event on the form element.
   * Prevents the default form submission and calls the `onSubmit` callback
   * with the current form data. Manages the `isLoading` state during the
   * submission process. Handles nested data by unflattening dotted field names.
   */
  @action
  async handleSubmit(event: SubmitEvent) {
    event.preventDefault();
    const form = event.currentTarget;
    if (form instanceof HTMLFormElement) {
      this.isLoading = true;
      let data = dataFrom(event) as T;

      // If initial data had nested structure, unflatten the form data
      if (this.isNestedStructure) {
        data = unflattenData(data as Record<string, unknown>) as T;
      }

      let errors: FormErrors | undefined;
      if (this.validateOnSubmit) {
        errors = await this.validate(data);
      }

      const resultData = this.buildFormResultData(data);
      this.uncontrolledData = data;
      try {
        if (errors && this.args.onError) {
          // Call onError handler when there are validation errors
          await this.args.onError(errors, data, event);
        } else if (!errors && this.args.onSubmit) {
          // Run `onSubmit` if validation was skipped OR if validation passed
          await this.args.onSubmit(resultData, event);
          // Update snapshot on successful submit (new baseline)
          this.initialDataSnapshot = this.flattenIfNeeded(data);
          // Clear dirty state since we've updated the baseline
          this.dirty = new Set();
        }
      } finally {
        this.isLoading = false;
      }
    }
  }

  /**
   * Modifier to capture the form element reference.
   */
  captureElement = modifier((element: HTMLFormElement) => {
    this.element = element;
  });

  /**
   * Resets the form to its initial state.
   * This method:
   * 1. Calls the native form reset() to clear all form controls
   * 2. Restores data from the initial snapshot
   * 3. Clears validation errors
   * 4. Clears dirty state
   *
   * For controlled forms, this triggers onChange with the initial data.
   * For uncontrolled forms, this updates the internal state.
   */
  @action
  reset() {
    if (!this.element) {
      return;
    }

    this.element.reset();

    // Clear state
    this.errors = {};
    this.dirty = new Set();

    // Restore initial data
    if (this.initialDataSnapshot) {
      // Unflatten data if it was nested
      const restoredData = this.isNestedStructure
        ? (unflattenData(this.initialDataSnapshot) as T)
        : ({ ...this.initialDataSnapshot } as T);

      // For controlled forms, call onChange to let parent update state
      if (this.isControlled && this.args.onChange) {
        const resultData = this.buildFormResultData(restoredData);

        // Create a synthetic event with the form element as currentTarget
        // This matches the structure expected by handleInput
        const syntheticEvent = new Event('input', { bubbles: true });
        Object.defineProperty(syntheticEvent, 'currentTarget', {
          writable: false,
          value: this.element
        });

        this.args.onChange(resultData, syntheticEvent);
      } else {
        // For uncontrolled forms, update internal state
        this.uncontrolledData = restoredData;
      }
    } else {
      // No initial data, just clear uncontrolled data
      this.uncontrolledData = undefined;
    }
  }

  <template>
    {{! @glint-nocheck component generics (field) trigger:  type instantiation is excessively deep and possibly infinite }}
    <form
      {{this.captureElement}}
      {{on "input" this.handleInput}}
      {{on "submit" this.handleSubmit}}
      ...attributes
    >
      {{yield
        (hash
          data=this.currentData
          isLoading=this.isLoading
          isValid=this.isValid
          isInvalid=this.isInvalid
          errors=this.errors
          dirty=this.dirty
          reset=this.reset
          Field=(component
            Field
            errors=this.errors
            formData=this.currentData
            disabled=@disabled
            validateOn=this.fieldValidateOn
            validateField=this.validateField
          )
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
  type FormDataCompiled,
  type FormResultData,
  type FormErrors
};
export default Form;
