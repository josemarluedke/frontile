import Component from '@glimmer/component';

interface FormFieldHintArgs {
  id?: string;
  isSmall?: boolean;
  isLarge?: boolean;
}

export default class FormFieldHint extends Component<FormFieldHintArgs> {}
