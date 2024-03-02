import Component from '@glimmer/component';
import { action } from '@ember/object';
import { on } from '@ember/modifier';
import { FormControl, type FormControlSharedArgs } from './form-control';
import { useStyles } from '@frontile/theme';

interface Args extends FormControlSharedArgs {
  checked?: boolean;
  name?: string;
  size?: 'sm' | 'md' | 'lg';
  class?: string;
  containerClass?: string;

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

    const { base, input, labelContainer, label } = checkbox({
      size: this.args.size
    });

    return {
      base: base({ class: this.args.containerClass }),
      input: input({
        class: this.args.class
      }),
      labelContainer: labelContainer(),
      label: label()
    };
  }

  <template>
    <FormControl
      @isInvalid={{@isInvalid}}
      @errors={{@errors}}
      @size={{@size}}
      @isRequired={{@isRequired}}
      @class={{this.classes.base}}
      @preventErrorFeedback={{true}}
      as |c|
    >
      <input
        {{on "change" this.handleChange}}
        id={{c.id}}
        name={{@name}}
        checked={{this.isChecked}}
        type="checkbox"
        class={{this.classes.input}}
        data-component="checkbox"
        aria-invalid={{if c.isInvalid "true"}}
        aria-describedby={{c.describedBy @description c.isInvalid}}
        ...attributes
      />
      <div class={{this.classes.labelContainer}}>
        {{#if @label}}
          <c.Label @class={{this.classes.label}}>{{@label}}</c.Label>
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
