import { FormInputBase, FormInputBaseSignature } from './form-input';

interface FormTextareaSignature extends FormInputBaseSignature {
  Element: HTMLTextAreaElement;
}

export default class FormTextarea extends FormInputBase<FormTextareaSignature> {}
