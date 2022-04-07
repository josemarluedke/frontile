import Base, { BaseArgs, BaseSignature } from './base';
import { action } from '@ember/object';

interface ChangesetFormFieldsRadioGroupArgs extends BaseArgs {
  onChange?: (value: unknown, event: Event) => void;
}

interface ChangesetFormFieldsRadioGroupSignature extends BaseSignature {
  Args: ChangesetFormFieldsRadioGroupArgs;
}

export default class ChangesetFormFieldsRadioGroup extends Base<ChangesetFormFieldsRadioGroupSignature> {
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
