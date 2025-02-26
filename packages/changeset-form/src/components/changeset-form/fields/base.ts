import Component from '@glimmer/component';
import type { BufferedChangeset } from 'ember-changeset/types';
import { assert } from '@ember/debug';
import { action } from '@ember/object';
import { later } from '@ember/runloop';

export interface BaseArgs {
  changeset: BufferedChangeset;
  fieldName: string;
  errors?: string[] | string;
}

export interface BaseSignature {
  Args: BaseArgs;
}

export default class ChangesetFormFieldsBase<
  T extends BaseSignature,
  V = unknown
> extends Component<T> {
  constructor(owner: unknown, args: T['Args']) {
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

  get value(): V {
    return this.args.changeset.get(this.args.fieldName);
  }

  get errors(): string[] {
    if (typeof this.args.errors !== 'undefined') {
      if (typeof this.args.errors === 'string') {
        return [this.args.errors];
      }
      return this.args.errors;
    }

    const fieldErrors = this.args.changeset.errors.filter((error) => {
      return error.key === this.args.fieldName;
    });

    return fieldErrors.reduce((errors: string[], error): string[] => {
      if (Array.isArray(error.validation)) {
        const results = [...errors];
        error.validation.forEach((err) => {
          if (typeof err === 'string') {
            results.push(err);
          } else if (Array.isArray(err)) {
            results.push(...err);
          }
        });
        return results;
      } else {
        return [...errors, error.validation];
      }
    }, []);
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
