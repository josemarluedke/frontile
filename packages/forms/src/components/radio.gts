import Component from '@glimmer/component';
import { action } from '@ember/object';
import { on } from '@ember/modifier';
import { FormControl, type FormControlSharedArgs } from './form-control';
import {
  useStyles,
  type SlotsToClasses,
  type RadioVariants,
  type RadioSlots
} from '@frontile/theme';

interface Args extends FormControlSharedArgs {
  value?: string | boolean | number;
  checked?: string | boolean | number;
  name?: string;

  size?: RadioVariants['size'];
  classes?: SlotsToClasses<RadioSlots>;

  // Callback when onchange is triggered
  onChange?: (
    value: string | boolean | number | undefined,
    event: Event
  ) => void;
}

interface RadioSignature {
  Args: Args;
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
        value={{@value}}
        checked={{this.isChecked}}
        type="radio"
        class={{this.classes.input class=@classes.input}}
        data-component="radio"
        aria-invalid={{if c.isInvalid "true"}}
        aria-describedby={{c.describedBy @description c.isInvalid}}
        ...attributes
      />
      <div class={{this.classes.labelContainer class=@classes.labelContainer}}>
        {{#if @label}}
          <c.Label
            @class={{(this.classes.label class=@classes.label)}}
          >{{@label}}</c.Label>
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
