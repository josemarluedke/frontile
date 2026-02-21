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

interface Args<T> extends FormControlSharedArgs {
  name?: string;
  value?: T;
  onChange?: RadioSignature<T>['Args']['onChange'];
  size?: RadioVariants['size'];
  classes?: SlotsToClasses<RadioGroupSlots>;

  /*
   *
   * @defaultValue 'vertical'
   */
  orientation?: 'horizontal' | 'vertical';
}

interface RadioGroupSignature<T> {
  Args: Args<T>;
  Blocks: {
    default: [
      Radio: WithBoundArgs<
        typeof Radio,
        'name' | 'onChange' | 'checkedValue' | 'isDisabled'
      >
    ];
  };
  Element: HTMLDivElement;
}

class RadioGroup<T extends string | number | boolean> extends Component<
  RadioGroupSignature<T>
> {
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
        {{! @glint-nocheck: Radio has a type param, glint cannt handle that with WithboundArgs}}
        {{yield
          (component
            Radio
            name=@name
            onChange=@onChange
            size=@size
            checkedValue=@value
            isDisabled=@isDisabled
          )
        }}
      </div>
    </FormControl>
  </template>
}

export { RadioGroup, type RadioGroupSignature };
export default RadioGroup;
