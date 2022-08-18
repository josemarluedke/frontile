import Component from '@glimmer/component';
import { guidFor } from '@ember/object/internals';
import FormFieldCheckbox from './checkbox';
import FormFieldFeedback from './feedback';
import FormFieldHint from './hint';
import FormFieldInput from './input';
import FormFieldLabel from './label';
import FormFieldRadio from './radio';
import FormFieldTextarea from './textarea';

export interface FormFieldArgs {
  size?: 'sm' | 'lg';
}

export interface FormFieldSignature {
  Args: FormFieldArgs;
  Blocks: {
    default: [
      {
        id: string;
        hintId: string;
        feedbackId: string;
        Label: FormFieldLabel;
        Hint: FormFieldHint;
        Feedback: FormFieldFeedback;
        Input: FormFieldInput;
        Textarea: FormFieldTextarea;
        Checkbox: FormFieldCheckbox;
        Radio: FormFieldRadio;
      }
    ];
  };
  Element: HTMLDivElement;
}

export default class FormField extends Component<FormFieldSignature> {
  id = guidFor(this);

  get hintId(): string {
    return this.id + '-hint';
  }

  get feedbackId(): string {
    return this.id + '-feedback';
  }
}
