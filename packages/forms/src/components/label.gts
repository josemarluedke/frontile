import Component from '@glimmer/component';
import {
  useStyles,
  type LabelSlots,
  type LabelVariants,
  type SlotsToClasses
} from '@frontile/theme';

interface LabelSignature {
  Args: {
    /**
     * The 'for' attribute of a <label>.
     */
    for?: string;

    /*
     * @defaultValue 'md'
     */
    size?: LabelVariants['size'];
    classes?: SlotsToClasses<LabelSlots>;

    /**
     * The class name to be passed to the label base slot.
     */
    class?: string;

    /*
     * Whether the field is required or not, if true, an asterisk will be added to the label.
     * @defaultValue false
     */
    isRequired?: boolean;
  };
  Element: HTMLLabelElement;
  Blocks: {
    default: [];
  };
}

class Label extends Component<LabelSignature> {
  get classes() {
    const { label } = useStyles();
    return label({
      size: this.args.size || 'md'
    });
  }

  get baseClasses() {
    const val = [];
    if (this.args.class) val.push(this.args.class);
    if (this.classes.base && Array.isArray(this.classes.base)) {
      val.push(...this.classes.base);
    } else if (this.classes.base) {
      val.push(this.classes.base);
    }
    return val;
  }

  <template>
    <label
      for={{@for}}
      class={{this.classes.base class=this.baseClasses}}
      data-component="label"
      ...attributes
    >
      {{yield}}
      {{#if @isRequired}}
        <span class={{this.classes.asterisk class=@classes.asterisk}}>*</span>
      {{/if}}
    </label>
  </template>
}

export { Label, type LabelSignature };
export default Label;
