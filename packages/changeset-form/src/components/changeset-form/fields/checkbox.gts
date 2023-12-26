import Base, {
  type BaseArgs,
  type BaseSignature,
  type ValidationError
} from './base';
import { action } from '@ember/object';
import FormCheckbox from '@frontile/forms/components/form-checkbox';

export interface ChangesetFormFieldsCheckboxArgs extends BaseArgs {
  _groupName?: string;
  _parentOnChange?: (value: unknown, event: Event) => void;

  onChange?: (value: unknown, event: Event) => void;
}

export interface ChangesetFormFieldsCheckboxSignature extends BaseSignature {
  Args: ChangesetFormFieldsCheckboxArgs;
}

export default class ChangesetFormFieldsCheckbox extends Base<ChangesetFormFieldsCheckboxSignature> {
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

  @action async handleChange(value: unknown, event: Event): Promise<void> {
    this.args.changeset.set(this.fullFieldName, value);

    await this.validate();

    if (typeof this.args._parentOnChange === 'function') {
      this.args._parentOnChange(value, event);
    }

    if (typeof this.args.onChange === 'function') {
      this.args.onChange(value, event);
    }
  }

  <template>
    <FormCheckbox
      @onChange={{this.handleChange}}
      @checked={{this.value}}
      @hint={{@hint}}
      @name={{@name}}
      @containerClass={{@containerClass}}
      @size={{@size}}
      ...attributes
    >
      {{#if (has-block)}}
        {{yield}}
      {{else}}
        {{@label}}
      {{/if}}
    </FormCheckbox>
  </template>
}
