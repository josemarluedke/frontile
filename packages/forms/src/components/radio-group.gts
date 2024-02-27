import Component from '@glimmer/component';
import { hash } from '@ember/helper';
import {
  FormControlRadio,
  type FormControlRadioSignature
} from './form-control-radio';
import { Radio } from './radio';

import type { WithBoundArgs } from '@glint/template';

interface RadioGroupSignature {
  Args: {
    name?: string;
    value?: string;
    onChange?: FormControlRadioSignature['Args']['onChange'];
    size?: FormControlRadioSignature['Args']['size'];
  };
  Blocks: {
    default: [
      {
        ControlRadio: WithBoundArgs<
          typeof FormControlRadio,
          'name' | 'onChange' | 'checked'
        >;
        Radio: WithBoundArgs<typeof Radio, 'name' | 'onChange' | 'checked'>;
      }
    ];
  };
  Element: HTMLDivElement;
}

class RadioGroup extends Component<RadioGroupSignature> {
  <template>
    {{yield
      (hash
        ControlRadio=(component
          FormControlRadio
          name=@name
          onChange=@onChange
          size=@size
          checked=@value
        )
        Radio=(component
          Radio name=@name onChange=@onChange size=@size checked=@value
        )
      )
      to="default"
    }}
  </template>
}

export { RadioGroup, type RadioGroupSignature };
export default RadioGroup;
