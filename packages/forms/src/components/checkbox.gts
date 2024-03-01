import Component from '@glimmer/component';
import { action } from '@ember/object';
import { on } from '@ember/modifier';
import { FormControl } from './form-control';
import { useStyles } from '@frontile/theme';

interface CheckboxSignature {
  Args: {
    checked?: boolean;
    name?: string;
    size?: 'sm' | 'md' | 'lg';
    class?: string;

    label?: string;
    isRequired?: boolean;
    description?: string;
    errors?: string[] | string;
    isInvalid?: boolean;

    /*
     * Callback when onchange is triggered
     */
    onChange?: (value: boolean, event: Event) => void;
  };
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
      size: this.args.size,
      class: this.args.class
    });
  }

  <template>
    <FormControl
      @isInvalid={{@isInvalid}}
      @errors={{@errors}}
      @class={{@class}}
      @size={{@size}}
      @isRequired={{@isRequired}}
      as |c|
    >
      <input
        {{on "change" this.handleChange}}
        id={{c.id}}
        name={{@name}}
        checked={{this.isChecked}}
        type="checkbox"
        class={{this.classes}}
        data-component="checkbox"
        aria-invalid={{if c.isInvalid "true"}}
        aria-describedby={{c.describedBy @description c.isInvalid}}
        ...attributes
      />
      <div>
        {{#if @label}}
          <c.Label>{{@label}}</c.Label>
        {{/if}}
        {{#if @description}}
          <c.Description>{{@description}}</c.Description>
        {{/if}}
      </div>
    </FormControl>
  </template>
}

export { Checkbox, type CheckboxSignature };
export default Checkbox;
