import Component from '@glimmer/component';
import { useStyles, type FormDescriptionVariants } from '@frontile/theme';

interface FormDescriptionSignature {
  Args: {
    id?: string;
    /*
     * @defaultValue 'md'
     */
    size?: FormDescriptionVariants['size'];

    class?: string;
  };
  Element: HTMLDivElement;
  Blocks: {
    default: [];
  };
}

class FormDescription extends Component<FormDescriptionSignature> {
  get classes() {
    const { formDescription } = useStyles();

    return formDescription({
      size: this.args.size || 'md',
      class: this.args.class
    });
  }

  <template>
    <div
      id={{@id}}
      class={{this.classes}}
      data-component="form-description"
      ...attributes
    >
      {{yield}}
    </div>
  </template>
}

export { FormDescription, type FormDescriptionSignature };
export default FormDescription;
