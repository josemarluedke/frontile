import Base, { type BaseArgs, type BaseSignature } from './base';
import { action } from '@ember/object';
import FormRadio from '@frontile/forms/components/form-radio';

export interface ChangesetFormFieldsRadioArgs extends BaseArgs {
  onChange?: (value: unknown, event: Event) => void;
}

export interface ChangesetFormFieldsRadioSignature extends BaseSignature {
  Args: ChangesetFormFieldsRadioArgs;
  Element: HTMLInputElement;
}

export default class ChangesetFormFieldsRadio extends Base<ChangesetFormFieldsRadioSignature> {
  @action
  async handleChange(value: unknown, event: Event): Promise<void> {
    event.preventDefault();

    this.args.changeset.set(this.args.fieldName, value);
    await this.validate();

    if (typeof this.args.onChange === 'function') {
      this.args.onChange(value, event);
    }
  }
  <template>
    <FormRadio
      @onChange={{this.handleChange}}
      @checked={{this.value}}
      @hint={{@hint}}
      @value={{@value}}
      @name={{@name}}
      @containerClass={{@containerClass}}
      @size={{@size}}
      ...attributes
      {{on "blur" this.validate}}
    >
      {{#if (has-block)}}
        {{yield}}
      {{else}}
        {{@label}}
      {{/if}}
    </FormRadio>
  </template>
}
