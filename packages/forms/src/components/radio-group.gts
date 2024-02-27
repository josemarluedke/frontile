import Component from '@glimmer/component';
import { Radio, type RadioSignature } from './radio';
import { FormControl } from './form-control';

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
  };
  Blocks: {
    default: [
      Radio: WithBoundArgs<typeof Radio, 'name' | 'onChange' | 'checked'>
    ];
  };
  Element: HTMLDivElement;
}

class RadioGroup extends Component<RadioGroupSignature> {
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
        (component
          Radio name=@name onChange=@onChange size=@size checked=@value
        )
        to="default"
      }}
    </FormControl>
  </template>
}

export { RadioGroup, type RadioGroupSignature };
export default RadioGroup;
