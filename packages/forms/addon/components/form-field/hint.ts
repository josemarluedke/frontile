import Component from '@glimmer/component';

interface FormFieldHintArgs {
  id?: string;
  size?: 'sm' | 'lg';
}

export default class FormFieldHint extends Component<FormFieldHintArgs> {}
