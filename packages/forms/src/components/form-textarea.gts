import { FormInputBase, type FormInputBaseSignature } from './form-input';
import useFrontileClass from '@frontile/core/helpers/use-frontile-class';
import FormField from './form-field';
import { on } from '@ember/modifier';
import { concat } from '@ember/helper';

export interface FormTextareaSignature extends FormInputBaseSignature {
  Element: HTMLTextAreaElement;
  Blocks: {
    default: [];
  };
}

export default class FormTextarea extends FormInputBase<FormTextareaSignature> {
  <template>
    <FormField
      @size={{@size}}
      class={{useFrontileClass "form-textarea" @size class=@containerClass}}
      as |f|
    >
      {{#if @label}}
        <f.Label class={{useFrontileClass "form-textarea" @size part="label"}}>
          {{@label}}
        </f.Label>
      {{/if}}

      {{#if @hint}}
        <f.Hint class={{useFrontileClass "form-textarea" @size part="hint"}}>
          {{@hint}}
        </f.Hint>
      {{/if}}

      <f.Textarea
        {{on "focus" this.handleFocusIn}}
        {{on "blur" this.handleFocusOut}}
        @onInput={{@onInput}}
        @onChange={{@onChange}}
        @value={{@value}}
        class={{useFrontileClass "form-textarea" @size part="textarea"}}
        aria-invalid={{if this.showErrorFeedback "true"}}
        aria-describedby="{{if @hint f.hintId}}{{if
          this.showErrorFeedback
          (concat ' ' f.feedbackId)
        }}"
        ...attributes
      />

      {{yield}}

      {{#if this.showErrorFeedback}}
        <f.Feedback
          class={{useFrontileClass "form-textarea" @size part="feedback"}}
          @errors={{@errors}}
        />
      {{/if}}
    </FormField>
  </template>
}
