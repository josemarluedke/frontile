import Base, { BaseArgs } from './base';
import { action } from '@ember/object';

interface ChangesetFormFieldsRadioArgs extends BaseArgs {
  onChange?: (value: unknown, event: Event) => void;
}

export default class ChangesetFormFieldsRadio extends Base<
  ChangesetFormFieldsRadioArgs
> {
  @action handleChange(value: unknown, event: Event): void {
    event.preventDefault();

    this.args.changeset.set(this.args.fieldName, value);
    this.validate();

    if (typeof this.args.onChange === 'function') {
      this.args.onChange(value, event);
    }
  }
}
