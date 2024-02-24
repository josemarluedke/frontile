import Component from '@glimmer/component';
import { useStyles } from '@frontile/theme';

export interface FormFieldHintArgs {
  id?: string;
  size?: 'sm' | 'md' | 'lg';
  class?: string;
}

export interface FormFieldHintSignature {
  Args: FormFieldHintArgs;
  Element: HTMLDivElement;
  Blocks: {
    default: [];
  };
}

export default class FormFieldHint extends Component<FormFieldHintSignature> {
  get classes() {
    const { hint } = useStyles();

    return hint({
      size: this.args.size,
      class: this.args.class
    });
  }

  <template>
    <div
      id={{@id}}
      class={{this.classes}}
      data-test-id="form-field-hint"
      ...attributes
    >
      {{yield}}
    </div>
  </template>
}
