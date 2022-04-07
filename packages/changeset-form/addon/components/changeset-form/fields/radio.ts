import Base, { BaseArgs, BaseSignature } from './base';
import { action } from '@ember/object';

export interface ChangesetFormFieldsRadioArgs extends BaseArgs {
  onChange?: (value: unknown, event: Event) => void;
}

export interface ChangesetFormFieldsRadioSignature extends BaseSignature {
  Args: ChangesetFormFieldsRadioArgs;
  Element: HTMLInputElement;
}

export default class ChangesetFormFieldsRadio extends Base<ChangesetFormFieldsRadioSignature> {
  @action
  async handleChange(value: unknown, event: Event): Promise<void> {
    event.preventDefault();

    this.args.changeset.set(this.args.fieldName, value);
    await this.validate();

    if (typeof this.args.onChange === 'function') {
      this.args.onChange(value, event);
    }
  }
}
