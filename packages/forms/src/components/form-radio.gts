import Component from '@glimmer/component';
import { action } from '@ember/object';
import FormField from './form-field';
import { useStyles } from '@frontile/theme';

export interface FormRadioArgs {
  /** The input field label */
  label?: string;
  /** A help text to be displayed */
  hint?: string;
  /**
   * The value to be used in the radio button.
   * You must also pass `onChange` to update its value.
   */
  value: string | number | boolean | undefined;
  /**
   * The current checked value.
   * This will be used to compare against the `value` argument,
   * if equal, the radio will me marked as checked.
   */
  checked: unknown;
  /** The name of the checkbox */
  name?: string;
  /** CSS classes to be added in the container element */
  containerClass?: string;
  /** The size */
  size?: 'sm' | 'md' | 'lg';
  /** Callback when onchange is triggered */
  onChange: (value: unknown, event: Event) => void;

  /**
   * Internal function for InputRadioGroup
   * @ignore
   **/
  _parentOnChange?: (value: unknown, event: Event) => void;

  /** CSS classes to be added in the container element, in be used in for group
   * @ignore*/
  privateContainerClass?: string;
}

export interface FormRadioSignature {
  Args: FormRadioArgs;
  Element: HTMLInputElement;
  Blocks: {
    default: [];
  };
}

export default class FormRadio extends Component<FormRadioSignature> {
  @action handleChange(value: unknown, event: Event): void {
    event.preventDefault();

    if (typeof this.args.onChange === 'function') {
      this.args.onChange(value, event);
    }

    if (typeof this.args._parentOnChange === 'function') {
      this.args._parentOnChange(value, event);
    }
  }

  get isChecked(): boolean {
    return this.args.checked == this.args.value;
  }

  get classes() {
    const { formRadio } = useStyles();

    const { base, label, radio, hint, labelContainer, inputContainer } =
      formRadio({
        size: this.args.size
      });

    let containerClasses = '';
    if (this.args.containerClass) {
      containerClasses = this.args.containerClass;
    }
    if (this.args.privateContainerClass) {
      containerClasses += ' ' + this.args.privateContainerClass;
    }

    return {
      base: base({
        class: containerClasses
      }),
      label: label(),
      inputContainer: inputContainer(),
      labelContainer: labelContainer(),
      hint: hint(),
      radio: radio()
    };
  }

  <template>
    <FormField @size={{@size}} class={{this.classes.base}} as |f|>
      <div class={{this.classes.labelContainer}}>
        <div class={{this.classes.inputContainer}}>
          {{!  Zero-width space character, used to align checkbox properly }}
          {{! eslint-disable no-irregular-whitespace}}
          ​
          <f.Radio
            @onChange={{this.handleChange}}
            @value={{@value}}
            @checked={{@checked}}
            @name={{@name}}
            @class={{this.classes.radio}}
            aria-describedby={{if @hint f.hintId}}
            ...attributes
          />
        </div>

        <f.Label @class={{this.classes.label}}>
          {{#if (has-block)}}
            {{yield}}
          {{else}}
            {{@label}}
          {{/if}}
        </f.Label>
      </div>

      {{#if @hint}}
        <f.Hint @class={{this.classes.hint}}>
          {{@hint}}
        </f.Hint>
      {{/if}}
    </FormField>
  </template>
}
