import Base, { type BaseArgs, type BaseSignature } from './base';
import { action } from '@ember/object';
import { on } from '@ember/modifier';
import FormTextarea from '@frontile/forms-legacy/components/form-textarea';
import { type FormInputArgs } from '@frontile/forms-legacy/components/form-input';

export interface ChangesetFormFieldsTextareaArgs
  extends BaseArgs,
    FormInputArgs {
  onInput?: (value: string, event: InputEvent) => void;
}

export interface ChangesetFormFieldsTextareaSignature extends BaseSignature {
  Args: ChangesetFormFieldsTextareaArgs;
  Element: HTMLTextAreaElement;
  Blocks: {
    default: [];
  };
}

export default class ChangesetFormFieldsTextarea extends Base<
  ChangesetFormFieldsTextareaSignature,
  string | undefined
> {
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
