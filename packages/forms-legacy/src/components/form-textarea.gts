import { FormInputBase, type FormInputBaseSignature } from './form-input';
import { on } from '@ember/modifier';
import { concat } from '@ember/helper';
import { useStyles } from '@frontile/theme';
import FormField from './form-field';

export interface FormTextareaSignature extends FormInputBaseSignature {
  Element: HTMLTextAreaElement;
  Blocks: {
    default: [];
  };
}

export default class FormTextarea extends FormInputBase<FormTextareaSignature> {
  get classes() {
    const { formInput } = useStyles();

    const { base, label, input, hint, feedback } = formInput({
      size: this.args.size
    });

    return {
      base: base({
        class: this.args.containerClass
      }),
      label: label(),
      input: input({ class: this.args.inputClass }),
      hint: hint(),
      feedback: feedback()
    };
  }

  <template>
    <FormField @size={{@size}} class={{this.classes.base}} as |f|>
      {{#if @label}}
        <f.Label @class={{this.classes.label}}>
          {{@label}}
        </f.Label>
      {{/if}}

      {{#if @hint}}
        <f.Hint @class={{this.classes.hint}}>
          {{@hint}}
        </f.Hint>
      {{/if}}

      <f.Textarea
        {{on "focus" this.handleFocusIn}}
        {{on "blur" this.handleFocusOut}}
        @onInput={{@onInput}}
        @onChange={{@onChange}}
        @value={{@value}}
        @class={{this.classes.input}}
        aria-invalid={{if this.showErrorFeedback "true"}}
        aria-describedby="{{if @hint f.hintId}}{{if
          this.showErrorFeedback
          (concat ' ' f.feedbackId)
        }}"
        ...attributes
      />

      {{yield}}

      {{#if this.showErrorFeedback}}
        <f.Feedback @class={{this.classes.feedback}} @errors={{@errors}} />
      {{/if}}
    </FormField>
  </template>
}
