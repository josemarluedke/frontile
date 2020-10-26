import Component from '@glimmer/component';

interface FormFieldLabelArgs {
  for?: string;
  size?: 'sm' | 'lg';
}

export default class FormFieldLabel extends Component<FormFieldLabelArgs> {}
