import Base, { type BaseArgs, type BaseSignature } from './base';
import { action } from '@ember/object';
import FormCheckbox, {
  type FormCheckboxArgs
} from '@frontile/forms/components/form-checkbox';

export interface ChangesetFormFieldsCheckboxArgs
  extends BaseArgs,
    FormCheckboxArgs {
  _groupName?: string;
  _parentOnChange?: (value: unknown, event: Event) => void;

  onChange: (value: boolean, event: Event) => void;
}

export interface ChangesetFormFieldsCheckboxSignature extends BaseSignature {
  Args: ChangesetFormFieldsCheckboxArgs;
  Element: HTMLInputElement;
  Blocks: {
    default: [];
  };
}

export default class ChangesetFormFieldsCheckbox extends Base<ChangesetFormFieldsCheckboxSignature> {
  get fullFieldName(): string {
    return this.args._groupName
      ? `${this.args._groupName}.${this.args.fieldName}`
      : this.args.fieldName;
  }

  get value(): boolean {
    return this.args.changeset.get(this.fullFieldName);
  }

  get errors(): string[] {
    if (typeof this.args.errors !== 'undefined') {
      return this.args.errors;
    }

    const fieldErrors = this.args.changeset.errors.filter((error) => {
      return error.key === this.fullFieldName;
    });

    return fieldErrors.reduce((errors: string[], error): string[] => {
      if (Array.isArray(error.validation)) {
        const results = [...errors];
        error.validation.forEach((err) => {
          results.push(...err);
        });
        return results;
      } else {
        return [...errors, error.validation];
      }
    }, []);
  }

  @action async validate(): Promise<void> {
    await this.args.changeset.validate(this.fullFieldName);
  }

  @action async handleChange(value: boolean, event: Event): Promise<void> {
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
