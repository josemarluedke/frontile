import Base, { BaseArgs } from './base';
import { action } from '@ember/object';

interface ChangesetFormFieldsTextareaArgs extends BaseArgs {
  onInput?: (value: string, event: InputEvent) => void;
}

export default class ChangesetFormFieldsTextarea extends Base<
  ChangesetFormFieldsTextareaArgs
> {
  @action handleInput(value: string, event: InputEvent): void {
    this.args.changeset.set(this.args.fieldName, value);

    if (typeof this.args.onInput === 'function') {
      this.args.onInput(value, event);
    }
  }
}
