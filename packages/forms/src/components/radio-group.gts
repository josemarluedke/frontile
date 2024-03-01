import Component from '@glimmer/component';
import { Radio, type RadioSignature } from './radio';
import { FormControl } from './form-control';
import { useStyles } from '@frontile/theme';

import type { WithBoundArgs } from '@glint/template';

interface RadioGroupSignature {
  Args: {
    name?: string;
    value?: string;
    onChange?: RadioSignature['Args']['onChange'];
    size?: RadioSignature['Args']['size'];

    label?: string;
    isRequired?: boolean;
    description?: string;
    errors?: string[] | string;
    isInvalid?: boolean;

    /*
     *
     * @defaultValue 'vertical'
     */
    orientation?: 'horizontal' | 'vertical';
  };
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
    const { base, optionsContainer, label } = radioGroup({
      size: this.args.size
    });

    return {
      base: base(),
      label: label(),
      optionsContainer: optionsContainer()
    };
  }
  <template>
    <FormControl
      @size={{@size}}
      @isRequired={{@isRequired}}
      @description={{@description}}
      @errors={{@errors}}
      @isInvalid={{@isInvalid}}
      ...attributes
      as |c|
    >
      <c.Label @class={{this.classes.label}}>{{@label}}</c.Label>
      <div
        class={{this.classes.optionsContainer}}
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
