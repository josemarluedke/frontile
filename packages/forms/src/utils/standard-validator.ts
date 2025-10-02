import type { StandardSchemaV1 } from '@standard-schema/spec';

/**
 * The issues collection returned by a Standard Schema validation failure.
 */
export type Issues = readonly StandardSchemaV1.Issue[];

/**
 * The return type of a validator function.
 * Resolves to the issues (when validation fails) or undefined
 * (when it succeeds).
 */
export type ValidatorReturn = Promise<Issues | undefined>;

/**
 * A custom validator function.
 * If there are errors, they are returned by the validator as
 * StandardSchemaV1 issues.  If there are no errors, nothing is returned.
 */
export type CustomValidatorFn<Input = unknown> = (
  input: Input
) => ValidatorReturn | Issues | undefined;

/**
 * Provides convenience methods for validating data using Standard Schema.
 * Also supports custom validator functions that return issues in the
 * Standard Schema format.
 *
 * Most of the time you should use `validateAll` or `validateFieldAll` to
 * validate data.  Schema and custom validation are optional arguments
 * to these methods.  This is useful because schema and custom validation
 * must both be optional in the form component, which is the primary use
 * case for this class.
 *
 * Note:  all methods are static, so you do not need to instantiate
 * this class.
 *
 * @see https://standardschema.dev/
 */
class StandardValidator {
  private constructor() {
    throw new Error('StandardValidator is static and cannot be instantiated');
  }

  /**
   * Validates data against the provided standard schema.
   * If there are errors, they are returned.  Otherwise, nothing is returned.
   * This provides a boolean indication of outcome:  if there is a return
   * value, validation failed.  Otherwise, validation succeeded.
   * @see https://standardschema.dev/
   *
   * @example
   * const input = …; // your data to validate
   * const schema = …; // your standard schema
   * const issues = await StandardValidator.validate(input, schema);
   *
   * @param input The input to validate.
   * @param schema The standard schema to validate against.
   * @return The issues if validation failed, otherwise undefined.
   */
  static async validate<I, O>(
    input: I,
    schema: StandardSchemaV1<I, O>
  ): ValidatorReturn {
    const result = await schema['~standard'].validate(input);
    return result.issues;
  }

  /**
   * Validates a single field within the input data using the provided
   * standard schema.  If there are issues related to the specified field,
   * they are returned.  Otherwise, nothing is returned.
   *
   * Note:  because standard schema does not provide a way to validate
   * individual fields, this method filters the issues returned by the
   * schema validation to find those related to the specified field.
   * @see https://standardschema.dev/
   *
   * @param input The input data to validate.
   * @param fieldName The name of the field to validate.
   * @param schema The standard schema to validate against.
   * @returns The issues related to the specified field if validation failed,
   *          otherwise undefined.
   */
  static async validateField<I, O>(
    input: I,
    fieldName: string,
    schema: StandardSchemaV1<I, O>
  ): ValidatorReturn {
    const issues = await StandardValidator.validate(input, schema);
    if (issues) {
      return StandardValidator.filterFieldIssues(issues, fieldName);
    }
  }

  /**
   * Validates input using a custom validator function.
   * If there are errors, they are returned by the validator as
   * StandardSchemaV1 issues. If there are no errors, nothing is returned.
   * @see https://standardschema.dev/
   *
   * @param input The input data to validate.
   * @param customValidator The custom validator function to use.
   * @returns The issues if validation failed, otherwise undefined.
   */
  static async validateCustom<I>(
    input: I,
    customValidator: CustomValidatorFn<I>
  ): ValidatorReturn {
    return await customValidator(input);
  }

