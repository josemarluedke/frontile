import Base, { BaseArgs } from './base';
import { action } from '@ember/object';

interface Args extends BaseArgs {
  onChange?: (value: unknown, event: Event) => void;
}

export default class ChangesetFormFieldsRadioGroup extends Base<Args> {
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
