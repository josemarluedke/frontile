import Component from '@glimmer/component';
import { guidFor } from '@ember/object/internals';

interface FormFieldArgs {
  isSmall?: boolean;
}

export default class FormField extends Component<FormFieldArgs> {
  id = guidFor(this);

  get hintId(): string {
    return this.id + '-hint';
  }

  get feedbackId(): string {
    return this.id + '-feedback';
  }
}
