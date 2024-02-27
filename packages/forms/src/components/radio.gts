import Component from '@glimmer/component';
import { action } from '@ember/object';
import { on } from '@ember/modifier';
import { FormControl } from './form-control';
import { useStyles } from '@frontile/theme';

interface RadioSignature {
  Args: {
    value?: string;
    checked?: unknown;
    name?: string;
    size?: 'sm' | 'md' | 'lg';
    class?: string;

    label?: string;
    isRequired?: boolean;
    description?: string;
    errors?: string[] | string;
    isInvalid?: boolean;

    // Callback when onchange is triggered
    onChange?: (value: string | undefined, event: Event) => void;
  };
  Element: HTMLInputElement;
}

class Radio extends Component<RadioSignature> {
  get isChecked(): boolean {
    return this.args.checked === this.args.value;
  }

  @action handleChange(event: Event): void {
    event.preventDefault();

    if (typeof this.args.onChange === 'function') {
      this.args.onChange(this.args.value, event);
    }
  }

  get classes() {
    const { radio } = useStyles();

    return radio({
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
        value={{@value}}
        checked={{this.isChecked}}
        type="radio"
        class={{this.classes}}
        data-component="radio"
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

export { Radio, type RadioSignature };
export default Radio;
