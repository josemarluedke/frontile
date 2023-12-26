import Base, { type BaseArgs, type BaseSignature } from './base';
import { action } from '@ember/object';
import type { FormRadioSignature } from '@frontile/forms/components/form-radio';
import FormRadioGroup, {
  type FormRadioGroupArgs
} from '@frontile/forms/components/form-radio-group';
import type { ComponentLike } from '@glint/template';

export interface ChangesetFormFieldsRadioGroupArgs
  extends BaseArgs,
    FormRadioGroupArgs {
  onChange?: (value: unknown, event: Event) => void;
}

export interface ChangesetFormFieldsRadioGroupSignature extends BaseSignature {
  Args: ChangesetFormFieldsRadioGroupArgs;
  Blocks: { default: [radio: ComponentLike<FormRadioSignature>] };
  Element: HTMLDivElement;
}

export default class ChangesetFormFieldsRadioGroup extends Base<
  ChangesetFormFieldsRadioGroupSignature,
  string | boolean | number | undefined
> {
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
    <FormRadioGroup
      @onChange={{this.handleChange}}
      @value={{this.value}}
      @errors={{this.errors}}
      @label={{@label}}
      @hint={{@hint}}
      @hasSubmitted={{@hasSubmitted}}
      @hasError={{@hasError}}
      @showError={{@showError}}
      @containerClass={{@containerClass}}
      @size={{@size}}
      @isInline={{@isInline}}
      ...attributes
      as |Radio|
    >
      {{yield Radio}}
    </FormRadioGroup>
  </template>
}
