import Component from '@glimmer/component';
import { BufferedChangeset } from 'ember-changeset/types';
import { assert } from '@ember/debug';
import { action } from '@ember/object';
import { ValidationError } from './base';

interface ChangesetFormFieldsGroupArgs {
  errors?: string[];
  changeset: BufferedChangeset;
  groupName?: string;
  onChange?: (value: unknown, event: Event) => void;
}

export default class ChangesetFormFieldsCheckboxGroup extends Component<ChangesetFormFieldsGroupArgs> {
  constructor(owner: unknown, args: ChangesetFormFieldsGroupArgs) {
    super(owner, args);

    assert(
      '<ChangesetForm> fields must receive @changeset',
      typeof this.args.changeset !== 'undefined'
    );
  }

  get errors(): string[] {
    if (typeof this.args.errors !== 'undefined') {
      return this.args.errors;
    }

    if (!this.args.groupName) {
      return [];
    }

    const fieldErrors = this.args.changeset.errors.filter((error) => {
      return error.key === this.args.groupName;
    });

    return fieldErrors.reduce(
      (errors: string[], error: ValidationError): string[] => {
        return [...errors, ...error.validation];
      },
      []
    );
  }

  @action async validate(): Promise<void> {
    if (this.args.groupName) {
      await this.args.changeset.validate(this.args.groupName);
    }
  }

  @action handleChange(value: unknown, event: Event): void {
    this.validate();

    if (typeof this.args.onChange === 'function') {
      this.args.onChange(value, event);
    }
  }
}
