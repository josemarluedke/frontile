import Component from '@glimmer/component';
import useFrontileClass from '@frontile/core/helpers/use-frontile-class';

export interface FormFieldHintArgs {
  id?: string;
  size?: 'sm' | 'lg';
}

export interface FormFieldHintSignature {
  Args: FormFieldHintArgs;
  Element: HTMLDivElement;
  Blocks: {
    default: [];
  };
}

export default class FormFieldHint extends Component<FormFieldHintSignature> {
  <template>
    <div
      id={{@id}}
      class={{useFrontileClass "form-field-hint" @size}}
      data-test-id="form-field-hint"
      ...attributes
    >
      {{yield}}
    </div>
  </template>
}
