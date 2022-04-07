import Base, { BaseArgs, BaseSignature } from './base';
import { action } from '@ember/object';
import { Select } from 'ember-power-select/addon/components/power-select';

interface ChangesetFormFieldsSelectArgs extends BaseArgs {
  onChange?: (selection: unknown, select: Select, event?: Event) => void;
  onFocusOut?: (select: Select, event: FocusEvent) => void;
  onClose?: (select: Select, event: Event) => void;
}

interface ChangesetFormFieldsSelectSignature extends BaseSignature {
  Args: ChangesetFormFieldsSelectArgs;
}

export default class ChangesetFormFieldsSelect extends Base<ChangesetFormFieldsSelectSignature> {
  @action
  async handleChange(
    selection: unknown,
    select: Select,
    event?: Event
  ): Promise<void> {
    this.args.changeset.set(this.args.fieldName, selection);
    await this.validate();

    if (typeof this.args.onChange === 'function') {
      this.args.onChange(selection, select, event);
    }
  }

  @action
  async handleFocusOut(select: Select, event: FocusEvent): Promise<void> {
    await this.validate();

    if (typeof this.args.onFocusOut === 'function') {
      this.args.onFocusOut(select, event);
    }
  }

  @action
  async handleClose(select: Select, event: Event): Promise<void> {
    await this.validate();

    if (typeof this.args.onClose === 'function') {
      this.args.onClose(select, event);
    }
  }
}
