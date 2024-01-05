import Component from '@glimmer/component';
import { useStyles } from '@frontile/theme';

export interface FormFieldLabelArgs {
  for?: string;
  size?: 'sm' | 'md' | 'lg';
  class?: string;
}

export interface FormFieldLabelSignature {
  Args: FormFieldLabelArgs;
  Element: HTMLLabelElement;
  Blocks: {
    default: [];
  };
}

export default class FormFieldLabel extends Component<FormFieldLabelSignature> {
  get classes() {
    const { label } = useStyles();

    return label({ size: this.args.size, class: this.args.class });
  }

  <template>
    <label
      for={{@for}}
      class={{this.classes}}
      data-test-id="form-field-label"
      ...attributes
    >
      {{yield}}
    </label>
  </template>
}
