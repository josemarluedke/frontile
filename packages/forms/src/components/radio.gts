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
    const { base, input, labelContainer, label } = radio({
      size: this.args.size
    });

    return {
      base: base(),
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
        value={{@value}}
        checked={{this.isChecked}}
        type="radio"
        class={{this.classes.input}}
        data-component="radio"
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

export { Radio, type RadioSignature };
export default Radio;
