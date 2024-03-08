import Component from '@glimmer/component';
import { Checkbox, type CheckboxSignature } from './checkbox';
import { FormControl, type FormControlSharedArgs } from './form-control';
import {
  useStyles,
  type CheckboxGroupVariants,
  type CheckboxGroupSlots,
  type SlotsToClasses
} from '@frontile/theme';
import type { WithBoundArgs } from '@glint/template';

interface Args extends FormControlSharedArgs {
  name?: string;
  onChange?: CheckboxSignature['Args']['onChange'];
  size?: CheckboxGroupVariants['size'];
  classes?: SlotsToClasses<CheckboxGroupSlots>;

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
    const { checkboxGroup } = useStyles();
    return checkboxGroup({
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
          (component Checkbox name=@name onChange=@onChange size=@size)
          to="default"
        }}
      </div>
    </FormControl>
  </template>
}

export { CheckboxGroup, type CheckboxGroupSignature };
export default CheckboxGroup;
