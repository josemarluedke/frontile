import Component from '@glimmer/component';

interface FormFieldLabelArgs {
  for?: string;
  isSmall?: boolean;
  isLarge?: boolean;
}

export default class FormFieldLabel extends Component<FormFieldLabelArgs> {}
