import Component from '@glimmer/component';
import { action } from '@ember/object';
import { tracked } from '@glimmer/tracking';
import { concat } from '@ember/helper';
import FormRadio from './form-radio';
import FormField from './form-field';
import useFrontileClass from '@frontile/core/helpers/use-frontile-class';
import type { WithBoundArgs } from '@glint/template';

export interface FormRadioGroupArgs {
  value: string | number | boolean | undefined;
  /** The group label */
  label?: string;
  /** A help text to be displayed */
  hint?: string;
  /** If the form has been submitted, used to force displaying errors */
  hasSubmitted?: boolean;
  /** If has errors */
  hasError?: boolean;
  /** Force displaying errors */
  showError?: boolean;
  /** A list of errors or a single text describing the error */
  errors?: string[] | string;
  /** CSS classes to be added in the container element */
  containerClass?: string;
  /** The size */
  size?: 'sm' | 'lg';
  /** If the Checkbox should be in one line */
  isInline?: boolean;

  /** Default callback added to the yielded FormRadio component, called when onchange is triggered */
  onChange?: (value: unknown, event: Event) => void;
}

export interface FormRadioGroupSignature {
  Args: FormRadioGroupArgs;
  Blocks: {
    default: [
      radio: WithBoundArgs<typeof FormRadio, 'checked'> &
        WithBoundArgs<typeof FormRadio, 'privateContainerClass'> &
        WithBoundArgs<typeof FormRadio, '_parentOnChange'> &
        WithBoundArgs<typeof FormRadio, 'size'> &
        WithBoundArgs<typeof FormRadio, 'name'>
    ];
  };
  Element: HTMLDivElement;
}

export default class FormRadioGroup extends Component<FormRadioGroupSignature> {
  @tracked shouldShowErrorFeedback = false;

  get showErrorFeedback(): boolean {
    if (this.args.hasError === false) {
      return false;
    }

    if (
      (this.args.showError ||
        this.args.hasSubmitted ||
        this.shouldShowErrorFeedback) &&
      this.args.errors &&
      this.args.errors.length > 0
    ) {
      return true;
    } else {
      return false;
    }
  }

  @action handleChange(value: unknown, event: Event): void {
    this.shouldShowErrorFeedback = true;

    if (typeof this.args.onChange === 'function') {
      this.args.onChange(value, event);
    }
  }

  <template>
    <FormField
      @size={{@size}}
      class={{useFrontileClass
        "form-radio-group"
        @size
        (if @isInline "inline")
        class=@containerClass
      }}
      role="radiogroup"
      ...attributes
      as |f|
    >
      {{#if @label}}
        <f.Label
          class={{useFrontileClass
            "form-radio-group"
            @size
            (if @isInline "inline")
            part="label"
          }}
        >
          {{@label}}
        </f.Label>
      {{/if}}

      {{#if @hint}}
        <f.Hint
          class={{useFrontileClass
            "form-radio-group"
            @size
            (if @isInline "inline")
            part="hint"
          }}
        >
          {{@hint}}
        </f.Hint>
      {{/if}}

      {{yield
        (component
          FormRadio
          checked=@value
          privateContainerClass=(useFrontileClass
            "form-radio-group" @size (if @isInline "inline") part="form-radio"
          )
          _parentOnChange=this.handleChange
          size=@size
          name=(concat f.id "-radio-group")
        )
      }}

      {{#if this.showErrorFeedback}}
        <f.Feedback
          class={{useFrontileClass
            "form-radio-group"
            @size
            (if @isInline "inline")
            part="feedback"
          }}
          @errors={{@errors}}
        />
      {{/if}}
    </FormField>
  </template>
}
