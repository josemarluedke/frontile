import Base, { BaseArgs, BaseSignature } from './base';
import { action } from '@ember/object';

interface ChangesetFormFieldsInputArgs extends BaseArgs {
  onInput?: (value: string, event: InputEvent) => void;
}

interface ChangesetFormFieldsInputSignature extends BaseSignature {
  Args: ChangesetFormFieldsInputArgs;
}

export default class ChangesetFormFieldsInput extends Base<ChangesetFormFieldsInputSignature> {
  @action handleInput(value: string, event: InputEvent): void {
    this.args.changeset.set(this.args.fieldName, value);

    if (typeof this.args.onInput === 'function') {
      this.args.onInput(value, event);
    }
  }
}
