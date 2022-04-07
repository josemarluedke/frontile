import Component from '@glimmer/component';

interface FormFieldHintSignature {
  Args: {
    id?: string;
    size?: 'sm' | 'lg';
  };
  Element: HTMLDivElement;
}

export default class FormFieldHint extends Component<FormFieldHintSignature> {}
