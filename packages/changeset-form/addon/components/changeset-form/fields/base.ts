import Component from '@glimmer/component';
import { BufferedChangeset } from 'ember-changeset/types';
import { assert } from '@ember/debug';
import { action } from '@ember/object';
import { later } from '@ember/runloop';

export interface BaseArgs {
  changeset: BufferedChangeset;
  fieldName: string;
  errors?: string[];
}

export interface ValidationError {
  key: string;
  value: unknown;
  validation: string[] | string;
}

export default class ChangesetFormFieldsBase<
  T extends BaseArgs
> extends Component<T> {
  constructor(owner: unknown, args: T) {
    super(owner, args);

    assert(
      '<ChangesetForm> fields must receive @changeset',
      typeof this.args.changeset !== 'undefined'
    );

    assert(
      '<ChangesetForm> fields must receive @fieldName',
      typeof this.args.fieldName !== 'undefined'
    );
  }

  get value(): unknown {
    return this.args.changeset.get(this.args.fieldName);
  }

  get errors(): string[] {
    if (typeof this.args.errors !== 'undefined') {
      return this.args.errors;
    }

    const fieldErrors = this.args.changeset.errors.filter((error) => {
      return error.key === this.args.fieldName;
    });

    return fieldErrors.reduce(
      (errors: string[], error: ValidationError): string[] => {
        if (Array.isArray(error.validation)) {
          return [...errors, ...error.validation];
        } else {
          return [...errors, error.validation];
        }
      },
      []
    );
  }

  @action
  async validate(): Promise<void> {
    later(
      this,
      () => {
        this.args.changeset.validate(this.args.fieldName);
      },
      1
    );
  }
}
