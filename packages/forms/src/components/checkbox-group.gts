import Component from '@glimmer/component';
import { Checkbox, type CheckboxSignature } from './checkbox';
import { FormControl, type FormControlSharedArgs } from './form-control';
import { useStyles } from '@frontile/theme';
import type { WithBoundArgs } from '@glint/template';

interface Args extends FormControlSharedArgs {
  name?: string;
  onChange?: CheckboxSignature['Args']['onChange'];
  size?: CheckboxSignature['Args']['size'];

  /*
   *
   * @defaultValue 'vertical'
   */
  orientation?: 'horizontal' | 'vertical';
}

interface CheckboxGroupSignature {
  Args: Args;
  Blocks: {
    default: [Checkbox: WithBoundArgs<typeof Checkbox, 'name' | 'onChange'>];
  };
  Element: HTMLDivElement;
}

class CheckboxGroup extends Component<CheckboxGroupSignature> {
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
          (component Checkbox name=@name onChange=@onChange size=@size)
          to="default"
        }}
      </div>
    </FormControl>
  </template>
}

export { CheckboxGroup, type CheckboxGroupSignature };
export default CheckboxGroup;
