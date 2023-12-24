import Base, { BaseArgs, BaseSignature } from './base';
import { action } from '@ember/object';
import type FormRadio from '@frontile/forms/components/form-radio';

export interface ChangesetFormFieldsRadioGroupArgs extends BaseArgs {
  onChange?: (value: unknown, event: Event) => void;
}

export interface ChangesetFormFieldsRadioGroupSignature extends BaseSignature {
  Args: ChangesetFormFieldsRadioGroupArgs;
  Blocks: {
    default: [radio: FormRadio];
  };
  Element: HTMLDivElement;
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