  /**
   * Validates a single field within the input data using a custom validator
   * function.  If there are issues related to the specified field, they are
   * returned.  Otherwise, nothing is returned.
   *
   * Note:  because custom validators may return issues for multiple fields,
   * this method filters the issues returned by the custom validator to find
   * those related to the specified field.
   * @see https://standardschema.dev/
   *
   * @param input The input data to validate.
   * @param fieldName The name of the field to validate.
   * @param customValidator The custom validator function to use.
   * @returns The issues related to the specified field if validation failed,
   *          otherwise undefined.
   */
  static async validateFieldCustom<I>(
    input: I,
    fieldName: string,
    customValidator: CustomValidatorFn<I>
  ): ValidatorReturn {
    const issues = await StandardValidator.validateCustom(
      input,
      customValidator
    );
    if (issues) {
      return StandardValidator.filterFieldIssues(issues, fieldName);
    }
  }

  /**
   * Validates input data using both a standard schema and a custom validator
   * function, merging any issues found by either method.  If there are issues,
   * they are returned. Otherwise, nothing is returned.  This method runs both
   * validations in parallel.
   *
   * Note:  `schema` and `customValidator` are both optional.  If either the
   * schema or custom validator is not provided, that validation is skipped.
   * @see https://standardschema.dev/
   *
   * @param input The input data to validate.
   * @param schema Optional standard schema to validate against.
   * @param customValidator Optional custom validator function to use.
   * @returns issues if validation failed, otherwise undefined.
   */
  static async validateAll<I, O>(
    input: I,
    schema?: StandardSchemaV1<I, O>,
    customValidator?: CustomValidatorFn<I>
  ): ValidatorReturn {
    const standardIssues = schema && StandardValidator.validate(input, schema);
    const customIssues =
      customValidator &&
      StandardValidator.validateCustom(input, customValidator);
    const [s, c] = await Promise.all([standardIssues, customIssues]);
    if (s || c) {
      return [...(s ?? []), ...(c ?? [])];
    }
  }

  /**
   * Validates a single field within the input data using both a standard
   * schema and a custom validator function, merging any issues found by
   * either method. If there are issues related to the specified field,
   * they are returned. Otherwise, nothing is returned. This method runs
   * both validations in parallel.
   *
   * Note: `schema` and `customValidator` are both optional. If either the
   * schema or custom validator is not provided, that validation is skipped.
   * @see https://standardschema.dev/
   *
   * @param input The input data to validate.
   * @param fieldName The name of the field to validate.
   * @param schema Optional standard schema to validate against.
   * @param customValidator Optional custom validator function to use.
   * @returns The issues related to the specified field if validation failed,
   *          otherwise undefined.
   */
  static async validateFieldAll<I, O>(
    input: I,
    fieldName: string,
    schema?: StandardSchemaV1<I, O>,
    customValidator?: CustomValidatorFn<I>
  ): ValidatorReturn {
    const standardIssues =
      schema && StandardValidator.validateField(input, fieldName, schema);
    const customIssues =
      customValidator &&
      StandardValidator.validateFieldCustom(input, fieldName, customValidator);
    const [s, c] = await Promise.all([standardIssues, customIssues]);
    if (s || c) {
      return [...(s ?? []), ...(c ?? [])];
    }
  }

  /**
   * Filters issues to those related to the specified field name.
   * Supports both simple field names and dotted notation for nested fields.
   *
   * @param issues The issues to filter.
   * @param fieldName The name of the field to filter by (e.g., "email" or
   *        "profile.contact.email").
   * @returns The issues related to the specified field, or undefined if
   *          there are none.
   */
  static filterFieldIssues(
    issues: Issues,
    fieldName: string
  ): Issues | undefined {
    const fieldParts = fieldName.split('.');

    const fieldIssues = issues.filter((issue) => {
      if (!issue.path) return false;

      // Extract keys from path segments
      const pathKeys = issue.path
        .map((s) => (typeof s === 'object' && 'key' in s ? s.key : s))
        .filter(Boolean);

      // For exact path matching:
      // The paths must be the same length and match exactly
      return (
        pathKeys.length === fieldParts.length &&
        pathKeys.every((key, i) => key === fieldParts[i])
      );
    });

    return fieldIssues.length > 0 ? fieldIssues : undefined;
  }
}

export { StandardValidator };
export default StandardValidator;
