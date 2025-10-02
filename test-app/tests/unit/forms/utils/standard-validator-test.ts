import { module, test } from 'qunit';
import { setupTest } from 'ember-qunit';
import { StandardValidator } from '@frontile/forms';
import * as v from 'valibot';

module('Unit | Forms | StandardValidator', function (hooks) {
  setupTest(hooks);

  test('validate data against a schema', async function (assert) {
    assert.expect(5);

    const UserSchema = v.object({
      name: v.string(),
      email: v.pipe(v.string(), v.email()),
      age: v.pipe(v.number(), v.minValue(18))
    });

    const validData = {
      name: 'John Doe',
      email: 'john@example.com',
      age: 25
    };

    const invalidData = {
      name: 'Jane Doe',
      email: 'invalid-email',
      age: 15
    };

    // Assert that validation passes with valid data
    const validResult = await StandardValidator.validate(validData, UserSchema);
    // (this is a little unintuitive as a valid result returns undefined)
    assert.ok(!validResult, 'Validation should pass with valid data');

    // ...and fails with invalid data.
    const invalidResult = await StandardValidator.validate(
      invalidData,
      UserSchema
    );
    // (whereas an invalid result returns an array of issues)
    assert.ok(invalidResult, 'Validation should fail with invalid data');
    assert.ok(invalidResult?.length, 'Should have validation issues');

    // Check that we have issues for email and age
    const emailIssue = invalidResult?.find((issue) =>
      issue.path?.some((p) =>
        typeof p === 'object' && 'key' in p ? p.key === 'email' : p === 'email'
      )
    );
    const ageIssue = invalidResult?.find((issue) =>
      issue.path?.some((p) =>
        typeof p === 'object' && 'key' in p ? p.key === 'age' : p === 'age'
      )
    );

    assert.ok(emailIssue, 'Should have an issue for invalid email');
    assert.ok(ageIssue, 'Should have an issue for age below minimum');
  });

  test('validate works with nested schema fields', async function (assert) {
    assert.expect(3);

    const UserSchema = v.object({
      name: v.string(),
      profile: v.object({
        age: v.pipe(v.number(), v.minValue(18)),
        contact: v.object({
          email: v.pipe(v.string(), v.email())
        })
      })
    });

    const invalidData = {
      name: 'John',
      profile: {
        age: 16,
        contact: {
          email: 'invalid-email'
        }
      }
    };

    const result = await StandardValidator.validate(invalidData, UserSchema);

    assert.ok(result, 'Should have validation issues for nested fields');
    assert.strictEqual(
      result?.length,
      2,
      'Should have 2 issues from nested validation'
    );

    const hasNestedErrors = result?.some(
      (issue) => issue.path && issue.path.length > 1
    );
    assert.ok(hasNestedErrors, 'Should have errors with nested paths');
  });

  test('validateField returns undefined for valid field data', async function (assert) {
    assert.expect(3);
    const UserSchema = v.object({
      name: v.pipe(v.string(), v.minLength(3)),
      email: v.pipe(v.string(), v.email()),
      age: v.pipe(v.number(), v.minValue(18), v.maxValue(100))
    });

    const validData = {
      name: 'John Doe',
      email: 'john@example.com',
      age: 25
    };

    const nameResult = await StandardValidator.validateField(
      validData,
      'name',
      UserSchema
    );
    assert.ok(!nameResult, 'Should return undefined for valid name field');

    const emailResult = await StandardValidator.validateField(
      validData,
      'email',
      UserSchema
    );
    assert.ok(!emailResult, 'Should return undefined for valid email field');

    const ageResult = await StandardValidator.validateField(
      validData,
      'age',
      UserSchema
    );
    assert.ok(!ageResult, 'Should return undefined for valid age field');
  });

  test('validateField returns only specified field errors when multiple fields are invalid', async function (assert) {
    assert.expect(9);
    const UserSchema = v.object({
      name: v.pipe(v.string(), v.minLength(3)),
      email: v.pipe(v.string(), v.email()),
      age: v.pipe(v.number(), v.minValue(18), v.maxValue(100))
    });

    // Data with multiple invalid fields
    const invalidData = {
      name: 'Jo', // Too short (min 3 chars)
      email: 'not-an-email', // Invalid email format
      age: 150 // Too high (max 100)
    };

    // Validate email field - should only get email errors
    const emailResult = await StandardValidator.validateField(
      invalidData,
      'email',
      UserSchema
    );
    assert.ok(emailResult, 'Should have issues for invalid email');
    assert.strictEqual(
      emailResult?.length,
      1,
      'Should have exactly one email issue'
    );
    assert.ok(
      emailResult?.[0]?.path?.some((p) =>
        typeof p === 'object' && 'key' in p ? p.key === 'email' : p === 'email'
      ),
      'Issue should be for email field only'
    );

    // Validate name field - should only get name errors
    const nameResult = await StandardValidator.validateField(
      invalidData,
      'name',
      UserSchema
    );
    assert.ok(nameResult, 'Should have issues for invalid name');
    assert.strictEqual(
      nameResult?.length,
      1,
      'Should have exactly one name issue'
    );
    assert.ok(
      nameResult?.[0]?.path?.some((p) =>
        typeof p === 'object' && 'key' in p ? p.key === 'name' : p === 'name'
      ),
      'Issue should be for name field only'
    );

    // Validate age field - should only get age errors
    const ageResult = await StandardValidator.validateField(
      invalidData,
      'age',
      UserSchema
    );
    assert.ok(ageResult, 'Should have issues for invalid age');
    assert.strictEqual(
      ageResult?.length,
      1,
      'Should have exactly one age issue'
    );
    assert.ok(
      ageResult?.[0]?.path?.some((p) =>
        typeof p === 'object' && 'key' in p ? p.key === 'age' : p === 'age'
      ),
      'Issue should be for age field only'
    );
  });

  test('validateField returns undefined for valid fields even when other fields are invalid', async function (assert) {
    assert.expect(5);
    const UserSchema = v.object({
      name: v.pipe(v.string(), v.minLength(3)),
      email: v.pipe(v.string(), v.email()),
      age: v.pipe(v.number(), v.minValue(18), v.maxValue(100))
    });

    const mixedData = {
      name: 'John Doe', // Valid
      email: 'invalid-email', // Invalid
      age: 150 // Invalid
    };

    // Valid field should return undefined
    const nameResult = await StandardValidator.validateField(
      mixedData,
      'name',
      UserSchema
    );
    assert.ok(
      !nameResult,
      'Should return undefined for valid name field despite other invalid fields'
    );

    // Invalid fields should return issues
    const emailResult = await StandardValidator.validateField(
      mixedData,
      'email',
      UserSchema
    );
    assert.ok(emailResult, 'Should return issues for invalid email field');
    assert.strictEqual(
      emailResult?.length,
      1,
      'Should have exactly one email issue'
    );

    const ageResult = await StandardValidator.validateField(
      mixedData,
      'age',
      UserSchema
    );
    assert.ok(ageResult, 'Should return issues for invalid age field');
    assert.strictEqual(
      ageResult?.length,
      1,
      'Should have exactly one age issue'
    );
  });

  test('validateField works with nested fields using dot notation', async function (assert) {
    assert.expect(4);

    const UserSchema = v.object({
      profile: v.object({
        age: v.pipe(v.number(), v.minValue(18)),
        contact: v.object({
          email: v.pipe(v.string(), v.email()),
          phone: v.pipe(v.string(), v.minLength(10))
        })
      })
    });

    const data = {
      profile: {
        age: 16, // Invalid
        contact: {
          email: 'invalid', // Invalid
          phone: '123' // Invalid
        }
      }
    };

    // Validate nested email field
    const emailResult = await StandardValidator.validateField(
      data,
      'profile.contact.email',
      UserSchema
    );
    assert.ok(emailResult, 'Should have error for invalid nested email');
    assert.strictEqual(
      emailResult?.length,
      1,
      'Should have exactly one email error'
    );

    // Validate nested age field
    const ageResult = await StandardValidator.validateField(
      data,
      'profile.age',
      UserSchema
    );
    assert.ok(ageResult, 'Should have error for invalid nested age');
    assert.strictEqual(
      ageResult?.length,
      1,
      'Should have exactly one age error'
    );
  });

  test('validateCustom works for valid and invalid data', async function (assert) {
    assert.expect(7);
    // Custom validator that checks if age is between 18 and 65
    const ageRangeValidator = async (data: { age: number }) => {
      if (data.age < 18 || data.age > 65) {
        return [
          {
            message: 'Age must be between 18 and 65',
            path: [{ key: 'age' }]
          }
        ];
      }
      return undefined;
    };

    // Test valid data
    const validData = { age: 30 };
    const validResult = await StandardValidator.validateCustom(
      validData,
      ageRangeValidator
    );
    assert.ok(!validResult, 'Should return undefined for valid age');

    // Test invalid data - too young
    const tooYoung = { age: 15 };
    const youngResult = await StandardValidator.validateCustom(
      tooYoung,
      ageRangeValidator
    );
    assert.ok(youngResult, 'Should return issues for age below 18');
    assert.strictEqual(youngResult?.length, 1, 'Should have exactly one issue');
    assert.strictEqual(
      youngResult?.[0]?.message,
      'Age must be between 18 and 65'
    );

    // Test invalid data - too old
    const tooOld = { age: 70 };
    const oldResult = await StandardValidator.validateCustom(
      tooOld,
      ageRangeValidator
    );
    assert.ok(oldResult, 'Should return issues for age above 65');
    assert.strictEqual(oldResult?.length, 1, 'Should have exactly one issue');
    assert.strictEqual(
      oldResult?.[0]?.message,
      'Age must be between 18 and 65'
    );
  });

  test('validateFieldCustom returns only specified field errors', async function (assert) {
    assert.expect(6);
    // Custom validator that returns errors for multiple fields
    const validator = async (data: { username?: string; email?: string }) => {
      const issues = [];

      if (data.username && data.username.length < 3) {
        issues.push({
          message: 'Username too short',
          path: [{ key: 'username' }]
        });
      }

      if (data.email && !data.email.includes('@')) {
        issues.push({
          message: 'Invalid email',
          path: [{ key: 'email' }]
        });
      }

      return issues.length > 0 ? issues : undefined;
    };

    // Data with both fields invalid
    const data = {
      username: 'ab', // Too short
      email: 'notanemail' // Missing @
    };

    // Validate only username field
    const usernameResult = await StandardValidator.validateFieldCustom(
      data,
      'username',
      validator
    );
    assert.ok(usernameResult, 'Should have username issues');
    assert.strictEqual(
      usernameResult?.length,
      1,
      'Should have exactly one issue'
    );
    assert.strictEqual(usernameResult?.[0]?.message, 'Username too short');

    // Validate only email field
    const emailResult = await StandardValidator.validateFieldCustom(
      data,
      'email',
      validator
    );
    assert.ok(emailResult, 'Should have email issues');
    assert.strictEqual(emailResult?.length, 1, 'Should have exactly one issue');
    assert.strictEqual(emailResult?.[0]?.message, 'Invalid email');
  });

  test('validateCustom works with deeply nested field validation', async function (assert) {
    assert.expect(4);

    const customValidator = async (data: {
      user?: {
        profile?: {
          settings?: {
            notifications?: {
              email?: boolean;
              sms?: boolean;
            };
            privacy?: {
              shareProfile?: boolean;
            };
          };
        };
      };
    }) => {
      const issues = [];

      // Validate deeply nested notification settings
      if (data.user?.profile?.settings?.notifications) {
        const notif = data.user.profile.settings.notifications;

        if (!notif.email && !notif.sms) {
          issues.push({
            message: 'At least one notification method must be enabled',
            path: [
              { key: 'user' },
              { key: 'profile' },
              { key: 'settings' },
              { key: 'notifications' }
            ]
          });
        }
      }

      // Validate deeply nested privacy settings
      if (data.user?.profile?.settings?.privacy?.shareProfile === undefined) {
        issues.push({
          message: 'Privacy preference must be set',
          path: [
            { key: 'user' },
            { key: 'profile' },
            { key: 'settings' },
            { key: 'privacy' },
            { key: 'shareProfile' }
          ]
        });
      }

      return issues.length > 0 ? issues : undefined;
    };

    const invalidData = {
      user: {
        profile: {
          settings: {
            notifications: {
              email: false,
              sms: false
            },
            privacy: {}
          }
        }
      }
    };

    const result = await StandardValidator.validateCustom(
      invalidData,
      customValidator
    );

    assert.ok(result, 'Should have validation issues for nested fields');
    assert.strictEqual(result?.length, 2, 'Should have 2 validation issues');

    // Check that all errors have deeply nested paths
    const allDeeplyNested = result?.every(
      (issue) => issue.path && issue.path.length >= 4
    );
    assert.ok(allDeeplyNested, 'All errors should have deeply nested paths');

    // Verify we can filter these nested errors
    if (result) {
      const notificationErrors = StandardValidator.filterFieldIssues(
        result,
        'user.profile.settings.notifications'
      );
      assert.ok(
        notificationErrors?.length === 1,
        'Should filter deeply nested notification errors'
      );
    }
  });

  test('validateFieldCustom works with nested fields using dot notation', async function (assert) {
    assert.expect(3);

    const customValidator = async (data: {
      profile?: {
        age?: number;
        contact?: {
          email?: string;
        };
      };
    }) => {
      const issues = [];

      // Validate nested profile.age field
      if (data.profile?.age && data.profile.age < 21) {
        issues.push({
          message: 'Must be 21 or older',
          path: [{ key: 'profile' }, { key: 'age' }]
        });
      }

      // Validate nested profile.contact.email field
      if (
        data.profile?.contact?.email &&
        !data.profile.contact.email.endsWith('@company.com')
      ) {
        issues.push({
          message: 'Must use company email',
          path: [{ key: 'profile' }, { key: 'contact' }, { key: 'email' }]
        });
      }

      return issues.length > 0 ? issues : undefined;
    };

    const data = {
      profile: {
        age: 18,
        contact: {
          email: 'user@example.com'
        }
      }
    };

    // Validate only nested email field with dot notation
    const emailResult = await StandardValidator.validateFieldCustom(
      data,
      'profile.contact.email',
      customValidator
    );
    assert.ok(emailResult, 'Should have email validation issue');
    assert.strictEqual(
      emailResult?.length,
      1,
      'Should have exactly one email issue'
    );
    assert.strictEqual(emailResult?.[0]?.message, 'Must use company email');
  });

  test('validateAll merges schema and custom validation errors', async function (assert) {
    assert.expect(4);
    // Schema validation
    const schema = v.object({
      email: v.pipe(v.string(), v.email()),
      age: v.pipe(v.number(), v.minValue(18))
    });

    // Custom validation with additional rules
    const customValidator = async (data: { email?: string }) => {
      if (data.email && !data.email.endsWith('@company.com')) {
        return [
          {
            message: 'Must use company email',
            path: [{ key: 'email' }]
          }
        ];
      }
      return undefined;
    };

    // Invalid data that fails both validations
    const data = {
      email: 'invalid', // Fails schema (not valid email format)
      age: 16 // Fails schema (below 18)
    };

    const result = await StandardValidator.validateAll(
      data,
      schema,
      customValidator
    );

    assert.ok(result, 'Should have validation issues');
    assert.strictEqual(
      result?.length,
      3,
      'Should have 3 issues total (2 from schema, 1 from custom)'
    );

    // Verify we have both schema and custom errors
    const hasSchemaError = result?.some((issue) =>
      issue.path?.some((p) =>
        typeof p === 'object' && 'key' in p ? p.key === 'age' : p === 'age'
      )
    );
    const hasCustomError = result?.some(
      (issue) => issue.message === 'Must use company email'
    );

    assert.ok(hasSchemaError, 'Should include schema validation errors');
    assert.ok(hasCustomError, 'Should include custom validation errors');
  });

  test('validateAll works with only custom validator (no schema)', async function (assert) {
    assert.expect(3);

    // Custom validator without a schema
    const customValidator = async (data: {
      username?: string;
      age?: number;
    }) => {
      const issues = [];

      if (data.username && data.username.length < 5) {
        issues.push({
          message: 'Username must be at least 5 characters',
          path: [{ key: 'username' }]
        });
      }

      if (data.age && data.age < 21) {
        issues.push({
          message: 'Must be 21 or older',
          path: [{ key: 'age' }]
        });
      }

      return issues.length > 0 ? issues : undefined;
    };

    // Test data that fails custom validation
    const invalidData = {
      username: 'joe',
      age: 18
    };

    // Validate with only custom validator (no schema)
    const result = await StandardValidator.validateAll(
      invalidData,
      undefined, // No schema provided
      customValidator
    );

    assert.ok(result, 'Should have validation issues from custom validator');
    assert.strictEqual(
      result?.length,
      2,
      'Should have 2 issues from custom validator'
    );

    // Verify the issues are from custom validator
    const messages = result?.map((issue) => issue.message);
    assert.deepEqual(
      messages,
      ['Username must be at least 5 characters', 'Must be 21 or older'],
      'Should have the expected custom validation messages'
    );
  });

  test('validateAll works with only schema (no custom validator)', async function (assert) {
    assert.expect(6);

    const UserSchema = v.object({
      name: v.pipe(v.string(), v.minLength(2)),
      email: v.pipe(v.string(), v.email()),
      age: v.pipe(v.number(), v.minValue(18), v.maxValue(120))
    });

    // Test with valid data
    const validData = {
      name: 'John Doe',
      email: 'john@example.com',
      age: 25
    };

    const validResult = await StandardValidator.validateAll(
      validData,
      UserSchema
      // No custom validator provided
    );

    assert.ok(
      !validResult,
      'Should return undefined for valid data with schema only'
    );

    // Test with invalid data
    const invalidData = {
      name: 'J', // Too short
      email: 'invalid-email', // Invalid format
      age: 16 // Below minimum
    };

    const invalidResult = await StandardValidator.validateAll(
      invalidData,
      UserSchema
      // No custom validator provided
    );

    assert.ok(invalidResult, 'Should have validation issues from schema');
    assert.strictEqual(
      invalidResult?.length,
      3,
      'Should have 3 issues from schema validation'
    );

    // Verify all expected fields have errors
    const fieldErrors = ['name', 'email', 'age'];
    fieldErrors.forEach((field) => {
      const hasFieldError = invalidResult?.some((issue) =>
        issue.path?.some((p) =>
          typeof p === 'object' && 'key' in p ? p.key === field : p === field
        )
      );
      assert.ok(hasFieldError, `Should have error for ${field} field`);
    });
  });

  test('validateAll works with neither schema nor custom validator', async function (assert) {
    assert.expect(1);
    const data = { name: 'John', email: 'invalid' };
    const result = await StandardValidator.validateAll(data);
    assert.ok(
      !result,
      'Should return undefined when no validation is provided'
    );
  });

  test('validateAll works with nested fields', async function (assert) {
    assert.expect(5);

    const schema = v.object({
      user: v.object({
        profile: v.object({
          personal: v.object({
            age: v.pipe(v.number(), v.minValue(18)),
            name: v.pipe(v.string(), v.minLength(2))
          }),
          contact: v.object({
            email: v.pipe(v.string(), v.email()),
            phone: v.pipe(v.string(), v.minLength(10))
          })
        })
      })
    });

    const invalidData = {
      user: {
        profile: {
          personal: {
            age: 16, // Invalid
            name: 'J' // Invalid
          },
          contact: {
            email: 'not-email', // Invalid
            phone: '123' // Invalid
          }
        }
      }
    };

    const result = await StandardValidator.validateAll(invalidData, schema);

    assert.ok(result, 'Should have validation issues');
    assert.strictEqual(result?.length, 4, 'Should have 4 validation errors');

    // Verify each nested field has an error with proper path
    const fields = ['age', 'name', 'email', 'phone'];
    const allFieldsHaveErrors = fields.every((field) =>
      result?.some((issue) =>
        issue.path?.some((p) =>
          typeof p === 'object' && 'key' in p ? p.key === field : p === field
        )
      )
    );
    assert.ok(allFieldsHaveErrors, 'All nested fields should have errors');

    // Check that paths are properly nested (length > 1)
    const allErrorsAreNested = result?.every(
      (issue) => issue.path && issue.path.length > 1
    );
    assert.ok(allErrorsAreNested, 'All errors should have nested paths');

    // Verify we can filter a specific deeply nested field
    if (result) {
      const emailErrors = StandardValidator.filterFieldIssues(
        result,
        'user.profile.contact.email'
      );
      assert.ok(
        emailErrors?.length === 1,
        'Should be able to filter deeply nested field errors'
      );
    }
  });

  test('validateFieldAll merges schema and custom errors for single field only', async function (assert) {
    assert.expect(5);
    // Schema validation
    const schema = v.object({
      email: v.pipe(v.string(), v.email()),
      username: v.pipe(v.string(), v.minLength(3))
    });

    // Custom validator for multiple fields
    const customValidator = async (data: {
      email?: string;
      username?: string;
    }) => {
      const issues = [];

      if (data.email && !data.email.endsWith('@company.com')) {
        issues.push({
          message: 'Must use company email',
          path: [{ key: 'email' }]
        });
      }

      if (data.username && data.username === 'admin') {
        issues.push({
          message: 'Username reserved',
          path: [{ key: 'username' }]
        });
      }

      return issues.length > 0 ? issues : undefined;
    };

    // Data that fails both fields in both validators
    const data = {
      email: 'invalid', // Fails both schema and custom
      username: 'ad' // Fails schema only (too short)
    };

    // Validate only email field - should get email errors from both validators
    const emailResult = await StandardValidator.validateFieldAll(
      data,
      'email',
      schema,
      customValidator
    );

    assert.ok(emailResult, 'Should have email validation issues');
    assert.strictEqual(
      emailResult?.length,
      2,
      'Should have 2 email issues (1 schema + 1 custom)'
    );

    // Verify both types of errors are present for email
    const hasSchemaEmailError = emailResult?.some(
      (issue) =>
        issue.path?.some((p) =>
          typeof p === 'object' && 'key' in p
            ? p.key === 'email'
            : p === 'email'
        ) && !issue.message?.includes('company')
    );
    const hasCustomEmailError = emailResult?.some(
      (issue) => issue.message === 'Must use company email'
    );

    assert.ok(hasSchemaEmailError, 'Should have schema email error');
    assert.ok(hasCustomEmailError, 'Should have custom email error');

    // Verify no username errors are included
    const hasUsernameError = emailResult?.some((issue) =>
      issue.path?.some((p) =>
        typeof p === 'object' && 'key' in p
          ? p.key === 'username'
          : p === 'username'
      )
    );
    assert.notOk(
      hasUsernameError,
      'Should not include username errors when validating email field'
    );
  });

  test('validateFieldAll works with nested fields using dot notation', async function (assert) {
    assert.expect(4);

    // Schema validation for nested fields
    const schema = v.object({
      profile: v.object({
        contact: v.object({
          email: v.pipe(v.string(), v.email()),
          phone: v.pipe(v.string(), v.minLength(10))
        })
      })
    });

    // Custom validator for additional nested field rules
    const customValidator = async (data: {
      profile?: {
        contact?: {
          email?: string;
          phone?: string;
        };
      };
    }) => {
      const issues = [];

      if (
        data.profile?.contact?.email &&
        !data.profile.contact.email.endsWith('@company.com')
      ) {
        issues.push({
          message: 'Must use company email',
          path: [{ key: 'profile' }, { key: 'contact' }, { key: 'email' }]
        });
      }

      if (
        data.profile?.contact?.phone &&
        !data.profile.contact.phone.startsWith('+1')
      ) {
        issues.push({
          message: 'Must be US phone number',
          path: [{ key: 'profile' }, { key: 'contact' }, { key: 'phone' }]
        });
      }

      return issues.length > 0 ? issues : undefined;
    };

    const data = {
      profile: {
        contact: {
          email: 'invalid', // Fails both schema and custom
          phone: '555-1234' // Fails both schema and custom
        }
      }
    };

    // Validate only nested email field - should get errors from both validators
    const emailResult = await StandardValidator.validateFieldAll(
      data,
      'profile.contact.email',
      schema,
      customValidator
    );

    assert.ok(emailResult, 'Should have nested email validation issues');
    assert.strictEqual(
      emailResult?.length,
      2,
      'Should have 2 email issues (1 schema + 1 custom)'
    );

    const hasSchemaError = emailResult?.some(
      (issue) => !issue.message?.includes('company')
    );
    const hasCustomError = emailResult?.some(
      (issue) => issue.message === 'Must use company email'
    );

    assert.ok(hasSchemaError, 'Should have schema validation error for email');
    assert.ok(hasCustomError, 'Should have custom validation error for email');
  });

  test('filterFieldIssues returns only issues for specified field', function (assert) {
    assert.expect(6);
    const issues = [
      { message: 'Invalid email', path: [{ key: 'email' }] },
      { message: 'Name too short', path: [{ key: 'name' }] },
      { message: 'Email required', path: [{ key: 'email' }] },
      { message: 'Age too low', path: [{ key: 'age' }] }
    ];

    // Filter for email issues
    const emailIssues = StandardValidator.filterFieldIssues(issues, 'email');
    assert.strictEqual(emailIssues?.length, 2, 'Should return 2 email issues');
    assert.strictEqual(emailIssues?.[0]?.message, 'Invalid email');
    assert.strictEqual(emailIssues?.[1]?.message, 'Email required');

    // Filter for name issues
    const nameIssues = StandardValidator.filterFieldIssues(issues, 'name');
    assert.strictEqual(nameIssues?.length, 1, 'Should return 1 name issue');
    assert.strictEqual(nameIssues?.[0]?.message, 'Name too short');

    // Filter for non-existent field
    const phoneIssues = StandardValidator.filterFieldIssues(issues, 'phone');
    assert.notOk(
      phoneIssues,
      'Should return undefined for field with no issues'
    );
  });

  test('filterFieldIssues works with nested fields using dot notation', function (assert) {
    assert.expect(5);

    const issues = [
      { message: 'Age too low', path: [{ key: 'profile' }, { key: 'age' }] },
      {
        message: 'Invalid email',
        path: [{ key: 'profile' }, { key: 'contact' }, { key: 'email' }]
      },
      {
        message: 'Phone too short',
        path: [{ key: 'profile' }, { key: 'contact' }, { key: 'phone' }]
      },
      { message: 'Name required', path: [{ key: 'name' }] }
    ];
    // Test filtering nested field with dot notation
    const emailIssues = StandardValidator.filterFieldIssues(
      issues,
      'profile.contact.email'
    );
    assert.ok(emailIssues, 'Should find nested email field');
    assert.strictEqual(
      emailIssues?.length,
      1,
      'Should return exactly one email issue'
    );
    assert.strictEqual(emailIssues?.[0]?.message, 'Invalid email');

    // Test filtering another nested field
    const ageIssues = StandardValidator.filterFieldIssues(
      issues,
      'profile.age'
    );
    assert.ok(ageIssues, 'Should find nested age field');
    assert.strictEqual(ageIssues?.[0]?.message, 'Age too low');
  });

  test('filterFieldIssues handles mixed path segment types correctly', function (assert) {
    assert.expect(4);

    const issues = [
      // Path with mixed segment types: string and object formats
      {
        message: 'Email invalid',
        path: ['profile', { key: 'contact' }, { key: 'email' }]
      },
      {
        message: 'Phone invalid',
        path: [{ key: 'profile' }, 'contact', { key: 'phone' }]
      },
      {
        message: 'Age invalid',
        path: ['user', 'profile', { key: 'age' }]
      },
      {
        message: 'Name invalid',
        path: [{ key: 'user' }, { key: 'name' }]
      }
    ];

    // Test filtering with mixed segment types in path
    const emailIssues = StandardValidator.filterFieldIssues(
      issues,
      'profile.contact.email'
    );
    assert.ok(emailIssues, 'Should find field with mixed segment types');
    assert.strictEqual(
      emailIssues?.length,
      1,
      'Should match exactly one issue'
    );

    const phoneIssues = StandardValidator.filterFieldIssues(
      issues,
      'profile.contact.phone'
    );
    assert.ok(
      phoneIssues,
      'Should find field with different mixed segment pattern'
    );
    assert.strictEqual(phoneIssues?.[0]?.message, 'Phone invalid');
  });

  test('filterFieldIssues correctly distinguishes between similar nested paths', function (assert) {
    assert.expect(6);

    const issues = [
      { message: 'Email 1 invalid', path: [{ key: 'email' }] }, // top-level email
      {
        message: 'Email 2 invalid',
        path: [{ key: 'profile' }, { key: 'email' }]
      }, // profile.email
      {
        message: 'Email 3 invalid',
        path: [{ key: 'profile' }, { key: 'contact' }, { key: 'email' }]
      }, // profile.contact.email
      {
        message: 'Email 4 invalid',
        path: [{ key: 'user' }, { key: 'contact' }, { key: 'email' }]
      }, // user.contact.email
      { message: 'Contact invalid', path: [{ key: 'contact' }] }, // top-level contact
      { message: 'Profile invalid', path: [{ key: 'profile' }] } // top-level profile
    ];

    // Test that simple 'email' only matches top-level email
    const topLevelEmail = StandardValidator.filterFieldIssues(issues, 'email');
    assert.strictEqual(
      topLevelEmail?.length,
      1,
      'Should match only top-level email'
    );
    assert.strictEqual(topLevelEmail?.[0]?.message, 'Email 1 invalid');

    // Test that 'profile.email' only matches that specific path
    const profileEmail = StandardValidator.filterFieldIssues(
      issues,
      'profile.email'
    );
    assert.strictEqual(
      profileEmail?.length,
      1,
      'Should match only profile.email'
    );
    assert.strictEqual(profileEmail?.[0]?.message, 'Email 2 invalid');

    // Test that 'profile.contact.email' only matches that specific nested path
    const nestedEmail = StandardValidator.filterFieldIssues(
      issues,
      'profile.contact.email'
    );
    assert.strictEqual(
      nestedEmail?.length,
      1,
      'Should match only profile.contact.email'
    );
    assert.strictEqual(nestedEmail?.[0]?.message, 'Email 3 invalid');
  });
});
