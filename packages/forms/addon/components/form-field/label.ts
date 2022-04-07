import Component from '@glimmer/component';

interface FormFieldLabelSignature {
  Args: {
    for?: string;
    size?: 'sm' | 'lg';
  };
  Element: HTMLLabelElement;
}

export default class FormFieldLabel extends Component<FormFieldLabelSignature> {}
