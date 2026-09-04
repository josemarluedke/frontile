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
  /**
   * The name attribute applied to every checkbox in the group, so they are
   * submitted together as one field.
   */
  name?: string;

  /**
   * Callback when a checkbox in the group is toggled. It is bound onto every
   * yielded Checkbox, so a checkbox that sets its own `@onChange` replaces this
   * one rather than running alongside it.
   */
  onChange?: CheckboxSignature['Args']['onChange'];

  /**
   * The size applied to every checkbox in the group and to the group's label.
   */
  size?: CheckboxGroupVariants['size'];

  /**
   * Class names for each slot of the component, merged with the theme's.
   */
  classes?: SlotsToClasses<CheckboxGroupSlots>;

  /**
   * How the checkboxes are laid out.
   *
   * @defaultValue 'vertical'
   */
  orientation?: 'horizontal' | 'vertical';
}

interface CheckboxGroupSignature {
  Args: Args;
  Blocks: {
    default: [
      Checkbox: WithBoundArgs<
        typeof Checkbox,
        'name' | 'onChange' | 'isDisabled'
      >
    ];
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
        {{yield
          (component
            Checkbox
            name=@name
            onChange=@onChange
            size=@size
            isDisabled=@isDisabled
          )
          to="default"
        }}
      </div>
    </FormControl>
  </template>
}

export { CheckboxGroup, type CheckboxGroupSignature };
export default CheckboxGroup;
