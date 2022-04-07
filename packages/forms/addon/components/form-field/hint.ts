import Component from '@glimmer/component';

export interface FormFieldHintArgs {
  id?: string;
  size?: 'sm' | 'lg';
}

export interface FormFieldHintSignature {
  Args: FormFieldHintArgs;
  Element: HTMLDivElement;
}

export default class FormFieldHint extends Component<FormFieldHintSignature> {}
