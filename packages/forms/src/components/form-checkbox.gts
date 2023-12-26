import Component from '@glimmer/component';
import { action } from '@ember/object';
import useFrontileClass from '@frontile/core/helpers/use-frontile-class';
import FormField from './form-field';
import { array } from '@ember/helper';

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
  size?: 'sm' | 'lg';
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

  <template>
    <FormField
      @size={{@size}}
      class={{useFrontileClass
        "form-checkbox"
        @size
        (if @checked "checked")
        class=(array @containerClass @privateContainerClass)
      }}
      as |f|
    >
      <div
        class={{useFrontileClass "form-checkbox" @size part="label-container"}}
      >
        <div
          class={{useFrontileClass
            "form-checkbox"
            @size
            part="input-container"
          }}
        >
          {{!  Zero-width space character, used to align checkbox properly }}
          {{! eslint-disable no-irregular-whitespace}}
          ​
          <f.Checkbox
            @onChange={{this.handleChange}}
            @checked={{@checked}}
            @name={{@name}}
            class={{useFrontileClass "form-checkbox" @size part="checkbox"}}
            aria-describedby={{if @hint f.hintId}}
            ...attributes
          />
        </div>

        <f.Label class={{useFrontileClass "form-checkbox" @size part="label"}}>
          {{#if (has-block)}}
            {{yield}}
          {{else}}
            {{@label}}
          {{/if}}
        </f.Label>
      </div>

      {{#if @hint}}
        <f.Hint class={{useFrontileClass "form-checkbox" @size part="hint"}}>
          {{@hint}}
        </f.Hint>
      {{/if}}
    </FormField>
  </template>
}
