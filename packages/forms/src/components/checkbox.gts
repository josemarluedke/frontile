import Component from '@glimmer/component';
import { action } from '@ember/object';
import { on } from '@ember/modifier';
import { FormControl, type FormControlSharedArgs } from './form-control';
import {
  useStyles,
  type CheckboxVariants,
  type CheckboxSlots,
  type SlotsToClasses
} from '@frontile/theme';

interface Args extends FormControlSharedArgs {
  checked?: boolean;
  name?: string;
  size?: CheckboxVariants['size'];
  classes?: SlotsToClasses<CheckboxSlots>;

  /*
   * Callback when onchange is triggered
   */
  onChange?: (value: boolean, event: Event) => void;
}

interface CheckboxSignature {
  Args: Args;
  Element: HTMLInputElement;
}

class Checkbox extends Component<CheckboxSignature> {
  get isChecked(): boolean {
    return !!this.args.checked;
  }

  @action handleChange(event: Event): void {
    event.preventDefault();

    const value = !this.args.checked;

    if (typeof this.args.onChange === 'function') {
      this.args.onChange(value, event);
    }
  }

  get classes() {
    const { checkbox } = useStyles();
    return checkbox({
      size: this.args.size
    });
  }

  <template>
    <FormControl
      @isInvalid={{@isInvalid}}
      @errors={{@errors}}
      @size={{@size}}
      @isRequired={{@isRequired}}
      @class={{this.classes.base class=@classes.base}}
      @preventErrorFeedback={{true}}
      as |c|
    >
      <input
        {{on "change" this.handleChange}}
        id={{c.id}}
        name={{@name}}
        checked={{this.isChecked}}
        type="checkbox"
        disabled={{@isDisabled}}
        class={{this.classes.input class=@classes.input}}
        data-component="checkbox"
        aria-invalid={{if c.isInvalid "true"}}
        aria-describedby={{c.describedBy @description c.isInvalid}}
        ...attributes
      />
      <div class={{this.classes.labelContainer class=@classes.labelContainer}}>
        {{#if @label}}
          <c.Label @class={{this.classes.label class=@classes.label}}>
            {{@label}}
          </c.Label>
        {{/if}}
        {{#if @description}}
          <c.Description>{{@description}}</c.Description>
        {{/if}}
        {{#if c.isInvalid}}
          <c.Feedback />
        {{/if}}
      </div>
    </FormControl>
  </template>
}

export { Checkbox, type CheckboxSignature };
export default Checkbox;
