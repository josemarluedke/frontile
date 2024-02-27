import Component from '@glimmer/component';
import { hash } from '@ember/helper';
import {
  FormControlCheckbox,
  type FormControlCheckboxSignature
} from './form-control-checkbox';
import { Checkbox } from './checkbox';

import type { WithBoundArgs } from '@glint/template';

interface CheckboxGroupSignature {
  Args: {
    name?: string;
    onChange?: FormControlCheckboxSignature['Args']['onChange'];
    size?: FormControlCheckboxSignature['Args']['size'];
  };
  Blocks: {
    default: [
      {
        ControlCheckbox: WithBoundArgs<
          typeof FormControlCheckbox,
          'name' | 'onChange'
        >;
        Checkbox: WithBoundArgs<typeof Checkbox, 'name' | 'onChange'>;
      }
    ];
  };
  Element: HTMLDivElement;
}

class CheckboxGroup extends Component<CheckboxGroupSignature> {
  <template>
    {{yield
      (hash
        ControlCheckbox=(component
          FormControlCheckbox name=@name onChange=@onChange size=@size
        )
        Checkbox=(component Checkbox name=@name onChange=@onChange size=@size)
      )
      to="default"
    }}
  </template>
}

export { CheckboxGroup, type CheckboxGroupSignature };
export default CheckboxGroup;
