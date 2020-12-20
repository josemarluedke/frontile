import Base, { BaseArgs } from './base';
import { action } from '@ember/object';

interface ChangesetFormFieldsInputArgs extends BaseArgs {
  onInput?: (value: string, event: InputEvent) => void;
}

export default class ChangesetFormFieldsInput extends Base<ChangesetFormFieldsInputArgs> {
  @action handleInput(value: string, event: InputEvent): void {
    this.args.changeset.set(this.args.fieldName, value);

    if (typeof this.args.onInput === 'function') {
      this.args.onInput(value, event);
    }
  }
}
