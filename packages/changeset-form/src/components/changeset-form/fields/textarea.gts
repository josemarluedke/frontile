import Base, { type BaseArgs, type BaseSignature } from './base';
import { action } from '@ember/object';
import { on } from '@ember/modifier';
import FormTextarea from '@frontile/forms/components/form-textarea';

export interface ChangesetFormFieldsTextareaArgs extends BaseArgs {
  onInput?: (value: string, event: InputEvent) => void;
}

export interface ChangesetFormFieldsTextareaSignature extends BaseSignature {
  Args: ChangesetFormFieldsTextareaArgs;
}

export default class ChangesetFormFieldsTextarea extends Base<ChangesetFormFieldsTextareaSignature> {
  @action handleInput(value: string, event: InputEvent): void {
    this.args.changeset.set(this.args.fieldName, value);

    if (typeof this.args.onInput === 'function') {
      this.args.onInput(value, event);
    }
  }
  <template>
    <FormTextarea
      {{on "blur" this.validate}}
      @value={{this.value}}
      @onInput={{this.handleInput}}
      @errors={{this.errors}}
      @hasSubmitted={{@hasSubmitted}}
      @type={{@type}}
      @label={{@label}}
      @hint={{@hint}}
      @hasError={{@hasError}}
      @showError={{@showError}}
      @containerClass={{@containerClass}}
      @size={{@size}}
      @onChange={{@onChange}}
      @onFocusIn={{@onFocusIn}}
      @onFocusOut={{@onFocusOut}}
      ...attributes
    >
      {{yield}}
    </FormTextarea>
  </template>
}
