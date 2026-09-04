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
  /**
   * The name attribute applied to every radio in the group, which is what makes
   * the browser treat them as mutually exclusive.
   */
  name?: string;

  /**
   * The currently selected value. Pair with `onChange` to control the group.
   */
  value?: T;

  /**
   * Callback when the selected radio changes, receiving the new value.
   */
  onChange?: RadioSignature<T>['Args']['onChange'];

  /**
   * The size applied to every radio in the group and to the group's label.
   */
  size?: RadioVariants['size'];

  /**
   * Class names for each slot of the component, merged with the theme's.
   */
  classes?: SlotsToClasses<RadioGroupSlots>;

  /**
   * How the radios are laid out.
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
      @errors={{@errors}}
      @isInvalid={{@isInvalid}}
      @class={{this.classes.base class=@classes.base}}
      ...attributes
      as |c|
    >
      <c.Label @class={{this.classes.label class=@classes.label}}>
        {{@label}}
      </c.Label>

      {{#if @description}}
        <c.Description>{{@description}}</c.Description>
      {{/if}}

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
