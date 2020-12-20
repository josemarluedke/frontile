import Base, { BaseArgs } from './base';
import { action } from '@ember/object';
import { Select } from 'ember-power-select/addon/components/power-select';

interface ChangesetFormFieldsSelectArgs extends BaseArgs {
  onChange?: (selection: unknown, select: Select, event?: Event) => void;
  onFocusOut?: (select: Select, event: FocusEvent) => void;
  onClose?: (select: Select, event: Event) => void;
}

export default class ChangesetFormFieldsSelect extends Base<ChangesetFormFieldsSelectArgs> {
  @action
  handleChange(selection: unknown, select: Select, event?: Event): void {
    this.args.changeset.set(this.args.fieldName, selection);
    this.validate();

    if (typeof this.args.onChange === 'function') {
      this.args.onChange(selection, select, event);
    }
  }

  @action handleFocusOut(select: Select, event: FocusEvent): void {
    this.validate();

    if (typeof this.args.onFocusOut === 'function') {
      this.args.onFocusOut(select, event);
    }
  }

  @action handleClose(select: Select, event: Event): void {
    this.validate();

    if (typeof this.args.onClose === 'function') {
      this.args.onClose(select, event);
    }
  }
}
