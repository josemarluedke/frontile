import Base, { type BaseArgs, type BaseSignature } from './base';
import { action } from '@ember/object';
import { on } from '@ember/modifier';
import FormInput, {
  type FormInputArgs
} from '@frontile/forms/components/form-input';

export interface ChangesetFormFieldsInputArgs extends BaseArgs, FormInputArgs {
  onInput?: (value: string, event: InputEvent) => void;
}

export interface ChangesetFormFieldsInputSignature extends BaseSignature {
  Args: ChangesetFormFieldsInputArgs;
  Element: HTMLInputElement;
  Blocks: { default: [] };
}

export default class ChangesetFormFieldsInput extends Base<ChangesetFormFieldsInputSignature> {
  @action handleInput(value: string, event: InputEvent): void {
    this.args.changeset.set(this.args.fieldName, value);

    if (typeof this.args.onInput === 'function') {
      this.args.onInput(value, event);
    }
  }

  <template>
    <FormInput
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
    </FormInput>
  </template>
}
