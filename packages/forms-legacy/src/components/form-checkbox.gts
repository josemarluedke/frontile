import Component from '@glimmer/component';
import { action } from '@ember/object';
import { useStyles } from '@frontile/theme';
import FormField from './form-field';

export interface FormCheckboxArgs {
  /** The input field label */
  label?: string;
  /** A help text to be displayed */
  hint?: string;
  /**
   * If the checkbox is checked.
   * You must also pass `onChange` to update its value.
   */
  checked: boolean;
  /** The name of the checkbox */
  name?: string;
  /** CSS classes to be added in the container element */
  containerClass?: string;
  /** The size */
  size?: 'sm' | 'md' | 'lg';
  /** Callback when onchange is triggered */
  onChange: (value: boolean, event: Event) => void;

  /**
   * Internal function for InputCheckboxGroup
   * @ignore
   **/
  _parentOnChange?: (value: boolean, event: Event) => void;

  /**
   * CSS classes to be added in the container element
   * @ignore
   * */
  privateContainerClass?: string;
}

export interface FormCheckboxSignature {
  Args: FormCheckboxArgs;
  Element: HTMLInputElement;
  Blocks: {
    default: [];
  };
}

export default class FormCheckbox extends Component<FormCheckboxSignature> {
  @action handleChange(value: boolean, event: Event): void {
    if (typeof this.args.onChange === 'function') {
      this.args.onChange(value, event);
    }

    if (typeof this.args._parentOnChange === 'function') {
      this.args._parentOnChange(value, event);
    }
  }

  get classes() {
    const { formCheckbox } = useStyles();

    const { base, label, checkbox, hint, labelContainer, inputContainer } =
      formCheckbox({
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
      checkbox: checkbox()
    };
  }

  <template>
    <FormField @size={{@size}} class={{this.classes.base}} as |f|>
      <div class={{this.classes.labelContainer}}>
        <div class={{this.classes.inputContainer}}>
          {{!  Zero-width space character, used to align checkbox properly }}
          {{! eslint-disable no-irregular-whitespace}}
          ​
          <f.Checkbox
            @onChange={{this.handleChange}}
            @checked={{@checked}}
            @name={{@name}}
            @class={{this.classes.checkbox}}
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
