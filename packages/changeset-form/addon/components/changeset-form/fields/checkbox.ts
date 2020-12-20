import Base, { BaseArgs, ValidationError } from './base';
import { action } from '@ember/object';

interface ChangesetFormFieldsCheckboxArgs extends BaseArgs {
  _groupName?: string;
  _parentOnChange?: (value: unknown, event: Event) => void;

  onChange?: (value: unknown, event: Event) => void;
}

export default class ChangesetFormFieldsCheckbox extends Base<ChangesetFormFieldsCheckboxArgs> {
  get fullFieldName(): string {
    return this.args._groupName
      ? `${this.args._groupName}.${this.args.fieldName}`
      : this.args.fieldName;
  }

  get value(): unknown {
    return this.args.changeset.get(this.fullFieldName);
  }

  get errors(): string[] {
    if (typeof this.args.errors !== 'undefined') {
      return this.args.errors;
    }

    const fieldErrors = this.args.changeset.errors.filter((error) => {
      return error.key === this.fullFieldName;
    });

    return fieldErrors.reduce(
      (errors: string[], error: ValidationError): string[] => {
        return [...errors, ...error.validation];
      },
      []
    );
  }

  @action async validate(): Promise<void> {
    await this.args.changeset.validate(this.fullFieldName);
  }

  @action handleChange(value: unknown, event: Event): void {
    this.args.changeset.set(this.fullFieldName, value);

    this.validate();

    if (typeof this.args._parentOnChange === 'function') {
      this.args._parentOnChange(value, event);
    }

    if (typeof this.args.onChange === 'function') {
      this.args.onChange(value, event);
    }
  }
}
