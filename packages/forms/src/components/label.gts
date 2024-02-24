import Component from '@glimmer/component';
import { useStyles } from '@frontile/theme';

interface LabelSignature {
  Args: {
    /**
     * The 'for' attribute of a <label>.
     */
    for?: string;

    /*
     * @defaultValue 'md'
     */
    size?: 'sm' | 'md' | 'lg';

    /*
     * Whether the field is required or not, if true, an asterisk will be added to the label.
     * @defaultValue false
     */
    isRequired?: boolean;
    class?: string;
  };
  Element: HTMLLabelElement;
  Blocks: {
    default: [];
  };
}

class Label extends Component<LabelSignature> {
  get classes() {
    const { label } = useStyles();
    const { base, asterisk } = label({
      size: this.args.size || 'md'
    });

    return {
      base: base({ class: this.args.class }),
      asterisk: asterisk()
    };
  }

  <template>
    <label
      for={{@for}}
      class={{this.classes.base}}
      data-component="label"
      ...attributes
    >
      {{yield}}
      {{#if @isRequired}}
        <span class={{this.classes.asterisk}}>*</span>
      {{/if}}
    </label>
  </template>
}

export { Label, type LabelSignature };
export default Label;
