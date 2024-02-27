import Component from '@glimmer/component';
import { Checkbox, type CheckboxSignature } from './checkbox';
import { FormControl } from './form-control';

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
  };
  Blocks: {
    default: [Checkbox: WithBoundArgs<typeof Checkbox, 'name' | 'onChange'>];
  };
  Element: HTMLDivElement;
}

class CheckboxGroup extends Component<CheckboxGroupSignature> {
  <template>
    <FormControl
      @size={{@size}}
      @label={{@label}}
      @isRequired={{@isRequired}}
      @description={{@description}}
      @errors={{@errors}}
      @isInvalid={{@isInvalid}}
    >
      {{yield
        (component Checkbox name=@name onChange=@onChange size=@size)
        to="default"
      }}
    </FormControl>
  </template>
}

export { CheckboxGroup, type CheckboxGroupSignature };
export default CheckboxGroup;
