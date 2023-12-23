import Component from '@glimmer/component';

export interface FormFieldLabelArgs {
  for?: string;
  size?: 'sm' | 'lg';
}

export interface FormFieldLabelSignature {
  Args: FormFieldLabelArgs;
  Element: HTMLLabelElement;
}

export default class FormFieldLabel extends Component<FormFieldLabelSignature> {}
