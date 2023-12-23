import Component from '@glimmer/component';
import useFrontileClass from '@frontile/core/helpers/use-frontile-class';

export interface FormFieldLabelArgs {
  for?: string;
  size?: 'sm' | 'lg';
}

export interface FormFieldLabelSignature {
  Args: FormFieldLabelArgs;
  Element: HTMLLabelElement;
  Blocks: {
    default: [];
  };
}

export default class FormFieldLabel extends Component<FormFieldLabelSignature> {
  <template>
    <label
      for={{@for}}
      class={{useFrontileClass "form-field-label" @size}}
      data-test-id="form-field-label"
      ...attributes
    >
      {{yield}}
    </label>
  </template>
}
