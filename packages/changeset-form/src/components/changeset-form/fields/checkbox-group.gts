import Component from '@glimmer/component';
import { assert } from '@ember/debug';
import { action } from '@ember/object';
import ChangesetFormFieldsCheckbox from './checkbox';
import FormCheckboxGroup, {
  type FormCheckboxGroupArgs
} from '@frontile/forms-legacy/components/form-checkbox-group';
import type { BaseArgs, BaseSignature } from './base';
import type { BufferedChangeset } from 'ember-changeset/types';
import type { WithBoundArgs } from '@glint/template';
import type Owner from '@ember/owner';

export interface ChangesetFormFieldsGroupArgs
  extends BaseArgs,
    FormCheckboxGroupArgs {
  errors?: string[];
  changeset: BufferedChangeset;
  groupName?: string;
  onChange?: (value: unknown, event: Event) => void;
}

export interface ChangesetFormFieldsCheckboxGroupSignature
  extends BaseSignature {
  Args: ChangesetFormFieldsGroupArgs;
  Blocks: {
    default: [
      checkbox: WithBoundArgs<
        typeof ChangesetFormFieldsCheckbox,
        '_groupName'
      > &
        WithBoundArgs<typeof ChangesetFormFieldsCheckbox, '_parentOnChange'> &
        WithBoundArgs<typeof ChangesetFormFieldsCheckbox, 'changeset'> &
        WithBoundArgs<typeof ChangesetFormFieldsCheckbox, 'size'>
    ];
  };
  Element: HTMLDivElement;
}

export default class ChangesetFormFieldsCheckboxGroup extends Component<ChangesetFormFieldsCheckboxGroupSignature> {
  constructor(owner: Owner, args: ChangesetFormFieldsGroupArgs) {
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

  <template>
    <FormCheckboxGroup
      @onChange={{this.handleChange}}
      @errors={{this.errors}}
      @label={{@label}}
      @hint={{@hint}}
      @hasError={{@hasError}}
      @showError={{@showError}}
      @hasSubmitted={{@hasSubmitted}}
      @containerClass={{@containerClass}}
      @size={{@size}}
      @isInline={{@isInline}}
      ...attributes
      as |_ api|
    >
      {{yield
        (component
          ChangesetFormFieldsCheckbox
          _groupName=@groupName
          _parentOnChange=api.onChange
          changeset=@changeset
          size=@size
        )
      }}
    </FormCheckboxGroup>
  </template>
}
