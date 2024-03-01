import Component from '@glimmer/component';
import { Checkbox, type CheckboxSignature } from './checkbox';
import { FormControl } from './form-control';
import { useStyles } from '@frontile/theme';

import type { WithBoundArgs } from '@glint/template';

interface CheckboxGroupSignature {
  Args: {
    name?: string;

    label?: string;
    isRequired?: boolean;
    description?: string;
    errors?: string[] | string;
    isInvalid?: boolean;

    onChange?: CheckboxSignature['Args']['onChange'];
    size?: CheckboxSignature['Args']['size'];

    /*
     *
     * @defaultValue 'vertical'
     */
    orientation?: 'horizontal' | 'vertical';
  };
  Blocks: {
    default: [Checkbox: WithBoundArgs<typeof Checkbox, 'name' | 'onChange'>];
  };
  Element: HTMLDivElement;
}

class CheckboxGroup extends Component<CheckboxGroupSignature> {
  get classes() {
    const { radioGroup } = useStyles();
    const { base, optionsContainer } = radioGroup({
      size: this.args.size
    });

    return {
      base: base(),
      optionsContainer: optionsContainer()
    };
  }
  <template>
    <FormControl
      @size={{@size}}
      @label={{@label}}
      @isRequired={{@isRequired}}
      @description={{@description}}
      @errors={{@errors}}
      @isInvalid={{@isInvalid}}
    >
      <div
        class={{this.classes.optionsContainer}}
        data-orientation={{if @orientation @orientation "vertical"}}
      >
        {{yield
          (component Checkbox name=@name onChange=@onChange size=@size)
          to="default"
        }}
      </div>
    </FormControl>
  </template>
}

export { CheckboxGroup, type CheckboxGroupSignature };
export default CheckboxGroup;
