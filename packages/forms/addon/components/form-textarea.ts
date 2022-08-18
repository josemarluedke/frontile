import { FormInputBase, FormInputBaseSignature } from './form-input';

export interface FormTextareaSignature extends FormInputBaseSignature {
  Element: HTMLTextAreaElement;
}

export default class FormTextarea extends FormInputBase<FormTextareaSignature> {}
