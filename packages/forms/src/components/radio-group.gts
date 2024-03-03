import Component from '@glimmer/component';
import { Radio, type RadioSignature } from './radio';
import { FormControl, type FormControlSharedArgs } from './form-control';
import {
  useStyles,
  type RadioGroupSlots,
  type RadioVariants,
  type SlotsToClasses
} from '@frontile/theme';
import type { WithBoundArgs } from '@glint/template';

interface Args extends FormControlSharedArgs {
  name?: string;
  value?: string;
  onChange?: RadioSignature['Args']['onChange'];
  size?: RadioVariants['size'];
  classes?: SlotsToClasses<RadioGroupSlots>;

  /*
   *
   * @defaultValue 'vertical'
   */
  orientation?: 'horizontal' | 'vertical';
}

interface RadioGroupSignature {
  Args: Args;
  Blocks: {
    default: [
      Radio: WithBoundArgs<typeof Radio, 'name' | 'onChange' | 'checked'>
    ];
  };
  Element: HTMLDivElement;
}

class RadioGroup extends Component<RadioGroupSignature> {
  get classes() {
    const { radioGroup } = useStyles();
    return radioGroup({
      size: this.args.size
    });
  }

  <template>
    <FormControl
      @size={{@size}}
      @isRequired={{@isRequired}}
      @description={{@description}}
      @errors={{@errors}}
      @isInvalid={{@isInvalid}}
      @class={{this.classes.base class=@classes.base}}
      ...attributes
      as |c|
    >
      <c.Label @class={{this.classes.label class=@classes.label}}>
        {{@label}}
      </c.Label>
      <div
        class={{this.classes.optionsContainer class=@classes.optionsContainer}}
        data-orientation={{if @orientation @orientation "vertical"}}
      >
        {{yield
          (component
            Radio name=@name onChange=@onChange size=@size checked=@value
          )
          to="default"
        }}
      </div>
    </FormControl>
  </template>
}

export { RadioGroup, type RadioGroupSignature };
export default RadioGroup;
